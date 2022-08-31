
; *********************************************************************
; INTRO.S
; Code to initialize and play the intro animation when the game starts,
; and the game's start screen ("PUSH START BUTTON").
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

; =================================================================
; HSCROLL_STAGGER
; -----------------------------------------------------------------
; Stagger the HSCROLL values of each pair of rows in SCROLL A and B
; =================================================================
HSCROLL_STAGGER:
_AMT = 32*8
    LEA.L   INTRO_HSCROLL, a0
    MOVE.W  #_AMT, d0
    MOVE.W  d0, d1
    SWAP    d0
    MOVE.W  d1, d0  ; d0 = _AMT, _AMT

    NEG.W   d1
    SWAP    d1
    MOVE.W  d0, d1
    NEG.W   d1      ; d1 = -_AMT, -_AMT

    ; we'll do 8 words per loop iteration: 2x + & - for A & B
    MOVE.W  #VRAM_HSCROLL_SIZE/16, d2
_LOOP:
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    DBRA    d2, _LOOP

    RTS

; ==============================================================
; HSCROLL_MERGE
; --------------------------------------------------------------
; Merge the rows of SCROLL A and B by the given number of pixels
; --------------------------------------------------------------
; Parameters:
;   d0 - amount to un-stagger by
; ==============================================================
HSCROLL_MERGE:
    LEA.L   INTRO_HSCROLL, a0
    MOVE.W  (a0), d1
    SUB.W   d0, d1
    MOVE.W  d1, d0
    SWAP    d1
    MOVE.W  d0, d1
    
    NEG.W   d0
    SWAP    d0
    MOVE.W  d1, d0
    NEG.W   d0

    ; we'll do 8 words per iteration: 2x + & - for A & B
    MOVE.W  #VRAM_HSCROLL_SIZE/16, d2
_LOOP:
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    DBRA    d2, _LOOP
    
    RTS

INTRO_1_MSG_X_1 = (40-12)/2
INTRO_1_MSG_X_2 = (40-8)/2
INTRO_1_MSG_Y = 14
INTRO_1_SPEED = 4
INTRO_1_LENGTH = 256/INTRO_1_SPEED

INTRO_1_INIT:
    LOAD_STATE_HARD

    ; set background color
    VDP_REG 7, $00
    ; use row-by-row HSCROLL
    VDP_REG 11, %00000011

    BSR.W   HSCROLL_STAGGER

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
    MOVE.W  #INTRO_1_MSG_X_1, d3
    MOVE.W  #INTRO_1_MSG_Y, d4
    LEA.L   STR_DEVNAME, a0
    JSR     DRAW_STRING

    MOVE.W  #INTRO_1_MSG_X_2, d3
    MOVE.W  #INTRO_1_MSG_Y+1, d4
    LEA.L   STR_PRESENTS, a0
    JSR     DRAW_STRING

    MOVE.L  #INTRO_1_ANIM, (MAIN_VECTOR)
    MOVE.L  #VB_INTRO, (VBVECTOR)
    CLR.W   (MAIN_TICK)

    ; by default, music is on
    MOVE.W  #-1, (MUSIC_ON)

    ; re-enable display and interrupts
    END_LOAD_STATE_HARD

    RTS

; wait for 2 seconds before advancing stage
INTRO_1_ANIM:
    MOVEQ   #INTRO_1_SPEED, d0
    BSR.W   HSCROLL_MERGE

    CMP.W   #INTRO_1_LENGTH, (MAIN_TICK)
    BLT.B   _INTRO_ANIM_RET
    MOVE.L  #INTRO_1_WAIT, (MAIN_VECTOR)
    CLR.W   (MAIN_TICK)
_INTRO_ANIM_RET:
    RTS

INTRO_1_WAIT:
_LEN = 20
    CMP.W   #_LEN, (MAIN_TICK)
    BLE.B   _RET
    CLR.W   (MAIN_TICK)
    MOVE.L  #INTRO_1_LEAVE, (MAIN_VECTOR)
_RET:
    RTS

INTRO_1_LEAVE:
_SPEED = 4
_LEN = 256/_SPEED
    MOVEQ   #_SPEED, d0
    BSR.W   HSCROLL_MERGE

    CMP.W   #_LEN, (MAIN_TICK)
    BLT.B   _RET
    MOVE.L  #INTRO_2_INIT, (MAIN_VECTOR)
_RET:
    RTS

INTRO_2_INIT:
    LOAD_STATE_HARD

    JSR     CLEAR_BUFF_PLANE
    BSR.W   HSCROLL_STAGGER
    JSR     DRAW_TITLE

    CLR.W   (MAIN_TICK)
    MOVE.L  #INTRO_2_ANIM, (MAIN_VECTOR)

    END_LOAD_STATE
    RTS

INTRO_2_ANIM:
_SPEED = 16
_LEN = 256/_SPEED
    MOVEQ   #_SPEED, d0
    BSR.W   HSCROLL_MERGE

    CMP.W   #_LEN, (MAIN_TICK)
    BLT.B   _RET
    MOVE.L  #STARTSCRN_INIT, (MAIN_VECTOR)
    CLR.W   (MAIN_TICK)
_RET:
    RTS

START_MSG_X = 14
START_MSG_Y = 26

STARTSCRN_INIT:
    LOAD_STATE_SOFT

    MOVE.L  #VBMAIN, (VBVECTOR)
    ; use full HSCROLL
    VDP_REG 11, %00000000

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
    END_LOAD_STATE

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
