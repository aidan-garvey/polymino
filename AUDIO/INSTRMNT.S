
; *****************************************************************
; INSTRMNT.S
; Includes the instrument data for use by Echo sound engine.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

EIF_HIHAT:
    INCBIN  AUDIO/EIF/hihat.eif
EIF_DFGDFG:
    INCBIN  AUDIO/EIF/dfgdfg.eif
EIF_BASS2:
    INCBIN  AUDIO/EIF/bass2.eif
EIF_NOISE:
    INCBIN  AUDIO/EIF/noise.eif
EIF_LONGHIHAT:
    INCBIN  AUDIO/EIF/longhihat.eif
EIF_SHORT:
    INCBIN  AUDIO/EIF/short.eif
EWF_CRUNCH:
    INCBIN  AUDIO/EWF/crunch.ewf
EEF_FLAT:
    DC.B    $FE, $00, $FF
EEF_FADE:
    ; initial attack
    DC.B    $08, $04, $00
    ; fade-out
    DC.B    $01, $02, $03, $04, $05
    DC.B    $06, $06, $07, $07, $08, $08, $09, $09
    DC.B    $FE, $0A, $FF

INSTRUMENT_LIST:
    Echo_ListEntry EIF_HIHAT
    Echo_ListEntry EIF_DFGDFG
    Echo_ListEntry EIF_BASS2
    Echo_ListEntry EIF_NOISE
    Echo_ListEntry EIF_LONGHIHAT
    Echo_ListEntry EIF_SHORT
    Echo_ListEntry EWF_CRUNCH
    Echo_ListEntry EEF_FLAT
    Echo_ListEntry EEF_FADE
    Echo_ListEnd
