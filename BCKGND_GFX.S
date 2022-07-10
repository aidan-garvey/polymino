
BCKGND_NIGHT_PAL:
            ; BGR
    DC.W    $0000 ; 0: black/transparent
    DC.W    $0EEE ; 1: white
    DC.W    $0CCC ; 2: v. light gray
    DC.W    $0AAA ; 3: light gray
    
    DC.W    $0000 ; 4: black
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
    DC.W    $0000

; ----------
; CHARACTERS
; ----------
; expected position in VRAM: $2000

BCKGND_NIGHT_CHARS:
    ; 0: LARGE STAR
    DC.L    $00030000
    DC.L    $00030000
    DC.L    $00323000
    DC.L    $33212330
    DC.L    $00323000
    DC.L    $00030000
    DC.L    $00030000
    DC.L    $00000000

    ; 1: SMALL STAR
    DC.L    $00000000
    DC.L    $00300000
    DC.L    $03230000
    DC.L    $00300000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

; --------
; PATTERNS
; --------
; uses palette 3
; uses chars starting at cell $100

LARGE_STAR_PATTERN:
    DC.W    $6100
SMALL_STAR_PATTERN:
    DC.W    $6101

