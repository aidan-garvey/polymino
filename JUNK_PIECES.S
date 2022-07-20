
; *****************************************************************
; JUNK_PIECES.S
; Stores the types of junk pieces that can spawn in.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; For each piece, there is a byte for width and for height.
; Following the dimensions, there are 14 bytes of data which
; indicate the pattern to use for the junk. Some of this data
; may be unused, but for simplicity it will be easier to have
; each piece stored 16B apart.

; The data used for the patterns are indexes into the patterns
; in JUNK_GFX, and -1 indicates an empty tile. Since dimensions
; are given, excess data does not need to be set to -1.

JUNK_PIECES:
    ; 3x2 piece
    DC.B    3, 2
    DC.B    0, 4, 1
    DC.B    2, 5, 3
    ; 8 bytes of filler to align next piece
    DS.B    8

    ; 4x3 L-shaped
    DC.B    4, 3
    DC.B    0, 1, -1, -1
    DC.B    6, 10, 4, 1
    DC.B    2, 5, 5, 3
    DS.B    2
    
    ; 4x2
    DC.B    4, 2
    DC.B    0, 4, 4, 1
    DC.B    2, 5, 5, 3
    DS.B    6

    ; 3x3
    DC.B    3, 3
    DC.B    0, 4, 1
    DC.B    6, 8, 7
    DC.B    2, 5, 3
    DS.B    5
