
; *******************************************************************
; INPUT.S
; Subroutine for reading joypad inputs from both ports. Also contains
; the indices for each button in the resulting data.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *******************************************************************

BUTTON_UP = 0
BUTTON_DOWN = 1
BUTTON_LEFT = 2
BUTTON_RIGHT = 3
BUTTON_B = 4
BUTTON_C = 5
BUTTON_A = 6
BUTTON_START = 7

; Read input from both controllers
; Thrashed: a5-a6/d0/d6-d7
READ_INPUT:
    MOVE.W  SR, d0
    MOVE.W  #$2700, SR ; disable interrupts
    REMOVE_Z80
    BSR.B   _READ_BOTH
    REPLACE_Z80
    MOVE.W  d0, SR  ; restore interrupts
    RTS

_READ_BOTH:
    ; a5 will point to joypad storage in RAM 
    LEA.L   JOY1, a5
    ; copy data in JOY1&2 to JOY1&2_OLD
    MOVE.L  (a5), 4(a5)
    ; a6 will point to data port for P1
    LEA.L   JOY1_DATA, a6
    ; read for P1
    BSR.B   _READ_JOY
    ; a6 will point to data port for P2
    ADDQ.W  #2, a6
    ; fall-thru to read for P2

_READ_JOY:
    MOVE.B  #0, (a6)    ; we want values for START and A from data port
    NOP                 ; wait for port
    NOP
    MOVE.B  (a6), d7    ; d7 = {x 0 ST A 0 0 D U}
    LSL.B   #2, d7      ; d7 = {ST A 0 0 D U 0 0}, wait for port
    MOVE.B  #$40, (a6)  ; we want the rest of the buttons from data port
    ANDI.W  #$C0, d7    ; d7 = {ST A 0 0 0 0 0 0}, wait for port
    MOVE.B  (a6), d6    ; d6 = {x 1 C B R L D U}
    ANDI.W  #$3F, d6    ; d6 = {0 0 C B R L D U}
    OR.B    d6, d7      ; d7 = {ST A C B R L D U}
    NOT.B   d7          ; 0 == pressed -> 1 == pressed
    MOVE.W  d7, (a5)+
    RTS     ; return to READ_BOTH, then READ_INPUT
    