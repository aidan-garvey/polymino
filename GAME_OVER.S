
; *****************************************************************
; GAME_OVER.S
; Contains subroutine for game over animation.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; =====================================
; GAME_OVER_ANIM
; -------------------------------------
; When the player's game ends, run this
; animation to create the appearance of
; their blocks falling off the screen.
; Also checks if both players have lost
; and, if so, advances the game phase.
; -------------------------------------
; Parameters:
;   a2 - player game state
;   a4 - screen buffer
;   a5 - player cursor
; Thrashed:
;   a0, d0, d3-d4
; =====================================
GAME_OVER_ANIM:
    PUSH.L  a2
    ; hide player's cursor
    CLR.W   (a5)
    ; hide next junk outline
    CLR.W   (P1_OUTLINE-P1_SPRITE, a5)

    ADDQ.W  #1, (GAME_OVER_T_OFF, a2)
    MOVE.W  (GAME_OVER_T_OFF, a2), d0
    ; only update every X frames
    ANDI.W  #GAME_OVER_MASK, d0
    BNE.B   _RET

    ; clear the bottom row of blocks
    MOVEA.L a2, a0
    MOVEQ   #BOARD_WIDTH-1, d3
    MOVEQ   #BOARD_HEIGHT-1, d4

_CLEAR_ROW_LOOP:
    CLR.W   -(a0)
    JSR     ERASE_BLOCK
    DBRA    d3, _CLEAR_ROW_LOOP

    ; move all blocks down by 1
    ; a2 now points to block below a0
    ; d4 still equals height-1, which is what we want
_MOVE_ROW:
    MOVEQ   #BOARD_WIDTH-1, d3
_MOVE_BLOCK:
    SUBQ.L  #2, a2
    TST.W   -(a0)
    BEQ.B   _BLOCK_STEP
    JSR     SWAP_BLOCKS_V
    MOVE.W  (a0), (a2)
    CLR.W   (a0)
_BLOCK_STEP:
    DBRA    d3, _MOVE_BLOCK
    ; break if row number <= 0
    SUBQ.W  #1, d4
    BGT.B   _MOVE_ROW

    ; if both players lost, switch main vector subroutine
    TST.W   (GAME_OVER_1)
    BEQ.B   _RET

    TST.W   (GAME_OVER_2)
    BEQ.B   _RET

    ; don't change anything if we've already advanced the phase of the game
    CMP.L   #GAME_LOOP, (MAIN_VECTOR)
    BNE.B   _RET

    MOVE.L  #GAME_OVER_WAIT_1, (MAIN_VECTOR)
    CLR.W   (MAIN_TICK)

_RET:
    POP.L   a2
    RTS

; ========================================
; GAME_OVER_WAIT_1
; ----------------------------------------
; Update particles and play GAME_OVER_ANIM
; for a handful of frames before the next
; phase of the game over sequence
; ========================================

GAME_OVER_WAIT_1:
_LEN = 10
    JSR     UPDATE_PARTICLES

    LEA.L   GAME_STATE_1, a2
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    LEA.L   P1_SPRITE, a5
    JSR     GAME_OVER_ANIM

    CMP.W   #1, (NUM_PLAYERS)
    BEQ.B   _SKIP_P2

    LEA.L   GAME_STATE_2, a2
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    LEA.L   P2_SPRITE, a5
    JSR     GAME_OVER_ANIM
_SKIP_P2:

    ; if we've waited enough frames, move onto next phase
    CMP.W   #_LEN, (MAIN_TICK)
    BLT.B   _RET

    MOVE.L  #GAME_OVER_INIT, (MAIN_VECTOR)

_RET:
    RTS

; ========================================================
; GAME_OVER_INIT
; --------------------------------------------------------
; Clear all particles and load the "GAME OVER" sprite into
; VRAM where the first two particles would normally go
; ========================================================
GAME_OVER_INIT:
_X = $80+(40*4)
_VEL = 0
_ACC = GRAVITY

    JSR     DELETE_PARTICLES
    LEA.L   PART_SPRITES, a0
    ; make previous sprite point to game over sprite
    MOVE.B  #MENU_CURSOR_LNK, -5(a0)
    ; left sprite data
    MOVE.W  #$40, (a0)+ ; Y pos
    MOVE.W  #$0F00|GAMEOVR_LNK_1, (a0)+ ; 4x4 size
    MOVE.W  #$8000|GAMEOVR_GFX_CHAR, (a0)+
    MOVE.W  #_X-32, (a0)+
    ; right sprite data
    MOVE.W  #$40, (a0)+
    MOVE.W  #$0F00, (a0)+
    MOVE.W  #$8000|GAMEOVR_GFX_CHAR+16, (a0)+
    MOVE.W  #_X, (a0)

    ; write vertical speed and acceleration of message to
    ; particle data area (not in same format as particles)
    LEA.L   PART_DATA, a0
    MOVE.W  #_VEL, (a0)+
    MOVE.W  #_ACC, (a0)

    CLR.W   (MAIN_TICK)
    MOVE.L  #GAME_OVER_ANIM_2, (MAIN_VECTOR)
    RTS

; ==============================================
; GAME_OVER_ANIM_2
; ----------------------------------------------
; Make the "GAME OVER" message drop into screen,
; wait for player 1 to press a button
; ==============================================
GAME_OVER_ANIM_2:
_REFLECT = ($80+28*4-4*4)<<4

    ; keep playing GAME_OVER_ANIM
    LEA.L   GAME_STATE_1, a2
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    LEA.L   P1_SPRITE, a5
    JSR     GAME_OVER_ANIM

    CMP.W   #1, (NUM_PLAYERS)
    BEQ.B   _SKIP_P2

    LEA.L   GAME_STATE_2, a2
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    LEA.L   P2_SPRITE, a5
    JSR     GAME_OVER_ANIM
_SKIP_P2:

    MOVE.W  (JOY1), d0
    MOVE.W  (JOY1_OLD), d1
    EOR.W   d0, d1  ; d1 indicates change in button status
    AND.W   d1, d0  ; d0 indicates newly pressed this frame
    AND.W   #$00F0, d0 ; ignore d-pad inputs
    BEQ.B   _NO_PRESS
    ; if button was pressed, clean up the game and return to start screen
    MOVE.L  #PAUSE_EXIT_INIT, (MAIN_VECTOR)
_NO_PRESS:

    ; update position of message
    LEA.L   PART_DATA+2, a0
    ; add accel to velocity
    MOVE.W  (a0), d0
    ADD.W   d0, -(a0)
    ; add velocity to position
    MOVE.W  (a0), d0
    LEA.L   PART_SPRITES, a1
    MOVE.W  (a1), d1
    ROL.W   #4, d1  ; d1 := y pos with subpixels
    ADD.W   d0, d1
    ; if new position is too low, flip velocity to make message bounce
    CMP.W   #_REFLECT, d1
    BLT.B   _NOREF
    ; only flip velocity if it's positive
    TST.W   d0
    BLE.B   _NOREF
    ; flip velocity and divide by 2 so bounce decreases over time
    ASR.W   #1, d0
    NEG.W   d0
    BNE.B   _SAVEVEL
    ; if velocity reaches zero after flipping, clear acceleration
    CLR.W   2(a0)
_SAVEVEL:
    ; save new velocity
    MOVE.W  d0, (a0)

_NOREF:
    ; save position
    ROR.W   #4, d1
    MOVE.W  d1, (a1)
    ADDQ.L  #PART_SPRITE_SIZE, a1
    MOVE.W  d1, (a1)

    RTS

