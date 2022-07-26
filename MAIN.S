
; *********************************************************************
;         Beams: A 1-2 player puzzle game for the Sega Genesis
;                   Copyright (C) 2022 Aidan Garvey
; *********************************************************************
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.
; *********************************************************************

    ORG $0000

; ****************************************
; Include files which don't take up memory
; ****************************************
    INCLUDE CONST/RAM_MAP.S
    INCLUDE CONST/CONST_ADDR.S
    INCLUDE CONST/CONST_GAME.S
    INCLUDE CONST/CONST_HW.S
    INCLUDE CONST/CHAR_INDEX.S
    INCLUDE CONST/SPRITE_INDEX.S
    INCLUDE MACROS.S

; **********************
; Cartridge header, code
; **********************
    INCLUDE HEADER.S
    INCLUDE INTERRUPT.S
    INCLUDE STARTUP.S
    INCLUDE SUB_GENERAL.S
    INCLUDE DMA.S
    INCLUDE INPUT.S
    INCLUDE RANDOM.S 

; =============================
; MAIN_INIT
; -----------------------------
; Subroutine to set up the game
; before the main loop is run
; =============================
MAIN_INIT:
    ; palette 0: UI palette
    LEA.L   UI_PALETTE, a0
    MOVEQ   #0, d0
    JSR     LOAD_PALETTE

    ; palette 1: first blocks palette
    LEA.L   BLOCK_PALETTE_1, a0
    MOVEQ   #1, d0
    JSR     LOAD_PALETTE

    ; palettes 2: second blocks palette
    LEA.L   BLOCK_PALETTE_2, a0
    MOVEQ   #2, d0
    JSR     LOAD_PALETTE

    ; palette 3: background
    LEA.L   BCKGND_PAL, a0
    MOVEQ   #3, d0
    JSR     LOAD_PALETTE

    JSR     DUMP_PALETTES

    ; background: palette 0, color 1 (color of SCROLLA mask)
    VDP_REG 7, $01

    ; load block graphics into VRAM
    MOVE.L  #BLOCK_CHARS, d0    ; address
    MOVE.W  #16*8, d1           ; 16 words * 8 chars
    MOVE.W  #VRAM_BLOCK_GFX, d2 ; start at tile 1 (address $20)
    JSR     DMADump

    ; temporary hard-coded game setup
    
    ; global:
    MOVE.L  #GAME_LOOP, (MAIN_VECTOR)
    LEA.L   GLOBAL_STATE, a0
    MOVE.W  #2, (a0)+   ; number of players
    MOVE.W  #10, (a0)+  ; frames b/w physics updates
    MOVE.W  #0, (a0)+   ; counter for above
    MOVE.W  #40, (a0)+  ; physics updates b/w junk
    MOVE.W  #0, (a0)+   ; game is not paused

    ; p1:
    LEA.L   GAME_STATE_1, a0
    MOVE.W  #5, (a0)+       ; starting rows
    MOVE.L  #0, (a0)+       ; bcd score
    MOVE.W  #3, (a0)+       ; lifelines
    MOVE.W  #BOARD_WIDTH/2-1, (a0)+ ; cursor x
    MOVE.W  #BOARD_HEIGHT/2, (a0)+  ; cursor y
    MOVE.L  #0, (a0)+       ; cursor h&v timers
    MOVE.W  #0, (a0)+       ; combo multiplier
    MOVE.W  #0, (a0)+       ; no projectiles to check
    MOVE.W  #0, (a0)+       ; game not over
    MOVE.W  #0, (a0)+       ; game over timer
    LEA.L   JUNK_TIMER_1, a0
    MOVE.W  (JUNK_MAX), (a0)+ ; junk timer
    MOVE.W  #0, (a0)+       ; id of next junk, 0 means it needs to be initialized
    MOVE.W  #0, (a0)+       ; index of next junk piece type

    ; p2:
    LEA.L   GAME_STATE_2, a0
    MOVE.W  #5, (a0)+       ; starting rows
    MOVE.L  #0, (a0)+       ; bcd score
    MOVE.W  #3, (a0)+       ; lifelines
    MOVE.W  #BOARD_WIDTH/2-1, (a0)+ ; cursor x
    MOVE.W  #BOARD_HEIGHT/2, (a0)+  ; cursor y
    MOVE.L  #0, (a0)+       ; cursor h&v timers
    MOVE.W  #0, (a0)+       ; combo multiplier
    MOVE.W  #0, (a0)+       ; no projectiles to check
    MOVE.W  #0, (a0)+       ; game not over
    MOVE.W  #0, (a0)+       ; game over timer
    LEA.L   JUNK_TIMER_2, a0
    MOVE.W  (JUNK_MAX), (a0)+ ; junk timer
    MOVE.W  #0, (a0)+       ; id of next junk
    MOVE.W  #0, (a0)+       ; index of next junk piece type

    JSR     RAND_SEED       ; initialize pseudorandom number generator

    JSR     INIT_BACKGROUND ; copy background to VRAM
    JSR     INIT_HUD        ; initialize UI sprites for both players
    JSR     INIT_JUNK       ; generate chars for junk, copy to VRAM
    JSR     INIT_PARTICLES  ; copy particle graphics to VRAM

    ; must be done last since SCROLLA needs to be persistent
    ; in BUFF_PLANE for the duration of a game
    JSR     INIT_SCROLLA

    MOVE.L  #0, (MAIN_TICK) ; init main and frame tick, each is 2B

    RTS

; ===============================================
; MAIN_LOOP
; -----------------------------------------------
; Executed once per frame. Reads joypad input and
; calls whichever subroutine is in MAIN_VECTOR.
; ===============================================
MAIN_LOOP:
    ; only execute once per frame
    WAIT_VB
    ADD.W   #1, (MAIN_TICK)
    JSR     READ_INPUT
    MOVE.L  (MAIN_VECTOR), a0
    JSR     (a0)
    BRA.B   MAIN_LOOP


; =========================================================
; GAME_LOOP
; ---------------------------------------------------------
; Performs the following for P1, then for P2 if multiplayer
; 1) Generate rows of blocks
; 2) Process player actions
; 3) Update physics, process matches
; 4) Place new junk, game over if no room
; ---------------------------------------------------------
; For each subroutine called by this loop, data registers
; are caller-saved and address registers are callee-saved.
; =========================================================
GAME_LOOP:
    JSR     UPDATE_PAUSED

    ; if game is paused, do not update anything else
    TST.W   (GAME_PAUSED)
    BNE     @GAME_LOOP_END

    ; move particles, called once for both players
    JSR     UPDATE_PARTICLES

    ; update timers
    LEA.L   UPDATE_TIMER, a0
    ADD.W   #1, (a0)
    ; compare update timer to timer limit
    MOVE.W  (a0), d0
    CMP.W   -(a0), d0
    BLT     @SKIP_UPDATE_RESET
    CLR.W   2(a0)    ; if we're at the limit, reset timer
    
@SKIP_UPDATE_RESET:

    ; needed addresses:
    LEA.L   PLAYER_1_DATA, a1   ; start of board for P1
    LEA.L   GAME_STATE_1, a2    ; start of game state for P1
    LEA.L   JOY1, a3            ; joypad inputs for P1
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4 ; scroll plane buffer for P1's board
    LEA.L   P1_SPRITE, a5

    CMPI.W  #1, (NUM_PLAYERS)
    BEQ.B   @LOOP_START ; if 1 player, run main loop once, for P1
    BSR     @LOOP_START ; if 2 players, run main loop for P1, then P2

    ; re-configure pointers for P2 data
    LEA.L   PLAYER_2_DATA, a1
    LEA.L   GAME_STATE_2, a2
    LEA.L   JOY2, a3
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    LEA.L   P2_SPRITE, a5

@LOOP_START:
    ; if game is over, play game over animation then return from subroutine
    TST.W   (GAME_OVER_OFF, a2)
    BEQ.B   @NOT_GAME_OVER

    JSR     GAME_OVER_ANIM
    BRA.W   @GAME_LOOP_END

@NOT_GAME_OVER:
    JSR     GENERATE_ROWS
    ; handle inputs from player
    JSR     PLAYER_ACTIONS
    ; if update timer is at zero, update game physics
    TST.W   (UPDATE_TIMER)
    BNE.B   @SKIP_UPDATE_PHYSICS
    JSR     UPDATE_PHYSICS
    ; when we update physics, increment junk timer
    ADDQ.W  #1, (JUNK_TIMER_OFF, a2)
    MOVE.W  (JUNK_TIMER_OFF, a2), d0
    CMP.W   (JUNK_MAX), d0
    BLT     @SKIP_MATCH_ALL
    CLR.W   (JUNK_TIMER_OFF, a2)

    BRA     @SKIP_MATCH_ALL
@SKIP_UPDATE_PHYSICS:
    ; to spread the load, update matches the frame before physics
    MOVE.W  (UPDATE_MAX), d0
    SUBQ    #1, d0
    CMP.W   (UPDATE_TIMER), d0
    BNE     @SKIP_MATCH_ALL
    JSR     CHECK_ALL_MATCHES
@SKIP_MATCH_ALL:

    ; if junk timer is at zero, place junk
    TST.W   (JUNK_TIMER_OFF, a2)
    BNE.B   @SKIP_PLACE_JUNK
    JSR     PLACE_NEW_JUNK  ; should set an indicator for game over if applicable
    MOVE.W  #1, (JUNK_TIMER_OFF, a2)
    ; since new junk spawned, we'll need to check if it can be shattered
    MOVE.W  #-1, (CHECK_PROJ_OFF, a2)
    ; we also need to update the cursor for the next junk piece
    JSR     DRAW_JUNK_OUTLINE
@SKIP_PLACE_JUNK:

    ; remove any matched blocks from the board
    JSR     CLEAR_BLOCKS

    ; check current player's projectiles, see if they can destroy junk.
    ; only run once a new projectile is spawned, or new junk arrives
    TST.W   (CHECK_PROJ_OFF, a2)
    BEQ.B   @SKIP_PROJ_CHECK
    JSR     PROJ_CHECK
    CLR.W   (CHECK_PROJ_OFF, a2)
@SKIP_PROJ_CHECK:

    ; for any junk being shattered by projectiles,
    ; advance its animation or replace it with a block
    JSR     SHATTER_ANIM

    ; write to sprite buffer
    JSR     DRAW_CURSOR

    ; write digit characters to where score sprites get their chars
    JSR     DRAW_SCORE

@GAME_LOOP_END:
    RTS

; ***********
; SUBROUTINES
; ***********
    INCLUDE MENUS.S
    INCLUDE INIT_GRAPHICS.S
    INCLUDE BOARD.S 
    INCLUDE DRAW.S 
    INCLUDE PARTICLES.S
    INCLUDE SCORE.S
    INCLUDE SUB_JUNK.S
    INCLUDE GAME_OVER.S

; ******
; ASSETS
; ******
    INCLUDE GFX/GFX_UI.S 
    INCLUDE GFX/GFX_BLOCK.S 
    INCLUDE GFX/GFX_BCKGRND.S
    INCLUDE GFX/GFX_TEXT.S
    INCLUDE GFX/GFX_JUNK.S
    INCLUDE GFX/GFX_PARTICLE.S
    INCLUDE GFX/GFX_OUTLINE.S
    INCLUDE JUNK_PIECES.S
