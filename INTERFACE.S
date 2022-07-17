
; *******************************************************************
; INTERFACE.S
; Subroutines for initializing different parts of the user interface.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *******************************************************************

SCROLLA_FILLER:
    MOVEQ   #11, d4
@SCROLLA_FILL_LOOP:
    MOVE.L  d0, (a0)+
    DBRA    d4, @SCROLLA_FILL_LOOP
    RTS

; =====================
; INIT_WINDOW
; ---------------------
; Copy patterns to VRAM
; for SCROLLA
; ---------------------
; Thrashed:
;   d0-d6
; =====================
INIT_SCROLLA:
    ; load characters into VRAM
    MOVE.L  #UI_BRDR_CHARS, d0
    MOVE.W  #NUM_UI_CHARS*16, d1
    MOVE.W  #VRAM_UI_GFX, d2
    JSR     DMADump

    ; load patterns into registers
    
    ; d0 := FILLER, FILLER
    LEA.L   UI_FILLER, a1
    MOVE.W  (a1), d0
    SWAP    d0
    MOVE.W  (a1), d0

    ; d1 := EDGE_TOP, EDGE_TOP
    LEA.L   UI_EDGE_T, a1
    MOVE.W  (a1), d1
    SWAP    d1
    MOVE.W  (a1), d1

    ; d2 := CORNER_TL, CORNER_TR
    LEA.L   UI_BRDR_TL, a1
    MOVE.L  (a1), d2

    ; d3 := 3WAY_D
    LEA.L   UI_BRDR_3WAY_D, a1
    MOVE.W  (a1), d3

    ; d6 := DITHER, DITHER
    LEA.L   UI_DITHER, a1
    MOVE.W  (a1), d6
    SWAP    d6
    MOVE.W  (a1), d6

    ; horizontal layout: 1 border, 7 P1 info,
    ; 1 border, 10 P1 board, 2 border, 10 P2 board,
    ; 1 border, 7 P2 info, 1 border, 24 filler

    ; vertical layout: 1 filler, 1 border, 24 horizontal layout, 1 border, 5 filler
    LEA.L   BUFF_PLANE, a0

    ; row 1: 64 filler
    MOVEQ   #31, d4
@TOP_FILLER_LOOP:
    MOVE.L  d0, (a0)+
    DBRA    d4, @TOP_FILLER_LOOP
    
    ; row 2: corner, 7 edge, 3way, 10 edge, 2 corner, 10 edge,
    ;   3way, 7 edge, corner, 24 filler

    ; tl corner
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 7 edge
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.W  d1, (a0)+
    ; 3way
    MOVE.W  d3, (a0)+
    ; 10 edge
    MOVEQ   #4, d4
@TOP_EDGE_LOOP_1:
    MOVE.L  d1, (a0)+
    DBRA    d4, @TOP_EDGE_LOOP_1
    ; tr, tl corner
    MOVE.L  d2, (a0)+
    ; 10 edge
    MOVEQ   #4, d4
@TOP_EDGE_LOOP_2:
    MOVE.L  d1, (a0)+
    DBRA    d4, @TOP_EDGE_LOOP_2
    ; 3way
    MOVE.W  d3, (a0)+
    ; 7 edge
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.W  d1, (a0)+
    ; tr corner
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 24 filler
    BSR     SCROLLA_FILLER



    ; don't need corners or h. edges for a while
    ; d1 := vertical separator
    LEA.L   UI_SEP_V, a1
    MOVE.W  (a1), d1
    ; d2 := EDGE_L, EDGE_R 
    LEA.L   UI_EDGE_L, a1
    MOVE.L  (a1), d2
    ; d3 := DITHER, DITHER
    LEA.L   UI_DITHER, a1
    MOVE.W  (a1), d3
    SWAP    d3
    MOVE.W  (a1), d3
    ; MOVEQ   #0, d3
    ; copy 24 rows of the horizontal layout pattern
    MOVEQ   #23, d5
@H_LAYOUT_LOOP:
    ; 1 left edge
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 7 info
    MOVE.L  d6, (a0)+
    MOVE.L  d6, (a0)+
    MOVE.L  d6, (a0)+
    MOVE.W  d6, (a0)+
    ; 1 separator
    MOVE.W  d1, (a0)+
    ; 10 P1 board
    MOVEQ   #4, d4
@H_LAYOUT_BOARD_1:
    MOVE.L  d3, (a0)+
    DBRA    d4, @H_LAYOUT_BOARD_1
    ; 2 border
    MOVE.L  d2, (a0)+
    ; 10 P2 board
    MOVEQ   #4, d4
@H_LAYOUT_BOARD_2:
    MOVE.L  d3, (a0)+
    DBRA    d4, @H_LAYOUT_BOARD_2
    ; 1 separator
    MOVE.W  d1, (a0)+
    ; 7 P2 info
    MOVE.L  d6, (a0)+
    MOVE.L  d6, (a0)+
    MOVE.L  d6, (a0)+
    MOVE.W  d6, (a0)+
    ; 1 border
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 24 filler
    BSR     SCROLLA_FILLER
    DBRA    d5, @H_LAYOUT_LOOP

    ; *****************
    ; END H_LAYOUT_LOOP
    ; *****************

    ; d1 := EDGE_BOT, EDGE_BOT
    LEA.L   UI_EDGE_B, a1
    MOVE.W  (a1), d1
    SWAP    d1
    MOVE.W  (a1), d1

    ; d2 := CORNER_BL, CORNER_BR
    LEA.L   UI_BRDR_BL, a1
    MOVE.L  (a1), d2

    ; d3 := 3WAY_U
    LEA.L   UI_BRDR_3WAY_U, a1
    MOVE.W  (a1), d3

    ; row 27: corner, 7 edge, 3way, 10 edge, 2 corner, 10 edge,
    ;   3way, 7 edge, corner, 24 filler

    ; corner
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 7 edge
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.W  d1, (a0)+
    ; 3way
    MOVE.W  d3, (a0)+
    ; 10 edge
    MOVEQ   #4, d4
@BOT_EDGE_LOOP_1:
    MOVE.L  d1, (a0)+
    DBRA    d4, @BOT_EDGE_LOOP_1
    ; 2 corner
    MOVE.L  d2, (a0)+
    ; 10 edge
    MOVEQ   #4, d4
@BOT_EDGE_LOOP_2:
    MOVE.L  d1, (a0)+
    DBRA    d4, @BOT_EDGE_LOOP_2
    ; 3way
    MOVE.W  d3, (a0)+
    ; 7 edge
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.L  d1, (a0)+
    MOVE.W  d1, (a0)+
    ; corner
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 24 filler
    BSR     SCROLLA_FILLER

    ; copy 5 rows of filler - 64 x 5 cells
    ; 32 x 5 LONGs
    MOVEQ   #31, d4
@BOT_FILLER_LOOP:
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    DBRA    d4, @BOT_FILLER_LOOP

    ; transfer plane to VRAM
    MOVE.L  #BUFF_PLANE, d0
    ; MOVE.W  #VRAM_WINDOW_SIZE/2, d1
    ; MOVE.W  #VRAM_WINDOW, d2
    MOVE.W  #VRAM_SCROLLA_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLA, d2
    JSR     DMADump

    RTS

; =====================================
; INIT_HUD
; -------------------------------------
; Load HUD sprites into VRAM. Writes to
; BUFF_PLANE before calling DMA.
; =====================================
INIT_HUD:
    ; copy cursor chars
    LEA.L   BUFF_PLANE, a1
    LEA.L   GAME_CURSOR_V, a0
    ; copy top and centre
    JSR     CopyCharRAM
    JSR     CopyCharRAM
    ; copy a blank char
    MOVEQ   #7, d0
@BLANK_LOOP_1:
    MOVE.L  #0, (a1)+
    DBRA    d0, @BLANK_LOOP_1
    ; copy right char
    JSR     CopyCharRAM

    ; copy all chars from TEXT_GFX.S
    MOVEQ   #25, d1
    LEA.L   TEXT_NEXT, a0
@TEXT_LOOP:
    JSR     CopyCharRAM
    DBRA    d1, @TEXT_LOOP

    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #16*20, d1 ; 16 chars in TEXT_GFX + 4 for cursor, 16 words per char
    MOVE.W  #VRAM_SPRITE_GFX, d2
    JSR     DMADump

    ; initialize size and link data for P1 and P2 cursors
    MOVE.W  #$0501, (P1_SPRITE+2)
    MOVE.W  #$0507, (P2_SPRITE+2)

    ; initialize HUD text for P1

    ; "NEXT"
    LEA.L   P1_T_NEXT, a0
    MOVE.W  #T_NEXT_VPOS, (a0)+
    MOVE.W  #$0C02, (a0)+ ; 4x1
    MOVE.W  #T_NEXT_CHAR, (a0)+
    MOVE.W  #T_NEXT_HPOS_1, (a0)+

    ; "SCORE"
    MOVE.W  #T_SCORE_VPOS, (a0)+
    MOVE.W  #$0C03, (a0)+ ; 4x1
    MOVE.W  #T_SCORE_CHAR, (a0)+
    MOVE.W  #T_SCORE_HPOS_1, (a0)+

    ; "LIFE\nLINES"
    MOVE.W  #T_LLINES_VPOS, (a0)+
    MOVE.W  #$0D04, (a0)+ ; 4x2
    MOVE.W  #T_LLINES_CHAR, (a0)+
    MOVE.W  #T_LLINES_HPOS_1, (a0)+

    ; upper 3 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    MOVE.W  #$0805, (a0)+ ; 3x1
    MOVE.W  #P1_SCOREH_DGTS, (a0)+
    MOVE.W  #SCORE_DGTS_HPOS_1, (a0)+
    ; lower 4 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    MOVE.W  #$0C06, (a0)+ ; 4x1
    MOVE.W  #P1_SCOREL_DGTS, (a0)+
    MOVE.W  #SCORE_DGTS_HLOW_1, (a0)+

    ; initialize HUD text for P2

    ; "NEXT"
    LEA.L   P2_T_NEXT, a0
    MOVE.W  #T_NEXT_VPOS, (a0)+
    MOVE.W  #$0C08, (a0)+ ; 4x1
    MOVE.W  #T_NEXT_CHAR, (a0)+
    MOVE.W  #T_NEXT_HPOS_2, (a0)+

    ; "SCORE"
    MOVE.W  #T_SCORE_VPOS, (a0)+
    MOVE.W  #$0C09, (a0)+ ; 4x1
    MOVE.W  #T_SCORE_CHAR, (a0)+
    MOVE.W  #T_SCORE_HPOS_2, (a0)+

    ; "LIFE\nLINES"
    MOVE.W  #T_LLINES_VPOS, (a0)+
    MOVE.W  #$0D0A, (a0)+ ; 4x2
    MOVE.W  #T_LLINES_CHAR, (a0)+
    MOVE.W  #T_LLINES_HPOS_2, (a0)+

    ; upper 3 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    MOVE.W  #$080B, (a0)+ ; 3x1
    MOVE.W  #P2_SCOREH_DGTS, (a0)+
    MOVE.W  #SCORE_DGTS_HPOS_2, (a0)+
    ; lower 4 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    MOVE.W  #$0C0C, (a0)+ ; 4x1
    MOVE.W  #P2_SCOREL_DGTS, (a0)+
    MOVE.W  #SCORE_DGTS_HLOW_2, (a0)+

    ; place empty sprite in buffer afterwards
    ; LEA.L   VAR_SPRITES, a0
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)

    RTS

INIT_BACKGROUND:
    ; load star graphics into VRAM
    MOVE.L  #BCKGND_NIGHT_CHARS, d0 ; address
    MOVE.W  #32, d1                 ; 16 words * 2 chars
    MOVE.W  #VRAM_BCKGND_GFX, d2    ; start at tile $100 (address $2000)
    JSR     DMADump

    ; *******************************
    ; ** STAR GENERATION ALGORITHM **
    ; -------------------------------
    ; Place stars in a uniform but
    ; random-looking arrangement in
    ; the scroll buffer. Uses two
    ; patterns - one for a small star
    ; and one for a large star. The
    ; small star is in the upper-left
    ; of the tile so flipping it will
    ; vary placement further.
    ; *******************************
    
    LEA.L   BUFF_PLANE, a0
    ; pattern consists of 32*64 tiles
    MOVE.W  #32*64-1, d0

    MOVEQ   #0, d1  ; counter for small stars
    MOVEQ   #0, d2  ; counter for large stars
    MOVE.W  (SMALL_STAR_PATTERN), d3 ; tile with small star
    MOVE.W  (LARGE_STAR_PATTERN), d4 ; tile with large star
    MOVEQ   #0, d5  ; blank pattern for tile with no star
    MOVEQ   #23, d6 ; used as limit for large star counter
    MOVEQ   #11, d7 ; used as limit for small star counter

@NIGHT_SKY_LOOP:
    ; if the small star counter has reached its limit, place a small star
    CMP.W   d7, d1
    BNE     @LARGE_STAR_CHECK
    ; if the large star counter is also at its limit, reset it
    CMP.B   d6, d2
    BNE     @SMALL_STAR_PLACE
    MOVEQ   #0, d2      ; reset large counter
    BCHG    #2, d6      ; change value of large star limit to vary the spacing
@SMALL_STAR_PLACE:
    BCHG    #3, d7      ; change value of small star limit to vary spacing
    MOVEQ   #0, d1      ; reset small counter
    MOVE.W  d3, (a0)+   ; place a small star
    BCHG    #12, d3     ; toggle small star vertical flip
    BEQ     @NIGHT_SKY_STEP
    BCHG    #11, d3     ; every second small star, toggle horizontal flip
    BRA     @NIGHT_SKY_STEP
@LARGE_STAR_CHECK:
    CMP.B   d6, d2      ; check if large star counter has hit the limit
    BNE     @NO_STAR_PLACE
    MOVEQ   #0, d2      ; reset large counter
    BCHG    #1, d6      ; change value of large limit to vary spacing
    MOVE.W  d4, (a0)+   ; place large star
    BCHG    #11, d3     ; toggle *small* star horizontal flip
    BNE     @NIGHT_SKY_STEP
    BCHG    #12, d3     ; every second large star, toggle small v flip
    BRA     @NIGHT_SKY_STEP
@NO_STAR_PLACE:
    MOVE.W  d5, (a0)+   ; place empty tile
@NIGHT_SKY_STEP:
    ADDQ.W  #1, d1      
    ADDQ.W  #1, d2      ; increment counters
    DBRA    d0, @NIGHT_SKY_LOOP

    ; DMA transfer to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_SCROLLB_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLB, d2
    JSR     DMADump

    RTS

; ===========================
; INIT_JUNK
; ---------------------------
; Generate characters for the
; junk pieces and copy them
; to VRAM. The existing chars
; in ROM are for gray junk,
; so this code makes modified
; copies in different colors.
; ===========================
INIT_JUNK:
    ; chars will be put in RAM before DMA
    
    ; gray is ready to be used as-is
    LEA.L   BUFF_PLANE, a1
    LEA.L   JUNK_CHARS, a0
    JSR     CopyCharRAM
    JSR     CopyCharRAM
    JSR     CopyCharRAM
    JSR     CopyCharRAM

    ; blue
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$9, d0
    MOVE.W  #$1, d1
    BSR     @INIT_JUNK_SR

    ; red
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$A, d0
    MOVE.W  #$2, d1
    BSR     @INIT_JUNK_SR

    ; green
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$B, d0
    MOVE.W  #$3, d1
    BSR     @INIT_JUNK_SR

    ; yellow
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$C, d0
    MOVE.W  #$4, d1
    BSR     @INIT_JUNK_SR

    ; orange
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$D, d0
    MOVE.W  #$5, d1
    BSR     @INIT_JUNK_SR

    ; violet
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$E, d0
    MOVE.W  #$6, d1
    BSR     @INIT_JUNK_SR

    ; teal
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$F, d0
    MOVE.W  #$7, d1
    BSR     @INIT_JUNK_SR

    ; dark green
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$8, d0
    MOVE.W  #$B, d1
    BSR     @INIT_JUNK_SR

    ; dma characters to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_JUNK_SIZE/2, d1
    MOVE.W  #VRAM_JUNK_GFX, d2
    JSR     DMADump

    ; dma patterns to VRAM

    RTS

; a0 points to source character
; a1 points to destination
; d0 contains the color to replace dark gray with
; d1 contains the color to replace light gray with
@INIT_JUNK_SR:
    ; for 8 long words -> d7
        ; copy long to data register -> d2
        ; clear another data register to be our destination -> d3
        ; for 8 groups of 4 bits -> d6
            ; transfer 4 bits to another data reg -> d4
            ; compare with dark/light
            ; OR d0/d1 with dest register
            ; shift source right by 4, rotate dest right by 4
        ; copy dest register to (a1)+
    
    ; for 4 chars * 8 long words
    MOVEQ   #31, d7
@IJ_CHAR_LOOP:
        MOVE.L  (a0)+, d2   ; d2 := source row
        MOVEQ   #0, d3      ; d3 modified source row
        MOVEQ   #0, d4      ; d4 is for intermediate comparisons
        ; for 8 4-bit pixels
        MOVEQ   #7, d6
@IJ_ROW_LOOP:
            MOVE.B  d2, d4
            ANDI.B  #$0F, d4    ; d4 := current pixel
            CMPI.B  #JUNK_DARK, d4
            BEQ     @IJ_DARK
            OR.B    d1, d3      ; copy light pixel
            BRA     @IJ_ROW_STEP
@IJ_DARK:
            OR.B    d0, d3      ; copy dark pixel
@IJ_ROW_STEP:
            LSR.L   #4, d2      ; get next pixel in lower 4 bits
            ROR.L   #4, d3      ; do same for d3, but preserve bits
            DBRA    d6, @IJ_ROW_LOOP
        MOVE.L  d3, (a1)+
        DBRA    d7, @IJ_CHAR_LOOP
    RTS

    



