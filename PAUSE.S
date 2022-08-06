
; *****************************************************************
; PAUSE.S
; Subroutines that handle pausing the game and the pause menus
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ===============================================
; UPDATE_PAUSED
; -----------------------------------------------
; Pause the game when player 1 or 2 presses start
; -----------------------------------------------
; Thrashed: d0-d1
; ===============================================
UPDATE_PAUSED:
    ; check for P1 pressing start
    MOVE.W  (JOY1), d0    ; current joypad inputs
    MOVE.W  (JOY1+4), d1   ; previous frame's inputs
    ; to get buttons pressed this frame but not held:
    ; XOR new inputs into old inputs, then AND result with new inputs
    EOR.W   d0, d1
    AND.W   d0, d1  ; d1 indicates buttons pressed for the first frame

    ; if start pressed by P1, pause
    BTST    #BUTTON_START, d1
    BEQ.B   @UPDATE_PAUSED_P2
    MOVE.L  #INIT_PAUSED_P1, (MAIN_VECTOR)
    BRA.B   @UPDATE_PAUSED_RET

@UPDATE_PAUSED_P2:
    MOVE.W  (JOY2), d0
    MOVE.W  (JOY2+4), d1
    EOR.W   d0, d1
    AND.W   d0, d1

    ; if start pressed by P2, pause
    BTST    #BUTTON_START, d1
    BEQ.B   @UPDATE_PAUSED_RET
    MOVE.L  #INIT_PAUSED_P2, (MAIN_VECTOR)

@UPDATE_PAUSED_RET:
    RTS

; constants for P1's pause menu, or shared by P1 and P2
PAUSE1_TX = 17
PAUSE_TY = 12
PAUSE1_XPOS = 15*8+$80
PAUSE_YPOS = 12*8+$80
PAUSE_YSPACING = $10
PAUSE1_NBUTTONS = 2
PAUSE1_PLAYER = 0
PAUSE_CON_MASK = %01000000 ; A
PAUSE_EX_MASK = %10010000 ; START, B
PAUSE1_BUFF = BUFF_PLANE+(15*2)+(9*128)

; set up player 1's pause menu
INIT_PAUSED_P1:
    ; initialize menu
    LEA.L   CURR_MENU, a0
    MOVE.W  #PAUSE1_XPOS, (MENU_XPOS, a0)
    MOVE.W  #PAUSE_YPOS, (MENU_YPOS, a0)
    MOVE.W  #PAUSE_YSPACING, (MENU_YSPACING, a0)
    MOVE.B  #PAUSE1_NBUTTONS, (MENU_NBUTTONS, a0)
    CLR.B   (MENU_BTNINDEX, a0)
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  #PAUSE1_PLAYER, (MENU_PLAYER, a0)
    MOVE.B  #PAUSE_CON_MASK, (MENU_CON_MASK, a0)
    MOVE.B  #PAUSE_EX_MASK, (MENU_EX_MASK, a0)

    ; save the patterns that the pause menu will overwrite, then clear them
    LEA.L   PAUSE1_BUFF, a0     ; top-left pattern of pause menu's destination
    LEA.L   PAUSE_BUFFER, a1    ; area to save patterns from PAUSE1_BUFF
    MOVEQ   #6, d1  ; 7 rows
@SAVE_BUFF1_ROW:
    MOVEQ   #4, d0  ; 5 long-words for 10 patterns
@SAVE_BUFF1_TILE:
    MOVE.L  (a0), (a1)+
    CLR.L   (a0)+
    DBRA    d0, @SAVE_BUFF1_TILE
    ADDA.W  #BOARD_ROW_GAP, a0
    DBRA    d1, @SAVE_BUFF1_ROW

    ; draw menu
    LEA.L   STR_PAUSE1, a0
    MOVE.W  #PAUSE1_TX-1, d3
    MOVE.W  #PAUSE_TY-2, d4
    JSR     DRAW_STRING

    LEA.L   STR_CONTINUE, a0
    MOVE.W  #PAUSE1_TX, d3
    MOVE.W  #PAUSE_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_QUIT, a0
    MOVE.W  #PAUSE1_TX, d3
    MOVE.W  #PAUSE_TY+2, d4
    JSR     DRAW_STRING

    ; hide both game cursors by moving them off-screen.
    ; will be updated once game resumes by DRAW_CURSOR
    LEA.L   P1_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)
    LEA.L   P2_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)

    MOVE.L  #PAUSE1_LOOP, (MAIN_VECTOR)
    MOVE.W  #-1, (GAME_PAUSED)

    RTS

; constants for P2's pause menu
PAUSE2_TX = 17
PAUSE2_XPOS = 15*8+$80
PAUSE2_NBUTTONS = 1
PAUSE2_PLAYER = 1
PAUSE2_BUFF = BUFF_PLANE+(15*2)+(9*128)

; set up player 2's pause menu
INIT_PAUSED_P2:
    ; initialize menu
    LEA.L   CURR_MENU, a0
    MOVE.W  #PAUSE2_XPOS, (MENU_XPOS, a0)
    MOVE.W  #PAUSE_YPOS, (MENU_YPOS, a0)
    MOVE.W  #PAUSE_YSPACING, (MENU_YSPACING, a0)
    MOVE.B  #PAUSE2_NBUTTONS, (MENU_NBUTTONS, a0)
    CLR.B   (MENU_BTNINDEX, a0)
    CLR.B   (MENU_SELECTED, a0)
    MOVE.B  #PAUSE2_PLAYER, (MENU_PLAYER, a0)
    MOVE.B  #PAUSE_CON_MASK, (MENU_CON_MASK, a0)
    MOVE.B  #PAUSE_EX_MASK, (MENU_EX_MASK, a0)

    ; save the patterns that the pause menu will overwrite
    LEA.L   PAUSE2_BUFF, a0     ; top-left pattern of pause menu's destination
    LEA.L   PAUSE_BUFFER, a1    ; area to save patterns from PAUSE1_BUFF
    MOVEQ   #4, d1  ; 5 rows
@SAVE_BUFF2_ROW:
    MOVEQ   #4, d0  ; 5 long-words for 10 patterns
@SAVE_BUFF2_TILE:
    MOVE.L  (a0), (a1)+
    CLR.L   (a0)+
    DBRA    d0, @SAVE_BUFF2_TILE
    ADDA.W  #BOARD_ROW_GAP, a0
    DBRA    d1, @SAVE_BUFF2_ROW

    ; draw menu
    LEA.L   STR_PAUSE2, a0
    MOVE.W  #PAUSE2_TX-1, d3
    MOVE.W  #PAUSE_TY-2, d4
    JSR     DRAW_STRING

    LEA.L   STR_CONTINUE, a0
    MOVE.W  #PAUSE2_TX, d3
    MOVE.W  #PAUSE_TY, d4
    JSR     DRAW_STRING

    ; hide both game cursors by moving them off-screen.
    ; will be updated once game resumes by DRAW_CURSOR
    LEA.L   P1_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)
    LEA.L   P2_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)

    MOVE.L  #PAUSE2_LOOP, (MAIN_VECTOR)
    MOVE.W  #-1, (GAME_PAUSED)

    RTS

; main game loop subroutine when P1 has paused the game.
; lets P1 unpause with START or B, unpause with the "continue" option, or quit the game
PAUSE1_LOOP:
    JSR     MENU_CURSOR
    LEA.L   CURR_MENU, a0

    TST.B   (MENU_SELECTED, a0)
    BEQ.B   @PAUSE1_RET     ; if no option chosen, do nothing
    BLT.B   @PAUSE1_EXIT    ; if menu exitted, unpause
    TST.B   (MENU_BTNINDEX, a0)
    BEQ.B   @PAUSE1_EXIT    ; if "CONTINUE" was chosen, unpause
    ; if "QUIT" was chosen, return to the start menu
    MOVE.L  #PAUSE_EXIT_INIT, (MAIN_VECTOR)
    BRA.B   @PAUSE1_RET
@PAUSE1_EXIT:
    MOVE.L  #UNPAUSE_1, (MAIN_VECTOR)
@PAUSE1_RET:
    RTS

; main game loop subroutine when P2 has paused the game.
; lets P2 unpause with START or B, or unpause with the "continue" option
PAUSE2_LOOP:
    JSR     MENU_CURSOR
    LEA.L   CURR_MENU, a0

    TST.B   (MENU_SELECTED, a0)
    BEQ.B   @PAUSE2_RET
    ; the only option for P2 is continue, so if any action was taken, unpause
    MOVE.L  #UNPAUSE_2, (MAIN_VECTOR)
@PAUSE2_RET:
    RTS

; to unpause, copy PAUSE_BUFFER back to screen buffer,
; move cursor off screen
UNPAUSE_1:
    ; set menu cursor's x and y to 0
    LEA.L   CURSOR_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)

    ; copy PAUSE_BUFF back to screen buffer
    LEA.L   PAUSE_BUFFER, a0
    LEA.L   PAUSE1_BUFF, a1
    MOVEQ   #6, d1  ; 7 rows
@LOAD_BUFF1_ROW:
    MOVEQ   #4, d0  ; 5 long words for 10 patterns
@LOAD_BUFF1_TILE:
    MOVE.L  (a0)+, (a1)+
    DBRA    d0, @LOAD_BUFF1_TILE
    ADDA.W  #BOARD_ROW_GAP, a1
    DBRA    d1, @LOAD_BUFF1_ROW

    MOVE.L  #GAME_LOOP, (MAIN_VECTOR)
    CLR.W   (GAME_PAUSED)
    RTS

; to unpause, copy PAUSE_BUFFER back to screen buffer,
; move cursor off screen
UNPAUSE_2:
    ; set menu cursor's x and y to 0
    LEA.L   CURSOR_SPRITE, a0
    MOVE.W  #0, (a0)
    MOVE.W  #0, 6(a0)

    ; copy PAUSE_BUFF back to screen buffer
    LEA.L   PAUSE_BUFFER, a0
    LEA.L   PAUSE2_BUFF, a1
    MOVEQ   #4, d1  ; 5 rows
@LOAD_BUFF2_ROW:
    MOVEQ   #4, d0  ; 5 long words for 10 patterns
@LOAD_BUFF2_TILE:
    MOVE.L  (a0)+, (a1)+
    DBRA    d0, @LOAD_BUFF2_TILE
    ADDA.W  #BOARD_ROW_GAP, a1
    DBRA    d1, @LOAD_BUFF2_ROW

    MOVE.L  #GAME_LOOP, (MAIN_VECTOR)
    CLR.W   (GAME_PAUSED)
    RTS

; un-load parts of the game before going back to the start screen
PAUSE_EXIT_INIT:
    LOAD_STATE

    JSR     CLEAR_BUFF_PLANE
    ; use cleared screen buffer to clear SCROLL B
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_SCROLLB_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLB, d2
    JSR     DMADump
    ; delete all sprites
    JSR     CLEAR_BUFF_SPRITES

    CLR.W   (GAME_PAUSED)

    MOVE.L  #STARTSCRN_INIT, (MAIN_VECTOR)
    END_LOAD_STATE
    RTS
