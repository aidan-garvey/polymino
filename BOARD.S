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
;   a0, d0-d2
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

    ; check for matches at swapped blocks
    MOVE.L  a4, a0
    JSR     CHECK_MATCH
    MOVE.L  a4, a0
    ADDA.W  #2, a0
    JSR     CHECK_MATCH

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

    ; check for matches at swapped blocks
    MOVE.L  a4, a0
    JSR     CHECK_MATCH
    MOVE.L  a5, a0
    JSR     CHECK_MATCH

@SKIP_B_PRESS:

    POP     a4-a5
    RTS

; =====================================
; UPDATE_PHYSICS
; -------------------------------------
; For each block with empty space below
; it, make it fall due to gravity.
; -------------------------------------
; Paramaters:
;   a1 - points to game board
;   a2 - points to end of board
; Thrashed:
;   a0, d0-d1
; =====================================
UPDATE_PHYSICS:
    PUSH    a1
    ; clear updated flag for all blocks
    ; do 2 blocks (4 bytes) per iteration
    MOVE.W  #BOARD_SIZE/4, d0
@CLEAR_UPDATE_FLAG:
    ANDI.L  #$DFFFDFFF, (a1)+ ; clears update bit
    DBRA    d0, @CLEAR_UPDATE_FLAG

    ; a1 will point 1 row above a0
    MOVE.L  a2, a0
    MOVE.L  a2, a1
    SUBA.W  #BOARD_WIDTH*2, a1

    ; we will iterate every row except the top
    MOVE.W  #BOARD_WIDTH*BOARD_HEIGHT-1, d0
@UPDATE_BLOCK_LOOP:
    SUBA.W  #2, a1
    TST.W   -(a0)
    ; if (a0) not empty, (a1) can't move down
    BNE     @UPDATE_BLOCK_STEP
    ; move (a1) downwards
    MOVE.W  (a1), (a0)
    CLR.W   (a1)
    ORI.W   #$2000, (a0) ; set update bit
@UPDATE_BLOCK_STEP:  
    DBRA    d0, @UPDATE_BLOCK_LOOP

    POP     a1
    RTS

PLACE_NEW_JUNK:
    NOP
    RTS

; ========================
; CHECK_MATCH
; ------------------------
; Check for a match that
; includes a given block
; ------------------------
; Parameters:
;   a0 - pointer to block
;   a2 - player game state
; Thrashed:
;   d0-d2
; ========================
CHECK_MATCH:
    PUSH    a1/a3
    MOVE.L  a0, a1
    MOVE.L  a0, a3
    MOVE.W  (a3)+, d0   ; d0 := (a0), a3 points one block to the right
    
    ; move a1 to the left until (a1) != d0, but don't go further left than the board
    MOVE.W  8(a2), d1   ; d1 := (CURSOR_X)
    MOVEQ   #0, d2      ; so we don't break the loop instantly
    BRA     @CHECK_LEFT_STEP
@CHECK_LEFT_LOOP:
    CMP.W   -(a1), d0
@CHECK_LEFT_STEP:
    DBNE    d1, @CHECK_LEFT_LOOP
    ; if we exitted the loop due to the count, (a1) matches d0.
    ; if we exitted due to the NE condition, (a1 + 2) matches d0, but (a1) doesn't.
    BEQ     @CHECK_LEFT_DONE
    ADDA.W  #2, a1
@CHECK_LEFT_DONE:
    
    ; move a3 to the right until (a3) != d0, don't go further right than the board
    MOVE.W  #BOARD_WIDTH, d1
    SUB.W   8(a2), d1
    SUBQ    #1, d1  ; d1 := BOARD_WIDTH - CURSOR_X - 1
    MOVEQ   #0, d2  ; so we don't break the loop instantly
    BRA     @CHECK_RIGHT_STEP
@CHECK_RIGHT_LOOP:
    CMP.W   (a3)+, d0
@CHECK_RIGHT_STEP:
    DBNE    d1, @CHECK_RIGHT_LOOP
    ; if we exitted the loop due to the count, (a1 - 2) matches d0.
    ; if we exitted due to the NE condition, (a1 - 4) matches d0, but (a1 - 2) doesn't.
    BEQ     @CHECK_RIGHT_DONE
    SUBA.W  #2, a3
@CHECK_RIGHT_DONE:
    SUBA.W  #2, a3

    ; if a3 - a1 >= 4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #4, d1
    BLT     @NO_H_MATCH
    ; spawn projectile
    
    ; clear the blocks
    ; >= 4 words is >= 2 blocks of space, is >= 2+1 blocks to clear
    LSR.W   #1, d1
@H_CLEAR_LOOP:
    CLR.W   (a1)+
    DBRA    d1, @H_CLEAR_LOOP
@NO_H_MATCH:

    ; same as above, but vertical
    MOVE.L  a0, a1
    MOVE.L  a0, a3
    ; d0 still contains the block

    ; move a1 up until (a1) != d0, but don't go above the top of the board
    MOVE.W  10(a2), d1
    MOVE.W  #0, d2
    BRA     @CHECK_UP_STEP
@CHECK_UP_LOOP:
    SUBA.W  #BOARD_WIDTH*2, a1
    CMP.W   (a1), d0
@CHECK_UP_STEP:
    DBNE    d1, @CHECK_UP_LOOP
    ; if we exitted due to NE, go back down a row
    BEQ     @CHECK_UP_DONE
    ADDA.W  #BOARD_WIDTH*2, a1
@CHECK_UP_DONE:

    ; move a3 down until (a3) != d0, but don't go below the board
    MOVE.W  #BOARD_HEIGHT, d1
    SUB.W   10(a2), d1
    SUBQ    #1, d1
    MOVE.W  #0, d2
    BRA     @CHECK_DOWN_STEP
@CHECK_DOWN_LOOP:
    ADDA.W  #BOARD_WIDTH*2, a3
    CMP.W   (a3), d0
@CHECK_DOWN_STEP:
    DBNE    d1, @CHECK_DOWN_LOOP
    ; if we exitted due to NE, go up a row
    BEQ     @CHECK_DOWN_DONE
    SUBA.W  #BOARD_WIDTH*2, a3
@CHECK_DOWN_DONE:

    ; if a3 - a1 >= BOARD_WIDTH*4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #BOARD_WIDTH*4, d1
    BLT     @NO_V_MATCH
    ; clear the blocks
@V_CLEAR_LOOP:
    CLR.W   (a1)
    ADDA.W  #BOARD_WIDTH*2, a1
    CMP.L   a1, a3
    BGT     @V_CLEAR_LOOP
    CLR.W   (a1) ; clear the block at a3, then stop clearing
@NO_V_MATCH:

    POP     a1/a3
    RTS
