
UI_PALETTE:
;             BGR
    DC.W    $0000   ; 0: black/transparent
    DC.W    $0000   ; 1: black
    DC.W    $0EEE   ; 2: white
    DC.W    $048A   ; 3: bronze

    DC.W    $0A44   ; 4: royal purple
    DC.W    $0E82   ; 5: light blue
    DC.W    $0EEE
    DC.W    $0EEE

    ; dotted lines, colours will be swapped to create movement effect
    DC.W    $048A
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
UI_BRDR_CORNER_C:   ; 80
    ; top-left corner
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555333
    DC.L    $55533444

    DC.L    $55534433
    DC.L    $55344300
    DC.L    $55343000
    DC.L    $55343000

UI_BRDR_3WAY_C:     ; 81
    ; 3-way intersecting corner, _|_
    DC.L    $00344300
    DC.L    $00344300
    DC.L    $03444430
    DC.L    $34433443

    DC.L    $44355344
    DC.L    $33555533
    DC.L    $55555555
    DC.L    $55555555

UI_FILLER_C:        ; 82
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555
    DC.L    $55555555

UI_BRDR_PAT:

UI_BRDR_TL:
    DC.W    $0080
UI_BRDR_TR:
    DC.W    $0880
UI_BRDR_BL:
    DC.W    $1080
UI_BRDR_BR:
    DC.W    $1880

UI_BRDR_3WAY_U:
    DC.W    $0081
UI_BRDR_3WAY_D:
    DC.W    $1081

UI_FILLER:
    DC.W    $0082
