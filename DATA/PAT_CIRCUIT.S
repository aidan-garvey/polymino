
; *****************************************************************
; PAT_CICUIT.S
; Patterns used to construct the circuit board background.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; see REF_CIRCUIT.S for characters referenced here
; add the palette bits into each pattern before transferring to VRAM
CIRC_PATTERNS:
    ; row 0
    DCB.W   7, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$A 
    DS.W    8
    DC.W    CIRC_CHAR+1
    DS.W    16
    DC.W    CIRC_CHAR+$17
    DS.W    6

    ; row 1
    DS.W    7
    DC.W    CIRC_CHAR+9
    DS.W    8
    DC.W    CIRC_CHAR+1
    DS.W    16
    DC.W    CIRC_CHAR+$17
    DS.W    6

    ; row 2
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$12
    DC.W    CIRC_CHAR+$11
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    8
    DC.W    CIRC_CHAR+1
    DS.W    10
    DC.W    CIRC_CHAR+$18
    DCB.W   5, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$1B
    DS.W    6

    ; row 3
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$15
    DCB.W   2, CIRC_CHAR
    DC.W    CIRC_CHAR+3
    DC.W    CIRC_CHAR+9
    DS.W    8
    DC.W    CIRC_CHAR+1
    DS.W    10
    DC.W    CIRC_CHAR+$17
    DS.W    12

    ; row 4
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$12
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    2
    DC.W    CIRC_CHAR+1
    DC.W    CIRC_CHAR+9
    DS.W    8
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$12
    DC.W    CIRC_CHAR+$11
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    12

    ; row 5
    DS.W    6
    DC.W    CIRC_CHAR+1
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+2
    DCB.W   5, CIRC_CHAR
    DC.W    CIRC_CHAR+6
    DCB.W   3, CIRC_CHAR
    DC.W    $0800|CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$E
    DCB.W   4, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$1E
    DCB.W   5, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$A 
    DS.W    6

    ; row 6
    DS.W    6
    DC.W    CIRC_CHAR+1
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+1
    DS.W    9
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$20
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    2
    DC.W    CIRC_CHAR+$18
    DCB.W   2, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$19
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 7
    DS.W    6
    DC.W    CIRC_CHAR+1
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$14
    DC.W    CIRC_CHAR+$11
    DS.W    9
    DC.W    CIRC_CHAR+$17
    DS.W    3
    DC.W    CIRC_CHAR+$17
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 8
    DS.W    3
    DC.W    CIRC_CHAR+2
    DCB.W   2, CIRC_CHAR
    DC.W    CIRC_CHAR+5
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    9
    DC.W    CIRC_CHAR+$17
    DS.W    3
    DC.W    CIRC_CHAR+$17
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    4
    DC.W    CIRC_CHAR+$1F
    DCB.W   2, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$19
    DS.W    3

    ; row 9
    DS.W    3
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    9
    DC.W    CIRC_CHAR+$17
    DS.W    3
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$20
    DC.W    CIRC_CHAR+$11
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    3

    ; row 10
    DS.W    3
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    6
    DC.W    CIRC_CHAR+2
    DC.W    CIRC_CHAR
    DC.W    CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$1B
    DS.W    3
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    3

    ; row 11
    DS.W    3
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$14
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    6
    DC.W    CIRC_CHAR+1
    DS.W    6
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$20
    DC.W    CIRC_CHAR+$11
    DS.W    2

    ; row 12
    DS.W    3
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+1
    DS.W    7
    DC.W    CIRC_CHAR+1
    DS.W    6
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$21
    DCB.W   2, CIRC_CHAR+$16

    ; row 13
    DS.W    1
    DC.W    CIRC_CHAR+2
    DC.W    CIRC_CHAR
    DC.W    CIRC_CHAR+6
    DC.W    CIRC_CHAR
    DC.W    CIRC_CHAR+3
    DS.W    1
    DC.W    CIRC_CHAR+$C 
    DCB.W   2, CIRC_CHAR
    DC.W    CIRC_CHAR+5
    DS.W    7
    DC.W    CIRC_CHAR+1
    DS.W    6
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$13
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$20
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    2

    ; row 14
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$F 
    DC.W    CIRC_CHAR+$11
    DS.W    9
    DC.W    CIRC_CHAR+7
    DC.W    CIRC_CHAR
    DCB.W   5, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$1B
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$20
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    3

    ; row 15
    DC.W    CIRC_CHAR+8
    DC.W    CIRC_CHAR+$B 
    DCB.W   3, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$B 
    DC.W    CIRC_CHAR+$D 
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$E 
    DCB.W   7, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$A 
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    9
    DC.W    CIRC_CHAR+$17
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    3

    ; row 16
    DS.W    6
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$14
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    7
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    9
    DC.W    CIRC_CHAR+$17
    DS.W    4
    DC.W    CIRC_CHAR+$1F
    DCB.W   2, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$1B 
    DS.W    3

    ; row 17
    DS.W    7
    DC.W    CIRC_CHAR+1
    DS.W    8
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    2
    DC.W    CIRC_CHAR+$18
    DCB.W   6, CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$1B 
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 18
    DS.W    7
    DC.W    CIRC_CHAR+4
    DCB.W   4, CIRC_CHAR
    DC.W    CIRC_CHAR+3
    DS.W    3
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    11
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 19
    DS.W    12
    DC.W    CIRC_CHAR+1
    DS.W    3
    DC.W    CIRC_CHAR+$C 
    DC.W    CIRC_CHAR 
    DC.W    CIRC_CHAR+5
    DS.W    2
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$11)<<16)|CIRC_CHAR+$11
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 20
    DS.W    10
    DC.W    CIRC_CHAR+2
    DC.W    CIRC_CHAR
    DC.W    CIRC_CHAR+6
    DC.W    CIRC_CHAR
    DC.W    CIRC_CHAR+3
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$21
    DC.W    $0800|CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$21
    DC.W    $0800|CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 21
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$11
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$11
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$11
    DC.W    CIRC_CHAR+1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$11
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$13)<<16)|CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+$18
    DCB.W   4, CIRC_CHAR+$16
    
    ; row 22
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$15
    DC.W    CIRC_CHAR
    DC.W    $0800|CIRC_CHAR+$15
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$15
    DC.W    CIRC_CHAR+6
    DC.W    $0800|CIRC_CHAR+$15
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$13)<<16)|CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+$17
    DS.W    4

    ; row 23
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$13)<<16)|CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+$17
    DS.W    4

    ; row 24
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$13)<<16)|CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    1
    DC.W    CIRC_CHAR+$1A
    DCB.W   4, CIRC_CHAR+$16

    ; row 25
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($0800|CIRC_CHAR+$13)<<16)|CIRC_CHAR+$13
    DS.W    4
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 26
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$21
    DC.W    $0800|CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$21
    DC.W    $0800|CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$21
    DC.W    CIRC_CHAR+$16
    DC.W    CIRC_CHAR+$19
    DS.W    2
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 27
    DS.W    2
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$15
    DC.W    CIRC_CHAR
    DC.W    $0800|CIRC_CHAR+$15
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$13
    DC.W    CIRC_CHAR+$13
    DS.W    1
    DC.W    CIRC_CHAR+1
    DS.W    1
    DC.W    CIRC_CHAR+9
    DS.W    4
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DCB.L   3, (($1800|CIRC_CHAR+$11)<<16)|$1000|CIRC_CHAR+$11
    DS.W    1
    DC.W    CIRC_CHAR+$17
    DS.W    2
    DC.W    CIRC_CHAR+9
    DS.W    6

    ; row 28
    DS.W    2
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    1
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    1
    DC.W    CIRC_CHAR+1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$F 
    DC.W    CIRC_CHAR+$11
    DS.W    3
    DC.W    CIRC_CHAR+$17
    DS.W    8
    DC.W    CIRC_CHAR+$17
    DS.W    1
    DC.W    $0800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$F 
    DC.W    CIRC_CHAR+$11
    DS.W    5

    ; row 29
    DS.W    14
    DC.W    CIRC_CHAR+4
    DC.W    $0800|CIRC_CHAR+$15
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$E 
    DCB.W   3, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$1E 
    DCB.W   8, CIRC_CHAR+8
    DC.W    CIRC_CHAR+$1E
    DC.W    CIRC_CHAR+8
    DC.W    CIRC_CHAR+$D 
    DC.W    CIRC_CHAR+$10
    DC.W    CIRC_CHAR+$E
    DCB.W   5, CIRC_CHAR+8

    ; row 30
    DS.W    15
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$14
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    14
    DC.W    $1800|CIRC_CHAR+$11
    DC.W    CIRC_CHAR+$20
    DC.W    $1000|CIRC_CHAR+$11
    DS.W    5

    ; row 31
    DS.W    16
    DC.W    CIRC_CHAR+1
    DS.W    16
    DC.W    CIRC_CHAR+$17
    DS.W    6
