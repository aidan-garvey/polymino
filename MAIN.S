
    ORG $0000

; ****************************************
; Include files which don't take up memory
; ****************************************
    INCLUDE CONST_GAME.S 
    INCLUDE CONST_HW.S 
    INCLUDE RAM_MAP.S 
    INCLUDE MACROS.S

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

    ; palette 1: Blocks palette
    LEA.L   BLOCK_PALETTE, a0
    MOVEQ   #1, d0
    JSR     LOAD_PALETTE

    ; palettes 2, 3: UI (temporary)
    LEA.L   BLOCK_PALETTE, a0
    MOVEQ   #2, d0
    JSR     LOAD_PALETTE

    LEA.L   BCKGND_NIGHT_PAL, a0
    MOVEQ   #3, d0
    JSR     LOAD_PALETTE

    JSR     DUMP_PALETTES

    ; background: palette 3, color 0
    VDP_REG 7, %00110000

    ; load block graphics into VRAM
    MOVE.L  #BLOCK_CHARS, d0    ; address
    MOVE.W  #16*8, d1           ; 16 words * 8 chars
    MOVE.W  #$20, d2            ; start at tile 1 (address $20)
    JSR     DMADump

    ; temporary hard-coded game setup
    
    ; global:
    MOVE.L  #GAME_LOOP, (MAIN_VECTOR)
    MOVE.L  #0, (GAME_TICK)
    LEA.L   GLOBAL_STATE, a0
    MOVE.W  #2, (a0)+   ; number of players
    MOVE.W  #15, (a0)+  ; frames b/w physics updates
    MOVE.W  #0, (a0)+   ; counter for above
    MOVE.W  #40, (a0)+  ; physics updates b/w junk
    MOVE.W  #0, (a0)+   ; counter for above

    ; p1:
    LEA.L   NEW_ROWS_1, a0
    MOVE.W  #6, (a0)+
    MOVE.L  #$0123456, (a0)+; bcd score
    MOVE.W  #3, (a0)+       ; lifelines
    MOVE.W  #1, (a0)+       ; cursor x
    MOVE.W  #1, (a0)+       ; cursor y

    ; p2:
    LEA.L   NEW_ROWS_2, a0
    MOVE.W  #4, (a0)+
    MOVE.L  #$9876543, (a0)+; bcd score
    MOVE.W  #4, (a0)+       ; lifelines
    MOVE.W  #9, (a0)+       ; cursor x
    MOVE.W  #23, (a0)+      ; cursor y

    JSR     RAND_SEED   ; initialize pseudorandom number generator

    JSR     INIT_BACKGROUND ; copy background to VRAM
    ; JSR     INIT_WINDOW ; fill WINDOW patterns
    JSR     INIT_SCROLLA
    JSR     INIT_CURSOR ; initialize cursors for both players

    RTS

; =================================================
; MAIN_LOOP
; -------------------------------------------------
; Executed once per frame. Reads joypad input
; and calls whichever subroutine is in MAIN_VECTOR.
; =================================================
MAIN_LOOP:
    ; only execute once per frame
    WAIT_VB
    ADD.L   #1, (GAME_TICK)
    JSR     READ_INPUT
    MOVE.L  (MAIN_VECTOR), a0
    JSR     (a0)
    BRA     MAIN_LOOP


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
    ; update timers
    LEA.L   UPDATE_TIMER, a0
    ADD.W   #1, (a0)
    ; compare update timer to timer limit
    MOVE.W  (a0), d0
    CMP.W   -(a0), d0
    BLT     @SKIP_UPDATE_RESET
    CLR.W   (a0)    ; if we're at the limit, reset timer
@SKIP_UPDATE_RESET:
    LEA.L   JUNK_TIMER, a0
    ADD.W   #1, (a0)
    ; compare junk timer to timer limit
    MOVE.W  (a0), d0
    CMP.W   -(a0), d0
    BLT     @SKIP_JUNK_RESET
    CLR.W   (a0)
@SKIP_JUNK_RESET:

    ; needed addresses:
    LEA.L   PLAYER_1_DATA, a1   ; start of board for P1
    LEA.L   NEW_ROWS_1, a2      ; start of game state for P1
    LEA.L   JOY1, a3            ; joypad inputs for P1
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4 ; scroll plane buffer for P1's board
    LEA.L   P1_SPRITE, a5

    ; if 2 players, run code twice
    ; MOVE.W  (NUM_PLAYERS), d0
    ; CMPI.W  #1, d0
    CMPI.W  #1, (NUM_PLAYERS)
    BEQ.B   @LOOP_START
    JSR     @LOOP_START
    ; re-configure pointers for P2 data
    LEA.L   PLAYER_2_DATA, a1
    LEA.L   NEW_ROWS_2, a2
    LEA.L   JOY2, a3
    LEA.L   BUFF_PLANE+BOARD2_OFFSET, a4
    LEA.L   P2_SPRITE, a5

@LOOP_START:
    JSR     GENERATE_ROWS
    ; handle inputs from player
    JSR     PLAYER_ACTIONS
    ; if update timer is at zero, update game physics
    TST.W   (UPDATE_TIMER)
    BNE.B   @SKIP_UPDATE_PHYSICS
    JSR     UPDATE_PHYSICS
@SKIP_UPDATE_PHYSICS:
    ; if junk timer is at zero, place junk
    TST.W   (JUNK_TIMER)
    BNE.B   @SKIP_PLACE_JUNK
    JSR     PLACE_NEW_JUNK  ; should set an indicator for game over if applicable
@SKIP_PLACE_JUNK:
    ; convert game board to graphics, place in scroll plane buffer
    JSR     DRAW_BOARD

    ; write info such as score to scroll plane buffer
    JSR     DRAW_INFO

    ; write to sprite buffer
    JSR     DRAW_SPRITES

    RTS

; ***********
; SUBROUTINES
; ***********
    INCLUDE INTERFACE.S
    INCLUDE BOARD.S 
    INCLUDE DRAW.S 
    

; ******
; ASSETS
; ******
    INCLUDE UI_GFX.S 
    INCLUDE BLOCK_GFX.S 
    INCLUDE BCKGND_GFX.S