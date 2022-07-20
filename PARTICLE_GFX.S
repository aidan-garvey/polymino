
; *****************************************************************
; PARTICLE_GFX.S
; Graphics for particle effect sprites.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; These characters use the same palettes as blocks (see BLOCK_GFX.S)
; As a result, each one can appear as two colours.

PROJECTILE_CHARS:
    ; blue / orange
    DC.L    $00000000
    DC.L    $00111100
    DC.L    $01122110
    DC.L    $11233211

    DC.L    $12300321
    DC.L    $23000032
    DC.L    $30000003
    DC.L    $00000000

    ; red / pink
    DC.L    $00000000
    DC.L    $00444400
    DC.L    $04455440
    DC.L    $44566544

    DC.L    $45600654
    DC.L    $56000065
    DC.L    $60000006
    DC.L    $00000000

    ; green / purple
    DC.L    $00000000
    DC.L    $00777700
    DC.L    $07788770
    DC.L    $77899877

    DC.L    $78900987
    DC.L    $89000098
    DC.L    $90000009
    DC.L    $00000000

    ; yellow / teal
    DC.L    $00000000
    DC.L    $00AAAA00
    DC.L    $0AABBAA0
    DC.L    $AABCCBAA

    DC.L    $ABC00CBA
    DC.L    $BC0000CB
    DC.L    $C000000C
    DC.L    $00000000
