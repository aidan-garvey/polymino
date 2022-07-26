
; *****************************************************************
; GFX_LETTERS.S
; A font with 8x8 uppercase letters
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; uses UI_PALETTE - 1 = black, 2 = white

LETTER_CHARS:
    ; A
    DC.L    $22222000
    DC.L    $01222100
    DC.L    $02212200
    DC.L    $02212210

    DC.L    $02222210
    DC.L    $02212210
    DC.L    $22212220
    DC.L    $01110111
    
    ; B
    DC.L    $22222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $02222110
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $22222110
    DC.L    $01111100

    ; C
    DC.L    $02222200
    DC.L    $22111210
    DC.L    $22100010
    DC.L    $22100000

    DC.L    $22100000
    DC.L    $22100200
    DC.L    $02222010
    DC.L    $00111100

    ; D
    DC.L    $22222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $02212210

    DC.L    $02212210
    DC.L    $02212210
    DC.L    $22222110
    DC.L    $01111100

    ; E
    DC.L    $22222200
    DC.L    $02211210
    DC.L    $02212010
    DC.L    $02222100

    DC.L    $02212100
    DC.L    $02210200
    DC.L    $22222210
    DC.L    $01111110

    ; F
    DC.L    $22222200
    DC.L    $02211210
    DC.L    $02212010
    DC.L    $02222100

    DC.L    $02212100
    DC.L    $02210100
    DC.L    $22222000
    DC.L    $01111100

    ; G
    DC.L    $02222200
    DC.L    $22111210
    DC.L    $22100010
    DC.L    $22100000

    DC.L    $22122220
    DC.L    $22102211
    DC.L    $02222210
    DC.L    $00111110

    ; H
    DC.L    $22202220
    DC.L    $02212211
    DC.L    $02212210
    DC.L    $02222210

    DC.L    $02212210
    DC.L    $02212210
    DC.L    $22212220
    DC.L    $01110111

    ; I
    DC.L    $22222200
    DC.L    $01221110
    DC.L    $00221000
    DC.L    $00221000
    
    DC.L    $00221000
    DC.L    $00221000
    DC.L    $22222200
    DC.L    $01111110

    ; J
    DC.L    $00222220
    DC.L    $00012211
    DC.L    $00002210
    DC.L    $00002210

    DC.L    $22002210
    DC.L    $22102210
    DC.L    $22222110
    DC.L    $01111100

    ; K
    DC.L    $22202220
    DC.L    $02210211
    DC.L    $02212010
    DC.L    $02220100

    DC.L    $02222000
    DC.L    $02212200
    DC.L    $22220220
    DC.L    $01111011

    ; L
    DC.L    $22220000
    DC.L    $02211000
    DC.L    $02210000
    DC.L    $02210000

    DC.L    $02210200
    DC.L    $02210210
    DC.L    $22222210
    DC.L    $01111110

    ; M
    DC.L    $22000220
    DC.L    $02202211
    DC.L    $02212210
    DC.L    $02212210

    DC.L    $02120210
    DC.L    $02121210
    DC.L    $22202220
    DC.L    $01110111

    ; N
    DC.L    $22002220
    DC.L    $02200211
    DC.L    $02220210
    DC.L    $02121210

    DC.L    $02122210
    DC.L    $02102210
    DC.L    $22200210
    DC.L    $01110010

    ; O
    DC.L    $02222000
    DC.L    $22112200
    DC.L    $22102210
    DC.L    $22102210

    DC.L    $22102210
    DC.L    $22102210
    DC.L    $02222110
    DC.L    $00111100

    ; P
    DC.L    $22222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $02212210

    DC.L    $02222110
    DC.L    $02211100
    DC.L    $22220000
    DC.L    $01111000

    ; Q
    DC.L    $02222000
    DC.L    $22112200
    DC.L    $22102210
    DC.L    $22102210

    DC.L    $22102210
    DC.L    $02222110
    DC.L    $00222200
    DC.L    $00011110

    ; R
    DC.L    $22222000
    DC.L    $02212200
    DC.L    $02212210
    DC.L    $02222110

    DC.L    $02212100
    DC.L    $02212200
    DC.L    $22220220
    DC.L    $01111011

    ; S
    DC.L    $02222000
    DC.L    $22112100
    DC.L    $22100100
    DC.L    $02220000

    DC.L    $00122000
    DC.L    $20022100
    DC.L    $22221100
    DC.L    $01111000

    ; T
    DC.L    $22222200
    DC.L    $21221210
    DC.L    $21221210
    DC.L    $01221010

    DC.L    $00221000
    DC.L    $00221000
    DC.L    $02222000
    DC.L    $00111100

    ; U
    DC.L    $22202220
    DC.L    $02212211
    DC.L    $02212210
    DC.L    $02212210

    DC.L    $02212210
    DC.L    $02212210
    DC.L    $00222110
    DC.L    $00011100

    ; V
    DC.L    $22202220
    DC.L    $02212211
    DC.L    $02212210
    DC.L    $02212210
    
    DC.L    $00212110
    DC.L    $00222100
    DC.L    $00222100
    DC.L    $00011100

    ; W
    DC.L    $22202222
    DC.L    $22110221
    DC.L    $22120221
    DC.L    $22121221

    DC.L    $02221211
    DC.L    $02212210
    DC.L    $02212210
    DC.L    $00110110

    ; X
    DC.L    $22202220
    DC.L    $02212211
    DC.L    $00222110
    DC.L    $00222100

    DC.L    $00222100
    DC.L    $02212200
    DC.L    $22212220
    DC.L    $01110111

    ; Y
    DC.L    $22202222
    DC.L    $02210221
    DC.L    $00222211
    DC.L    $00022110

    DC.L    $00022100
    DC.L    $00022100
    DC.L    $00222200
    DC.L    $00011110

    ; Z
    DC.L    $22222000
    DC.L    $21122100
    DC.L    $21221100
    DC.L    $01221000

    DC.L    $02212000
    DC.L    $22112100
    DC.L    $22222100
    DC.L    $01111100

LETTER_PATTERNS:
    DC.W    LETTER_GFX_CHAR
    DC.W    LETTER_GFX_CHAR+1
    DC.W    LETTER_GFX_CHAR+2
    DC.W    LETTER_GFX_CHAR+3
    DC.W    LETTER_GFX_CHAR+4
    DC.W    LETTER_GFX_CHAR+5
    DC.W    LETTER_GFX_CHAR+6
    DC.W    LETTER_GFX_CHAR+7
    DC.W    LETTER_GFX_CHAR+8
    DC.W    LETTER_GFX_CHAR+9
    DC.W    LETTER_GFX_CHAR+10
    DC.W    LETTER_GFX_CHAR+11
    DC.W    LETTER_GFX_CHAR+12
    DC.W    LETTER_GFX_CHAR+13
    DC.W    LETTER_GFX_CHAR+14
    DC.W    LETTER_GFX_CHAR+15
    DC.W    LETTER_GFX_CHAR+16
    DC.W    LETTER_GFX_CHAR+17
    DC.W    LETTER_GFX_CHAR+18
    DC.W    LETTER_GFX_CHAR+19
    DC.W    LETTER_GFX_CHAR+20
    DC.W    LETTER_GFX_CHAR+21
    DC.W    LETTER_GFX_CHAR+22
    DC.W    LETTER_GFX_CHAR+23
    DC.W    LETTER_GFX_CHAR+24
    DC.W    LETTER_GFX_CHAR+25
