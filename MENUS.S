
; *****************************************************************
; MENUS.S
; Subroutines for the game's menu system.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Menu struct for moving the cursor b/w buttons and selecting one:
MENU_XPOS = 0       ; 2B - what the cursor's x pos should be
MENU_YPOS = 2       ; 2B - what the cursor's y pos should be for the first option
MENU_YSPACING = 4   ; 2B - vertical spacing b/w buttons
MENU_NBUTTONS = 6   ; 1B - number of buttons
MENU_BTNINDEX = 7   ; 1B - index of current button
MENU_SELECTED = 8   ; 1B - 0 = no, -1 = menu exitted, +1 = option selected
MENU_PLAYER = 9     ; 1B - does player 1 or 2 have control of this menu? (0 = p1, 1 = p2)
MENU_CON_MASK = 10  ; 1B - mask for buttons that confirm a selection
MENU_EX_MASK = 11   ; 1B - mask for buttons that exit the menu

; ========================================================
; MENU_CURSOR
; --------------------------------------------------------
; Move the cursor between the options in the current menu,
; and set the SELECTED flag if A is pressed
; ========================================================
MENU_CURSOR:
    PUSH    a0/a1/d0/d1

    LEA.L   CURR_MENU, a0
    ; get button inputs that are not held
    LEA.L   JOY1, a1
    TST.B   (MENU_PLAYER, a0)
    BEQ.B   _MENU_CURSOR_P1
    ; if player 2, point to JOY2 instead
    ADDQ.W  #2, a1
_MENU_CURSOR_P1:
    MOVE.W  (a1), d0    ; d0 := current inputs
    MOVE.W  4(a1), d1   ; d1 := previous inputs
    
    EOR.W   d0, d1      ; d1 := inputs that changed
    AND.W   d1, d0      ; d0 := inputs that changed and pressed this frame

    LEA.L   CURSOR_SPRITE, a1
    ; copy menu X position to cursor sprite
    MOVE.W  (a0), 6(a1)

    ; move the cursor
    BTST    #BUTTON_UP, d0
    BEQ.B   _SKIP_UP
    ; don't allow pressing up and down
    BTST    #BUTTON_DOWN, d0
    BNE.B   _SKIP_MOVE
    ; make cursor wrap around if it is at the top
    TST.B   (MENU_BTNINDEX, a0)
    BNE.B   _MOVE_UP_SUB
    MOVE.B  (MENU_NBUTTONS, a0), (MENU_BTNINDEX, a0)
_MOVE_UP_SUB:
    ; move up
    SUBQ.B  #1, (MENU_BTNINDEX, a0)
    BRA.B   _SKIP_MOVE
_SKIP_UP:
    BTST    #BUTTON_DOWN, d0
    BEQ.B   _SKIP_MOVE
    ; move down
    MOVE.B  (MENU_BTNINDEX, a0), d1
    ADDQ.B  #1, d1
    CMP.B   (MENU_NBUTTONS, a0), d1
    BLT.B   _MOVE_DOWN_WRITE
    ; if cursor is below bottom, wrap around to top
    MOVEQ   #0, d1
_MOVE_DOWN_WRITE:
    MOVE.B  d1, (MENU_BTNINDEX, a0)
_SKIP_MOVE:

    ; calculate y position of cursor sprite
    MOVE.B  (MENU_BTNINDEX, a0), d1
    EXT.W   d1
    MOVE.W  (MENU_YSPACING, a0), d2
    MULU.W  d2, d1
    ADD.W   (MENU_YPOS, a0), d1
    ; copy to sprite table buffer
    MOVE.W  d1, (a1)

    ; check for selection
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  (MENU_CON_MASK, a0), d1
    ; BTST    #BUTTON_A, d0
    AND.B   d0, d1
    ; if selection made, set MENU_SELECTED to +1
    BEQ.B   _MENU_EXIT_CHECK
    MOVE.B  #1, (MENU_SELECTED, a0)
    LEA.L   ESF_SELECT, a0
    JSR     Echo_PlaySFX
    BRA.B   _MENU_CURSOR_RET
_MENU_EXIT_CHECK:
    ; check for exit
    MOVE.B  (MENU_EX_MASK, a0), d1
    AND.B   d0, d1
    BEQ.B   _MENU_CURSOR_RET
    MOVE.B  #-1, (MENU_SELECTED, a0)
    LEA.L   ESF_EXIT, a0
    JSR     Echo_PlaySFX
_MENU_CURSOR_RET:
    POP     a0/a1/d0/d1
    RTS


MAIN_MENU_TX = 16
MAIN_MENU_TY = 20
MAIN_MENU_PX = $80+(MAIN_MENU_TX-2)*8
MAIN_MENU_PY = $80+MAIN_MENU_TY*8
MAIN_MENU_VSPACE = $10
MAIN_MENU_NBUTTONS = 4
MAIN_MENU_PLAYER = 0
MAIN_MENU_CON_MASK = %11000000
MAIN_MENU_EX_MASK = %00010000

; configure and draw the main menu
MAIN_MENU_INIT:
    LOAD_STATE_SOFT

    ; initialize UI sprites for both players
    JSR     LOAD_SPRITES

    JSR     CLEAR_BUFF_PLANE

    LEA.L   STR_1P, a0
    MOVE.W  #MAIN_MENU_TX, d3
    MOVE.W  #MAIN_MENU_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_2P, a0
    MOVE.W  #MAIN_MENU_TX, d3
    MOVE.W  #MAIN_MENU_TY+2, d4
    JSR     DRAW_STRING

    LEA.L   STR_HOWTO, a0
    MOVE.W  #MAIN_MENU_TX, d3
    MOVE.W  #MAIN_MENU_TY+4, d4
    JSR     DRAW_STRING

    LEA.L   STR_OPTIONS, a0
    MOVE.W  #MAIN_MENU_TX, d3
    MOVE.W  #MAIN_MENU_TY+6, d4
    JSR     DRAW_STRING

    LEA.L   CURR_MENU, a0
    MOVE.W  #MAIN_MENU_PX, (MENU_XPOS, a0)
    MOVE.W  #MAIN_MENU_PY, (MENU_YPOS, a0)
    MOVE.W  #MAIN_MENU_VSPACE, (MENU_YSPACING, a0)
    MOVE.B  #MAIN_MENU_NBUTTONS, (MENU_NBUTTONS, a0)
    CLR.B   (MENU_BTNINDEX, a0)
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  #MAIN_MENU_PLAYER, (MENU_PLAYER, a0)
    MOVE.B  #MAIN_MENU_CON_MASK, (MENU_CON_MASK, a0)
    MOVE.B  #MAIN_MENU_EX_MASK, (MENU_EX_MASK, a0)

    MOVE.L  #MAIN_MENU_LOOP, (MAIN_VECTOR)
    END_LOAD_STATE
    RTS

; detect if the player has chosen an option on the main menu
MAIN_MENU_LOOP:
    JSR     MENU_CURSOR
    LEA.L   CURR_MENU, a0

    TST.B   (MENU_SELECTED, a0)
    BLT.B   _EXIT   ; if player pressed B, go back to start screen
    BEQ.B   _RET
    ; if a button was selected:
    TST.B   (MENU_BTNINDEX, a0)
    BEQ.B   _PLAYER_1_START ; button 0 is "1 PLAYER"
    CMP.B   #1, (MENU_BTNINDEX, a0)
    BEQ.B   _PLAYER_2_START ; button 1 is "2 PLAYERS"
    CMP.B   #2, (MENU_BTNINDEX, a0)
    BEQ.B   _HOW_TO_PLAY    ; button 2 is "HOW TO PLAY"
    ; if options is pressed, switch to options menu
    MOVE.L  #OPT_MENU_INIT, (MAIN_VECTOR)
    BRA.B   _RET
_PLAYER_1_START:
    MOVE.W  #1, (NUM_PLAYERS)
    MOVE.L  #DIFF_MENU_INIT, (MAIN_VECTOR)
    BRA.B   _RET
_PLAYER_2_START:
    MOVE.W  #2, (NUM_PLAYERS)
    MOVE.L  #DIFF_MENU_INIT, (MAIN_VECTOR)
    BRA.B   _RET
_HOW_TO_PLAY:
    MOVE.W  #1, (NUM_PLAYERS)
    MOVE.L  #DEMO_INIT, (MAIN_VECTOR)
    BRA.B   _RET
_EXIT:
    MOVE.L  #STARTSCRN_INIT, (MAIN_VECTOR)
    MOVE.W  #1, (CURSOR_SPRITE)
_RET:
    RTS

DIFF_MENU_TX = 19
DIFF_MENU_TY = 9
DIFF_MENU_PX = $80+(DIFF_MENU_TX-2)*8
DIFF_MENU_PY = $80+DIFF_MENU_TY*8
DIFF_MENU_VSPACE = $10
DIFF_MENU_NBUTTONS = 5
DIFF_MENU_PLAYER = 0
DIFF_MENU_CON_MASK = %11000000
DIFF_MENU_EX_MASK = %00010000
DIFF_MENU_PLANE = BUFF_PLANE+(DIFF_MENU_TX*2)+(DIFF_MENU_TY*128)

; configure and draw the menu for selecting a difficulty
DIFF_MENU_INIT:
    LOAD_STATE_SOFT

    JSR     CLEAR_BUFF_PLANE

    LEA.L   STR_DIFF, a0
    MOVEQ   #11, d3
    MOVEQ   #DIFF_MENU_TY-2, d4
    JSR     DRAW_STRING

    LEA.L   DIGIT_PATTERNS+2, a0 ; pattern for '1'
    LEA.L   DIFF_MENU_PLANE, a1
    MOVEQ   #4, d0
_DIFF_MENU_OPTS:
    MOVE.W  (a0)+, (a1)
    ADDA.W  #256, a1
    DBRA    d0, _DIFF_MENU_OPTS

    LEA.L   CURR_MENU, a0
    MOVE.W  #DIFF_MENU_PX, (MENU_XPOS, a0)
    MOVE.W  #DIFF_MENU_PY, (MENU_YPOS, a0)
    MOVE.W  #DIFF_MENU_VSPACE, (MENU_YSPACING, a0)
    MOVE.B  #DIFF_MENU_NBUTTONS, (MENU_NBUTTONS, a0)
    CLR.B   (MENU_BTNINDEX, a0)
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  #DIFF_MENU_PLAYER, (MENU_PLAYER, a0)
    MOVE.B  #DIFF_MENU_CON_MASK, (MENU_CON_MASK, a0)
    MOVE.B  #DIFF_MENU_EX_MASK, (MENU_EX_MASK, a0)

    MOVE.L  #DIFF_MENU_LOOP, (MAIN_VECTOR)
    END_LOAD_STATE
    RTS

; detect if the player has chosen an option on the difficulty menu
DIFF_MENU_LOOP:
    JSR     MENU_CURSOR
    LEA.L   CURR_MENU, a0
    
    TST.B   (MENU_SELECTED, a0)
    BLT.B   _DIFF_MENU_EXIT
    BEQ.B   _DIFF_MENU_RET
    ; if difficulty was selected, calculate speed and start game
    MOVE.B  (MENU_BTNINDEX, a0), d0
    EXT.W   d0
    ; frames b/w physics updates = 15 - 3 * (difficulty - 1)
    MOVEQ   #15, d1
    SUB.W   d0, d1
    SUB.W   d0, d1
    SUB.W   d0, d1
    MOVE.W  d1, (UPDATE_MAX)
    MOVE.L  #GAME_INIT, (MAIN_VECTOR)
    BRA.B   _DIFF_MENU_RET
    ; if exitted, return to main menu
_DIFF_MENU_EXIT:
    MOVE.L  #MAIN_MENU_INIT, (MAIN_VECTOR)
_DIFF_MENU_RET:
    RTS

OPT_MENU_TX = 14
OPT_MENU_TX2 = OPT_MENU_TX+8
OPT_MENU_TY = 12
OPT_MENU_PX = $80+(OPT_MENU_TX-2)*8
OPT_MENU_PY = $80+OPT_MENU_TY*8
OPT_MENU_VSPACE = $10
OPT_MENU_NBUTTONS = 2
OPT_MENU_PLAYER = 0
OPT_MENU_CON_MASK = %01000000
OPT_MENU_EX_MASK = %10010000
OPT_MENU_PLANE = BUFF_PLANE+(OPT_MENU_TX*2)+(OPT_MENU_TY*128)

OPT_MENU_INIT:
    LOAD_STATE_SOFT

    JSR     CLEAR_BUFF_PLANE

    LEA.L   STR_OPTIONS, a0
    MOVEQ   #OPT_MENU_TX+2, d3
    MOVEQ   #OPT_MENU_TY-2, d4
    JSR     DRAW_STRING

    LEA.L   STR_MUSIC, a0
    MOVEQ   #OPT_MENU_TX, d3
    MOVEQ   #OPT_MENU_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_ON, a0
    TST.W   (MUSIC_ON)
    BNE.B   _DRAW_ON_OFF
    LEA.L   STR_OFF, a0
_DRAW_ON_OFF:
    MOVEQ   #OPT_MENU_TX2, d3
    MOVEQ   #OPT_MENU_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_CREDITS, a0
    MOVEQ   #OPT_MENU_TX, d3
    MOVEQ   #OPT_MENU_TY+2, d4
    JSR     DRAW_STRING

    LEA.L   CURR_MENU, a0
    MOVE.W  #OPT_MENU_PX, (MENU_XPOS, a0)
    MOVE.W  #OPT_MENU_PY, (MENU_YPOS, a0)
    MOVE.W  #OPT_MENU_VSPACE, (MENU_YSPACING, a0)
    MOVE.B  #OPT_MENU_NBUTTONS, (MENU_NBUTTONS, a0)
    CLR.B   (MENU_BTNINDEX, a0)
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  #OPT_MENU_PLAYER, (MENU_PLAYER, a0)
    MOVE.B  #OPT_MENU_CON_MASK, (MENU_CON_MASK, a0)
    MOVE.B  #OPT_MENU_EX_MASK, (MENU_EX_MASK, a0)

    MOVE.L  #OPT_MENU_LOOP, (MAIN_VECTOR)
    END_LOAD_STATE
    RTS

OPT_MENU_LOOP:
    JSR     MENU_CURSOR
    LEA.L   CURR_MENU, a0

    TST.B   (MENU_SELECTED, a0)
    BLT.B   _EXIT
    BEQ.B   _RET
    
    ; an option was selected:
    MOVE.B  (MENU_BTNINDEX, a0), d0
    TST.B   d0
    BEQ.B   _MUSIC
    ; music toggle wasn't selected. Currently, this means credits must be selected
    LEA.L   STR_MISSING, a0
    MOVEQ   #OPT_MENU_TX2, d3
    MOVEQ   #OPT_MENU_TY+2, d4
    JSR     DRAW_STRING
    BRA.B   _RET

_MUSIC:
    ; music toggled:
    TST.W   (MUSIC_ON)
    BNE.B   _MUSIC_OFF
    ; turn music on:
    MOVE.W  #-1, (MUSIC_ON)
    LEA.L   STR_ON, a0
    MOVEQ   #OPT_MENU_TX2, d3
    MOVEQ   #OPT_MENU_TY, d4
    JSR     DRAW_STRING
    ; append a space to hide the last 'F' in 'OFF'
    LEA.L   SCRATCH, a0
    MOVE.W  #' '<<8, (a0)
    ADDQ.W  #2, d3
    JSR     DRAW_STRING
    BRA.B   _RET
_MUSIC_OFF:
    ; turn music off:
    CLR.W   (MUSIC_ON)
    LEA.L   STR_OFF, a0
    MOVEQ   #OPT_MENU_TX2, d3
    MOVEQ   #OPT_MENU_TY, d4
    JSR     DRAW_STRING
    BRA.B   _RET

_EXIT:
    MOVE.L  #MAIN_MENU_INIT, (MAIN_VECTOR)
_RET:
    RTS
