
; *****************************************************************
; BLOCK_GFX.S
; Graphics for the blocks the player interacts with in the game.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Use as palette 1
;BLOCK_PALETTE:
;    DC.W    $0000   ; 0
;    DC.W    $0C00   ; 1 blue
;    DC.W    $000A   ; 2 red
;    DC.W    $04E2   ; 3 light green

;    DC.W    $00CC   ; 4 yellow
;    DC.W    $008E   ; 5 orange
;    DC.W    $0A0A   ; 6 violet
;    DC.W    $0EC2   ; 7 cyan
    
;    DC.W    $0020   ; 8 dark green
;    DC.W    $0600   ; 9 dark blue
;    DC.W    $0006   ; A dark red
;    DC.W    $0260   ; B green
    
;    DC.W    $0088   ; C dark yellow
;    DC.W    $0048   ; D dark orange
;    DC.W    $0606   ; E dark violet
;    DC.W    $0A60   ; F dark cyan

BLOCK_PALETTE_1:
    DC.W    $0000   ; 0

    DC.W    $0C00   ; 1 light blue
    DC.W    $0800   ; 2 blue
    DC.W    $0400   ; 3 dark blue

    DC.W    $000C   ; 4 light red
    DC.W    $0008   ; 5 red
    DC.W    $0004   ; 6 dark red

    DC.W    $00C6   ; 7 light green
    DC.W    $0084   ; 8 green
    DC.W    $0042   ; 9 dark green

    DC.W    $00CE   ; A light yellow
    DC.W    $00AA   ; B yellow
    DC.W    $0088   ; C dark yellow

    DC.W    $0000   ; D
    DC.W    $0000   ; E
    DC.W    $0000   ; F

BLOCK_PALETTE_2:
    DC.W    $0000   ; 0

    DC.W    $006E   ; 1 light orange
    DC.W    $004A   ; 2 orange
    DC.W    $0026   ; 3 dark orange

    DC.W    $0C0E   ; 4 light pink
    DC.W    $060A   ; 5 pink
    DC.W    $0408   ; 6 dark pink
    
    DC.W    $0C08   ; 7 light purple
    DC.W    $0804   ; 8 purple
    DC.W    $0602   ; 9 dark purple
    
    DC.W    $0CC0   ; A light cyan
    DC.W    $0AA0   ; B cyan
    DC.W    $0880   ; C dark cyan
    
    DC.W    $0000   ; D
    DC.W    $0000   ; E
    DC.W    $0000   ; F

; ----------
; CHARACTERS
; ----------
BLOCK_CHARS:
BLOCK_BLUE:
    DC.L    $22232223
    DC.L    $21132113
    DC.L    $21132113
    DC.L    $33333333

    DC.L    $22232223
    DC.L    $21132113
    DC.L    $21132113
    DC.L    $33333333

BLOCK_RED:
    DC.L    $55444455
    DC.L    $54666645
    DC.L    $46555564
    DC.L    $65555556

    DC.L    $55444455
    DC.L    $54666645
    DC.L    $46555564
    DC.L    $65555556

BLOCK_GREEN:
    DC.L    $99998888
    DC.L    $99988778
    DC.L    $99887778
    DC.L    $98877788

    DC.L    $88777889
    DC.L    $87778899
    DC.L    $87788999
    DC.L    $88889999

BLOCK_YELLOW:
    DC.L    $AAAAABBB
    DC.L    $AAAABBBB
    DC.L    $AAABBBBB
    DC.L    $AABBBBBC
    
    DC.L    $ABBBBBCC
    DC.L    $BBBBBCCC
    DC.L    $BBBBCCCC
    DC.L    $BBBCCCCC
    ;DC.L    $DDDDDEEE
    ;DC.L    $DDDDEEEE
    ;DC.L    $DDDEEEEE
    ;DC.L    $DDEEEEEF

    ;DC.L    $DEEEEEFF
    ;DC.L    $EEEEEFFF
    ;DC.L    $EEEEFFFF
    ;DC.L    $EEEFFFFF

BLOCK_ORANGE:
    DC.L    $21122112
    DC.L    $32111123
    DC.L    $32111123
    DC.L    $33211233
    
    DC.L    $33211233
    DC.L    $32111123
    DC.L    $32111123
    DC.L    $21122112
    ;DC.L    $BAABBAAB
    ;DC.L    $CBAAAABC
    ;DC.L    $CBAAAABC
    ;DC.L    $CCBAABCC

    ;DC.L    $CCBAABCC
    ;DC.L    $CBAAAABC
    ;DC.L    $CBAAAABC
    ;DC.L    $BAABBAAB

BLOCK_VIOLET:
    DC.L    $99999999
    DC.L    $99888899
    DC.L    $99877899
    DC.L    $98877889
    
    DC.L    $98777789
    DC.L    $88777788
    DC.L    $87777778
    DC.L    $88888888
    ;DC.L    $66666666
    ;DC.L    $66555566
    ;DC.L    $66544566
    ;DC.L    $65544556

    ;DC.L    $65444456
    ;DC.L    $55444455
    ;DC.L    $54444445
    ;DC.L    $55555555

BLOCK_TEAL:
    DC.L    $BBBBBBBC
    DC.L    $BBAABBBC
    DC.L    $BAABBAAC
    DC.L    $BBBBAABC
    
    DC.L    $BBBBBBBC
    DC.L    $BBBAABBC
    DC.L    $BBAABBCC
    DC.L    $CCCCCCCC
    ;DC.L    $88888889
    ;DC.L    $88778889
    ;DC.L    $87788779
    ;DC.L    $88887789
    
    ;DC.L    $88888889
    ;DC.L    $88877889
    ;DC.L    $88778899
    ;DC.L    $99999999

BLOCK_PINK:
    DC.L    $66666666
    DC.L    $66555566
    DC.L    $65544556
    DC.L    $65444456
    
    DC.L    $65444456
    DC.L    $65544556
    DC.L    $66555566
    DC.L    $66666666
    ;DC.L    $33333333
    ;DC.L    $33222233
    ;DC.L    $32211223
    ;DC.L    $32111123
    
    ;DC.L    $32111123
    ;DC.L    $32211223
    ;DC.L    $33222233
    ;DC.L    $33333333

; --------
; PATTERNS
; --------
BLOCK_PATTERNS:
PAT_BLUE:
    DC.W    $2000|BLOCK_GFX_CHAR
PAT_RED:
    DC.W    $2000|BLOCK_GFX_CHAR+1
PAT_GREEN:
    DC.W    $2000|BLOCK_GFX_CHAR+2
PAT_YELLOW:
    DC.W    $2000|BLOCK_GFX_CHAR+3
PAT_ORANGE:
    DC.W    $4000|BLOCK_GFX_CHAR+4
PAT_VIOLET:
    DC.W    $4000|BLOCK_GFX_CHAR+5
PAT_TEAL:
    DC.W    $4000|BLOCK_GFX_CHAR+6
PAT_PINK:
    DC.W    $4000|BLOCK_GFX_CHAR+7
