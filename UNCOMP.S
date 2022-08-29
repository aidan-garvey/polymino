
; *****************************************************************
; UNCOMPRESS.S
; Code to uncompress characters to a given destination
; 
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ============================================================
; UNCOMPRESS
; ------------------------------------------------------------
; Uncompress the given characters, write to given RAM location
; ------------------------------------------------------------
; Parameters:
;   a0 - source rows
;   a1 - source row indices (aka compressed characters)
;   a2 - destination
;   d0 - number of chars
; ============================================================
UNCOMPRESS:
    PUSH.L  a0-a2/d0-d1

    ; to get number of rows, multiply number of chars by 8
    LSL.W   #3, d0

    BRA.B   _STEP
_LOOP:
    MOVE.B  (a1)+, d1
    EXT.W   d1
    ; multiply by 4 since each row is 4 bytes
    ADD.W   d1, d1
    ADD.W   d1, d1
    MOVE.L  (a0, d1.w), (a2)+

_STEP:
    DBRA    d0, _LOOP

    POP.L   a0-a2/d0-d1
