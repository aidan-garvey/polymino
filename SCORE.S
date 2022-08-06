
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
    PUSH    d0

    MOVEQ   #MATCH_POINTS, d0
    MULU.W  (COMBO_OFF, a2), d0
    ADD.L   d0, (SCORE_BIN_OFF, a2)

    POP     d0
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
    PUSH    d0
    
    MOVEQ   #SHATTER_POINTS, d0
    MULU.W  (COMBO_OFF, a2), d0
    ADD.L   d0, (SCORE_BIN_OFF, a2)

    POP     d0
    RTS

; ========================================
; UPDATE_BCD_SCORE
; ----------------------------------------
; Convert the player's binary score to BCD
; ----------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; ========================================
UPDATE_BCD_SCORE:
    PUSH    d0-d7

    MOVEQ   #0, d0
    MOVE.L  (SCORE_BIN_OFF, a2), d1
    ; since the BCD score is seven digits, we need
    ; lower 24 bits of d1 moved to the upper bits
    LSL.L   #8, d1
    MOVEQ   #22, d7 ; shift 23 times, then a final time with no checks
@DDABBLE_LOOP:
    ; shift d1 left, shift the bit that got shifted out of d1 into d0
    ADD.L   d1, d1
    ROXL.L  #1, d0
    ; check d0 for digits >= 5
    MOVEQ   #$0F, d3    ; d3 will mask digits
    MOVEQ   #$05, d4    ; d4 will be used to compare with 5
    MOVEQ   #$03, d5    ; d5 will be used to add 3
    MOVEQ   #6, d6      ; we will check the lowest 7 digits
@CHECK5_LOOP:
    MOVE.L  d0, d2
    ; isolate current digit, check if >= 5
    AND.L   d3, d2
    CMP.L   d4, d2
    BLT.B   @CHECK5_STEP
    ADD.L   d5, d0

@CHECK5_STEP:
    LSL.L   #4, d3
    LSL.L   #4, d4
    LSL.L   #4, d5
    DBRA    d6, @CHECK5_LOOP

    DBRA    d7, @DDABBLE_LOOP

    ; last shift
    ADD.L   d1, d1
    ROXL.L  #1, d0

    ; save score
    MOVE.L  d0, (SCORE_BCD_OFF, a2)

    POP     d0-d7
    RTS
