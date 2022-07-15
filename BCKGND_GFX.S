
; *******************************************************************
; BCKGND_GFX.S
; Contains graphics for the game's backgrounds shown during gameplay.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *******************************************************************

BCKGND_NIGHT_PAL:
            ; BGR
    DC.W    $0000 ; 0: black/transparent
    DC.W    $0EEE ; 1: white
    DC.W    $0CCC ; 2: v. light gray
    DC.W    $0EAA ; 3: v. light blue
    
    DC.W    $08AE ; 4: v. light red
    DC.W    $0C88 ; 5: light blue
    DC.W    $0000
    DC.W    $0000
    
    DC.W    $0000
    DC.W    $0000
    DC.W    $0000
    DC.W    $0000
    
    DC.W    $0000
    DC.W    $0000
    DC.W    $0000
    DC.W    $0000

; ----------
; CHARACTERS
; ----------

BCKGND_NIGHT_CHARS:
    ; 0: LARGE DOT
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00044000
    DC.L    $00422400

    DC.L    $00422400
    DC.L    $00044000
    DC.L    $00000000
    DC.L    $00000000

    ; 1: SMALL DOT
    DC.L    $00000000
    DC.L    $05500000
    DC.L    $05500000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

; --------
; PATTERNS
; --------
; uses palette 3

LARGE_STAR_PATTERN:
    DC.W    $6000|BCKGND_GFX_CHAR
SMALL_STAR_PATTERN:
    DC.W    $6000|BCKGND_GFX_CHAR+1

