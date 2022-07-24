
; *****************************************************************
; GFX_OUTLINE.S
; Graphics for the sprites that outline where junk will drop.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Characters use UI_PALETTE (GFX_UI.S)

OUTLINE_CHARS:
    ; 0: top-left
    DC.L    $0AB00BA9
    DC.L    $A0000000
    DC.L    $B0000000
    DC.L    $00000000

    DC.L    $00000000
    DC.L    $B0000000
    DC.L    $A0000000
    DC.L    $90000000

    ; 1: top-right
    DC.L    $9AB00BA0
    DC.L    $0000000A
    DC.L    $0000000B
    DC.L    $00000000

    DC.L    $00000000
    DC.L    $0000000B
    DC.L    $0000000A
    DC.L    $00000009

    ; 2: bottom-left
    DC.L    $90000000
    DC.L    $A0000000
    DC.L    $B0000000
    DC.L    $00000000

    DC.L    $00000000
    DC.L    $B0000000
    DC.L    $A0000000
    DC.L    $0AB00BA9

    ; 3: bottom-right
    DC.L    $00000009
    DC.L    $0000000A
    DC.L    $0000000B
    DC.L    $00000000

    DC.L    $00000000
    DC.L    $0000000B
    DC.L    $0000000A
    DC.L    $9AB00BA0

    ; 4: top
    DC.L    $9AB00BA9
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 5: bottom
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $9AB00BA9

    ; 6: left
    DC.L    $90000000
    DC.L    $A0000000
    DC.L    $B0000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $B0000000
    DC.L    $A0000000
    DC.L    $90000000
    
    ; 7: right
    DC.L    $00000009
    DC.L    $0000000A
    DC.L    $0000000B
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $0000000B
    DC.L    $0000000A
    DC.L    $00000009
