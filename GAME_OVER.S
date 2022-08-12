
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
    ; hide player's cursor
    CLR.W   (a5)
    ; hide next junk outline
    CLR.W   (P1_OUTLINE-P1_SPRITE, a5)

    ADDQ.W  #1, (GAME_OVER_T_OFF, a2)
    MOVE.W  (GAME_OVER_T_OFF, a2), d0
    ; only update every X frames
    ANDI.W  #GAME_OVER_MASK, d0
    BNE.B   @GAME_OVER_RET

    ; clear the bottom row of blocks
    MOVEA.L a2, a0
    MOVEQ   #BOARD_WIDTH-1, d3
    MOVEQ   #BOARD_HEIGHT-1, d4

@CLEAR_ROW_LOOP:
    CLR.W   -(a0)
    JSR     ERASE_BLOCK
    DBRA    d3, @CLEAR_ROW_LOOP

    ; update physics to move everything down
    JSR     UPDATE_PHYSICS

@GAME_OVER_RET:
    RTS
