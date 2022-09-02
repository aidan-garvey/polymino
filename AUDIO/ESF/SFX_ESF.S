
; *****************************************************************
; SFX_ESF.S
; ESF data for sound effects used by Echo sound engine.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

ESF_CRUNCH:
    DC.B    $E6     ; lock PCM channel (FM channel #6)
    DC.B    $1C     ; note off PCM
    DC.W    $0C06   ; play sound effect
    DC.B    $FE, 30 ; delay 30 frames - sample is half a second
    DC.B    $FF     ; end stream, unlocks PCM channel

ESF_SELECT:
ESF_CLAP:
    DC.B    $E6
    DC.B    $1C
    DC.W    $0C0E
    DC.B    $DE
    DC.B    $FF

ESF_EXIT:
    DC.B    $E6
    DC.B    $1C
    DC.W    $0C0F
    DC.B    $FE, 20
    DC.B    $FF

;ESF_SELECT:
    DC.B    $EB     ; lock PSG #4
    DC.B    $1B     ; note off
    DC.W    $4B08   ; EEF_FADE
    DC.W    $0B06   ; note on
    DC.B    $DE
    DC.B    $FF

;ESF_TEST:
;    DC.B    $EB     ; lock noise channel
;    DC.B    $1B     ; note off
;    DC.W    $4B08   ; select instrument (EEF_FADE)
;    DC.W    $2B00   ; pump up da volume
;    DC.W    $0B04   ; note on, white noise high pitch
;    DC.W    $FE20   ; play for 20 ticks (1/3 second)
;    DC.B    $FF     ; end playback
