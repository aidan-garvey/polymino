
; gray junk uses the UI palette, the others use the blocks palette

JUNK_DARK EQU 6
JUNK_LIGHT EQU 7

JUNK_CHARS:
    ; 6: dark gray
    ; 7: light gray

    ; corner
    DC.L    $06666666
    DC.L    $66667776
    DC.L    $66777777
    DC.L    $67767777

    DC.L    $66777777
    DC.L    $67777777
    DC.L    $67777767
    DC.L    $66777777

    ; top/bottom edge
    DC.L    $66666666
    DC.L    $67776676
    DC.L    $77777777
    DC.L    $77777767

    DC.L    $76777777
    DC.L    $77777777
    DC.L    $77777677
    DC.L    $77777777

    ; left/right edge
    DC.L    $67777777
    DC.L    $67777777
    DC.L    $67776777
    DC.L    $66777777

    DC.L    $66777767
    DC.L    $67777777
    DC.L    $67767777
    DC.L    $66777777

    ; middle block
    DC.L    $77777777
    DC.L    $77777767
    DC.L    $76777777
    DC.L    $77777777

    DC.L    $77777777
    DC.L    $77777677
    DC.L    $77677777
    DC.L    $77777777

JUNK_PATTERNS:
; for each color of junk, there are 4 characters:
; top-left corner, top edge, left edge, middle.

; this gets translated into 9 patterns:
; top-left corner, top-right corner, bottom-left corner, bottom-right corner,
; top edge, bottom edge, left edge, right edge, middle.

; there is a copy of all 9 shared by every colour, and a
; copy for just gray junk, which uses a different palette.

; to make patterns for different colours, add the
; colour index multiplied by 4 to the pattern

JUNK_GRAY:  ; palette: 0 (UI)
    ; top-left
    DC.W    $0000|JUNK_GFX_CHAR
    ; top-right
    DC.W    $0800|JUNK_GFX_CHAR
    ; bottom-left
    DC.W    $1000|JUNK_GFX_CHAR
    ; bottom-right
    DC.W    $1800|JUNK_GFX_CHAR
    ; top
    DC.W    $0000|JUNK_GFX_CHAR+1
    ; bottom
    DC.W    $1000|JUNK_GFX_CHAR+1
    ; left
    DC.W    $0000|JUNK_GFX_CHAR+2
    ; right
    DC.W    $0800|JUNK_GFX_CHAR+2
    ; middle
    DC.W    $0000|JUNK_GFX_CHAR+3

JUNK_COLORED: ; palette: 1 (blocks)
    ; top-left
    DC.W    $2000|JUNK_GFX_CHAR+4
    ; top-right
    DC.W    $2800|JUNK_GFX_CHAR+4
    ; bottom-left
    DC.W    $3000|JUNK_GFX_CHAR+4
    ; bottom-right
    DC.W    $3800|JUNK_GFX_CHAR+4
    ; top
    DC.W    $2000|JUNK_GFX_CHAR+5
    ; bottom
    DC.W    $3000|JUNK_GFX_CHAR+5
    ; left
    DC.W    $2000|JUNK_GFX_CHAR+6
    ; right
    DC.W    $2800|JUNK_GFX_CHAR+6
    ; middle
    DC.W    $2000|JUNK_GFX_CHAR+7
