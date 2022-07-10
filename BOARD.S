; ***************************
; ********* BOARD.S *********
; ---------------------------
; Contains subroutines for
; operating on the game board
; ***************************

; Format of each cell in the board:
; JNU- -CCC IIII IIII
; J: 1 = junk, 0 = not junk
; N: J & !N = gray junk, J & N = coloured junk,
;    !J & !N = empty cell, !J & N = block
; U: 0 = not updated this frame, 1 = updated this frame
; C: 3 bits for colour
; I: 8-bit junk piece ID if J

; ===============================================
; GENERATE_ROWS
; -----------------------------------------------
; Generate rows of blocks starting at the bottom
; of the board. The number of rows to generate is
; stored in memory at NEW_ROWS_1 / NEW_ROWS_2.
; After generation, the content of NEW_ROWS_X is
; set to 0.
; -----------------------------------------------
; Parameters:
;   a1 - points to board (P1 or P2)
;   a2 - points to NEW_ROWS (P1 or P2)
; Thrashed:
;   d0-d3
; ===============================================
GENERATE_ROWS:
    PUSH    a3

    MOVE.W  (a2), d2    ; d2 counts number of rows to generate
    MOVE.W  #0, (a2)    ; since we're generating the rows, clear NEW_ROWS
    MOVE.L  a2, a3      ; a3 points to the end of the board
    BRA.B   @GEN_ROW_STEP
; generate a row of random blocks
@GEN_ROW_LOOP:
    MOVE.W  #BOARD_WIDTH-1, d3
@GEN_BLOCK_LOOP:
    ; use RNG to generate each block's colour
    JSR     RAND
    ; if current block is not empty, skip
    TST.W   -(a3)
    BNE.B   @GEN_BLOCK_STEP
@PLACE_BLOCK:
    ; d0-d1 contain the random state
    ; use d0 for the block data
    BSET    #14, d0     ; set N
    ANDI.W  #$4700, d0  ; clear all except N and color
    MOVE.W  d0, (a3)
@GEN_BLOCK_STEP:
    DBRA    d3, @GEN_BLOCK_LOOP
@GEN_ROW_STEP:
    DBRA    d2, @GEN_ROW_LOOP

    POP     a3
    RTS

; =========================================
; PLAYER_ACTIONS
; -----------------------------------------
; Handle the effects of the player's inputs
; -----------------------------------------
; Parameters:
;   a1 - start of the board
;   a2 - start of player game state
;   a3 - joypad inputs
; Thrashed:
;   d0-d2
; =========================================
PLAYER_ACTIONS:
    PUSH    a4-a5

    MOVE.W  (a3), d0    ; current joypad inputs
    MOVE.W  4(a3), d1   ; previous frame's inputs
    ; to get buttons pressed this frame but not held:
    ; XOR new inputs into old inputs, then AND result with new inputs
    EOR.W   d0, d1
    AND.W   d1, d0  ; d0 indicates buttons pressed for the first frame

    ; horizontal movement
    BTST    #3, d0  ; right
    BEQ     @SKIP_MOVE_RIGHT ; skip if right not pressed
    CMPI.W  #BOARD_WIDTH-1, 8(a2) ; CURSOR_X
    BEQ     @SKIP_MOVE_RIGHT ; skip if moving right would go out of bounds
    ADDI.W  #1, 8(a2)
@SKIP_MOVE_RIGHT:
    BTST    #2, d0  ; left
    BEQ     @SKIP_MOVE_LEFT ; skip if left not pressed
    TST.W   8(a2)   ; CURSOR_X
    BEQ     @SKIP_MOVE_LEFT ; skip if moving left would go out of bounds
    SUBI.W  #1, 8(a2)
@SKIP_MOVE_LEFT:

    ; vertical movement
    BTST    #1, d0  ; down
    BEQ     @SKIP_MOVE_DOWN
    CMPI.W  #BOARD_HEIGHT-1, 10(a2) ; CURSOR_Y
    BEQ     @SKIP_MOVE_DOWN
    ADDI.W  #1, 10(a2)
@SKIP_MOVE_DOWN:
    BTST    #0, d0  ; up
    BEQ     @SKIP_MOVE_UP
    TST.W   10(a2)   ; CURSOR_Y
    BEQ     @SKIP_MOVE_UP
    SUBI.W  #1, 10(a2)
@SKIP_MOVE_UP:

    ; if A pressed, swap horizontally
    BTST    #6, d0
    BEQ     @SKIP_A_PRESS

    ; get cursor pos, convert to RAM offset
    MOVE.W  8(a2), d1 ; horizontal position
    ; if cursor is all the way to the right, the
    ; horizontal component is shifted to the left
    CMPI.W  #BOARD_WIDTH-1, d1
    BNE     @A_PRESS_NO_SUB
    SUBQ    #1, d1
@A_PRESS_NO_SUB:
    ; get vertical pos
    MOVE.W  10(a2), d2
    ; multiply it by row width
    MULU.W  #BOARD_WIDTH, d2
    ; calculate RAM offset
    ADD.W   d2, d1
    ASL.W   #1, d1
    MOVE.L  a1, a4
    ADDA.W  d1, a4
    ; swap the blocks
    MOVE.L  (a4), d2
    SWAP    d2
    MOVE.L  d2, (a4)
@SKIP_A_PRESS:

    ; if B pressed, swap veritcally
    BTST    #4, d0
    BEQ     @SKIP_B_PRESS

    ; get cursor pos, convert to RAM offset
    MOVE.W  8(a2), d1 ; horizontal position
    ; get vertical pos
    MOVE.W  10(a2), d2
    ; if cursor is at top, move it down by 1
    BNE     @B_PRESS_NO_ADD
    ADDQ    #1, d2
@B_PRESS_NO_ADD:
    ; multiply by row width
    MULU.W  #BOARD_WIDTH, d2
    ; calculate RAM offset for top and bottom blocks
    ADD.W   d2, d1
    ASL.W   #1, d1
    MOVE.L  a1, a4
    MOVE.L  a1, a5
    ADDA.W  d1, a4
    SUBI.W  #BOARD_WIDTH*2, d1
    ADDA.W  d1, a5
    ; swap the blocks
    MOVE.W  (a4), d2
    MOVE.W  (a5), (a4)
    MOVE.W  d2, (a5)
@SKIP_B_PRESS:

    POP     a4-a5
    RTS

UPDATE_PHYSICS:
    NOP
    RTS

PLACE_NEW_JUNK:
    NOP
    RTS
