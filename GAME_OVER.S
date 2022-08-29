
; *****************************************************************
; GAME_OVER.S
; Contains subroutine for game over animation.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; =====================================
; GAME_OVER_ANIM
; -------------------------------------
; When the player's game ends, run this
; animation to create the appearance of
; their blocks falling off the screen.
; -------------------------------------
; Parameters:
;   a2 - player game state
;   a4 - screen buffer
;   a5 - player cursor
; Thrashed:
;   a0, d0, d3-d4
; =====================================
GAME_OVER_ANIM:
    PUSH.L  a2
    ; hide player's cursor
    CLR.W   (a5)
    ; hide next junk outline
    CLR.W   (P1_OUTLINE-P1_SPRITE, a5)

    ADDQ.W  #1, (GAME_OVER_T_OFF, a2)
    MOVE.W  (GAME_OVER_T_OFF, a2), d0
    ; only update every X frames
    ANDI.W  #GAME_OVER_MASK, d0
    BNE.B   _GAME_OVER_RET

    ; clear the bottom row of blocks
    MOVEA.L a2, a0
    MOVEQ   #BOARD_WIDTH-1, d3
    MOVEQ   #BOARD_HEIGHT-1, d4

_CLEAR_ROW_LOOP:
    CLR.W   -(a0)
    JSR     ERASE_BLOCK
    DBRA    d3, _CLEAR_ROW_LOOP

    ; move all blocks down by 1
    ; a2 now points to block below a0
    ; d4 still equals height-1, which is what we want
_MOVE_ROW:
    MOVEQ   #BOARD_WIDTH-1, d3
_MOVE_BLOCK:
    SUBQ.L  #2, a2
    TST.W   -(a0)
    BEQ.B   _BLOCK_STEP
    JSR     SWAP_BLOCKS_V
    MOVE.W  (a0), (a2)
    CLR.W   (a0)
_BLOCK_STEP:
    DBRA    d3, _MOVE_BLOCK
    ; break if row number <= 0
    SUBQ.W  #1, d4
    BGT.B   _MOVE_ROW

_GAME_OVER_RET:
    POP.L   a2
    RTS
