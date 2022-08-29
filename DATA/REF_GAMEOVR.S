
; ********************************************************************
; REF_GAMEOVR.S
; Uncompressed characters for the "GAME OVER" sprites, see GFX_GAMEOVR
; for the data included in the ROM.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; ********************************************************************

GAME_OVER_CHARS:
    ; SPRITE 1

    ; 0, 0
    DC.L    $000000CC
    DC.L    $0000CCCC
    DC.L    $000CCC11
    DC.L    $00CC1110

    DC.L    $0CC11000
    DC.L    $0CC10000
    DC.L    $CC1000CC
    DC.L    $CC1000CC

    ; 0, 1
    DC.L    $CC1000CC
    DC.L    $CC100001
    DC.L    $CC100000
    DC.L    $CCC00000
    
    DC.L    $0CCCCCCC
    DC.L    $001CCCCC
    DC.L    $00001111
    DC.L    $00000000

    ; 0, 2
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 0, 3
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 1, 0
    DC.L    $CCC0CC00
    DC.L    $CCCCCC10
    DC.L    $11CCCC10
    DC.L    $000CC110
    
    DC.L    $000CC100
    DC.L    $00001100
    DC.L    $00000000
    DC.L    $CCCCC000

    ; 1, 1
    DC.L    $CCCCC100
    DC.L    $11CC110C
    DC.L    $0CC1100C
    DC.L    $CCC100CC

    DC.L    $CCC1CCCC
    DC.L    $C111CCCC
    DC.L    $11000111
    DC.L    $00000000

    ; 1, 2
    DC.L    $00000000
    DC.L    $000000CC
    DC.L    $0000CCCC
    DC.L    $000CCC11

    DC.L    $00CC1110
    DC.L    $0CC11000
    DC.L    $0CC10000
    DC.L    $CC110000

    ; 1, 3
    DC.L    $CC100000
    DC.L    $CC100000
    DC.L    $CC100000
    DC.L    $CCC00000

    DC.L    $0CCC000C
    DC.L    $0CCCCCCC
    DC.L    $001CCCC1
    DC.L    $00001111

    ; 2, 0
    DC.L    $CCCCCCC0
    DC.L    $CCCCCCC1
    DC.L    $0111CCC1
    DC.L    $000CC1CC

    DC.L    $00CC11CC
    DC.L    $00CC10CC
    DC.L    $0CC110CC
    DC.L    $0CC100CC

    ; 2, 1
    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $C111111C
    DC.L    $1100000C
    
    DC.L    $CCC0CCCC
    DC.L    $CCC1CCCC
    DC.L    $11110111
    DC.L    $00000000

    ; 2, 2
    DC.L    $00000000
    DC.L    $CC0000CC
    DC.L    $CCCC00CC
    DC.L    $1CCC1001

    DC.L    $00CCC000
    DC.L    $000CC100
    DC.L    $000CC100
    DC.L    $000CC100

    ; 2, 3
    DC.L    $000CC100
    DC.L    $00CC1100
    DC.L    $00CC1000
    DC.L    $0CC11000
    
    DC.L    $CC110000
    DC.L    $C1100000
    DC.L    $11000000
    DC.L    $00000000

    ; 3, 0
    DC.L    $000CCCCC
    DC.L    $000CCCCC
    DC.L    $00001CCC
    DC.L    $00000CCC

    DC.L    $10000CCC
    DC.L    $10000CC1
    DC.L    $10000CC1
    DC.L    $1000CCC1

    ; 3, 1
    DC.L    $C000CC11
    DC.L    $C100CC10
    DC.L    $C100CC10
    DC.L    $C100CC10
    
    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $11111111
    DC.L    $00000000

    ; 3, 2
    DC.L    $00000000
    DC.L    $CCCCC0CC
    DC.L    $CCCCC1CC
    DC.L    $CC111101

    DC.L    $0CC00000
    DC.L    $0CC10000
    DC.L    $0CC1000C
    DC.L    $0CC100CC

    ; 3, 3
    DC.L    $0CC100CC
    DC.L    $00CC0CC1
    DC.L    $00CC1CC1
    DC.L    $00CCCC11

    DC.L    $00CCCC10
    DC.L    $00CCC110
    DC.L    $000C1100
    DC.L    $00001000

    ; SPRITE 2
    
    ; 0, 0
    DC.L    $00000000
    DC.L    $1000000C
    DC.L    $C00000CC
    DC.L    $C1000CCC
    
    DC.L    $C100CCCC
    DC.L    $CC00CC1C
    DC.L    $CC1CC11C
    DC.L    $CCCCC1CC

    ; 0, 1
    DC.L    $CCCC11CC
    DC.L    $0CC110CC
    DC.L    $0C1100CC
    DC.L    $001000CC
    
    DC.L    $C0CCCCCC
    DC.L    $C1CCCCCC
    DC.L    $11011111
    DC.L    $00000000

    ; 0, 2
    DC.L    $00000000
    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $1CC111CC

    DC.L    $CC1100CC
    DC.L    $CC1000CC
    DC.L    $C11000CC
    DC.L    $C10000CC

    ; 0, 3
    DC.L    $11000CCC
    DC.L    $10000CC1
    DC.L    $00000CC1
    DC.L    $00000CC1

    DC.L    $00000CC1
    DC.L    $00CCCCCC
    DC.L    $00CCCCCC
    DC.L    $00011111

    ; 1, 0
    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $CC11CC11
    DC.L    $C110CC10

    DC.L    $C100CC10
    DC.L    $C100CC10
    DC.L    $C100CCCC
    DC.L    $110CCCCC

    ; 1, 1
    DC.L    $100CC11C
    DC.L    $100CC10C
    DC.L    $100CC100
    DC.L    $100CC100

    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $11111111
    DC.L    $00000000

    ; 1, 2
    DC.L    $00000000
    DC.L    $CCCCCCCC
    DC.L    $CCCCCCCC
    DC.L    $111111CC

    DC.L    $100000CC
    DC.L    $10CC00CC
    DC.L    $10CC1001
    DC.L    $CCCC1000

    ; 1, 3
    DC.L    $CCC11000
    DC.L    $1CC10000
    DC.L    $0CC100CC
    DC.L    $001100CC

    DC.L    $000000CC
    DC.L    $CCCCCCC1
    DC.L    $CCCCCCC1
    DC.L    $11111111

    ; 2, 0
    DC.L    $CCCCCCC0
    DC.L    $CCCCCCC1
    DC.L    $1111CC11
    DC.L    $0000CC10

    DC.L    $CC00CC10
    DC.L    $CC100110
    DC.L    $CC100000
    DC.L    $C1100000

    ; 2, 1
    DC.L    $C1000000
    DC.L    $C100CC00
    DC.L    $1100CC10
    DC.L    $0000CC10

    DC.L    $CCCCC110
    DC.L    $CCCCC100
    DC.L    $11111100
    DC.L    $00000000

    ; 2, 2
    DC.L    $00000000
    DC.L    $C0CCCCCC
    DC.L    $C1CCCCCC
    DC.L    $1101CC11

    DC.L    $1000CC10
    DC.L    $1000CC10
    DC.L    $1000CC10
    DC.L    $0000CC10

    ; 2, 3
    DC.L    $000CCCCC
    DC.L    $000CCCCC
    DC.L    $000CC111
    DC.L    $100CC100

    DC.L    $100CC100
    DC.L    $CCCCCCC0
    DC.L    $CCCCCCC1
    DC.L    $01111111

    ; 3, 0
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 3, 1
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 3, 2
    DC.L    $00000000
    DC.L    $CCCCC000
    DC.L    $CCCCCC00
    DC.L    $1111CCC0

    DC.L    $00000CC1
    DC.L    $00000CC1
    DC.L    $0000CCC1
    DC.L    $000CCC11

    ; 3, 3
    DC.L    $CCCCC110
    DC.L    $CCC11100
    DC.L    $1CCC0000
    DC.L    $00CC1000
    
    DC.L    $00CCC000
    DC.L    $000CCCC0
    DC.L    $000CCCC1
    DC.L    $00001111
