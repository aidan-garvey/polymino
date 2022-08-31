
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

    MOVE.L  #GAME_OVER_INIT_1, (MAIN_VECTOR)

_RET:
    RTS

; ========================================================
; GAME_OVER_INIT
; --------------------------------------------------------
; Clear all particles and load the "GAME OVER" sprite into
; VRAM where the first two particles would normally go
; ========================================================
GAME_OVER_INIT_1:
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
    ; if velocity reaches zero after flipping, clear acceleration and advance animation
    CLR.W   2(a0)
    MOVE.L  #GAME_OVER_INIT_2, (MAIN_VECTOR)
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

; ==================================================================
; GAME_OVER_INIT_2
; ------------------------------------------------------------------
; Convert each tile of the "GAME OVER" message into a particle to
; shatter the message. These particles don't use the usual format or
; code since they don't belong to either player and only get deleted
; when they're completely off-screen, not off of one of the boards.
; ==================================================================
GAME_OVER_INIT_2:
    ; check inputs to see if we should leave
    MOVE.W  (JOY1), d0
    MOVE.W  (JOY1_OLD), d1
    EOR.W   d0, d1  ; d1 indicates change in button status
    AND.W   d1, d0  ; d0 indicates newly pressed this frame
    AND.W   #$00F0, d0 ; ignore d-pad inputs
    BEQ.B   _NO_PRESS
    ; if button was pressed, clean up the game and return to start screen
    MOVE.L  #PAUSE_EXIT_INIT, (MAIN_VECTOR)
    BRA.B   _RET
_NO_PRESS:

    ; **************
    ; init particles
    ; **************
    ; FIRST PART: set sprite attributes for all 32 particles
    LEA.L   PART_SPRITES, a0
    
    ; d0 tracks which char each sprite will use
    MOVE.W  #GAMEOVR_GFX_CHAR, d0
    ; set MSB to make sprites high priority
    BSET    #15, d0
    ; d1 tracks link data each sprite will use
    MOVEQ   #GAMEOVR_LNK_1, d1
    MOVE.W  (a0), d2    ; d2 := "GAME OVER" y position
    MOVE.W  6(a0), d3   ; d3 := "GAME OVER" x position

    MOVEQ   #7, d7      ; d7 := column loop counter

_SP_COL:
    MOVE.W  d2, d4
    MOVEQ   #3, d6      ; d6 := tile loop counter
_SP_TILE:
    MOVE.W  d4, (a0)+   ; y pos
    ADDQ.W  #8, d4
    MOVE.W  d1, (a0)+   ; link data
    ADDQ.W  #1, d1
    MOVE.W  d0, (a0)+   ; character number
    ADDQ.W  #1, d0
    MOVE.W  d3, (a0)+   ; x pos
    DBRA    d6, _SP_TILE
    ; after each column, increase X coordinate
    ADDQ.W  #8, d3
    DBRA    d7, _SP_COL

    ; SECOND PART: set particle velocity and acceleration
    LEA.L   PART_DATA, a0

    ; we'll be using these 2 values a lot
    MOVE.L  #GAMEOVR_VEL_MASK, d4
    MOVEQ   #15, d7  ; loop counter, total particles / 2
_P_LOOP:
    ; put random x and y velocity for 1 particle each in d0 & d1
    JSR     RAND
    AND.L   d4, d0
    AND.L   d4, d1
    ; x velocity will be in range [-$20, +$1F]
    MOVEQ   #$20, d5
    SWAP    d0
    SWAP    d1
    SUB.W   d5, d0
    SUB.W   d5, d1
    ; y velocity will be in range [-$40, -$1]
    ADD.W   d5, d5
    SWAP    d0
    SWAP    d1
    SUB.W   d5, d0
    SUB.W   d5, d1
    ; write particle data
    MOVE.L  d0, (a0)+
    MOVE.L  d1, (a0)+
    DBRA    d7, _P_LOOP

    MOVE.L  #GAME_OVER_ANIM_3, (MAIN_VECTOR)
_RET:
    RTS

; =========================================================
; GAME_OVER_ANIM_3
; ---------------------------------------------------------
; Play the shattering animation for the game over message,
; if player 1 presses a button then return to the main menu
; =========================================================
GAME_OVER_ANIM_3:
    ; update the particles
    LEA.L   PART_SPRITES, a0
    LEA.L   PART_DATA, a1
    MOVE.W  #$15F<<4, d5 ; bottom screen bound
    MOVEQ   #GRAVITY, d6
    MOVEQ   #31, d7 ; loop over each particle

_LOOP:
    ; skip particle if deleted
    TST.W   (a0)
    BEQ.B   _STEP

    ; update velocity by adding gravity to y velocity
    MOVE.L  (a1), d0
    ADD.W   d6, d0
    MOVE.L  d0, (a1)
    ; update y pos, delete if off screen
    MOVE.W  (a0), d1
    ROL.W   #4, d1
    ADD.W   d0, d1
    ; check if off screen
    CMP.W   d5, d1
    BGE.B   _DELETE
    ; not deleted: save y pos
    ROR.W   #4, d1
    MOVE.W  d1, (a0)

    ; update x position
    SWAP    d0
    MOVE.W  6(a0), d1
    ROL.W   #4, d1
    ADD.W   d0, d1
    ROR.W   #4, d1
    MOVE.W  d1, 6(a0)

_STEP:
    ADDQ.L  #8, a0
    ADDQ.L  #4, a1
    DBRA    d7, _LOOP
    BRA.B   _LOOPEND

_DELETE:
    CLR.W   (a0)
    BRA.B   _STEP

_LOOPEND:
    ; check player input to see if we should leave
    MOVE.W  (JOY1), d0
    MOVE.W  (JOY1_OLD), d1
    EOR.W   d0, d1  ; d1 indicates change in button status
    AND.W   d1, d0  ; d0 indicates newly pressed this frame
    AND.W   #$00F0, d0 ; ignore d-pad inputs
    BEQ.B   _NO_PRESS
    ; if button was pressed, clean up the game and return to start screen
    MOVE.L  #PAUSE_EXIT_INIT, (MAIN_VECTOR)
_NO_PRESS:
    RTS
