
; *********************************************************************
; INTRO.S
; Code to initialize and play the intro animation when the game starts,
; and the game's start screen ("PUSH START BUTTON").
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

INTRO_INIT:
    MOVE.L  #INTRO_ANIM, (MAIN_VECTOR)
    RTS

INTRO_ANIM:
    MOVE.L  #STARTSCRN_INIT, (MAIN_VECTOR)
    RTS

STARTSCRN_INIT:
    MOVE.L  #STARTSCRN_LOOP, (MAIN_VECTOR)
    RTS

STARTSCRN_LOOP:
    MOVE.L  #MAIN_MENU_INIT, (MAIN_VECTOR)
    RTS
