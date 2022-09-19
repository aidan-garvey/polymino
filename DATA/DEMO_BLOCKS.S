
; *********************************************************************
; DEMO_BLOCKS.S
; Board data for the "how to play" demo. The upper byte of each block
; is stored, and they are stored in reverse order.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

DEMO_BLOCKS:
    DC.B    $47, $40, $40,   0, $41, $45, $45, $42, $43, 0
    DC.B      0, $47, $44,   0, $44,   0,   0, $43, $45, 0
    DC.B      0,   0, $47,   0, $40,   0,   0, $46, $43, 0
    DCB.B   10, 0
