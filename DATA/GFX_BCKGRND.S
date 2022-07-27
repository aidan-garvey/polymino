
; *******************************************************************
; GFX_BCKGRND.S
; Contains graphics for the game's backgrounds shown during gameplay.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *******************************************************************

BCKGND_PAL:
            ; BGR
    DC.W    $0000 ; 0: black/transparent
    DC.W    $0EEE ; 1: white
    DC.W    $0CCC ; 2: v. light gray
    DC.W    $0C88 ; 3: mauve
    
    DC.W    $08AE ; 4: v. light red
    DC.W    $0CA8 ; 5: v. light blue
    DC.W    $0A64 ; 6: light blue
    DC.W    $0842 ; 7: blue

    DC.W    $0420 ; 8: dark blue
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

BCKGND_CHARS:
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
    DC.L    $03300000
    DC.L    $03300000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 2: WATERFALL
    DC.L    $78888877
    DC.L    $77887776
    DC.L    $67777766
    DC.L    $66776665

    DC.L    $56666651
    DC.L    $15665518
    DC.L    $81551188
    DC.L    $88118887

; --------
; PATTERNS
; --------
; uses palette 3

LARGE_STAR_PATTERN:
    DC.W    $6000|BCKGND_GFX_CHAR
SMALL_STAR_PATTERN:
    DC.W    $6000|BCKGND_GFX_CHAR+1
WATERFALL_1_PATTERN:
    DC.W    $6000|BCKGND_GFX_CHAR+2
WATERFALL_2_PATTERN:
    DC.W    $6800|BCKGND_GFX_CHAR+2
