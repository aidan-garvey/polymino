
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
EIF_SNARE1:
    INCBIN  AUDIO/EIF/snare1.eif
EIF_BASS1:
    INCBIN  AUDIO/EIF/bass1.eif
EIF_BASS3:
    INCBIN  AUDIO/EIF/bass3.eif
EIF_SNARE2:
    INCBIN  AUDIO/EIF/snare2.eif
EIF_LATEHIHAT:
    INCBIN  AUDIO/EIF/latehihat.eif
EWF_CLAP:
    INCBIN  AUDIO/EWF/clap.ewf
EWF_HIHAT:
    INCBIN  AUDIO/EWF/hh.ewf


INSTRUMENT_LIST:
    Echo_ListEntry EIF_HIHAT    ; 0
    Echo_ListEntry EIF_DFGDFG   ; 1
    Echo_ListEntry EIF_BASS2    ; 2
    Echo_ListEntry EIF_NOISE    ; 3
    Echo_ListEntry EIF_LONGHIHAT; 4
    Echo_ListEntry EIF_SHORT    ; 5
    Echo_ListEntry EWF_CRUNCH   ; 6
    Echo_ListEntry EEF_FLAT     ; 7
    Echo_ListEntry EEF_FADE     ; 8
    Echo_ListEntry EIF_SNARE1   ; 9
    Echo_ListEntry EIF_BASS1    ; A
    Echo_ListEntry EIF_BASS3    ; B
    Echo_ListEntry EIF_SNARE2   ; C
    Echo_ListEntry EIF_LATEHIHAT; D
    Echo_ListEntry EWF_CLAP     ; E
    Echo_ListEntry EWF_HIHAT    ; F
    Echo_ListEnd
