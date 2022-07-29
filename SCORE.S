
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
    BRA.B   ADD_SCORE

; ===========================================================
; ADD_SCORE
; -----------------------------------------------------------
; Award the number of points in scratch memory to the player,
; multiplied by the player combo. Grant the player a bomb if
; they cross a 5000 point boundary.
; -----------------------------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; ===========================================================
    NOP
ADD_SCORE:
    PUSH    a0-a1/d0-d1

    MOVE.B  (SCORE_OFF+2, a2), d1   ; d1 := thousands and hundreds for old score

    MOVE.W  (COMBO_OFF, a2), d0 ; d0 contains combo multiplier
    MOVE.L  a2, a0
    ADDA.W  #SCORE_OFF, a0  ; a0 -> player score
    LEA.L   SCRATCH, a1     ; a1 -> points to add
    BRA.B   @MULT_SCORE_STEP

@MULT_SCORE_LOOP:
    MOVE.W  #0, CCR ; reset flags so no erroneous extend bit
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
    ABCD    -(a1), -(a0)
@MULT_SCORE_STEP:
    ADDA.W  #4, a0
    ADDA.W  #4, a1
    DBRA    d0, @MULT_SCORE_LOOP

    ; if the player crossed a 5000 point boundary, give them a bomb
    ANDI.B  #$F0, d1
    MOVE.B  (SCORE_OFF+2, a2), d0
    ANDI.B  #$F0, d0
    ; don't check further if thousands digit is same
    CMP.B   d0, d1
    BEQ.B   @ADD_SCORE_RET
    ; if new thousands digit is zero, we crossed 10,000
    TST.B   d0
    BEQ.B   @ADD_BOMB
    ; check for 5,000
    CMPI.B  #$50, d0
    BNE.B   @ADD_SCORE_RET
@ADD_BOMB:
    MOVE.B  (BOMBS_OFF+1, a2), d0
    MOVEQ   #1, d1
    MOVE.W  #0, CCR ; reset flags so no erroneous extend bit
    ABCD    d1, d0
    MOVE.B  d0, (BOMBS_OFF+1, a2)

@ADD_SCORE_RET:
    POP     a0-a1/d0-d1
    RTS
    

