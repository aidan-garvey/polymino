
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
    MOVE.L  #MATCH_POINTS, (SCRATCH)
    BRA.B   ADD_SCORE

; ==============================================
; ADD_SHATTER_SCORE
; ----------------------------------------------
; Award points to the player for shattering junk
; ----------------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; ==============================================
ADD_SHATTER_SCORE:
    MOVE.L  #SHATTER_POINTS, (SCRATCH)
    TST.W   (COMBO_OFF, a2)
    BNE.B   ADD_SCORE
    MOVE.W  #1, (COMBO_OFF, a2)
    BRA.B   ADD_SCORE
    NOP

; =============================================
; ADD_SCORE
; ---------------------------------------------
; Award the number of points in scratch memory
; to the player, multiplied by the player combo
; ---------------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; =============================================
ADD_SCORE:
    PUSH    a0-a1/d0

    MOVE.W  (COMBO_OFF, a2), d0 ; d0 contains combo multiplier
    MOVE.L  a2, a0
    ADDA.W  #SCORE_OFF, a0  ; a0 -> player score
    LEA.L   SCRATCH, a1     ; a1 -> points to add
    BRA.B   @MULT_SCORE_STEP

@MULT_SCORE_LOOP:
    ANDI.B  #0, CCR ; reset flags so no erroneous extend bit
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
@MULT_SCORE_STEP:
    ADDA.W  #4, a0
    ADDA.W  #4, a1
    DBRA    d0, @MULT_SCORE_LOOP

    POP     a0-a1/d0
    RTS
    

