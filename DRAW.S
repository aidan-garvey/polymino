
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
    BEQ     _CURSOR_NO_V_SUB
    ; if cursor not at top, don't vflip, decrease sprite's y
    SUBQ    #1, d0
    ANDI.W  #$EFFF, d1  ; vflip = 0
_CURSOR_NO_V_SUB:
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
    BNE     _CURSOR_NO_H_SUB
    SUBQ    #1, d0
    ORI.W   #$0800, d1  ; hflip = 1
_CURSOR_NO_H_SUB:
    ; we now have enough info for 3rd write
    MOVE.W  d1, (a0)+
    ; multiply by 8
    ASL.W   #3, d0
    ; add offset to move into display area
    ADD.W   #$C8, d0
    ; little cheat: if a5 pointing to P2_SPRITE, add additional h offset
    CMPA.L  #P2_SPRITE, a5
    BNE     _WRITE_H_POS
    ADD.W   #$60, d0
_WRITE_H_POS:
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
    ADDA.W  #SCORE_BCD_OFF, a3 ;= BCD score

    ; first byte only uses lower 4b
    MOVE.B  (a3)+, d1
    ANDI.W  #$F, d1
    ; multiply by 32 to get character location
    LSL.W   #5, d1
    ADDA.W  d1, a0

    JSR     CopyCharRAM

    MOVEQ   #2, d3
_DRAW_SCORE_LOOP:
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

    DBRA    d3, _DRAW_SCORE_LOOP

    POP     a1/a3
    RTS

; =============================================
; DRAW_BOMBS
; ---------------------------------------------
; Copy the digits of the player's bomb count to
; VRAM so the bomb count sprite displays them
; ---------------------------------------------
; Parameters:
;   a2 - player state
; ---------------------------------------------
; Thrashed:
;   a0, d0-d2
; =============================================
DRAW_BOMBS:
    PUSH    a1

    MOVE.L  a2, a1
    ADDA.W  #BOMBS_BUFF_OFF, a1
    ; get both digits of score
    MOVE.B  (BOMBS_OFF+1, a2), d1
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

    POP     a1
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

    ; convert d4 into offset from a4.
    ; each cell is 2 bytes, each row is 128 bytes.
    ; d4 := d4 * 128 + d3 * 2
    ;     = 2 * (d4 * 64 + d3)
    LSL.W   #6, d4
    ADD.W   d3, d4
    ADD.W   d4, d4
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

    ; convert d4 into offset from a4.
    ; each cell is 2 bytes, each row is 128 bytes.
    ; d4 := d4 * 128 + d3 * 2
    ;     = 2 * (d4 * 64 + d3)
    LSL.W   #6, d4
    ADD.W   d3, d4
    ADD.W   d4, d4
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

    ; convert d4 into offset from a4.
    ; each cell is 2 bytes, each row is 128 bytes.
    ; d4 := d4 * 128 + d3 * 2
    ;     = 2 * (d4 * 64 + d3)
    LSL.W   #6, d4
    ADD.W   d3, d4
    ADD.W   d4, d4
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

    ; convert d4 into offset from a4.
    ; each cell is 2 bytes, each row is 128 bytes.
    ; d4 := d4 * 128 + d3 * 2
    ;     = 2 * (d4 * 64 + d3)
    LSL.W   #6, d4
    ADD.W   d3, d4
    ADD.W   d4, d4
    ADDA.W  d4, a4 ; a4 points to block in screen buffer
    CLR.W   (a4) ; clear the block

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

    ; convert d4 into offset from a4.
    ; each cell is 2 bytes, each row is 128 bytes.
    ; d4 := d4 * 128 + d3 * 2
    ;     = 2 * (d4 * 64 + d3)
    LSL.W   #6, d4
    ADD.W   d3, d4
    ADD.W   d4, d4
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
    PUSH    a0

    LEA.L   P_NEXT_POS_1, a0
    CMP.L   #GAME_STATE_1, a2
    BEQ.B   _CLEAR_UI_P1
    LEA.L   P_NEXT_POS_2, a0
_CLEAR_UI_P1:
    CLR.L   (a0)+
    CLR.L   (a0)+
    ADDA.W  #120, a0
    CLR.L   (a0)+
    CLR.L   (a0)+
    ADDA.W  #120, a0
    CLR.L   (a0)+
    CLR.L   (a0)+

    POP     a0
    RTS

; ==============================================
; DRAW_JUNK_OUTLINE
; ----------------------------------------------
; Fill a player's OUTLN_BUFF with the characters
; needed to display the outline of the next junk
; piece
; ----------------------------------------------
; Parameters:
;   a2 - player game state
; Thrashed:
;   a0, d0-d4
; ==============================================
DRAW_JUNK_OUTLINE:
    PUSH    a1/a3-a4

    ; ************************************
    ; update the x position of the outline
    ; ************************************

    ; destination column number within board
    MOVE.W  (NEXT_JUNK_X_OFF, a2), d0
    ; add column offset of player's board
    ADD.W   (BOARD_TX_OFF, a2), d0
    LSL.W   #3, d0  ; multiply tile X by pixels/tile
    ADDI.W  #$80, d0 ; add left edge offset

    ; make a0 point to player's outline sprite
    LEA.L   BUFF_SPRITES, a0
    ADDA.W  (OUTLINE_SP_OFF, a2), a0
    MOVE.W  d0, 6(a0)   ; write x position

    ; ***********************************
    ; copy the characters for the outline
    ; ***********************************

    MOVEA.L a2, a1
    ADDA.W  #OUTLN_BUFF_OFF, a1 ; a1 -> outline characters buffer

    MOVE.W  (JUNK_PAT_OFF, a2), d0
    LSL.W   #4, d0
    LEA.L   JUNK_PIECES, a3
    ADDA.W  d0, a3  ; a3 -> junk pattern to draw

    MOVE.B  (a3)+, d3   ; d3 := width
    MOVE.B  (a3)+, d4   ; d4 := height
    EXT.W   d3
    EXT.W   d4

    MOVE.W  d3, d1
    SUBQ.W  #1, d1  ; d1 will be used as a loop counter over the columns

    ; for each column
        ; load a3 into a4
        ; get first block, add width (d3) to a4, get second block, etc
        ; write (4 - width) blank chars
        ; increment a3, check if we've looped d1 times

_OUTLN_COL_LOOP:
    MOVEA.L a3, a4
    MOVE.W  d4, d2  ; d2 will be a loop counter
    SUBQ.W  #1, d2

_OUTLN_BLOCK_LOOP:
    MOVE.B  (a4), d0
    BLT.B   _EMPTY_BLOCK    ; -1 == space
    CMPI.B  #8, d0
    BGE.B   _EMPTY_BLOCK    ; middle blocks and inner corners don't appear in outlines
    LEA.L   OUTLINE_CHARS, a0
    EXT.W   d0
    LSL.W   #5, d0  ; multiply by 32 to get character offset
    ADDA.W  d0, a0  ; a0 -> junk outline character
    ; copy the outline character to the buffer
    JSR     CopyCharRAM
    BRA.B   _OUTLN_BLOCK_STEP

_EMPTY_BLOCK:
    JSR     ClearCharRAM

_OUTLN_BLOCK_STEP:
    ADDA.W  d3, a4  ; move a4 1 row down
    DBRA    d2, _OUTLN_BLOCK_LOOP

    ; after copying the column, we need to fill the
    ; remainder of the 4 chars per column with spaces
    MOVEQ   #4, d2
    SUB.W   d4, d2
    BRA.B   _OUTLN_SPACE_STEP

_OUTLN_SPACE_LOOP:
    JSR     ClearCharRAM

_OUTLN_SPACE_STEP:
    DBRA    d2, _OUTLN_SPACE_LOOP

_OUTLN_COL_STEP:
    ADDQ.W  #1, a3
    DBRA    d1, _OUTLN_COL_LOOP

    ; if the width was less than 4, we need to copy blank columns
    MOVEQ   #4, d1
    SUB.W   d3, d1
    BRA.B   _EMPTY_COL_STEP
_EMPTY_COL_LOOP:
    JSR     ClearCharRAM
    JSR     ClearCharRAM
    JSR     ClearCharRAM
    JSR     ClearCharRAM
_EMPTY_COL_STEP:
    DBRA    d1, _EMPTY_COL_LOOP

    POP     a1/a3-a4
    RTS
