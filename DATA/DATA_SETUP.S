
; *******************************************************************
; CONST_SETUP.S
; Initial game state values for setting up a new game - see RAM_MAP.S
; for the corresponding memory addresses these are written to.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *******************************************************************

GAME_STATE_SIZE EQU OUTLN_BUFF_1-GAME_STATE_1

INITIAL_GAME_STATE:
    DC.W    5   ; starting rows
    DC.L    0   ; bcd score
    DC.W    3   ; bcd bombs
    DC.W    BOARD_WIDTH/2-1 ; cursor X
    DC.W    BOARD_HEIGHT/2  ; cursor Y
    DC.W    0   ; h. cursor movement timer
    DC.W    0   ; v. cursor movement timer
    DC.W    1   ; combo
    DC.W    0   ; projectile check flag
    DC.W    0   ; game over flag
    DC.W    0   ; game over timer
    DC.L    0   ; binary score
    DC.W    0   ; cell column index of board - different per player
    DC.W    0   ; particle player flag - different per player
    DS.B    48  ; unused
    DS.B    $30 ; flags for clearing blocks from board
    DS.B    $E0 ; score graphics buffer
    DC.W    JUNK_T_UPDATES  ; junk timer
    DC.W    0   ; next junk ID, 0 means it needs initializing
    DC.W    0   ; next junk piece index
    DC.W    0   ; next junk piece x position
    DS.B    32  ; bitfield for tracking junk IDs