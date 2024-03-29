
; *****************************************************************
; GFX_TEXT.S
; Graphics for text, both whole phrases and individual characters.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; total chars: 26

; doesn't have its own palette, only uses 2 colors
; meant to use UI_PALETTE:
; 0: transparent
; 1: black
; 2: white

TEXT_NEXT:  ; 4x1 chars => 128B
    ; N
    DC.L    $02200222
    DC.L    $00220021
    DC.L    $00222021
    DC.L    $00212121

    DC.L    $00212221
    DC.L    $00210221
    DC.L    $02220021
    DC.L    $00111001
    
    ; E
    DC.L    $02222220
    DC.L    $10221121
    DC.L    $00221201
    DC.L    $00222210
    
    DC.L    $00221210
    DC.L    $00221020
    DC.L    $02222221
    DC.L    $00111111

    ; X
    DC.L    $22202220
    DC.L    $02212211
    DC.L    $00222110
    DC.L    $00222100
    
    DC.L    $00222100
    DC.L    $02212200
    DC.L    $22212220
    DC.L    $01110111

    ; T
    DC.L    $22222200
    DC.L    $21221210
    DC.L    $21221210
    DC.L    $01221010
    
    DC.L    $00221000
    DC.L    $00221000
    DC.L    $02222000
    DC.L    $00111100

TEXT_SCORE: ; 4x1 chars => 128B
    ; SC
    DC.L    $02222002
    DC.L    $22112122
    DC.L    $22100122
    DC.L    $02220022

    DC.L    $00122022
    DC.L    $20022122
    DC.L    $22221102
    DC.L    $01111000

    ; CO
    DC.L    $22200222
    DC.L    $11212211
    DC.L    $10012210
    DC.L    $10002210

    DC.L    $10002210
    DC.L    $10202210
    DC.L    $22010222
    DC.L    $11100011

    ; OR
    DC.L    $20222220
    DC.L    $22022122
    DC.L    $22122122
    DC.L    $22122221

    DC.L    $22122121
    DC.L    $22122122
    DC.L    $21222202
    DC.L    $11011110

    ; E
    DC.L    $02222220
    DC.L    $00221121
    DC.L    $10221201
    DC.L    $10222210

    DC.L    $00221210
    DC.L    $00221020
    DC.L    $22222221
    DC.L    $11111111

TEXT_BOMBS: ; 4x1 chars => 128B
    ; BO
    DC.L    $22220002
    DC.L    $22122022
    DC.L    $22122122
    DC.L    $22221122

    DC.L    $22122022
    DC.L    $22122122
    DC.L    $22221102
    DC.L    $01111000

    ; OM
    DC.L    $22202200
    DC.L    $11220220
    DC.L    $10221221
    DC.L    $10221221

    DC.L    $10221212
    DC.L    $10221212
    DC.L    $22212220
    DC.L    $11110111

    ; MB
    DC.L    $02202222
    DC.L    $22112212
    DC.L    $22102212
    DC.L    $22102222

    DC.L    $02102212
    DC.L    $12102212
    DC.L    $22202222
    DC.L    $01110111

    ; BS
    DC.L    $00022220
    DC.L    $20221120
    DC.L    $21221001
    DC.L    $11022200
    
    DC.L    $20001220
    DC.L    $21200221
    DC.L    $11222211
    DC.L    $10011110

TEXT_DIGITS:
    ; 0
    DC.L    $00222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $02212210

    DC.L    $02212210
    DC.L    $02212210
    DC.L    $00222110
    DC.L    $00011100

    ; 1
    DC.L    $00220000
    DC.L    $22221000
    DC.L    $01221000
    DC.L    $00221000

    DC.L    $00221000
    DC.L    $00221000
    DC.L    $22222200
    DC.L    $01111110

    ; 2
    DC.L    $00222000
    DC.L    $02212200
    DC.L    $00112210
    DC.L    $00022110
    
    DC.L    $00221100
    DC.L    $02211000
    DC.L    $02222200
    DC.L    $00111110

    ; 3
    DC.L    $00222000
    DC.L    $02012200
    DC.L    $00102210
    DC.L    $00222110

    DC.L    $00012200
    DC.L    $02002210
    DC.L    $00222110
    DC.L    $00011100

    ; 4
    DC.L    $00022000
    DC.L    $00222100
    DC.L    $02022100
    DC.L    $20122100

    DC.L    $22222200
    DC.L    $01122110
    DC.L    $00222200
    DC.L    $00011110

    ; 5
    DC.L    $02222200
    DC.L    $02211110
    DC.L    $02222000
    DC.L    $02112200

    DC.L    $00102210
    DC.L    $02002210
    DC.L    $00222110
    DC.L    $00011100

    ; 6
    DC.L    $00022200
    DC.L    $00221110
    DC.L    $02211000
    DC.L    $02222000

    DC.L    $02212200
    DC.L    $02212210
    DC.L    $00222110
    DC.L    $00011100

    ; 7
    DC.L    $02222200
    DC.L    $02112210
    DC.L    $00102210
    DC.L    $00002210

    DC.L    $00022110
    DC.L    $00022100
    DC.L    $00022100
    DC.L    $00001100

    ; 8
    DC.L    $00222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $00222110

    DC.L    $02212200
    DC.L    $02212210
    DC.L    $00222110
    DC.L    $00011100

    ; 9
    DC.L    $00222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $00222210
    DC.L    $00012210
    DC.L    $00022110
    DC.L    $02221100
    DC.L    $00111000

TEXT_COPYRIGHT:
    DC.L    $00222200
    DC.L    $02000020
    DC.L    $20022002
    DC.L    $20200002
    
    DC.L    $20200002
    DC.L    $20022002
    DC.L    $02000020
    DC.L    $00222200

DIGIT_PATTERNS:
    DC.W    DIGIT_GFX_CHAR
    DC.W    DIGIT_GFX_CHAR+1
    DC.W    DIGIT_GFX_CHAR+2
    DC.W    DIGIT_GFX_CHAR+3
    DC.W    DIGIT_GFX_CHAR+4
    DC.W    DIGIT_GFX_CHAR+5
    DC.W    DIGIT_GFX_CHAR+6
    DC.W    DIGIT_GFX_CHAR+7
    DC.W    DIGIT_GFX_CHAR+8
    DC.W    DIGIT_GFX_CHAR+9
    