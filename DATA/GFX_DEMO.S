
; *****************************************************************
; GFX_UI.S
; Graphics only used during the "how to play" demo.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

DEMO_DPAD_CHARS:
    ; vertical unpressed
    DC.L    $00000000
    DC.L    $0000FFFF
    DC.L    $0000FEEE
    DC.L    $0000FEEE

    DC.L    $0000FEEE
    DC.L    $0000FEEE
    DC.L    $0000FEEE
    DC.L    $0000FEEE

    ; horizontal unpressed
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $0FFFFFFF
    DC.L    $0FEEEEEE
    DC.L    $0FEEEEEE
    DC.L    $0FEEEEEE

    ; centre
    DC.L    $0000FEEE
    DC.L    $0000FEEE
    DC.L    $0000FEEE
    DC.L    $0000FEEE
    
    DC.L    $FFFFFEEE
    DC.L    $EEEEEEEE
    DC.L    $EEEEEEEF
    DC.L    $EEEEEEFF

    ; vertical pressed
    DC.L    $00000000
    DC.L    $0000FFFF
    DC.L    $0000FEEE
    DC.L    $0000FEEC

    DC.L    $0000FECD
    DC.L    $0000FECD
    DC.L    $0000FEEC
    DC.L    $0000FEEE

    ; horizontal pressed
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $0FFFFFFF
    DC.L    $0FEEEEEE
    DC.L    $0FEECCEE
    DC.L    $0FECDDCE

DEMO_BUTTON_CHARS:
    ; placeholders for now

    ; A unpressed
    DC.L    $000000EE
    DC.L    $0000EE66
    DC.L    $000E6666
    DC.L    $00E66666

    DC.L    $0E666666
    DC.L    $0E666666
    DC.L    $E6666666
    DC.L    $E6666666

    ; A pressed
    DC.L    $00000066
    DC.L    $00006677
    DC.L    $00067777
    DC.L    $00677777

    DC.L    $06777777
    DC.L    $06777777
    DC.L    $67777777
    DC.L    $67777777

    ; B unpressed
    DC.L    $000000EE
    DC.L    $0000EE66
    DC.L    $000E6666
    DC.L    $00E66666

    DC.L    $0E666666
    DC.L    $0E666666
    DC.L    $E6666666
    DC.L    $E6666666

    ; B pressed
    DC.L    $00000066
    DC.L    $00006677
    DC.L    $00067777
    DC.L    $00677777

    DC.L    $06777777
    DC.L    $06777777
    DC.L    $67777777
    DC.L    $67777777
    
    ; C unpressed
    DC.L    $000000EE
    DC.L    $0000EE66
    DC.L    $000E6666
    DC.L    $00E66666

    DC.L    $0E666666
    DC.L    $0E666666
    DC.L    $E6666666
    DC.L    $E6666666

    ; C pressed
    DC.L    $00000066
    DC.L    $00006677
    DC.L    $00067777
    DC.L    $00677777

    DC.L    $06777777
    DC.L    $06777777
    DC.L    $67777777
    DC.L    $67777777

; add 3 to a pattern to press
DEMO_DPAD_PATS:
    ; row 1
    DC.W    0
    DC.W    DEMO_GFX_CHAR
    DC.W    $0800|DEMO_GFX_CHAR
    DC.W    0
    ; row 2
    DC.W    DEMO_GFX_CHAR+1
    DC.W    DEMO_GFX_CHAR+2
    DC.W    $0800|DEMO_GFX_CHAR+2
    DC.W    $0800|DEMO_GFX_CHAR+1
    ; row 3
    DC.W    $1000|DEMO_GFX_CHAR+1
    DC.W    $1000|DEMO_GFX_CHAR+2
    DC.W    $1800|DEMO_GFX_CHAR+2
    DC.W    $1800|DEMO_GFX_CHAR+1
    ; row 4
    DC.W    0
    DC.W    $1000|DEMO_GFX_CHAR
    DC.W    $1800|DEMO_GFX_CHAR
    DC.W    0

; add 1 to press
DEMO_A_PATS:
    DC.W    DEMO_GFX_CHAR+5
    DC.W    $0800|DEMO_GFX_CHAR+5
    DC.W    $1000|DEMO_GFX_CHAR+5
    DC.W    $1800|DEMO_GFX_CHAR+5

; add 1 to press
DEMO_B_PATS:
    DC.W    DEMO_GFX_CHAR+7
    DC.W    $0800|DEMO_GFX_CHAR+7
    DC.W    $1000|DEMO_GFX_CHAR+7
    DC.W    $1800|DEMO_GFX_CHAR+7

; add 1 to press
DEMO_C_PATS:
    DC.W    DEMO_GFX_CHAR+9
    DC.W    $0800|DEMO_GFX_CHAR+9
    DC.W    $1000|DEMO_GFX_CHAR+9
    DC.W    $1800|DEMO_GFX_CHAR+9
