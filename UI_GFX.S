
UI_PALETTE:
;             BGR
    DC.W    $0000   ; 0: black/transparent
    DC.W    $0000   ; 1: black
    DC.W    $0EEE   ; 2: white
    DC.W    $048A   ; 3: bronze

    DC.W    $0A46   ; 4: royal purple
    DC.W    $0E84   ; 5: light blue
    DC.W    $0000   ; 6: black
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
NUM_UI_CHARS = 7
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
    DC.L    $66660660
    DC.L    $60006660
    DC.L    $06666606
    DC.L    $06606066
    
    DC.L    $66060660
    DC.L    $60666660
    DC.L    $06660006
    DC.L    $06606666

; UI_DITHER_C:        ; 86
    DC.L    $00660066
    DC.L    $06600660
    DC.L    $66006600
    DC.L    $60066006
    
    DC.L    $00660066
    DC.L    $06600660
    DC.L    $66006600
    DC.L    $60066006

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

UI_EDGE_L:
    DC.W    $0082
UI_EDGE_R:
    DC.W    $0882
UI_EDGE_B:
    DC.W    $0083
UI_EDGE_T:
    DC.W    $1083
UI_SEP_V:
    DC.W    $0084

UI_FILLER:
    DC.W    $0085
UI_DITHER:
    DC.W    $0086
