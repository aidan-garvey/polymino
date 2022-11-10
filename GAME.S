
; *****************************************************************
; GAME.S
; Main vector subroutines for initializing and running the game.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ====================================================
; GAME_INIT
; ----------------------------------------------------
; Do all necessary preparation for GAME_LOOP to be run
; ====================================================
GAME_INIT:
    LOAD_STATE_HARD

    JSR     CLEAR_BUFF_PLANE
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_SCROLLB_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLB, d2
    JSR     DMADump

    END_LOAD_STATE
    LOAD_STATE_HARD

    ; use lower PCM sample rate for BGM music
    MOVEQ   #$04, d0
    JSR     Echo_SetPCMRate

    ; load palettes
    
    ; palette 1: first blocks palette
    LEA.L   BLOCK_PALETTE_1, a0
    MOVEQ   #1, d0
    JSR     LOAD_PALETTE

    ; palettes 2: second blocks palette
    LEA.L   BLOCK_PALETTE_2, a0
    MOVEQ   #2, d0
    JSR     LOAD_PALETTE

    ; palette 3: background
    LEA.L   CIRCUIT_PAL, a0
    MOVEQ   #3, d0
    JSR     LOAD_PALETTE

    ; JSR     DUMP_PALETTES
    MOVE.W  #-1, (PAL_UPDATE)

    ; set background color
    VDP_REG 7, $30

    ; load block graphics into VRAM
    MOVE.L  #BLOCK_CHARS, d0    ; address
    MOVE.W  #16*8, d1           ; 16 words * 8 chars
    MOVE.W  #VRAM_BLOCK_GFX, d2 ; start at tile 1 (address $20)
    JSR     DMADump

    ; uncompress "GAME OVER" sprite graphics for later use
    LEA.L   GAME_OVER_ROWS, a0
    LEA.L   GAME_OVER_CHARS, a1
    LEA.L   BUFF_PLANE, a2
    MOVEQ   #32, d0
    JSR     UNCOMPRESS

    ; transfer to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #32*16, d1
    MOVE.W  #VRAM_GAMEOVR_GFX, d2
    JSR     DMADump

    ; enable vertical scrolling of SCROLL B
    MOVE.W  #-1, (VSCROLL_ON)
    
    ; global state, skipping the first two words:
        ; first word is number of players, determined in main menu
        ; second word is frames b/w physics updates, determined by difficulty selection
    LEA.L   GLOBAL_STATE+4, a0
    MOVE.W  #0, (a0)+   ; counter for physics updates
    MOVE.W  #JUNK_T_UPDATES, (a0)+  ; physics updates b/w junk
    MOVE.W  #0, (a0)+   ; game is not paused

    ; player 1:

    ; clear board data
    LEA.L   BOARD_1, a0
    MOVE.W  #(BOARD_WIDTH*BOARD_HEIGHT/2)-1, d0
_CLEAR_BOARD_1:
    CLR.L   (a0)+
    DBRA    d0, _CLEAR_BOARD_1

    ; game state
    LEA.L   GAME_STATE_1, a0
    LEA.L   INITIAL_GAME_STATE, a1
    MOVE.W  #GAME_STATE_SIZE/4, d0
_WRITE_STATE_1:
    MOVE.L  (a1)+, (a0)+
    DBRA    d0, _WRITE_STATE_1

    ; player-specific constants
    MOVE.W  #P1_BOARD_TX, (BOARD_TX_1)
    BCLR.B  #PART_PLAYER_FLAG_B, (PART_P_FLAG_1)
    MOVE.W  #P1_OUTLINE-BUFF_SPRITES, (OUTLINE_SP_1)

    ; player 2:

    ; clear board data
    LEA.L   BOARD_2, a0
    MOVE.W  #(BOARD_WIDTH*BOARD_HEIGHT/2)-1, d0
_CLEAR_BOARD_2:
    CLR.L   (a0)+
    DBRA    d0, _CLEAR_BOARD_2

    ; game state
    LEA.L   GAME_STATE_2, a0
    LEA.L   INITIAL_GAME_STATE, a1
    MOVE.W  #GAME_STATE_SIZE/4, d0
_WRITE_STATE_2:
    MOVE.L  (a1)+, (a0)+
    DBRA    d0, _WRITE_STATE_2
    
    ; player-specific constants
    MOVE.W  #P2_BOARD_TX, (BOARD_TX_2)
    BSET.B  #PART_PLAYER_FLAG_B, (PART_P_FLAG_2)
    MOVE.W  #P2_OUTLINE-BUFF_SPRITES, (OUTLINE_SP_2)

    JSR     RAND_SEED       ; initialize pseudorandom number generator

    JSR     INIT_CIRC_CHARS ; copy background chars to VRAM
    JSR     INIT_CIRC_PLANE ; copy background patterns to VRAM
    JSR     INIT_HUD        ; initialize UI sprites for both players
    JSR     INIT_JUNK       ; generate chars for junk, copy to VRAM
    JSR     INIT_PARTICLES  ; copy particle graphics to VRAM

    ; must be done last since SCROLLA needs to be persistent
    ; in BUFF_PLANE for the duration of a game
    JSR     INIT_SCROLLA

    ; generate initial blocks for both players
    LEA.L   GAME_STATE_1, a2
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    JSR     GENERATE_ROWS
 
    ; set game over = true for player 2, will be cleared if 2 players selected
    MOVE.W  #-1, (GAME_OVER_2)
    CMP.W   #1, (NUM_PLAYERS)
    BEQ.B   _GAME_INIT_END
    
    CLR.W   (GAME_OVER_2)
    LEA.L   GAME_STATE_2, a2
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    JSR     GENERATE_ROWS

_GAME_INIT_END:
    MOVE.L  #0, (MAIN_TICK) ; init main and frame tick, each is 2B

    MOVE.L  #GAME_LOOP, (MAIN_VECTOR)

    ; play background music if enabled
    TST.W   (MUSIC_ON)
    BEQ.B   _RET
    ; randomly choose track 1 or 2
    LEA.L   ESF_BGM_1, a0
    JSR     RAND
    BTST    #0, d0
    BEQ.B   _PLAY_BGM
    LEA.L   ESF_BGM_2, a0
_PLAY_BGM:
    JSR     Echo_PlayBGM

_RET:
    END_LOAD_STATE_HARD
    RTS

; ==========================================================
; GAME_LOOP
; ----------------------------------------------------------
; Performs all game logic for P1, then for P2 if multiplayer
; ==========================================================
GAME_LOOP:
    JSR     UPDATE_PAUSED

    ; move particles, called once for both players
    JSR     UPDATE_PARTICLES

    ; update timers
    LEA.L   UPDATE_TIMER, a0
    ADD.W   #1, (a0)
    ; compare update timer to timer limit
    MOVE.W  (a0), d0
    CMP.W   -(a0), d0
    BLT.B   _SKIP_UPDATE_RESET
    CLR.W   2(a0)    ; if we're at the limit, reset timer
    
_SKIP_UPDATE_RESET:

    ; needed addresses:
    LEA.L   PLAYER_1_DATA, a1   ; start of board for P1
    LEA.L   GAME_STATE_1, a2    ; start of game state for P1
    LEA.L   JOY1, a3            ; joypad inputs for P1
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4 ; scroll plane buffer for P1's board
    LEA.L   P1_SPRITE, a5

    CMPI.W  #1, (NUM_PLAYERS)
    BEQ.B   _LOOP_START ; if 1 player, run main loop for P1
    BSR     _LOOP_START ; if 2 players, run main loop for P1, then P2

    ; re-configure pointers for P2 data
    LEA.L   PLAYER_2_DATA, a1
    LEA.L   GAME_STATE_2, a2
    LEA.L   JOY2, a3
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    LEA.L   P2_SPRITE, a5

_LOOP_START:
    ; if game is over, play game over animation then return from subroutine
    TST.W   (GAME_OVER_OFF, a2)
    BEQ.B   _NOT_GAME_OVER

    JSR     GAME_OVER_ANIM
    BRA.W   _GAME_LOOP_END

_NOT_GAME_OVER:
    ; handle inputs from player
    JSR     PLAYER_ACTIONS
    ; if update timer is at zero, update game physics
    TST.W   (UPDATE_TIMER)
    BNE.B   _SKIP_UPDATE_PHYSICS
    JSR     UPDATE_PHYSICS
    ; when we update physics, increment junk timer
    ADDQ.W  #1, (JUNK_TIMER_OFF, a2)
    MOVE.W  (JUNK_TIMER_OFF, a2), d0
    CMP.W   (JUNK_MAX), d0
    BLT.B   _SKIP_MATCH_ALL
    CLR.W   (JUNK_TIMER_OFF, a2)

    BRA.B   _SKIP_MATCH_ALL
_SKIP_UPDATE_PHYSICS:
    ; to spread the load, update matches the frame before physics
    MOVE.W  (UPDATE_MAX), d0
    SUBQ    #1, d0
    CMP.W   (UPDATE_TIMER), d0
    BNE.B   _SKIP_MATCH_ALL
    JSR     CHECK_ALL_MATCHES
_SKIP_MATCH_ALL:

    ; if junk timer is at zero, place junk
    TST.W   (JUNK_TIMER_OFF, a2)
    BNE.B   _SKIP_PLACE_JUNK
    JSR     PLACE_NEW_JUNK  ; should set an indicator for game over if applicable
    MOVE.W  #1, (JUNK_TIMER_OFF, a2)
    ; since new junk spawned, we'll need to check if it can be shattered
    MOVE.W  #-1, (CHECK_PROJ_OFF, a2)
    ; we also need to update the cursor for the next junk piece
    JSR     DRAW_JUNK_OUTLINE
_SKIP_PLACE_JUNK:

    ; remove any matched blocks from the board
    JSR     CLEAR_BLOCKS

    ; check current player's projectiles, see if they can destroy junk.
    ; only run once a new projectile or junk piece is spawned, or junk
    ; moves during a physics update
    TST.W   (CHECK_PROJ_OFF, a2)
    BEQ.B   _SKIP_PROJ_CHECK
    JSR     PROJ_CHECK
    CLR.W   (CHECK_PROJ_OFF, a2)
_SKIP_PROJ_CHECK:

    ; for any junk being shattered by projectiles,
    ; advance its animation or replace it with a block
    JSR     SHATTER_ANIM

    ; write to sprite buffer
    JSR     DRAW_CURSOR

    ; convert binary score to BCD so it can be displayed
    JSR     UPDATE_BCD_SCORE

    ; write digit characters to where score sprites get their chars
    JSR     DRAW_SCORE

    ; same as DRAW_SCORE, but for bomb count
    JSR     DRAW_BOMBS

_GAME_LOOP_END:
    RTS
