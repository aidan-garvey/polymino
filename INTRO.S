
; *********************************************************************
; INTRO.S
; Code to initialize and play the intro animation when the game starts,
; and the game's start screen ("PUSH START BUTTON").
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

INTRO_MSG_X = 14
INTRO_MSG_Y = 14
START_MSG_X = 14
START_MSG_Y = 26
INTRO_LENGTH = 150

INTRO_INIT:
    LOAD_STATE_HARD

    ; set background color
    VDP_REG 7, $00

    JSR     CLEAR_BUFF_PLANE

    ; load character graphics into VRAM
    MOVE.L  #LETTER_CHARS, d0
    MOVE.W  #26*16, d1
    MOVE.W  #VRAM_LETTER_GFX, d2
    JSR     DMADump

    MOVE.L  #TEXT_DIGITS, d0
    MOVE.W  #10*16, d1
    MOVE.W  #VRAM_DIGIT_GFX, d2
    JSR     DMADump

    ; write intro message to screen
    MOVE.W  #INTRO_MSG_X, d3
    MOVE.W  #INTRO_MSG_Y, d4
    LEA.L   STR_INTRO, a0
    JSR     DRAW_STRING

    MOVE.L  #INTRO_ANIM, (MAIN_VECTOR)
    MOVE.W  #0, (MAIN_TICK)

    ; by default, music is on
    MOVE.W  #-1, (MUSIC_ON)

    ; re-enable display and interrupts
    END_LOAD_STATE_HARD

    RTS

; wait for 2 seconds before advancing stage
INTRO_ANIM:
    ADDQ.W  #1, (MAIN_TICK)
    CMP.W   #INTRO_LENGTH, (MAIN_TICK)
    BNE.B   _INTRO_ANIM_RET
    MOVE.L  #STARTSCRN_INIT, (MAIN_VECTOR)
_INTRO_ANIM_RET:
    RTS

STARTSCRN_INIT:
    LOAD_STATE_HARD

    ; set background color
    VDP_REG 7, $00

    JSR     DRAW_TITLE

    ; BUFF_PLANE was used by DRAW_TITLE, so clear it to use it for SCROLL A
    JSR     CLEAR_BUFF_PLANE
    MOVE.W  #START_MSG_X, d3
    MOVE.W  #START_MSG_Y, d4
    LEA.L   STR_START, a0
    JSR     DRAW_STRING

    CLR.W   (VSCROLL_ON)

    MOVE.L  #STARTSCRN_LOOP, (MAIN_VECTOR)
    END_LOAD_STATE_HARD

    RTS

STARTSCRN_LOOP:
    ; wait for any input from player 1 or 2
    MOVE.W  (JOY1), d0
    MOVE.W  (JOY1_OLD), d1
    EOR.W   d0, d1
    AND.W   d1, d0  ; d0 := player 1 input this frame, not held
    MOVE.W  (JOY2), d1
    MOVE.W  (JOY2_OLD), d2
    EOR.W   d1, d2
    AND.W   d2, d1  ; d0 := p2 input this frame, not held
    OR.W    d1, d0  ; d0 := either player input this frame, not held
    BEQ.B   _STARTSCRN_LOOP_RET
    MOVE.L  #MAIN_MENU_INIT, (MAIN_VECTOR)
_STARTSCRN_LOOP_RET:
    RTS
