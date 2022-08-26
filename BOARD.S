
; *****************************************************************
; BOARD.S
; Contains subroutines for manipulating on the game board.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Format of each cell in the board:
; -NS- -CCC IIII IIII
; N: Junk & !N = gray junk, Junk & N = coloured junk,
;    !Junk & !N = empty cell, !Junk & N = block
; S: block is shattering junk, does not interact
; C: 3 bits for colour
; I: 0: not junk
;    1..255: 8-bit junk piece ID or shatter timer
;    

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
;   a2 - points to player game state
;   a4 - points to screen buffer
; Thrashed:
;   d0-d4
; ===============================================
GENERATE_ROWS:
    MOVE.L  a3, -(SP)

    MOVE.W  (a2), d2    ; d2 counts number of rows to generate
    MOVE.W  #0, (a2)    ; since we're generating the rows, clear NEW_ROWS
    MOVE.L  a2, a3      ; a3 points to the end of the board
    MOVE.W  #BOARD_HEIGHT, d4 ; d4 tracks y pos for PLACE_BLOCK subroutine
    BRA.B   _GEN_ROW_STEP
; generate a row of random blocks
_GEN_ROW_LOOP:
    MOVE.W  #BOARD_WIDTH-1, d3
_GEN_BLOCK_LOOP:
    ; use RNG to generate each block's colour
    JSR     RAND

    ; d0-d1 contain the random state
    ; use d0 for the block data
    BSET    #14, d0     ; set N
    ANDI.W  #$4700, d0  ; clear all except N and color
    
    ; if new block would create a match, generate a different one

    ; check blocks to the right if possible
    CMP.W   #BOARD_WIDTH-3, d3
    BGT.B   _GEN_BLOCK_HSKIP
    CMP.W   (a3), d0
    BNE.B   _GEN_BLOCK_HSKIP
    CMP.W   2(a3), d0
    BEQ.B   _GEN_BLOCK_LOOP    
_GEN_BLOCK_HSKIP:

    ; check blocks below if possible
    CMP.W   #BOARD_HEIGHT-3, d4
    BGT.B   _GEN_BLOCK_VSKIP
    CMP.W   (BOARD_WIDTH*2-2, a3), d0
    BNE.B   _GEN_BLOCK_VSKIP
    CMP.W   (BOARD_WIDTH*4-2, a3), d0
    BEQ.B   _GEN_BLOCK_LOOP
_GEN_BLOCK_VSKIP:

    MOVE.W  d0, -(a3)

    JSR     PLACE_BLOCK
_GEN_BLOCK_STEP:
    DBRA    d3, _GEN_BLOCK_LOOP
_GEN_ROW_STEP:
    SUBQ    #1, d4
    DBRA    d2, _GEN_ROW_LOOP

    MOVE.L  (SP)+, a3
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
;   a4 - start of screen buffer
; Thrashed:
;   a0, d0-d6
; =========================================
PLAYER_ACTIONS:
    PUSH.L  a5-a6

    MOVE.W  (a3), d0    ; current joypad inputs
    MOVE.W  4(a3), d1   ; previous frame's inputs
    ; to get buttons pressed this frame but not held:
    ; XOR new inputs into old inputs, then AND result with new inputs
    EOR.W   d0, d1
    AND.W   d0, d1  ; d1 indicates buttons pressed for the first frame

    ; horizontal movement
    BTST    #BUTTON_RIGHT, d1  ; right pressed
    BNE.B   _MOVE_RIGHT ; if pressed for the first frame, move
    BTST    #BUTTON_RIGHT, d0  ; right held
    BEQ.B   _SKIP_MOVE_RIGHT ; if not held either, skip moving
    SUBQ.W  #1, (JOY_H_TIMER_OFF, a2) ; JOY_H_TIMER countdown
    BNE.B   _SKIP_MOVE_RIGHT ; if hold timer not at 0, don't move
_MOVE_RIGHT:
    MOVE.W  #HOLD_LENGTH, (JOY_H_TIMER_OFF, a2) ; reset hold timer
    CMPI.W  #BOARD_WIDTH-1, (CURSOR_X_OFF, a2)
    BEQ.B   _SKIP_MOVE_RIGHT ; skip if moving right would go out of bounds
    ADDQ.W  #1, (CURSOR_X_OFF, a2)
_SKIP_MOVE_RIGHT:


    BTST    #BUTTON_LEFT, d1  ; left
    BNE.B   _MOVE_LEFT ; if pressed for first frame, move
    BTST    #BUTTON_LEFT, d0  ; left held
    BEQ.B   _SKIP_MOVE_LEFT ; if not held either, skip moving
    SUBQ.W  #1, (JOY_H_TIMER_OFF, a2) ; JOY_H_TIMER countdown
    BNE.B   _SKIP_MOVE_LEFT ; if hold timer not at 0, don't move
_MOVE_LEFT:
    MOVE.W  #HOLD_LENGTH, (JOY_H_TIMER_OFF, a2)
    TST.W   (CURSOR_X_OFF, a2)   ; CURSOR_X
    BEQ.B   _SKIP_MOVE_LEFT ; skip if moving left would go out of bounds
    SUBQ.W  #1, (CURSOR_X_OFF, a2)
_SKIP_MOVE_LEFT:

    ; vertical movement
    BTST    #BUTTON_DOWN, d1  ; down
    BNE.B   _MOVE_DOWN
    BTST    #BUTTON_DOWN, d0  ; down held
    BEQ.B   _SKIP_MOVE_DOWN
    SUBQ.W  #1, (JOY_V_TIMER_OFF, a2) ; JOY_V_TIMER countdown
    BNE.B   _SKIP_MOVE_DOWN ; if hold timer not at 0, don't move
_MOVE_DOWN:
    MOVE.W  #HOLD_LENGTH, (JOY_V_TIMER_OFF, a2)
    CMPI.W  #BOARD_HEIGHT-1, (CURSOR_Y_OFF, a2) ; CURSOR_Y
    BEQ.B   _SKIP_MOVE_DOWN
    ADDQ.W  #1, (CURSOR_Y_OFF, a2)
_SKIP_MOVE_DOWN:


    BTST    #BUTTON_UP, d1  ; up
    BNE.B   _MOVE_UP
    BTST    #BUTTON_UP, d0  ; up held
    BEQ.B   _SKIP_MOVE_UP
    SUBQ.W  #1, (JOY_V_TIMER_OFF, a2) ; JOY_V_TIMER countdown
    BNE.B   _SKIP_MOVE_UP ; if hold timer not at 0, don't move
_MOVE_UP:
    MOVE.W  #HOLD_LENGTH, (JOY_V_TIMER_OFF, a2)
    TST.W   (CURSOR_Y_OFF, a2)   ; CURSOR_Y
    BEQ.B   _SKIP_MOVE_UP
    SUBQ.W  #1, (CURSOR_Y_OFF, a2)
_SKIP_MOVE_UP:

    ; d0 not needed for inputs from here on - only D-pad can be held

    ; if A pressed, swap horizontally
    BTST    #BUTTON_A, d1
    BEQ.W   _SKIP_A_PRESS

    ; get cursor pos, convert to RAM offset
    MOVE.W  (CURSOR_X_OFF, a2), d0 ; horizontal position
    ; if cursor is all the way to the right, the
    ; horizontal component is shifted to the left
    CMPI.W  #BOARD_WIDTH-1, d0
    BNE.B   _A_PRESS_NO_SUB
    SUBQ.W  #1, d0
_A_PRESS_NO_SUB:
    ; save x pos
    MOVE.W  d0, d3

    ; get vertical pos
    MOVE.W  (CURSOR_Y_OFF, a2), d2
    MOVE.W  d2, d4
    ; multiply it by row width
    ; MULU.W  #BOARD_WIDTH, d2
    ; since BOARD_WIDTH is always going to be 10:
    LSL.W   #3, d2  ; d2 = CURSOR_Y * 8
    ADD.W   d4, d2
    ADD.W   d4, d2  ; d2 = CURSOR_Y * 10
    ; calculate RAM offset
    ADD.W   d2, d0
    ASL.W   #1, d0
    MOVE.L  a1, a5
    ADDA.W  d0, a5
    ; a0 will check if the space below a block is empty
    MOVE.L  a5, a0
    ADDA.W  #BOARD_WIDTH*2, a0

    ; if a block is falling, and it is not empty, it is immovable

    ; don't do check for bottom row
    CMP.W   #BOARD_HEIGHT-1, d4
    BEQ     _H_FALL_CHECK_2

    TST.W   (a0)+
    BNE.B   _H_FALL_CHECK_1 ; if block below is occupied, check passes
    TST.W   (a5)
    BNE.B   _SKIP_A_PRESS ; if block below is empty and block above isn't, check fails
_H_FALL_CHECK_1:
    TST.W   (a0)+
    BNE.B   _H_FALL_CHECK_2
    TST.W   2(a5)
    BNE.B   _SKIP_A_PRESS
_H_FALL_CHECK_2:
    ; do not allow swap if either block is junk
    TST.B   1(a5)
    BNE.B   _SKIP_A_PRESS
    TST.B   3(a5)
    BNE.B   _SKIP_A_PRESS

    ; swap the blocks, unless they are both empty
    MOVE.L  (a5), d2
    BEQ.B   _SKIP_A_PRESS
    SWAP    d2
    MOVE.L  d2, (a5)
    JSR     SWAP_BLOCKS_H

    ; Save player's score. If it is unchanged after checking matches,
    ; reset player's combo due to not making a move which made a match
    MOVE.L  (SCORE_BIN_OFF, a2), d6

    ; check for matches at swapped blocks
    TST.W   (a5)
    BEQ.B   _SKIP_CHECK_A_1
    MOVE.L  a5, a0
    JSR     CHECK_MATCH
_SKIP_CHECK_A_1:
    MOVE.L  a5, a0
    ADDA.W  #2, a0
    TST.W   (a0)
    BEQ.B   _SKIP_CHECK_A_2
    ADDQ.W  #1, d3
    JSR     CHECK_MATCH
_SKIP_CHECK_A_2:

    ; if no score was gained after the move, reset combo
    CMP.L   (SCORE_BIN_OFF, a2), d6
    BNE.B   _SKIP_A_PRESS
    MOVE.W  #1, (COMBO_OFF, a2)

_SKIP_A_PRESS:

    ; if B pressed, swap veritcally
    BTST    #BUTTON_B, d1
    BEQ.B   _SKIP_B_PRESS

    ; get cursor pos, convert to RAM offset
    MOVE.W  (CURSOR_X_OFF, a2), d0 ; horizontal position
    MOVE.W  d0, d3
    ; get vertical pos
    MOVE.W  (CURSOR_Y_OFF, a2), d2
    ; if cursor is at top, move it down by 1
    BNE     _B_PRESS_NO_ADD
    ADDQ    #1, d2
_B_PRESS_NO_ADD:
    ; save vertical pos
    MOVE.W  d2, d4
    
    ; multiply by row width
    ; MULU.W  #BOARD_WIDTH, d2
    ; since BOARD_WIDTH is always going to be 10:
    LSL.W   #3, d2  ; d2 = CURSOR_Y * 8
    ADD.W   d4, d2
    ADD.W   d4, d2  ; d2 = CURSOR_Y * 10
    ; calculate RAM offset for top and bottom blocks
    ADD.W   d2, d0
    ADD.W   d0, d0
    MOVE.L  a1, a5
    ADDA.W  d0, a5
    MOVE.L  a5, a6
    SUBA.W  #BOARD_WIDTH*2, a6

    ; don't allow a vertical swap involving a space
    TST.W   (a5)
    BEQ.B   _SKIP_B_PRESS
    TST.W   (a6)
    BEQ.B   _SKIP_B_PRESS

    ; don't allow swapping junk
    TST.B   1(a5)
    BNE.B   _SKIP_B_PRESS
    TST.B   1(a6)
    BNE.B   _SKIP_B_PRESS

    ; swap the blocks
    MOVE.W  (a5), d2
    MOVE.W  (a6), (a5)
    MOVE.W  d2, (a6)
    JSR     SWAP_BLOCKS_V

    ; save old score to check if combo should be reset
    MOVE.L  (SCORE_BIN_OFF, a2), d6

    ; check for matches at swapped blocks
    TST.W   (a5)
    BEQ.B   _SKIP_CHECK_B_1
    MOVE.L  a5, a0
    JSR     CHECK_MATCH
_SKIP_CHECK_B_1:
    TST.W   (a6)
    BEQ.B   _SKIP_CHECK_B_2
    MOVE.L  a6, a0
    SUBQ.W  #1, d4
    JSR     CHECK_MATCH
_SKIP_CHECK_B_2:

    ; if score is unchanged, reset combo
    CMP.L   (SCORE_BIN_OFF, a2), d6
    BNE.B   _SKIP_B_PRESS
    MOVE.W  #1, (COMBO_OFF, a2)

_SKIP_B_PRESS:

    ; if C button pressed, use a bomb
    BTST    #BUTTON_C, d1
    BEQ.B   _SKIP_C_PRESS
    ; don't allow using a bomb when player has zero
    TST.W   (BOMBS_OFF, a2)
    BEQ.B   _SKIP_C_PRESS
    JSR     DROP_BOMB
    ; SUBQ.W  #1, (BOMBS_OFF, a2)
    MOVE.B  (BOMBS_OFF+1, a2), d0
    MOVEQ   #1, d1
    MOVE.W  #0, CCR ; reset flags so no erroneous extend bit
    SBCD    d1, d0
    MOVE.B  d0, (BOMBS_OFF+1, a2)
_SKIP_C_PRESS:

    POP.L   a5-a6
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
;   a4 - points to screen buffer
; Thrashed:
;   a0, d0-d1/d3-d4
; =====================================
UPDATE_PHYSICS:
    MOVE.L  a1, -(SP)

    ; a1 will point 1 row above a0
    MOVE.L  a2, a0
    MOVE.L  a2, a1
    SUBA.W  #BOARD_WIDTH*2, a1
    MOVEQ   #BOARD_WIDTH-1, d3
    MOVEQ   #BOARD_HEIGHT-1, d4

    ; we will iterate every row except the top
_UPDATE_BLOCK_LOOP:
    SUBA.W  #2, a1
    SUBA.W  #2, a0

    ; if (a1) is junk, call subroutine to move it
    TST.B   1(a1)
    BEQ.B   _UPDATE_NOT_JUNK
    ; don't update junk during its shatter animation
    BTST.B  #SHATTER_FLAG_B, (a1)
    BNE.B   _UPDATE_BLOCK_STEP
    BSR     UPDATE_JUNK
    BRA.B   _UPDATE_BLOCK_STEP
_UPDATE_NOT_JUNK:
    TST.W   (a0)
    ; if (a0) not empty, (a1) can't move down
    BNE.B   _UPDATE_BLOCK_STEP

    TST.W   (a1)
    ; if (a1) is empty, skip moving it down
    BEQ.B   _UPDATE_BLOCK_STEP

    ; move (a1) downwards
    MOVE.W  (a1), (a0)
    CLR.W   (a1)
    JSR     SWAP_BLOCKS_V

_UPDATE_BLOCK_STEP:
    SUBQ.W  #1, d3
    BGE.B   _UPDATE_BLOCK_LOOP
    MOVEQ   #BOARD_WIDTH-1, d3
    SUBQ.W  #1, d4
    BGT.B   _UPDATE_BLOCK_LOOP

    MOVE.L  (SP)+, a1
    RTS

; ==================================
; CLEAR_BLOCKS
; ----------------------------------
; Clears all blocks that are flagged
; to be cleared in TO_CLEAR
; ----------------------------------
; Parameters:
;   a1 - game board
;   a2 - game state
;   a4 - points to screen buffer
; Thrashed:
;   d0-d6
; ==================================
CLEAR_BLOCKS:
    PUSH.L  a0-a1
    MOVE.L  a2, a0
    ADD.W   #TO_CLEAR_OFF, a0
    MOVEQ   #BOARD_HEIGHT-1, d5 ; vertical loop counter
    MOVEQ   #0, d3 ; x pos
    MOVEQ   #0, d4 ; y pos
    MOVEQ   #0, d6 ; after loop, will be non-zero if any blocks were removed
_CLEAR_ROWS_LOOP:
    ; get 2 rows
    MOVE.W  (a0), d1
    CLR.W   (a0)+
    ; start at x = 0
    MOVEQ   #0, d2
_CLEAR_BLOCK_LOOP:
    BTST    d2, d1
    BEQ     _CLEAR_BLOCK_STEP
    MOVE.W  (a1), d0
    MOVE.W  #0, (a1)
    JSR     ERASE_BLOCK
    JSR     SPAWN_DEBRIS
    ADDQ.W  #1, d6 ; record block being removed
_CLEAR_BLOCK_STEP:
    ADDA.W  #2, a1
    ADDQ    #1, d2
    ADDQ    #1, d3
    CMPI.W  #BOARD_WIDTH, d2
    BLT     _CLEAR_BLOCK_LOOP
    ADDQ    #1, d4
    MOVEQ   #0, d3
    DBRA    d5, _CLEAR_ROWS_LOOP

    TST.W   d6
    BEQ.B   _NO_SFX
    ; play sound effect if any blocks broken
    LEA.L   ESF_CRUNCH, a0
    JSR     Echo_PlaySFX
_NO_SFX:

    POP.L     a0-a1
    RTS

; ===========================================
; SHATTER_ANIM
; -------------------------------------------
; For each junk block going through a shatter
; animation, advance its frame counter. If it
; is finished, replace it with a new block.
; -------------------------------------------
; Parameters:
;   a1 - game board
;   a2 - game state
;   a4 - screen buffer
; Thrashed:
;   d0-d4
; ===========================================
SHATTER_ANIM:
    MOVE.L  a3, -(SP)
    ; game state is right after board, we'll use a2 to access the board
    MOVE.L  a2, a3
    MOVEQ   #BOARD_WIDTH-1, d3
    MOVEQ   #BOARD_HEIGHT-1, d4

_SHATTER_LOOP:
    MOVE.W  -(a3), d0
    ; if block is not junk, skip it
    TST.B   d0
    BEQ.B   _SHATTER_STEP
    ; if block is not shattering, skip it
    BTST    #SHATTER_FLAG_W, d0
    BEQ.B   _SHATTER_STEP
    ; if block is shattering, count down
    SUBQ.B  #1, d0
    ; if timer reaches zero, replace with block
    BEQ.B   _SHATTER_REPLACE
    ; otherwise, store it and move on
    MOVE.W  d0, (a3)
    BRA.B   _SHATTER_STEP

_SHATTER_REPLACE:
    ; replace the junk block with a new block
    JSR     RAND
    BSET    #14, d0     ; set N
    ANDI.W  #$4700, d0  ; clear all except N and color
    MOVE.W  d0, (a3)    ; store in board data
    JSR     PLACE_BLOCK ; place block in screen buffer

_SHATTER_STEP:
    DBRA    d3, _SHATTER_LOOP
    MOVEQ   #BOARD_WIDTH-1, d3
    DBRA    d4, _SHATTER_LOOP

    MOVE.L  (SP)+, a3
    RTS

; ==============================================
; DROP_BOMB
; ----------------------------------------------
; Drop a bomb at the player's cursor, destroying
; nearby blocks and shattering any affected junk
; ----------------------------------------------
; Parameters:
;   a1 - game board
;   a2 - game state
;   a4 - screen buffer
; Thrashed:
;   upper words of d5-d6
; ==============================================
DROP_BOMB:
    MOVE.L  a0, -(SP)
    PUSH.W  d0-d6
    MOVE.W  (CURSOR_X_OFF, a2), d3
    MOVE.W  (CURSOR_Y_OFF, a2), d4
    ; we will start by clearing 3x3 area around cursor
    SUBQ.W  #1, d3
    SUBQ.W  #1, d4
    ; need to multiply y by 20 to get board data offset
    MOVE.W  d4, d5
    LSL.W   #4, d5  ; d5 := y * 16
    ADD.W   d4, d4
    ADD.W   d4, d4  ; d4 := y * 4
    ADD.W   d4, d5  ; d5 := y * 20
    LSR.W   #2, d4  ; d4 := y
    
    ADD.W   d3, d5
    ADD.W   d3, d5  ; d5 := x * 2 + y * 20

    MOVEA.L a1, a0
    ADDA.W  d5, a0  ; block top-left of player cursor

    ; clear 3 rows of 3
    MOVEQ   #2, d5
_BOMB_ROW_LOOP:
    MOVEQ   #2, d6
_BOMB_BLOCK_LOOP:
    BSR.B   _BOMB_BLOCK_EFFECT

    ; advance to next block
    ADDQ.W  #2, a0
    ADDQ.W  #1, d3
    DBRA    d6, _BOMB_BLOCK_LOOP
    ; advance to the next row
    ADDA.W  #BOARD_WIDTH*2-6, a0
    SUBQ.W  #3, d3
    ADDQ.W  #1, d4
    DBRA    d5, _BOMB_ROW_LOOP

    ; now delete 2 blocks left, right, up and down
    ; currently, pointed 1 row below the 3x3, at the left
    
    ; destroy bottom
    ADDQ.W  #1, d3
    ADDQ.W  #2, a0
    BSR.B   _BOMB_BLOCK_EFFECT
    ; right
    ADDQ.W  #2, d3
    SUBQ.W  #2, d4
    SUBA.W  #BOARD_WIDTH*4-4, a0
    BSR.B   _BOMB_BLOCK_EFFECT
    ; left
    SUBQ.W  #4, d3
    SUBQ.W  #8, a0
    BSR.B   _BOMB_BLOCK_EFFECT
    ; top
    ADDQ.W  #2, d3
    SUBQ.W  #2, d4
    SUBA.W  #BOARD_WIDTH*4-4, a0
    BSR.B   _BOMB_BLOCK_EFFECT

    POP.W   d0-d6
    MOVE.L  (SP)+, a0
    RTS

; ========================================
; _BOMB_BLOCK_EFFECT
; ----------------------------------------
; Helper for DROP_BOMB, which processes
; the effects of a bomb destroying a block
; ========================================
_BOMB_BLOCK_EFFECT:
    ; ensure we are in bounds
    TST.W   d3
    BLT.B   _BOMB_BLOCK_RET
    TST.W   d4
    BLT.B   _BOMB_BLOCK_RET
    CMP.W   #BOARD_WIDTH, d3
    BGE.B   _BOMB_BLOCK_RET
    CMP.W   #BOARD_HEIGHT, d4
    BGE.B   _BOMB_BLOCK_RET

    MOVE.W  (a0), d0
    ; if it is empty, skip
    BEQ.B   _BOMB_BLOCK_RET
    ; if it is non-shattering junk, shatter it before deleting
    BTST    #SHATTER_FLAG_W, d0
    BNE.B   _BOMB_BLOCK_DELETE
    TST.B   d0
    BEQ.B   _BOMB_BLOCK_DELETE
    JSR     SHATTER_JUNK
_BOMB_BLOCK_DELETE:
    ; delete from board data
    CLR.W   (a0)
    ; erase from screen buffer
    JSR     ERASE_BLOCK
    ; for non-junk, non-empty blocks, spawn debris
    TST.B   d0
    BNE.B   _BOMB_BLOCK_RET
    JSR     SPAWN_DEBRIS
_BOMB_BLOCK_RET:
    RTS
