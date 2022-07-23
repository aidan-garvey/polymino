
; *****************************************************************
; DRAW.S
; Subroutines that affect what appears on screen.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; =======================================
; DRAW_CURSOR
; ---------------------------------------
; Draw one of the players' cursors
; ---------------------------------------
; Parameters:
;   a2 - player game state
;   a5 - player's cursor in sprite buffer
; Thrashed:
;   d0-d1, a0
; =======================================
DRAW_CURSOR:
    ; LEA.L   VDP_DATA, a0
    MOVEA.L a5, a0
    MOVE.W  #$1000+CURSOR_CHAR, d1 ; pri = 0, pal = 0,
                        ; vflip = 1, hflip = 0, gfx location
    ; cursor sprite
    ; VDP_ACCESS VDP_W_VRAM, VRAM_SPRITETBL
    
    ; get vertical position
    MOVE.W  (CURSOR_Y_OFF, a2), d0
    BEQ     @CURSOR_NO_V_SUB
    ; if cursor not at top, don't vflip, decrease sprite's y
    SUBQ    #1, d0
    ANDI.W  #$EFFF, d1  ; vflip = 0
@CURSOR_NO_V_SUB:
    ; multiply by 8 since each cell is 8 pixels high
    ASL.W   #3, d0
    ; add offset to move into display area
    ADD.W   #$90, d0
    ; write vertical position
    MOVE.W  d0, (a0)+
    ; skip size and link
    ADDA.W  #2, a0
    ; MOVE.W  #$0500, (a0) ; hsize = 2, vsize = 2, link = 0
    ; horizontal position
    MOVE.W  (CURSOR_X_OFF, a2), d0
    CMPI.W  #BOARD_WIDTH-1, d0
    BNE     @CURSOR_NO_H_SUB
    SUBQ    #1, d0
    ORI.W   #$0800, d1  ; hflip = 1
@CURSOR_NO_H_SUB:
    ; we now have enough info for 3rd write
    MOVE.W  d1, (a0)+
    ; multiply by 8
    ASL.W   #3, d0
    ; add offset to move into display area
    ADD.W   #$C8, d0
    ; little cheat: if a5 pointing to P2_SPRITE, add additional h offset
    CMPA.L  #P2_SPRITE, a5
    BNE     @WRITE_H_POS
    ADD.W   #$60, d0
@WRITE_H_POS:
    MOVE.W  d0, (a0)

    RTS


; ========================================
; DRAW_SCORE
; ----------------------------------------
; Copy the digits of the player's score to
; VRAM so the score sprites display them
; ----------------------------------------
; Parameters:
;   a2 - player state
; ----------------------------------------
; Thrashed:
;   a0, d0-d2
; ========================================
DRAW_SCORE:
    PUSH    a1/a3
    LEA.L   TEXT_DIGITS, a0 ;= score graphics source
    MOVE.L  a2, a1
    ADDA.W  #SCORE_BUFF_OFF, a1 ;= score graphics dest
    MOVE.L  a2, a3
    ADDA.W  #SCORE_OFF, a3 ;= BCD score

    ; first byte only uses lower 4b
    MOVE.B  (a3)+, d1
    ANDI.W  #$F, d1
    ; multiply by 32 to get character location
    LSL.W   #5, d1
    ADDA.W  d1, a0

    JSR     CopyCharRAM

    MOVEQ   #2, d3
@DRAW_SCORE_LOOP:
    MOVE.B  (a3)+, d1
    LSL.W   #5, d1
    MOVE.W  d1, d2
    ANDI.W  #$F0<<5, d2 ; first digit
    LSR.W   #4, d2
    ANDI.W  #$0F<<5, d1 ; second digit
    
    LEA.L   TEXT_DIGITS, a0
    ADDA.W  d2, a0
    JSR     CopyCharRAM
    LEA.L   TEXT_DIGITS, a0
    ADDA.W  d1, a0
    JSR     CopyCharRAM

    DBRA    d3, @DRAW_SCORE_LOOP

    POP     a1/a3
    RTS

; ==================================
; PLACE_BLOCK
; ----------------------------------
; Place a block in the screen buffer
; based on the given block data
; ----------------------------------
; Parameters:
;   d0 - block data
;   d3 - x position
;   d4 - y position
;   a4 - points to screen buffer
; Thrashed:
;   none
; ==================================
PLACE_BLOCK:
    PUSH    a0/a4/d0/d3-d4

    LSL.W   #7, d4 ; each row is 64 cells = 128 bytes
    LSL.W   #1, d3 ; each cell is 2 bytes
    ADD.W   d3, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer

    ; determine pattern to use for block
    LEA.L   BLOCK_PATTERNS, a0
    LSR.W   #7, d0
    ANDI.W  #$000E, d0 ; d2 := color * 2
    ADDA.W  d0, a0 ; a0 points to block pattern to use
    MOVE.W  (a0), (a4)

    POP     a0/a4/d0/d3-d4
    RTS

; ======================================
; SWAP_BLOCKS_H:
; --------------------------------------
; Swap a block with the one on its right
; --------------------------------------
; Parameters:
;   d3 - x position of left block
;   d4 - y position of blocks
;   a4 - points to screen buffer
; Thrashed:
;   none
; ======================================
SWAP_BLOCKS_H:
    PUSH    a4/d3-d4

    LSL.W   #7, d4 ; each row is 64 cells = 128 bytes
    LSL.W   #1, d3 ; each cell is 2 bytes
    ADD.W   d3, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer
    ; swap the blocks
    MOVE.L  (a4), d3
    SWAP    d3
    MOVE.L  d3, (a4)

    POP     a4/d3-d4
    RTS

; ==================================
; SWAP_BLOCKS_V:
; ----------------------------------
; Swap a block with the one above it
; ----------------------------------
; Parameters:
;   d3 - x position of blocks
;   d4 - y position of top block
;   a4 - points to screen buffer
; Thrashed:
;   none
; ==================================
SWAP_BLOCKS_V:
    PUSH    a4-a5/d3-d4

    LSL.W   #7, d4 ; each row is 64 cells = 128 bytes
    LSL.W   #1, d3 ; each cell is 2 bytes
    ADD.W   d3, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer
    MOVE.L  a4, a5
    SUBA.W  #128, a5 ; a5 points 1 row lower than a4
    ; swap the blocks
    MOVE.W  (a4), d3
    MOVE.W  (a5), (a4)
    MOVE.W  d3, (a5)

    POP     a4-a5/d3-d4
    RTS

; ==============================
; ERASE_BLOCK
; ------------------------------
; Remove a block from the board
; ------------------------------
; Parameters:
;   d3 - x position of block
;   d4 - y position of block
;   a4 - points to screen buffer
; Thrashed:
;   none
; ==============================
ERASE_BLOCK:
    PUSH    a4/d3-d4

    LSL.W   #7, d4 ; each row is 64 cells = 128 bytes
    LSL.W   #1, d3 ; each cell is 2 bytes
    ADD.W   d3, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer
    MOVE.W  (UI_DITHER), (a4) ; clear the block

    POP     a4/d3-d4
    RTS

; ==============================
; PLACE_JUNK_BLOCK
; ------------------------------
; Add a junk block to the board
; ------------------------------
; Parameters:
;   d3 - x position of block
;   d4 - y position of block
;   a4 - points to screen buffer
;   a5 - points to block pattern
; Thrashed:
;   none
; ==============================
PLACE_JUNK_BLOCK:
    PUSH    a4/d3-d4

    LSL.W   #7, d4 ; each row is 64 cells = 128 bytes
    LSL.W   #1, d3 ; each cell is 2 bytes
    ADD.W   d3, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer
    MOVE.W  (a5), (a4) ; copy block data

    POP     a4/d3-d4
    RTS

; =======================================
; CLEAR_UI_NEXT
; ---------------------------------------
; Clear the space in the UI that displays
; the next junk piece that will drop
; ---------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   none
; =======================================
CLEAR_UI_NEXT:
    PUSH    a0/d0

    LEA.L   UI_DITHER, a0
    MOVE.W  (a0), d0
    SWAP    d0
    MOVE.W  (a0), d0

    LEA.L   P_NEXT_POS_1, a0
    CMP.L   #GAME_STATE_1, a2
    BEQ.B   @CLEAR_UI_P1
    LEA.L   P_NEXT_POS_2, a0
@CLEAR_UI_P1:
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    ADDA.W  #120, a0
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    ADDA.W  #120, a0
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+

    POP     a0/d0
    RTS

; ===============================================================
; MOVE_ROW
; ---------------------------------------------------------------
; Copy a row of 12 cells in the screen buffer to the row above it
; ---------------------------------------------------------------
; Parameters:
;   a0 - points to cell in first row of BUFF_PLANE
;   d1 - row number of top cell, mod 32
; Thrashed:
;   none
; ===============================================================
MOVE_ROW:
    PUSH    a0-a1/d1-d2
    ; make sure d1 is in range 0..31
    TST.W   d1
    BGE.B   @MR_ROW_POSITIVE
@MR_INC_ROW:
    ADDI.W  #32, d1
    BLT.B   @MR_INC_ROW
@MR_ROW_POSITIVE:
    ANDI.W  #$1F, d1    ; d1 %= 32
    LSL.W   #7, d1      ; d1 *= 128
    
    ADDA.W  d1, a0      ; a0 -> top row
    MOVE.L  a0, a1      
    ADDA.W  #128, a1    ; a1 -> bottom row
    CMP.L   #BUFF_PLANE+128*32, a1
    BLT.B   @BOTTOM_IN_BOUNDS
    SUBA.W  #128*32, a1
@BOTTOM_IN_BOUNDS:

    MOVEQ   #5, d2
@COPY_LOOP:
    MOVE.L  (a1)+, (a0)+
    DBRA    d2, @COPY_LOOP

    POP     a0-a1/d1-d2
    RTS

; ================================================
; DRAW_BOARD_ROW
; ------------------------------------------------
; Draw an empty game board row in the screen
; buffer, starting at the given horizontal offset
; ------------------------------------------------
; Parameters:
;   a0 - points to cell in first row of BUFF_PLANE
;   d1 - row number to write over, mod 32
; Thrashed:
;   none
; ================================================
DRAW_BOARD_ROW:
    PUSH    a0-a1/d1-d3
    ; d3 will act as a flag for which side of the
    ; screen we're using
    CMP.L   #BUFF_PLANE+28, a0
    SGT     d3  ; d3 = (a0 > SCREEN_WIDTH/2)

    ; load the main pattern we need into d2
    LEA.L   UI_DITHER, a1
    MOVE.W  (a1), d2
    SWAP    d2
    MOVE.W  (a1), d2

    ; make sure d1 is in range 0..31
    TST.W   d1
    BGE.B   @DB_ROW_POSITIVE
@DB_INC_ROW:
    ADDI.W  #32, d1
    BLT.B   @DB_INC_ROW
@DB_ROW_POSITIVE:
    ANDI.W  #$1F, d1    ; d1 %= 32
    LSL.W   #7, d1      ; d1 *= 128

    ADDA.W  d1, a0      ; a0 -> row we'll write over

    TST.B   d3
    BEQ.B   @P1_LEFT
    ; player 2: left edge
    MOVE.W  (UI_EDGE_L), (a0)+
    BRA.B   @P2_LEFT
@P1_LEFT:
    ; player 1: vertical separator
    MOVE.W  (UI_SEP_V), (a0)+
@P2_LEFT:

    ; both players: 10 dither patterns
    MOVE.L  d2, (a0)+
    MOVE.L  d2, (a0)+
    MOVE.L  d2, (a0)+
    MOVE.L  d2, (a0)+
    MOVE.L  d2, (a0)+

    TST.B   d3
    BEQ.B   @P1_RIGHT
    ; player 2: vertical separator
    MOVE.W  (UI_SEP_V), (a0)
    BRA.B   @P2_RIGHT
@P1_RIGHT:
    ; player 1: right edge
    MOVE.W  (UI_EDGE_R), (a0)
@P2_RIGHT:

    POP     a0-a1/d1-d3
    RTS


