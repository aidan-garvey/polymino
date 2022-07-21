
; *****************************************************************
; UI_GFX.S
; Grahpics for the user interface / game borders.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

UI_PALETTE:
;             BGR
    DC.W    $0000   ; 0: black/transparent
    DC.W    $0000   ; 1: black
    DC.W    $0EEE   ; 2: white
    DC.W    $048A   ; 3: bronze

    DC.W    $0A46   ; 4: royal purple
    DC.W    $0E84   ; 5: light blue
    DC.W    $0666   ; 6: dark gray
    DC.W    $0888   ; 7: gray

    DC.W    $0AAA   ; 8: light gray
    DC.W    $048A
    DC.W    $048A
    DC.W    $048A

    DC.W    $0A44
    DC.W    $0A44
    DC.W    $0A44
    DC.W    $0A44

UI_SPRITE_CHARS:
    ; cursor during gameplay
GAME_CURSOR_V:
    DC.L    $02121210
    DC.L    $20000001
    DC.L    $10000002
    DC.L    $20000001
    
    DC.L    $10000002
    DC.L    $20000001
    DC.L    $10000002
    DC.L    $20000001

GAME_CURSOR_C:
    DC.L    $21212121
    DC.L    $10000002
    DC.L    $20000001
    DC.L    $10000002

    DC.L    $20000001
    DC.L    $10000002
    DC.L    $20000001
    DC.L    $02121212

GAME_CURSOR_H:
    DC.L    $12121210
    DC.L    $00000001
    DC.L    $00000002
    DC.L    $00000001

    DC.L    $00000002
    DC.L    $00000001
    DC.L    $00000002
    DC.L    $21212120
    
UI_BRDR_CHARS:
    ; expected position in VRAM: $1000 (char 80)
NUM_UI_CHARS EQU 7
UI_BRDR_CORNER_C:   ; 80
    ; top-left corner
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

    DC.L    $55555555
    DC.L    $55555553
    DC.L    $55555534
    DC.L    $55555344

UI_BRDR_3WAY_C:     ; 81
    ; 3-way intersecting corner, _|_
    ; DC.L    $34355343
    DC.L    $44355344
    DC.L    $43555534
    DC.L    $35555553
    DC.L    $55555555

    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

UI_BRDR_V_EDGE_C:     ; 82
    ; left edge
    DC.L    $55555343
    DC.L    $55555343
    DC.L    $55555343
    DC.L    $55555343
    
    DC.L    $55555343
    DC.L    $55555343
    DC.L    $55555343
    DC.L    $55555343

UI_BRDR_H_EDGE_C:   ; 83
    ; bottom edge
    DC.L    $33333333
    DC.L    $44444444
    DC.L    $33333333
    DC.L    $55555555

    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

UI_BRDR_V_SEP_C:    ; 84
    DC.L    $34355343
    DC.L    $34355343
    DC.L    $34355343
    DC.L    $34355343
    
    DC.L    $34355343
    DC.L    $34355343
    DC.L    $34355343
    DC.L    $34355343

UI_FILLER_C:        ; 85
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

UI_DITHER_C:        ; 86
    DC.L    $11110110
    DC.L    $10001110
    DC.L    $01111101
    DC.L    $01101011
    
    DC.L    $11010110
    DC.L    $10111110
    DC.L    $01110001
    DC.L    $01101111

UI_BRDR_PAT:

UI_BRDR_TL:
    DC.W    $8000|UI_GFX_CHAR
UI_BRDR_TR:
    DC.W    $8800|UI_GFX_CHAR
UI_BRDR_BL:
    DC.W    $9000|UI_GFX_CHAR
UI_BRDR_BR:
    DC.W    $9800|UI_GFX_CHAR
UI_BRDR_3WAY_U:
    DC.W    $8000|UI_GFX_CHAR+1
UI_BRDR_3WAY_D:
    DC.W    $9000|UI_GFX_CHAR+1

UI_EDGE_L:
    DC.W    $8000|UI_GFX_CHAR+2
UI_EDGE_R:
    DC.W    $8800|UI_GFX_CHAR+2
UI_EDGE_B:
    DC.W    $8000|UI_GFX_CHAR+3
UI_EDGE_T:
    DC.W    $9000|UI_GFX_CHAR+3
UI_SEP_V:
    DC.W    $8000|UI_GFX_CHAR+4

UI_FILLER:
    DC.W    $8000|UI_GFX_CHAR+5
UI_DITHER:
    DC.W    $0000|UI_GFX_CHAR+6
