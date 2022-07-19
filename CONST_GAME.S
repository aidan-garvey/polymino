
; ********************************************************************
; CONST_GAME.S
; Constant values that don't fit into other CONST files or CHAR_INDEX.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; ********************************************************************

MATCH_POINTS = $5 ; base points awarded for matching blocks - BCD
SHATTER_POINTS = $50 ; base points awarded for destroying junk - BCD

BOARD_HEIGHT = 24 ; in cells
BOARD_WIDTH = 10 ; in cells
BOARD_SIZE = 480 ; size of board in bytes

SCORE_BUFF_SIZE = $E0

HOLD_LENGTH = 6 ; held buttons are handled every HOLD_LENGTH frames
SCROLL_DIV = 2  ; divisor for background scroll amount per frame

T_HOFF_1 = $88
T_HOFF_2 = $180

T_NEXT_VPOS = $94
T_NEXT_HPOS_1 = T_HOFF_1+12
T_NEXT_HPOS_2 = T_HOFF_2+12

T_SCORE_VPOS = T_NEXT_VPOS+$30
T_SCORE_HPOS_1 = T_HOFF_1+12
T_SCORE_HPOS_2 = T_HOFF_2+12

SCORE_DGTS_VPOS = T_SCORE_VPOS+12
SCORE_DGTS_HPOS_1 = T_HOFF_1
SCORE_DGTS_HPOS_2 = T_HOFF_2
SCORE_DGTS_HLOW_1 = SCORE_DGTS_HPOS_1+24
SCORE_DGTS_HLOW_2 = SCORE_DGTS_HPOS_2+24

T_LLINES_VPOS = SCORE_DGTS_VPOS+$10
T_LLINES_HPOS_1 = T_HOFF_1+4
T_LLINES_HPOS_2 = T_HOFF_2+4

