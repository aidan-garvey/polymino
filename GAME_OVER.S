
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
; Thrashed:
;   a0, d0-d7
; =====================================
GAME_OVER_ANIM:
    ; scroll cells w/ player's board down by
        ; 1 cell every X frames
    ; overwrite UI tiles to make UI stationary

    ADDQ.W  #1, (GAME_OVER_T_OFF, a2)
    MOVE.W  (GAME_OVER_T_OFF, a2), d0
    ; if it has not been X frames, don't do anything
    MOVE.W  d0, d1
    ANDI.W  #GAME_OVER_MASK, d1
    BNE.B   @GAME_OVER_RET

    LSR.W   #GAME_OVER_DIV, d0
    ; if we've scrolled everything further than the board height, return
    CMP.W   #28, d0
    BGE.B   @GAME_OVER_RET

    ; multiply by -8 for scroll value
    MOVE.W  d0, d1
    LSL.W   #3, d1 
    NEG.W   d1

    ; loop counter - we will scroll 6*2 tiles
    MOVEQ   #5, d2

    LEA.L   BUFF_VSCROLLA+8, a0
    LEA.L   BUFF_PLANE+16, a1

    CMP.L   #GAME_STATE_2, a2
    BNE.B   @SCROLL_LOOP

    ADDA.W  #12, a0
    ADDA.W  #24, a1

@SCROLL_LOOP:
    MOVE.W  d1, (a0)+
    DBRA    d2, @SCROLL_LOOP

    ; replace rows of SCROLLA with the ones below them so only
    ; the board appears to scroll
    
    MOVE.L  a1, a0  ; a0 -> first row of board

    ; top rows:
    MOVEQ   #0, d1
    SUB.W   d0, d1
    JSR     MOVE_ROW

    ADDQ.W  #1, d1
    JSR     MOVE_ROW

    ADDQ.W  #1, d1
    JSR     DRAW_BOARD_ROW

    ; bottom rows:
    MOVEQ   #26, d1
    SUB.W   d0, d1
    JSR     MOVE_ROW

    ADDQ.W  #1, d1
    JSR     MOVE_ROW

@GAME_OVER_RET:
    RTS

