
; *****************************************************************
; JUNK_GFX.S
; Graphics for the junk pieces that the player must shatter.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; gray junk uses the UI palette, the others use the blocks palette

JUNK_CHARS:
    ; 6: dark gray
    ; 7: gray
    ; 8: light gray

    ; outer corner
    DC.L    $06666666
    DC.L    $66667776
    DC.L    $66777777
    DC.L    $67767888

    DC.L    $66777878
    DC.L    $67778888
    DC.L    $67788788
    DC.L    $66788888

    ; top/bottom edge
    DC.L    $66666666
    DC.L    $67776676
    DC.L    $77677777
    DC.L    $78877877

    DC.L    $88887888
    DC.L    $87888888
    DC.L    $88888878
    DC.L    $88888888

    ; left/right edge
    DC.L    $67788888
    DC.L    $67788788
    DC.L    $67778888
    DC.L    $66778887

    DC.L    $66778888
    DC.L    $67788888
    DC.L    $67778878
    DC.L    $66778888

    ; middle
    DC.L    $88888888
    DC.L    $88888788
    DC.L    $88888888
    DC.L    $88888888
    
    DC.L    $87888888
    DC.L    $88888888
    DC.L    $88887888
    DC.L    $88888888

    ; inner corner
    DC.L    $67788888
    DC.L    $67788788
    DC.L    $77888888
    DC.L    $78888888
    
    DC.L    $88888888
    DC.L    $88788888
    DC.L    $88888878
    DC.L    $88888888

    ; corner
    ;DC.L    $06666666
    ;DC.L    $66667776
    ;DC.L    $66777777
    ;DC.L    $67767777

    ;DC.L    $66777777
    ;DC.L    $67777777
    ;DC.L    $67777767
    ;DC.L    $66777777

    ; top/bottom edge
    ;DC.L    $66666666
    ;DC.L    $67776676
    ;DC.L    $77777777
    ;DC.L    $77777767

    ;DC.L    $76777777
    ;DC.L    $77777777
    ;DC.L    $77777677
    ;DC.L    $77777777

    ; left/right edge
    ;DC.L    $67777777
    ;DC.L    $67777777
    ;DC.L    $67776777
    ;DC.L    $66777777

    ;DC.L    $66777767
    ;DC.L    $67777777
    ;DC.L    $67767777
    ;DC.L    $66777777

    ; middle block
    ;DC.L    $77777777
    ;DC.L    $77777767
    ;DC.L    $76777777
    ;DC.L    $77777777

    ;DC.L    $77777777
    ;DC.L    $77777677
    ;DC.L    $77677777
    ;DC.L    $77777777

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
    ; 0: top-left outer
    DC.W    $0000|JUNK_GFX_CHAR
    ; 1: top-right outer
    DC.W    $0800|JUNK_GFX_CHAR
    ; 2: bottom-left outer
    DC.W    $1000|JUNK_GFX_CHAR
    ; 3: bottom-right outer
    DC.W    $1800|JUNK_GFX_CHAR
    ; 4: top
    DC.W    $0000|JUNK_GFX_CHAR+1
    ; 5: bottom
    DC.W    $1800|JUNK_GFX_CHAR+1
    ; 6: left
    DC.W    $0000|JUNK_GFX_CHAR+2
    ; 7: right
    DC.W    $1800|JUNK_GFX_CHAR+2
    ; 8: middle
    DC.W    $0000|JUNK_GFX_CHAR+3
    ; 9: top-left inner
    DC.W    $0000|JUNK_GFX_CHAR+4
    ; A: top-right inner
    DC.W    $0800|JUNK_GFX_CHAR+4
    ; B: bottom-left inner
    DC.W    $1000|JUNK_GFX_CHAR+4
    ; C: bottom-right inner
    DC.W    $1800|JUNK_GFX_CHAR+4

JUNK_PAL1: ; palette: 1 (blocks)
    ; 0: top-left
    DC.W    $2000|JUNK_GFX_CHAR+5
    ; 1: top-right
    DC.W    $2800|JUNK_GFX_CHAR+5
    ; 2: bottom-left
    DC.W    $3000|JUNK_GFX_CHAR+5
    ; 3: bottom-right
    DC.W    $3800|JUNK_GFX_CHAR+5
    ; 4: top
    DC.W    $2000|JUNK_GFX_CHAR+6
    ; 5: bottom
    DC.W    $3800|JUNK_GFX_CHAR+6
    ; 6: left
    DC.W    $2000|JUNK_GFX_CHAR+7
    ; 7: right
    DC.W    $3800|JUNK_GFX_CHAR+7
    ; 8: middle
    DC.W    $2000|JUNK_GFX_CHAR+8
    ; 9: top-left inner
    DC.W    $2000|JUNK_GFX_CHAR+9
    ; A: top-right inner
    DC.W    $2800|JUNK_GFX_CHAR+9
    ; B: bottom-left inner
    DC.W    $3000|JUNK_GFX_CHAR+9
    ; C: bottom-right inner
    DC.W    $3800|JUNK_GFX_CHAR+9

JUNK_PAL2: ; palette: 2 (blocks)
    ; 0: top-left
    DC.W    $4000|JUNK_GFX_CHAR+5
    ; 1: top-right
    DC.W    $4800|JUNK_GFX_CHAR+5
    ; 2: bottom-left
    DC.W    $5000|JUNK_GFX_CHAR+5
    ; 3: bottom-right
    DC.W    $5800|JUNK_GFX_CHAR+5
    ; 4: top
    DC.W    $4000|JUNK_GFX_CHAR+6
    ; 5: bottom
    DC.W    $5800|JUNK_GFX_CHAR+6
    ; 6: left
    DC.W    $4000|JUNK_GFX_CHAR+7
    ; 7: right
    DC.W    $5800|JUNK_GFX_CHAR+7
    ; 8: middle
    DC.W    $4000|JUNK_GFX_CHAR+8
    ; 9: top-left inner
    DC.W    $4000|JUNK_GFX_CHAR+9
    ; A: top-right inner
    DC.W    $4800|JUNK_GFX_CHAR+9
    ; B: bottom-left inner
    DC.W    $5000|JUNK_GFX_CHAR+9
    ; C: bottom-right inner
    DC.W    $5800|JUNK_GFX_CHAR+9
