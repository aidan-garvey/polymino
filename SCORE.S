
; *****************************************************************
; SCORE.S
; Subroutines related to the player's score.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; =============================================
; ADD_MATCH_SCORE
; ---------------------------------------------
; Award points to the player for making a match
; ---------------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; =============================================
ADD_MATCH_SCORE:
    PUSH    a0-a1/d0

    ; move the points to scratch memory
    MOVE.L  #MATCH_POINTS, (SCRATCH)
    MOVE.W  (COMBO_OFF, a2), d0 ; d0 contains combo multiplier
    BRA.B   @MULT_SCORE_STEP
@MULT_SCORE_LOOP:
    MOVE.L  a2, a0
    ADDA.W  #SCORE_OFF+4, a0; a0 -> player score
    LEA.L   SCRATCH+4, a1   ; a1 -> points to add
    ANDI.B  #0, CCR         ; reset flags
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
@MULT_SCORE_STEP:
    DBRA    d0, @MULT_SCORE_LOOP

    POP     a0-a1/d0
    RTS
