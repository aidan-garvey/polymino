
; *****************************************************************
; BGM_1_ESF.S
; ESF data for a background music track used by Echo sound engine.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; for info about uncommented values, see:
; https://github.com/sikthehedgehog/Echo/blob/master/doc/esf.txt

; Q: Why on earth did you do it this way?
; A: I made the mistake of using VGM Music Maker to compose
;    the track, so there's no tool to convert it to ESF :-(

ESF_BGM_1:

_TICKS_PER_FRAME EQU 4

; FM note constants
_C3 EQU 32*3+2*0+1
_D3 EQU 32*3+2*2+1
_E3 EQU 32*3+2*4+1
_F3 EQU 32*3+2*5+1
_G3 EQU 32*3+2*7+1
_A3 EQU 32*3+2*9+1
_B3 EQU 32*3+2*11+1

_C2 EQU _C3-32
_D2 EQU _D3-32
_E2 EQU _E3-32
_F2 EQU _F3-32
_G2 EQU _G3-32
_A2 EQU _A3-32
_B2 EQU _B3-32

_C4 EQU _C3+32
_D4 EQU _D3+32
_E4 EQU _E3+32
_F4 EQU _F3+32
_G4 EQU _G3+32
_A4 EQU _A3+32
_B4 EQU _B3+32

_C1 EQU _C2-32

; PSG note constants
;_P_G4 EQU 12*4+7+128
;_P_A4 EQU 12*4+9+128
;_P_B4 EQU 12*4+11+128
;_P_C5 EQU 12*5+0+128
_P_G4 EQU _G4+1*32
_P_A4 EQU _A4+1*32
_P_B4 EQU _B4+1*32
_P_C5 EQU _C4+2*32
_P_G5 EQU _P_G4+32
_P_A5 EQU _P_A4+32
_P_B5 EQU _P_B4+32
_P_C6 EQU _P_C5+32

; other frequent values:
; (note the word "frame" in this file refers to a beat of the song,
; while "tick" refers to one television frame or 1/60 seconds)

; note-off on FM channel #1 then wait 1 frame
_CUT EQU $10D0|_TICKS_PER_FRAME-1
; switch instrument in FM channel #2 and play B-3
_SHH EQU $41000100|_B3
_LHH EQU $41040100|_B3

_DEL1 EQU $D0|_TICKS_PER_FRAME-1 ; command to delay one frame

; declare a delay command, using short delay if possible
; parameter \1: number of frames
_DELAY: MACRO
; total ticks needed for the delay
_TICKS\@ EQU (\1)*_TICKS_PER_FRAME
    ; if it's too large for one command, split it
    IF _TICKS\@>=256
        ; use as many max-length delays as needed
        REPT    _TICKS\@/256
        DC.W    $FE00
        ENDR
        ; if there are any ticks remaining, call delay again to use optimal command format
        IF (_TICKS\@)%(256)
            _DELAY (\1)%(256/_TICKS_PER_FRAME)
        ENDIF
    ; if it's too large for a short delay, use a long delay
    ELSEIF _TICKS\@>16
        DC.B    $FE, _TICKS\@
    ; if it's 16 or fewer ticks, use short delay, don't allow 0-tick delays
    ELSEIF _TICKS\@>0
        DC.B    $D0|_TICKS\@-1
    ENDIF
    ENDM

; play a white noise note on PSG #4 with PSG #3's frequency
; parameter \1: _P_xx PSG note constant
_PSG4: MACRO
    ;; set channel 3 frequency
    ;DC.B    $3A, \1
    ;; play white noise
    ;DC.W    $0B07
    DC.B    $05, \1
    ENDM


    ; *************************
    ; ** START OF MUSIC DATA **
    ; *************************

    ; consistent instruments
    DC.W    $4001   ; channel 1
    DC.W    $4202   ; channel 3
    DC.W    $4405   ; channel 4
    DC.W    $4505   ; channel 5
    ;DC.W    $4B07   ; PSG 4
    ; consistent volumes
    DC.W    $2100   ; channel 2 maxed
    DC.W    $2200   ; channel 3 maxed
    DC.W    $2400   ; channel 4 maxed
    DC.W    $2500   ; channel 5 maxed
    ;DC.W    $2B01   ; PSG 4 almost maxed

    ; *********
    ; PATTERN 2
    ; *********
    REPT    4       ; pattern will loop 4 times
    DC.W    $2000   ; channel 1 max volume
    DC.B    $00, _C3
    ; DC.B    $D6
    _DELAY 7

    DC.W    _CUT
    DC.W    $2010   ; channel 1 lower volume
    DC.B    $00, _C3
    ; DC.B    $D6
    _DELAY 7

    DC.W    _CUT
    DC.B    $00, _C3
    ; DC.B    $D2
    _DELAY 3

    DC.W    _CUT
    DC.B    $00, _B3, _DEL1
    DC.W    _CUT
    DC.B    $00, _A3
    ; DC.B    $D2
    _DELAY 3

    DC.W    _CUT
    DC.B    $00, _G3, _DEL1
    DC.W    _CUT
    DC.B    $00, _F3, _DEL1
    DC.W    _CUT
    DC.B    $00, _E3, _DEL1
    DC.W    _CUT
    
    ENDR

    DC.B    $FD ; point where track loops

    ; *********
    ; PATTERN 4
    ; *********
    REPT    4
    ; frame 0
    DC.W    $2000   ; channel 1 max volume
    DC.B    $00, _C3
    DC.L    _SHH
    DC.B    $02, _D2
    _DELAY 4
    
    ; 4
    DC.L    _LHH
    _DELAY 3

    ; 7-8
    DC.W    _CUT
    DC.W    $2010   ; channel 1 lower volume
    DC.B    $00, _C3
    DC.L    _SHH
    _DELAY 4

    ; C
    DC.L    _LHH
    _DELAY 3

    ; F-10
    DC.W    _CUT
    DC.B    $00, _C3
    DC.L    _SHH
    _DELAY 3

    ; 13-14
    DC.W    _CUT
    DC.B    $00, _B3
    DC.L    _LHH
    DC.B    _DEL1

    ; 15-16
    DC.W    _CUT
    DC.B    $00, _A3
    ; DC.B    $D1
    _DELAY 2

    ; 18
    DC.L    _SHH
    DC.B    _DEL1

    ; 19-1F
    DC.W    _CUT
    DC.B    $00, _G3, _DEL1
    DC.W    _CUT
    DC.B    $00, _F3
    DC.L    _LHH
    DC.B    _DEL1
    DC.W    _CUT
    DC.B    $00, _E3, _DEL1
    DC.B    $12     ; note off FM #3
    DC.W    _CUT

    ENDR

    ; *********
    ; PATTERN 0
    ; *********
    REPT    4
    ; frame 0
    DC.W    $2000   ; channel 1 max volume
    DC.B    $00, _C3
    DC.L    _SHH
    DC.B    $02, _D2
    _PSG4   _P_C5
    DC.B    _DEL1

    ; frame 1-3
    DC.B    $1B ; note off PSG 4
    _DELAY  3

    ; 4-6
    DC.L    _LHH
    _DELAY  3

    ; 7-8
    DC.W    _CUT

    DC.W    $2010
    DC.B    $00, _C3
    DC.L    _SHH
    _PSG4   _P_C5
    DC.B    _DEL1

    ; 9-B
    DC.B    $1B
    _DELAY  3

    ; C-E
    DC.L    _LHH
    _DELAY  3

    ; F
    DC.W    _CUT

    ; 10
    DC.B    $00, _C3
    DC.L    _SHH
    _PSG4   _P_G4
    DC.B    _DEL1

    ; 11-12
    DC.B    $1B
    _DELAY  2

    ; 13-14
    DC.W    _CUT

    DC.B    $00, _B3
    DC.L    _LHH
    DC.B    _DEL1

    ; 15-16
    DC.W    _CUT

    DC.B    $00, _A3
    _PSG4   _P_G4
    DC.B    _DEL1

    ; 17-18
    DC.B    $1B
    DC.B    _DEL1

    DC.L    _SHH
    DC.B    _DEL1

    ; 19-1F
    DC.W    _CUT

    DC.B    $00, _G3, _DEL1

    DC.W    _CUT

    DC.L    _LHH
    _PSG4   _P_A4
    DC.B    $00, _F3, _DEL1

    DC.B    $1B
    DC.W    _CUT

    DC.B    $00, _E3, _DEL1

    DC.B    $12
    DC.W    _CUT

    ; 20-23
    DC.W    $2000
    DC.B    $00, _C3
    DC.L    _SHH
    DC.B    $02, _D2
    _PSG4   _P_B4
    DC.B    _DEL1, $1B
    _DELAY  3

    ; 24-26
    DC.L    _LHH
    _DELAY  3

    ; 27-2B
    DC.W    _CUT
    DC.L    _SHH
    _PSG4   _P_B4
    DC.W    $2010
    DC.B    $00, _C3, _DEL1
    DC.B    $1B
    _DELAY  3

    ; 2C-2E
    DC.L    _LHH
    _DELAY  3

    ; 2F-32
    DC.W    _CUT
    DC.L    _SHH
    _PSG4   _P_G4
    DC.B    $00, _C3, _DEL1
    DC.B    $1B
    _DELAY  2

    ; 33
    DC.W    _CUT 

    DC.L    _LHH
    DC.B    $00, _B3, _DEL1

    DC.W    _CUT

    _PSG4   _P_G4
    DC.B    $00, _A3, _DEL1

    DC.B    $1B, _DEL1

    ; 38
    DC.L    _SHH
    DC.B    _DEL1

    DC.W    _CUT

    DC.B    $00, _G3, _DEL1

    DC.W    _CUT

    ; 3C
    DC.L    _LHH
    _PSG4   _P_G4
    DC.B    $00, _F3, _DEL1

    DC.B    $1B
    DC.W    _CUT

    DC.B    $00, _E3, _DEL1

    DC.B    $12
    DC.W    _CUT

    ENDR

    ; *********
    ; PATTERN 3
    ; *********

    ; frame 0
    _PSG4   _P_C5
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 8
    _PSG4   _P_C5
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 10
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 16
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 1C
    _PSG4   _P_A4
    DC.B    _DEL1, $1B
    _DELAY  3

    ; 20
    _PSG4   _P_B4
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 28
    _PSG4   _P_B4
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 30
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 36
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 3C
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  3

    ; *********
    ; PATTERN 1
    ; *********

    ; frame 0
    DC.B    $02, _D2
    _PSG4   _P_C5
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 8
    _PSG4   _P_C5
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 10
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 16
    _PSG4   _P_G4
    DC.B    _DEL1, $1B
    _DELAY  5

    ; 1C
    _PSG4   _P_A4
    DC.B    _DEL1, $1B
    _DELAY  2

    ; 1F
    DC.B    $12, _DEL1

    ; 20
    DC.B    $02, _D2
    _PSG4   _P_B4
    DC.B    _DEL1, $1B
    _DELAY  7

    ; 28
    _PSG4   _P_B4
    DC.B    _DEL1, $1B
    _DELAY  7

    ; let's spam some precussion!
    
    ; channel 1, 2, 4 instruments
    DC.W    $4000, $4104, $4405
    ; volumes cranked
    DC.W    $2000, $2100, $2400

    ; frame 30
    _PSG4   _P_G4
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    DC.B    _DEL1, $1B, _DEL1

    ; 32
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    _DELAY  2

    ; 34
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    _DELAY  2

    ; 36
    _PSG4   _P_G4
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    DC.B    _DEL1, $1B, _DEL1

    ; 38
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    _DELAY  2

    ; 3A
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    _DELAY  2
    
    ; 3C
    _PSG4   _P_G4
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    DC.B    _DEL1, $1B, _DEL1

    ; 3E-3F
    DC.B    $00, _B3
    DC.B    $01, _B3
    DC.B    $04, _C2
    DC.B    _DEL1, $12, _DEL1

    ; *********
    ; PATTERN 6
    ; *********

    ; change channel 1's instrument back
    DC.W    $4001

    REPT    2

    ; frame 0
    DC.W    $2000   ; ch. 1 vol up
    DC.L    _SHH
    _PSG4   _P_C5
    DC.B    $00, _C3, $02, _D2, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  3

    ; frame 4
    DC.L    _LHH
    _DELAY  3

    ; 7
    DC.W    _CUT
    ; 8
    _PSG4   _P_C5
    DC.L    _LHH
    DC.W    $2010   ; ch.1 vol down
    DC.B    $00, _C3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  3

    ; C
    DC.L    _LHH
    _DELAY  3

    ; F-11
    DC.W    _CUT
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _C3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  2

    ; 13
    DC.W    _CUT
    ; 14
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 15
    DC.W    _CUT
    ; 16
    _PSG4   _P_G4
    DC.B    $00, _A3, _DEL1
    ; 17
    DC.B    $1B, _DEL1
    ; 18
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 19
    DC.W    _CUT
    ; 1A
    DC.L    _SHH
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 1B
    DC.W    _CUT
    ; 1C
    DC.L    _LHH
    _PSG4   _P_A4
    DC.B    $00, _F3, _DEL1
    ; 1D
    DC.B    $1B
    DC.W    _CUT
    ; 1E
    DC.B    $00, _E3, _DEL1
    ; 1F
    DC.B    $12
    DC.W    _CUT
    ; 20
    DC.W    $2000   ; ch.1 vol up
    _PSG4   _P_B4 
    DC.L    _SHH
    DC.B    $00, _C3, $02, _D2, $04, _C1, _DEL1
    ; 21
    DC.B    $1B
    _DELAY  3
    ; 24
    DC.L    _LHH
    _DELAY  3
    ; 27
    DC.W    _CUT
    ; 28
    DC.W    $2010   ; ch.1 vol down
    DC.L    _LHH
    _PSG4   _P_B4
    DC.B    $00, _C3, $04, _C1, _DEL1
    ; 29
    DC.B    $1B
    _DELAY  3
    ; 2C
    DC.L    _LHH
    _DELAY  3
    ; 2F
    DC.W    _CUT
    ; 30
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _C3, $04, _C1, _DEL1
    ; 31
    DC.B    $1B
    _DELAY  2
    ; 33
    DC.W    _CUT
    ; 34
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 35
    DC.W    _CUT
    ; 36
    _PSG4   _P_G4
    DC.B    $00, _A3, _DEL1
    ; 37
    DC.B    $1B, _DEL1
    ; 38
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 39
    DC.W    _CUT
    ; 3A
    DC.L    _SHH
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 3B
    DC.W    _CUT
    ; 3C
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _F3, _DEL1
    ; 3D
    DC.B    $1B
    DC.W    _CUT
    ; 3E
    DC.B    $00, _E3, _DEL1
    ; 3F
    DC.B    $12
    DC.W    _CUT

    ENDR

    ; *********
    ; PATTERN 5
    ; *********

    REPT    2

    ; frame 0
    DC.W    $2000   ; ch. 1 vol up
    DC.L    _SHH
    _PSG4   _P_C6
    DC.B    $00, _C3, $02, _D3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  3

    ; frame 4
    DC.L    _LHH
    _DELAY  3

    ; 7
    DC.W    _CUT
    ; 8
    _PSG4   _P_C6
    DC.L    _SHH
    DC.W    $2010   ; ch.1 vol down
    DC.B    $00, _C3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  3

    ; C
    DC.L    _LHH
    _DELAY  3

    ; F-11
    DC.W    _CUT
    _PSG4   _P_G5
    DC.L    _SHH
    DC.B    $00, _C3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  2

    ; 13
    DC.W    _CUT
    ; 14
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 15
    DC.W    _CUT
    ; 16
    _PSG4   _P_G5
    DC.B    $00, _A3, _DEL1
    ; 17
    DC.B    $1B, _DEL1
    ; 18
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 19
    DC.W    _CUT
    ; 1A
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 1B
    DC.W    _CUT
    ; 1C
    DC.L    _LHH
    _PSG4   _P_A5
    DC.B    $00, _F3, _DEL1
    ; 1D
    DC.B    $1B
    DC.W    _CUT
    ; 1E
    DC.B    $00, _E3, _DEL1
    ; 1F
    DC.B    $12
    DC.W    _CUT
    ; 20
    _PSG4   _P_B5 
    DC.L    _SHH
    DC.W    $2000   ; ch.1 vol up
    DC.B    $00, _C3, $02, _D3, $04, _C1, _DEL1
    ; 21
    DC.B    $1B
    _DELAY  3
    ; 24
    DC.L    _LHH
    _DELAY  3
    ; 27
    DC.W    _CUT
    ; 28
    DC.W    $2010   ; ch.1 vol down
    DC.L    _SHH
    _PSG4   _P_B5
    DC.B    $00, _C3, $04, _C1, _DEL1
    ; 29
    DC.B    $1B
    _DELAY  3
    ; 2C
    DC.L    _LHH
    _DELAY  3
    ; 2F
    DC.W    _CUT
    ; 30
    _PSG4   _P_G5
    DC.L    _SHH
    DC.B    $00, _C3, $04, _C1, _DEL1
    ; 31
    DC.B    $1B
    _DELAY  2
    ; 33
    DC.W    _CUT
    ; 34
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 35
    DC.W    _CUT
    ; 36
    _PSG4   _P_G5
    DC.B    $00, _A3, _DEL1
    ; 37
    DC.B    $1B, _DEL1
    ; 38
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 39
    DC.W    _CUT
    ; 3A
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 3B
    DC.W    _CUT
    ; 3C
    _PSG4   _P_G5
    DC.L    _LHH
    DC.B    $00, _F3, _DEL1
    ; 3D
    DC.B    $1B
    DC.W    _CUT
    ; 3E
    DC.B    $00, _E3, _DEL1
    ; 3F
    DC.B    $12
    DC.W    _CUT

    ENDR

    ; *********
    ; PATTERN 8
    ; *********

    REPT    2

    ; frame 0
    DC.W    $2000   ; ch. 1 vol up
    DC.L    _SHH
    _PSG4   _P_C5
    DC.B    $00, _C3, $02, _D2, $04, _C1
    DC.B    _DEL1, $1B, _DEL1

    ; 2
    _PSG4   _P_C5
    DC.B    _DEL1, $1B, _DEL1

    ; frame 4
    DC.L    _LHH
    _DELAY  3

    ; 7
    DC.W    _CUT
    ; 8
    DC.L    _LHH
    DC.W    $2010   ; ch.1 vol down
    DC.B    $00, _C3, $04, _C1
    _DELAY  4

    ; C
    DC.L    _LHH
    _DELAY  3

    ; F-11
    DC.W    _CUT
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _C3, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  2

    ; 13
    DC.W    _CUT
    ; 14
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 15
    DC.W    _CUT
    ; 16
    _PSG4   _P_G4
    DC.B    $00, _A3, _DEL1
    ; 17
    DC.B    $1B, _DEL1
    ; 18
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 19
    DC.W    _CUT
    ; 1A
    DC.L    _SHH
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 1B
    DC.W    _CUT
    ; 1C
    DC.L    _LHH
    _PSG4   _P_A4
    DC.B    $00, _F3, _DEL1
    ; 1D
    DC.B    $1B
    DC.W    _CUT
    ; 1E
    DC.B    $00, _E3, _DEL1
    ; 1F
    DC.B    $12
    DC.W    _CUT
    ; 20
    _PSG4   _P_B4 
    DC.L    _SHH
    DC.W    $2000   ; ch.1 vol up
    DC.B    $00, _C3, $02, _D2, $04, _C1, _DEL1
    ; 21
    DC.B    $1B, _DEL1
    _PSG4   _P_B4
    DC.B    _DEL1, $1B, _DEL1
    ; 24
    DC.L    _LHH
    _DELAY  3
    ; 27
    DC.W    _CUT
    ; 28
    DC.W    $2010   ; ch.1 vol down
    DC.L    _LHH
    DC.B    $00, _C3, $04, _C1
    _DELAY  4
    ; 2C
    DC.L    _LHH
    _DELAY  3
    ; 2F
    DC.W    _CUT
    ; 30
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _C3, $04, _C1, _DEL1
    ; 31
    DC.B    $1B
    _DELAY  2
    ; 33
    DC.W    _CUT
    ; 34
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 35
    DC.W    _CUT
    ; 36
    _PSG4   _P_G4
    DC.B    $00, _A3, _DEL1
    ; 37
    DC.B    $1B, _DEL1
    ; 38
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 39
    DC.W    _CUT
    ; 3A
    DC.L    _SHH
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 3B
    DC.W    _CUT
    ; 3C
    _PSG4   _P_G4
    DC.L    _LHH
    DC.B    $00, _F3, _DEL1
    ; 3D
    DC.B    $1B
    DC.W    _CUT
    ; 3E
    DC.B    $00, _E3, _DEL1
    ; 3F
    DC.B    $12
    DC.W    _CUT

    ENDR

    ; *********
    ; PATTERN 7
    ; *********

    REPT    2

    ; frame 0
    DC.W    $2000   ; ch. 1 vol up
    DC.L    _SHH
    _PSG4   _P_C5
    DC.B    $00, _C3, $02, _D2, $04, _C1
    DC.B    _DEL1, $1B
    _DELAY  3

    ; frame 4
    DC.L    _LHH
    _DELAY  3

    ; 7
    DC.W    _CUT
    ; 8
    DC.L    _SHH
    DC.W    $2010   ; ch.1 vol down
    DC.B    $00, _C3, $04, _C1
    _DELAY  4

    ; C
    DC.L    _LHH
    _DELAY  3

    ; F-12
    DC.W    _CUT
    DC.L    _SHH
    DC.B    $00, _C3, $04, _C1
    _DELAY  3

    ; 13
    DC.W    _CUT
    ; 14
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 15
    DC.W    _CUT
    ; 16
    DC.B    $00, _A3
    _DELAY  2
    ; 18
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 19
    DC.W    _CUT
    ; 1A
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 1B
    DC.W    _CUT
    ; 1C
    DC.L    _LHH
    DC.B    $00, _F3, _DEL1
    ; 1D
    DC.W    _CUT
    ; 1E
    DC.B    $00, _E3, _DEL1
    ; 1F
    DC.B    $12
    DC.W    _CUT
    ; 20
    _PSG4   _P_C5
    DC.L    _SHH
    DC.W    $2000   ; ch.1 vol up
    DC.B    $00, _C3, $02, _D2, $04, _C1, _DEL1
    ; 21
    DC.B    $1B
    _DELAY  3
    ; 24
    DC.L    _LHH
    _DELAY  3
    ; 27
    DC.W    _CUT
    ; 28
    DC.W    $2010   ; ch.1 vol down
    DC.L    _SHH
    DC.B    $00, _C3, $04, _C1
    _DELAY  4
    ; 2C
    DC.L    _LHH
    _DELAY  3
    ; 2F
    DC.W    _CUT
    ; 30
    DC.L    _SHH
    DC.B    $00, _C3, $04, _C1
    _DELAY  3
    ; 33
    DC.W    _CUT
    ; 34
    DC.L    _LHH
    DC.B    $00, _B3, _DEL1
    ; 35
    DC.W    _CUT
    ; 36
    DC.B    $00, _A3
    _DELAY  2
    ; 38
    DC.L    _SHH
    DC.B    $04, _C1, _DEL1
    ; 39
    DC.W    _CUT
    ; 3A
    DC.B    $00, _G3, $04, _C1, _DEL1
    ; 3B
    DC.W    _CUT
    ; 3C
    DC.L    _LHH
    DC.B    $00, _F3, _DEL1
    ; 3D
    DC.W    _CUT
    ; 3E
    DC.B    $00, _E3, _DEL1
    ; 3F
    DC.B    $12
    DC.W    _CUT

    ENDR

    ; loop track
    DC.B    $FC, $00
    ; For some reason, when building with SN asm68k, the command to loop
    ; the track ($FC) is omitted if there isn't a byte following it.
    ; Probably something to do with using /oae- which changes the way
    ; DC.W is aligned (but is needed for this file to assemble correctly)
