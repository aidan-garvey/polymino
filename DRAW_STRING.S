
; *****************************************************************
; DRAW_STRING.S
; Code to display a null-terminated string in SCROLL A or B.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ==============================================
; DRAW_STRING
; ----------------------------------------------
; Display a null-terminated string in BUFF_PLANE
; ----------------------------------------------
; Parameters:
;   a0 - null-terminated string
;   d3 - x position of string (cell number)
;   d4 - y position of string (cell number)
; ==============================================
DRAW_STRING:
    PUSH.L  a0-a2/d0/d3-d4

    LEA.L   BUFF_PLANE, a1
    ADD.W   d3, d3  ; multiply x by 2 since each tile is a word
    LSL.W   #7, d4  ; multiply y by 128 since there are 64 tiles per row
    ADD.W   d3, d4
    ADDA.W  d4, a1

_DRAW_STRING_LOOP:
    MOVE.B  (a0)+, d0
    BEQ.B   _DRAW_STRING_RET
    CMP.B   #' ', d0
    BEQ.B   _DRAW_STRING_SPACE
    CMP.B   #'9', d0
    BLE.B   _DRAW_STRING_DIGIT
    ; if it is a letter:
    SUB.B   #'A', d0
    EXT.W   d0
    ; multiply by 2 to get word index
    ADD.W   d0, d0
    LEA.L   LETTER_PATTERNS, a2
    ADDA.W  d0, a2
    MOVE.W  (a2), (a1)+
    BRA.B   _DRAW_STRING_LOOP
_DRAW_STRING_SPACE:
    CLR.W   (a1)+
    BRA.B   _DRAW_STRING_LOOP
_DRAW_STRING_DIGIT:
    SUB.B   #'0', d0
    EXT.W   d0
    ADD.W   d0, d0
    LEA.L   DIGIT_PATTERNS, a2
    ADDA.W  d0, a2
    MOVE.W  (a2), (a1)+
    BRA.B   _DRAW_STRING_LOOP

_DRAW_STRING_RET:
    POP.L   a0-a2/d0/d3-d4
    RTS
