
UI_PALETTE:
;             BGR
    DC.W    $0000   ; black/transparent
    DC.W    $0000   ; black
    DC.W    $0EEE   ; white
    DC.W    $048A   ; bronze

    DC.W    $0A44   ; bronzer?
    DC.W    $0EEE
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

UI_CHARS:
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
    
