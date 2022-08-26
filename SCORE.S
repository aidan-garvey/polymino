
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
    MOVE.L  d0, -(SP)

    MOVEQ   #MATCH_POINTS, d0
    MULU.W  (COMBO_OFF, a2), d0
    ADD.L   d0, (SCORE_BIN_OFF, a2)

    MOVE.L  (SP)+, d0
    RTS

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
    MOVE.L  d0, -(SP)
    
    MOVEQ   #SHATTER_POINTS, d0
    MULU.W  (COMBO_OFF, a2), d0
    ADD.L   d0, (SCORE_BIN_OFF, a2)

    MOVE.L  (SP)+, d0
    RTS

; ========================================
; UPDATE_BCD_SCORE
; ----------------------------------------
; Convert the player's binary score to BCD
; ----------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   d0-d7
; ========================================
UPDATE_BCD_SCORE:
    MOVEQ   #0, d0
    MOVE.L  (SCORE_BIN_OFF, a2), d1
    ; since the BCD score is seven digits, we need
    ; lower 24 bits of d1 moved to the upper bits
    LSL.L   #8, d1
    
    ; we'll left shift d0:d1 24 times
    ; no chance of a 5 in d0 for first two shifts
    ADD.L   d1, d1
    ADDX.L  d0, d0
    ADD.L   d1, d1
    ADDX.L  d0, d0

    MOVEQ   #20, d7 ; shift with checks 21 times
_DDABBLE_LOOP:
    ; shift d0:d1 left
    ADD.L   d1, d1
    ADDX.L  d0, d0
    ; check d0 for digits >= 5
    MOVEQ   #$0F, d3    ; d3 will mask digits
    MOVEQ   #$05, d4    ; d4 will be used to compare with 5
    MOVEQ   #6, d6      ; we will check the lowest 7 digits
_CHECK5_LOOP:
    ; isolate current digit, add 3 if >= 5
    MOVE.W  d0, d2
    AND.W   d3, d2
    CMP.W   d4, d2
    BLT.B   _CHECK5_STEP
    ADDQ.L  #3, d0

_CHECK5_STEP:
    ; move next digit to lowest position
    ROR.L   #4, d0
    DBRA    d6, _CHECK5_LOOP

    ; we only rotated 7/8 times in the inner loop
    ROR.L   #4, d0

    DBRA    d7, _DDABBLE_LOOP

    ; last shift, 5's allowed in d0
    ADD.L   d1, d1
    ADDX.L  d0, d0

    ; d0 is the final score - check if player has earned a bomb
    MOVE.W  (SCORE_BCD_OFF+2, a2), d1 ; get lower 4 digits
    ; award a bomb every 5000 points
    ; if thousands digit is unchanged, don't award bomb
    EOR.W   d0, d1
    ANDI.W  #$F000, d1
    BEQ.B   _UPDATE_BCD_SCORE_SAVE
    ; if thousands digit is 0, award bomb
    MOVE.W  d0, d1
    ANDI.W  #$F000, d1
    BEQ.B   _GIVE_SCORE_BOMB
    ; if thousands is not 0 nor 5, don't award bomb
    CMP.W   #$5000, d1
    BNE.B   _UPDATE_BCD_SCORE_SAVE

_GIVE_SCORE_BOMB:
    ADDQ.W  #1, (BOMBS_OFF, a2)

_UPDATE_BCD_SCORE_SAVE: 
    MOVE.L  d0, (SCORE_BCD_OFF, a2)

    RTS
