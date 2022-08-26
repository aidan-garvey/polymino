
; *****************************************************************
; BGM_1_ESF.S
; ESF data for a background music track used by Echo sound engine.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; for info about uncommented values, see:
; https://github.com/sikthehedgehog/Echo/blob/master/doc/esf.txt

; Q: Why on earth did you do it this way AGAIN?
; A: Because I already figured it out, and this song
;    is copy/paste incarnate

ESF_BGM_2:

_TICKS_PER_FRAME EQU 3

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

_C5 EQU _C4+32

_DEL1: MACRO
    DC.B    $D0+_TICKS_PER_FRAME-1 ; command to delay one frame
    ENDM

_DEL2: MACRO
    DC.B    $D0+_TICKS_PER_FRAME*2-1 ; command to delay 2 frames
    ENDM

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

_BASS: MACRO
    DC.B    $00, _F2
    ENDM

_HH: MACRO
    DC.B    $01, _B2
    ENDM

_LHH: MACRO
    DC.B    $05, _B2
    ENDM

_SNARE: MACRO
    DC.B    $02, _B4
    ENDM

_HSNARE: MACRO
    DC.B    $02, _C5
    ENDM

_NOTE: MACRO
    DC.B    $04, \1-32
    ENDM

    ; *************************
    ; ** START OF MUSIC DATA **
    ; *************************

    ; instruments
    DC.W    $400A, $4104, $4209, $440B, $450D
    ; volume
    DC.W    $2008, $2100, $2200, $2408, $2510

    ; *********
    ; PATTERN 0
    ; *********
    REPT    4

    DC.B    $00, _F2
    _DELAY  4
    DC.B    $01, _B2
    _DELAY  4
    DC.B    $00, _F2
    _DELAY  4
    DC.B    $01, _B2
    _DELAY  4
    DC.B    $00, _F2
    _DELAY  4
    DC.B    $01, _B2
    _DELAY  4
    DC.B    $00, _F2
    _DELAY  4
    DC.B    $00, _F2, $01, _B2
    _DELAY  4

    ENDR

    ; *********
    ; PATTERN 1
    ; *********
    DC.B    $FD

    REPT    8

    DC.B    $00, _F2, $02, _B4
    _DELAY  2

    DC.B    $02, _B4
    _DELAY  2

    DC.B    $01, _B2
    _DELAY  2

    DC.B    $02, _B4
    _DELAY  2

    DC.B    $00, _F2, $02, _B4
    _DELAY  4



    DC.B    $01, _B2, $02, _B4
    _DELAY  2
    DC.B    $02, _B4
    _DELAY  2
    DC.B    $00, _F2
    _DELAY  2
    DC.B    $02, _B4
    _DELAY  2
    DC.B    $01, _B2, $02, _B4
    _DELAY 4



    DC.B    $00, _F2, $02, _B4
    _DELAY 2
    DC.B    $02, _B4
    _DELAY 2
    DC.B    $00, _F2, $01, _B2, $02, _B4
    _DELAY 2
    DC.B    $02, _B4
    _DELAY 2

    ENDR

    ; *********
    ; PATTERN 2
    ; *********
    REPT 4

    _BASS
    _SNARE
    _NOTE _G4
    _DEL2

    _SNARE
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _SNARE
    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _SNARE
    _NOTE _A4
    _DEL2 

    _NOTE _A4
    _DEL2

    _HH
    _SNARE
    _NOTE _A4
    _DEL2

    _SNARE
    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _DEL2

    _SNARE
    _NOTE _G4
    _DEL2

    _HH
    _SNARE
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _SNARE
    _NOTE _C5
    _DEL2

    _SNARE
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _SNARE
    _NOTE _A4
    _DEL2

    _SNARE
    _NOTE _A4
    _DEL2

    ; 20
    _BASS
    _SNARE
    _NOTE _D4
    _DEL2

    _SNARE
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _SNARE
    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _SNARE
    _NOTE _E4
    _DEL2 

    _NOTE _E4
    _DEL2

    _HH
    _SNARE
    _NOTE _E4
    _DEL2

    _SNARE
    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _NOTE _D4
    _DEL2

    _SNARE
    _NOTE _D4
    _DEL2

    _HH
    _SNARE
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 38
    _BASS
    _SNARE
    _NOTE _E4
    _DEL2

    _SNARE
    _NOTE _E4
    _DEL2

    _BASS
    _HH
    _SNARE
    _NOTE _G4
    _DEL2

    _SNARE
    _NOTE _G4
    _DEL2

    ENDR

    ; *********
    ; PATTERN 3
    ; *********
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2
    
    _BASS
    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 20
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    ; 38
    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    ; *********
    ; PATTERN 4
    ; *********
    
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2
    
    _BASS
    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    _BASS
    _NOTE _A4
    _DEL2

    ; 20
    _HH
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    ; 28
    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    ; 30
    _HH
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    ; 38
    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _G4
    _DEL2

    ; *********
    ; PATTERN 5
    ; *********
    REPT 4

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _DEL2 

    _BASS
    _NOTE _A4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _DEL2

    ; 20
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _NOTE _E4
    _DEL2 

    _BASS
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 38
    _BASS
    _NOTE _E4
    _DEL2

    _BASS
    _HH
    _NOTE _E4
    _DEL2

    _BASS
    _HH
    _NOTE _G4
    _DEL2

    _BASS
    _HH
    _NOTE _G4
    _DEL2

    ENDR

    ; *********
    ; PATTERN 6
    ; *********
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _DEL2 

    _BASS
    _NOTE _A4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _DEL2

    ; 20
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _NOTE _E4
    _DEL2 

    _BASS
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _HSNARE
    _DELAY 4

    ; 38
    _BASS
    _HSNARE
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    ; *********
    ; PATTERN 7
    ; *********
    REPT 3

    _BASS
    _NOTE _G4
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _DEL2 

    _BASS
    _NOTE _A4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _HSNARE
    _DELAY 4

    ; 18
    _BASS
    _HSNARE
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    ; 20
    _BASS
    _NOTE _D4
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _NOTE _E4
    _DEL2 

    _BASS
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _HSNARE
    _DELAY 4

    ; 38
    _BASS
    _HSNARE
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    _BASS
    _DEL2

    _BASS
    _HSNARE
    _DEL2

    ENDR

    ; *********
    ; PATTERN 8
    ; *********
    REPT 4

    _BASS
    _NOTE _G4
    _LHH
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 8
    _BASS
    _NOTE _A4
    _LHH
    _DEL2 

    _BASS
    _NOTE _A4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 10
    _BASS
    _NOTE _G4
    _LHH
    _DEL2

    _BASS
    _NOTE _G4
    _DEL2

    _HH
    _NOTE _A4
    _DEL2

    _NOTE _A4
    _DEL2

    ; 18
    _BASS
    _NOTE _C5
    _LHH
    _DEL2

    _BASS
    _HH
    _NOTE _C5
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _LHH
    _DEL2

    _BASS
    _HH
    _NOTE _A4
    _DEL2

    ; 20
    _BASS
    _NOTE _D4
    _LHH
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 28
    _BASS
    _NOTE _E4
    _LHH
    _DEL2 

    _BASS
    _NOTE _E4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 30
    _BASS
    _NOTE _D4
    _LHH
    _DEL2

    _BASS
    _NOTE _D4
    _DEL2

    _HH
    _NOTE _E4
    _DEL2

    _NOTE _E4
    _DEL2

    ; 38
    _BASS
    _NOTE _E4
    _LHH
    _DEL2

    _BASS
    _HH
    _NOTE _E4
    _DEL2

    _BASS
    _HH
    _NOTE _G4
    _LHH
    _DEL2

    _BASS
    _HH
    _NOTE _G4
    _DEL2

    ENDR

    ; *********
    ; PATTERN 9
    ; *********
    REPT 4

    _BASS
    _LHH
    _DELAY 4

    _HH
    _DELAY 4

    _BASS
    _LHH
    _DELAY 4

    _HH
    _DELAY 4

    ; 10
    _BASS
    _LHH
    _DELAY 4

    _HH
    _DELAY 4

    _BASS
    _LHH
    _DEL2

    _HH
    _DEL2

    _BASS
    _HH
    _LHH
    _DEL2

    _HH
    _DEL2

    ENDR

    ; **********
    ; PATTERN 10
    ; **********
    REPT 4

    _BASS
    _LHH
    _DELAY 4

    _HH
    _DEL2

    _HH
    _DEL2

    _BASS
    _LHH
    _DELAY 4

    _HH
    _DEL2

    _HH
    _DEL2

    ; 10
    _BASS
    _LHH
    _DELAY 4

    _HH
    _DEL2

    _HH
    _DEL2

    _BASS
    _LHH
    _DEL2

    _HH
    _DEL1
    _HH
    _DEL1

    _BASS
    _HH
    _LHH
    _DEL1
    
    _HH
    _DEL1
    _HH
    _DEL1
    _HH
    _DEL1

    ENDR

    ; **********
    ; PATTERN 11
    ; **********
    REPT 4

    ; 0
    _BASS
    _LHH
    _DEL2

    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    ; 8
    _BASS
    _LHH
    _DEL2

    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    ; 10
    _BASS
    _LHH
    _DELAY 4

    _HH
    _DEL2

    _HH
    _DEL2

    ; 18
    _BASS
    _LHH
    _DEL2

    _HH
    _DEL1
    _HH
    _DEL1

    _BASS
    _HH
    _LHH
    _DEL1
    
    _HH
    _DEL1
    _HH
    _DEL1
    _HH
    _DEL1

    ENDR

    ; **********
    ; PATTERN 12
    ; **********
    REPT 4

    ; 0
    _BASS
    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    ; 8
    _BASS
    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    ; 10
    _BASS
    _HH
    _LHH
    _DEL2

    _HH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _DEL2

    ; 18
    _BASS
    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL1
    _HH
    _DEL1

    _BASS
    _HH
    _LHH
    _DEL1
    
    _HH
    _DEL1
    _HH
    _LHH
    _DEL1
    _HH
    _DEL1

    ENDR

    ; **********
    ; PATTERN 13
    ; **********
    REPT 4

    ; 0
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    ; 8
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    _HH
    _LHH
    _DEL2

    ; 10
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    ; 18
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL1
    _HH
    _DEL1

    _BASS
    _HH
    _LHH
    _DEL1
    
    _HH
    _DEL1
    _HH
    _LHH
    _DEL1
    _HH
    _DEL1

    ENDR

    ; **********
    ; PATTERN 14
    ; **********
    REPT 4

    ; 0
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    ; 8
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    ; 10
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL2

    ; 18
    _BASS
    _HH
    _SNARE
    _LHH
    _DEL2

    _HH
    _SNARE
    _LHH
    _DEL1
    _HH
    _DEL1

    _BASS
    _HH
    _HSNARE
    _LHH
    _DEL1
    
    _HH
    _HSNARE
    _DEL1
    _HH
    _HSNARE
    _LHH
    _DEL1
    _HH
    _HSNARE
    _DEL1

    ENDR

    ; **********
    ; PATTERN 15
    ; **********
    REPT 4

    _BASS
    _SNARE
    _DEL2

    _SNARE
    _DEL2
    
    _SNARE
    _DEL2
    
    _SNARE
    _DEL2
    
    ; 8
    _BASS
    _SNARE
    _DEL2

    _SNARE
    _DEL2
    
    _SNARE
    _DEL2
    
    _SNARE
    _DEL2
    
    ; 10
    _BASS
    _SNARE
    _DEL2

    _SNARE
    _DEL2
    
    _SNARE
    _DEL2
    
    _SNARE
    _DEL2

    ; 18
    _BASS
    _SNARE
    _DEL2

    _SNARE
    _DEL2

    _BASS
    _HSNARE
    _DEL1
    _HSNARE
    _DEL1
    _HSNARE
    _DEL1
    _HSNARE
    _DEL1

    ENDR    

    DC.B    $FC, $00
