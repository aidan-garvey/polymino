
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
MENU_SELECTED = 8   ; 1B - has the button in BTNINDEX been selected with an A press?
MENU_PLAYER = 9     ; 1B - does player 1 or 2 have control of this menu? (0 = p1, 1 = p2)

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
    BEQ.B   @MENU_CURSOR_P1
    ; if player 2, point to JOY2 instead
    ADDQ.W  #2, a1
@MENU_CURSOR_P1:
    MOVE.W  (a1), d0    ; d0 := current inputs
    MOVE.W  4(a1), d1   ; d1 := previous inputs
    
    EOR.W   d0, d1      ; d1 := inputs that changed
    AND.W   d1, d0      ; d0 := inputs that changed and pressed this frame

    LEA.L   CURSOR_SPRITE, a1
    ; copy menu X position to cursor sprite
    MOVE.W  (a0), 6(a1)

    ; move the cursor
    BTST    #BUTTON_UP, d0
    BEQ.B   @SKIP_UP
    ; don't allow pressing up and down
    BTST    #BUTTON_DOWN, d0
    BNE.B   @SKIP_MOVE
    ; make cursor wrap around if it is at the top
    TST.B   (MENU_BTNINDEX, a0)
    BNE.B   @MOVE_UP_SUB
    MOVE.B  (MENU_NBUTTONS, a0), (MENU_BTNINDEX, a0)
@MOVE_UP_SUB:
    ; move up
    SUBQ.B  #1, (MENU_BTNINDEX, a0)
    BRA.B   @SKIP_MOVE
@SKIP_UP:
    BTST    #BUTTON_DOWN, d0
    BEQ.B   @SKIP_MOVE
    ; move down
    MOVE.B  (MENU_BTNINDEX, a0), d1
    ADDQ.B  #1, d1
    CMP.B   (MENU_NBUTTONS), d1
    BLT.B   @MOVE_DOWN_WRITE
    ; if cursor is below bottom, wrap around to top
    MOVEQ   #0, d1
@MOVE_DOWN_WRITE:
    MOVE.B  d1, (MENU_BTNINDEX, a0)
@SKIP_MOVE:

    ; calculate y position of cursor sprite
    MOVE.B  (MENU_BTNINDEX, a0), d1
    EXT.W   d1
    MOVE.B  (MENU_YSPACING, a0), d2
    EXT.W   d2
    MULU.W  d2, d1
    ADD.W   (MENU_YPOS, a0), d1
    ; copy to sprite table buffer
    MOVE.W  d1, (a1)

    ; check for A press
    BTST    #BUTTON_A, d0
    BNE.B   @SKIP_SELECTED
    MOVE.B  #-1, (MENU_SELECTED, a0)
@SKIP_SELECTED:

    POP     a0/a1/d0/d1
    RTS
    


MAIN_MENU_INIT:
    ; ...
    MOVE.L  #MAIN_MENU_LOOP, (MAIN_VECTOR)
    RTS

MAIN_MENU_LOOP:
    ; ...
    RTS

; ===========================
; UPDATE_PAUSED
; ---------------------------
; Pause/unpause the game when
; player 1 presses start
; ---------------------------
; Thrashed:
; ===========================
UPDATE_PAUSED:
    MOVE.W  (JOY1), d0    ; current joypad inputs
    MOVE.W  (JOY1+4), d1   ; previous frame's inputs
    ; to get buttons pressed this frame but not held:
    ; XOR new inputs into old inputs, then AND result with new inputs
    EOR.W   d0, d1
    AND.W   d0, d1  ; d1 indicates buttons pressed for the first frame

    ; if start not pressed, return
    BTST    #7, d1
    BEQ     @UPDATE_PAUSED_RET
    BCHG    #0, (GAME_PAUSED) ; toggle game pause

@UPDATE_PAUSED_RET:
    RTS