
; Use as palette 1
BLOCK_PALETTE:
    DC.W    $0000   ; 0
    DC.W    $0C00   ; 1 blue
    DC.W    $000A   ; 2 red
    DC.W    $04E2   ; 3 light green

    DC.W    $00CC   ; 4 yellow
    DC.W    $008E   ; 5 orange
    DC.W    $0A0A   ; 6 violet
    DC.W    $0EC2   ; 7 cyan
    
    DC.W    $0020   ; 8 dark green
    DC.W    $0600   ; 9 dark blue
    DC.W    $0006   ; A dark red
    DC.W    $0260   ; B green
    
    DC.W    $0088   ; C dark yellow
    DC.W    $0048   ; D dark orange
    DC.W    $0606   ; E dark violet
    DC.W    $0A60   ; F dark cyan

; ----------
; CHARACTERS
; ----------
; Copy into VRAM starting at $20 ($0 is blank)
BLOCK_CHARS:
BLOCK_BLUE:
    DC.L    $99999999
    DC.L    $91111119
    DC.L    $91111119
    DC.L    $91111119

    DC.L    $91111119
    DC.L    $91111119
    DC.L    $91111119
    DC.L    $99999999

BLOCK_RED:
    DC.L    $AAAAAAAA
    DC.L    $A222222A
    DC.L    $A222222A
    DC.L    $A222222A

    DC.L    $A222222A
    DC.L    $A222222A
    DC.L    $A222222A
    DC.L    $AAAAAAAA

BLOCK_GREEN:
    DC.L    $BBBBBBBB
    DC.L    $B333333B
    DC.L    $B333333B
    DC.L    $B333333B
    
    DC.L    $B333333B
    DC.L    $B333333B
    DC.L    $B333333B
    DC.L    $BBBBBBBB

BLOCK_YELLOW:
    DC.L    $CCCCCCCC
    DC.L    $C444444C
    DC.L    $C444444C
    DC.L    $C444444C

    DC.L    $C444444C
    DC.L    $C444444C
    DC.L    $C444444C
    DC.L    $CCCCCCCC

BLOCK_ORANGE:
    DC.L    $DDDDDDDD
    DC.L    $D555555D
    DC.L    $D555555D
    DC.L    $D555555D

    DC.L    $D555555D
    DC.L    $D555555D
    DC.L    $D555555D
    DC.L    $DDDDDDDD

BLOCK_VIOLET:
    DC.L    $EEEEEEEE
    DC.L    $E666666E
    DC.L    $E666666E
    DC.L    $E666666E

    DC.L    $E666666E
    DC.L    $E666666E
    DC.L    $E666666E
    DC.L    $EEEEEEEE

BLOCK_TEAL:
    DC.L    $FFFFFFFF
    DC.L    $F777777F
    DC.L    $F777777F
    DC.L    $F777777F

    DC.L    $F777777F
    DC.L    $F777777F
    DC.L    $F777777F
    DC.L    $FFFFFFFF

BLOCK_DGREEN:
    DC.L    $88888888
    DC.L    $8BBBBBB8
    DC.L    $8BBBBBB8
    DC.L    $8BBBBBB8

    DC.L    $8BBBBBB8
    DC.L    $8BBBBBB8
    DC.L    $8BBBBBB8
    DC.L    $88888888

; --------
; PATTERNS
; --------
BLOCK_PATTERNS:
PAT_BLUE:
    DC.W    $2001
PAT_RED:
    DC.W    $2002
PAT_GREEN:
    DC.W    $2003
PAT_YELLOW:
    DC.W    $2004
PAT_ORANGE:
    DC.W    $2005
PAT_VIOLET:
    DC.W    $2006
PAT_TEAL:
    DC.W    $2007
PAT_PINK:
    DC.W    $2008
