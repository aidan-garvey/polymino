
; *********************************************************************
; DEMO_INPUT.S
; Controller input data for the "how to play" demo. Each block contains
; the number of frames (must be even), followed by that many frames,
; ending with the address of the next DEMO_INIT_X subroutine to run.
; The number of frames is 2 bytes, each frame is 1 byte and the address
; is 4 bytes.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

    EVEN

; "HOW TO PLAY"
DEMO_INPUT_1:
    DC.W    60
    DS.B    60
    DC.L    DEMO_INIT_2

; "MOVE YOUR CURSOR WITH THE DIRECTION BUTTONS"
; up, up, left, up, left, hold right, hold down and start holding left while keeping down held
DEMO_INPUT_2:
    DC.W    210
    ; 0
    DS.B    10
    DCB.B   6, %00000001
    DS.B    10
    DCB.B   6, %00000001
    DS.B    10
    DCB.B   6, %00000100
    DS.B    10
    DCB.B   6, %00000001
    ; 64
    DS.B    10
    DCB.B   6, %00000100
    DS.B    40
    ; 120
    DCB.B   30, %00001000
    DS.B    10
    ; 160
    DCB.B   20, %00000010
    ; 180
    DCB.B   20, %00000110
    DS.B    10
    ; 210
    DC.L    DEMO_INIT_3

; "SWAP HORIZONTALLY WITH THE A BUTTON"
DEMO_INPUT_3:
    DC.W    210
    ; need to move down 6, left 2
    ; (move down 5, down-left 1, left 1)
    DCB.B   30, %00000010
    DCB.B   6,  %00000110
    DCB.B   6,  %00000100
    ; 42
    DS.B    20
    DCB.B   20, %01000000
    DS.B    20
    ; 102
    ; move up-right 1, right 3
    DCB.B   6,  %00001001
    DCB.B   18, %00001000
    ; 126
    DS.B    20
    DCB.B   20, %01000000
    DS.B    4
    ; 170
    DS.B    40
    ; 210
    DC.L    DEMO_INIT_4

; "SWAP VERTICALLY WITH THE B BUTTON"
DEMO_INPUT_4:
    DC.W    238
    DS.B    30
    ; down 2, left 3
    DCB.B   12, %00000110
    DCB.B   6,  %00000100
    ; 48
    DS.B    20
    DCB.B   20, %00010000
    DS.B    40
    ; 128
    ; right 5
    DCB.B   30, %00001000
    ; 158
    DS.B    20
    DCB.B   20, %00010000
    DS.B    40
    ; 238
    DC.L    DEMO_INIT_5

; "JUNK PIECES WILL DROP FROM THE BRONZE OUTLINE"
DEMO_INPUT_5:
    DC.W    180
    DS.B    180
    DC.L    DEMO_INIT_6

; "TO KEEP THE BOARD CLEAR YOU MUST DESTROY JUNK BY MATCHING BLOCKS"
DEMO_INPUT_6:
    DC.W    360
    DS.B    80
    DCB.B   6,  %00000001
    DCB.B   6,  %00000100
    DS.B    18
    DCB.B   15, %00010000
    DS.B    235
    DC.L    DEMO_INIT_7

; "JUNK WITH A COLOR MUST BE DESTROYED BY MATCHING THE SAME COLOR"
DEMO_INPUT_7:
    DC.W    550
    ; pause for a bit
    DS.B    120
    ; move left 2, up 1
    DCB.B   12, %00000100
    DCB.B   6,  %00000001
    DS.B    42
    ; press a
    DCB.B   12, %01000000
    DS.B    30
    ; move right 1, up 1
    DCB.B   6,  %00001001
    DS.B    12
    ; press b
    DCB.B   12, %00010000
    ; pause
    DS.B    48
    ; move up 1, left 3
    DCB.B   6,  %00000101
    DCB.B   12, %00000100
    ; a, right, a, right
    DCB.B   6,  %01000000
    DS.B    6
    DCB.B   6,  %00001000
    DS.B    6

    DCB.B   6,  %01000000
    DS.B    6
    DCB.B   6,  %00001000
    DS.B    6
    ; down, b, down, b
    DCB.B   6,  %00000010
    DS.B    6
    DCB.B   6,  %00010000
    DS.B    6
    DCB.B   6,  %00000010
    DS.B    6
    DCB.B   6,  %00010000
    DS.B    6

    DS.B    136

    DC.L    DEMO_INIT_8

; "YOU CAN DROP BOMBS WITH THE C BUTTON IN AN EMERGENCY"
DEMO_INPUT_8:
    DC.W    336
    DS.B    120
    ; up-right x 3
    DCB.B   18, %00001001
    ; up x 3
    DCB.B   18, %00000001
    DS.B    60
    DCB.B   30, %00100000
    DS.B    90
    DC.L    DEMO_INIT_9

DEMO_INPUT_9:
    DC.W    30
    DS.B    30
    DC.L    DEMO_INIT_9

    EVEN
