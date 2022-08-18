
; *********************************************************************
;         Beams: A 1-2 player puzzle game for the Sega Genesis
;                   Copyright (C) 2022 Aidan Garvey
; *********************************************************************
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.
; *********************************************************************

; -----------------
; Interrupt Vectors
; -----------------
    DC.L    STACK_END       ; Initial stack pointer value
    DC.L    STARTUP_RUN     ; Start of program
    DC.L    Exception       ; Bus error
    DC.L    Exception       ; Address error
    DC.L    Exception       ; Illegal instruction
    DC.L    Exception       ; Division by zero
    DC.L    Exception       ; CHK exception
    DC.L    Exception       ; TRAPV exception
    DC.L    Exception       ; Privilege violation
    DC.L    Exception       ; TRACE exception
    DC.L    Exception       ; Line-A emulator
    DC.L    Exception       ; Line-F emulator
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Spurious exception
    DC.L    Exception       ; IRQ level 1
    DC.L    EXTINT          ; IRQ level 2 (external interrupt)
    DC.L    Exception       ; IRQ level 3
    DC.L    HBLANK          ; IRQ level 4 (horizontal retrace interrupt)
    DC.L    Exception       ; IRQ level 5
    DC.L    VBLANK          ; IRQ level 6 (vertical retrace interrupt)
    DC.L    Exception       ; IRQ level 7
    DC.L    Exception       ; TRAP #00 exception
    DC.L    Exception       ; TRAP #01 exception
    DC.L    Exception       ; TRAP #02 exception
    DC.L    Exception       ; TRAP #03 exception
    DC.L    Exception       ; TRAP #04 exception
    DC.L    Exception       ; TRAP #05 exception
    DC.L    Exception       ; TRAP #06 exception
    DC.L    Exception       ; TRAP #07 exception
    DC.L    Exception       ; TRAP #08 exception
    DC.L    Exception       ; TRAP #09 exception
    DC.L    Exception       ; TRAP #10 exception
    DC.L    Exception       ; TRAP #11 exception
    DC.L    Exception       ; TRAP #12 exception
    DC.L    Exception       ; TRAP #13 exception
    DC.L    Exception       ; TRAP #14 exception
    DC.L    Exception       ; TRAP #15 exception
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    DC.L    Exception       ; Unused (reserved)
    
; ----------------
; Cartridge Header
; ----------------

    DC.B    'SEGA GENESIS    '
    DC.B    '(C)T-00 1990.OCT'
    DC.B    'BEAMS                                           '
    DC.B    'BEAMS                                           '
    DC.B    'GM T-000000 01'
    DC.W    $0                  ; CHECKSUM
    DC.B    'J               '  ; CONTROLLER DATA
    DC.L    $000000, $3FFFFF    ; ROM START, END
    DC.L    $FF0000, $FFFFFF    ; RAM START, END
    DC.B    '            '      ; EXTERNAL RAM INFO
    DC.B    '            '      ; MODEM DATA
    DC.B    '(C) AIDAN GARVEY 2022                   '  ; MEMO
    DC.B    'U               '  ; COUNTRIES WHERE GAME IS RELEASED
