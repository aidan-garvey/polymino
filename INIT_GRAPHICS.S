
; *******************************************************************
; INIT_SCREEN.S
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

; =================================
; INIT_SCROLLA
; ---------------------------------
; Copy patterns to VRAM for SCROLLA
; ---------------------------------
; Thrashed:
;   d0-d6
; =================================
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
    
    ; copy 24 rows of the horizontal layout pattern
    MOVEQ   #23, d5
@H_LAYOUT_LOOP:
    ; 1 left edge
    SWAP    d2
    MOVE.W  d2, (a0)+
    ; 7 info
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.W   (a0)+
    ; 1 separator
    MOVE.W  d1, (a0)+
    ; 10 P1 board
    MOVEQ   #4, d4
@H_LAYOUT_BOARD_1:
    CLR.L   (a0)+
    DBRA    d4, @H_LAYOUT_BOARD_1
    ; 2 border
    MOVE.L  d2, (a0)+
    ; 10 P2 board
    MOVEQ   #4, d4
@H_LAYOUT_BOARD_2:
    CLR.L   (a0)+
    DBRA    d4, @H_LAYOUT_BOARD_2
    ; 1 separator
    MOVE.W  d1, (a0)+
    ; 7 P2 info
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.W   (a0)+
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
    MOVE.W  #VRAM_SCROLLA_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLA, d2
    JSR     DMADump

    RTS

; ================================================
; LOAD_SPRITES
; ------------------------------------------------
; Load persistent (non-particle) sprites into VRAM
; ================================================
LOAD_SPRITES:
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

    ; copy menu cursor
    JSR     CopyCharRAM

    ; copy the chars for "NEXT," "SCORE," and "BOMBS" from GFX_TEXT.S
    MOVEQ   #11, d1
    LEA.L   TEXT_NEXT, a0
@TEXT_LOOP_1:
    JSR     CopyCharRAM
    DBRA    d1, @TEXT_LOOP_1

    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #16*17, d1 ; 12 chars in GFX_TEXT + 5 for cursors, 16 words per char
    MOVE.W  #VRAM_SPRITE_GFX, d2
    JSR     DMADump

    ; initialize size and link data for P1 and P2 cursors
    MOVE.W  #$0500|P1_CURSOR_LNK, (P1_SPRITE+2)
    MOVE.W  #$0500|P2_CURSOR_LNK, (P2_SPRITE+2)

    ; initialize HUD text for P1

    ; "NEXT"
    LEA.L   P1_T_NEXT, a0
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P1_NEXT_LNK, (a0)+ ; 4x1
    MOVE.W  #T_NEXT_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; "SCORE"
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P1_SCORE_LNK, (a0)+ ; 4x1
    MOVE.W  #T_SCORE_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ;; "LIFE\nLINES"
    ;MOVE.W  #1, (a0)+
    ;MOVE.W  #$0D00|P1_LLINES_LNK, (a0)+ ; 4x2
    ;MOVE.W  #T_LLINES_CHAR, (a0)+
    ;MOVE.W  #1, (a0)+

    ; "BOMBS"
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P1_BOMBS_LNK, (a0)+ ; 4x1
    MOVE.W  #T_BOMBS_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; upper 3 digits of score
    MOVE.W  #1, (a0)+
    MOVE.W  #$0800|P1_SCORE_LNK_1, (a0)+ ; 3x1
    MOVE.W  #P1_SCOREH_DGTS, (a0)+
    MOVE.W  #1, (a0)+
    ; lower 4 digits of score
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P1_SCORE_LNK_2, (a0)+ ; 4x1
    MOVE.W  #P1_SCOREL_DGTS, (a0)+
    MOVE.W  #1, (a0)+

    ; outline
    MOVE.W  #$90, (a0)+
    MOVE.W  #$0F00|P1_OUTLINE_LNK, (a0)+
    MOVE.W  #P1_OUTLINE_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; both digits for number of bombs
    MOVE.W  #1, (a0)+
    MOVE.W  #$0400|P1_BOMBDGT_LNK, (a0)+ ; 2x1
    MOVE.W  #P1_BOMBS_DGTS, (a0)+
    MOVE.W  #1, (a0)+

    ; initialize HUD text for P2

    ; "NEXT"
    LEA.L   P2_T_NEXT, a0
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P2_NEXT_LNK, (a0)+ ; 4x1
    MOVE.W  #T_NEXT_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; "SCORE"
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P2_SCORE_LNK, (a0)+ ; 4x1
    MOVE.W  #T_SCORE_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ;; "LIFE\nLINES"
    ;MOVE.W  #1, (a0)+
    ;MOVE.W  #$0D00|P2_LLINES_LNK, (a0)+ ; 4x2
    ;MOVE.W  #T_LLINES_CHAR, (a0)+
    ;MOVE.W  #1, (a0)+

    ; "BOMBS"
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P2_BOMBS_LNK, (a0)+ ; 4x1
    MOVE.W  #T_BOMBS_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; upper 3 digits of score
    MOVE.W  #1, (a0)+
    MOVE.W  #$0800|P2_SCORE_LNK_1, (a0)+ ; 3x1
    MOVE.W  #P2_SCOREH_DGTS, (a0)+
    MOVE.W  #1, (a0)+
    ; lower 4 digits of score
    MOVE.W  #1, (a0)+
    MOVE.W  #$0C00|P2_SCORE_LNK_2, (a0)+ ; 4x1
    MOVE.W  #P2_SCOREL_DGTS, (a0)+
    MOVE.W  #1, (a0)+

    ; outline
    MOVE.W  #$90, (a0)+
    MOVE.W  #$0F00|P2_OUTLINE_LNK, (a0)+
    MOVE.W  #P2_OUTLINE_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; both digits for number of bombs
    MOVE.W  #1, (a0)+
    MOVE.W  #$0400|P2_BOMBDGT_LNK, (a0)+ ; 2x1
    MOVE.W  #P2_BOMBS_DGTS, (a0)+
    MOVE.W  #1, (a0)+

    ; menu cursor
    MOVE.W  #1, (a0)+
    MOVE.W  #$0000|MENU_CURSOR_LNK, (a0)+
    MOVE.W  #MENU_CRSR_CHAR, (a0)+
    MOVE.W  #1, (a0)+

    ; place empty sprite in buffer afterwards,
    ; will be overwritten by particles
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)

    RTS

; ============================================================
; INIT_HUD
; ------------------------------------------------------------
; Initialize the positions of the sprites used during gameplay
; ============================================================
INIT_HUD:
    ; initialize HUD text for P1

    ; "NEXT"
    LEA.L   P1_T_NEXT, a0
    MOVE.W  #T_NEXT_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_NEXT_HPOS_1, (a0)+

    ; "SCORE"
    MOVE.W  #T_SCORE_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_SCORE_HPOS_1, (a0)+

    ;; "LIFE\nLINES"
    ;MOVE.W  #T_LLINES_VPOS, (a0)+
    ;ADDQ.W  #4, a0
    ;MOVE.W  #T_LLINES_HPOS_1, (a0)+

    ; "BOMBS"
    MOVE.W  #T_BOMBS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_BOMBS_HPOS_1, (a0)+

    ; upper 3 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #SCORE_DGTS_HPOS_1, (a0)+
    ; lower 4 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #SCORE_DGTS_HLOW_1, (a0)+

    ; outline
    MOVE.W  #JUNK_OUTLINE_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #1, (a0)+

    ; number of bombs
    MOVE.W  #BOMBS_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #BOMBS_DGTS_HPOS_1, (a0)+

    ; initialize HUD text for P2

    CMP.W   #1, (NUM_PLAYERS)
    BEQ.B   @INIT_HUD_1P

    ; "NEXT"
    LEA.L   P2_T_NEXT, a0
    MOVE.W  #T_NEXT_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_NEXT_HPOS_2, (a0)+

    ; "SCORE"
    MOVE.W  #T_SCORE_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_SCORE_HPOS_2, (a0)+

    ;; "LIFE\nLINES"
    ;MOVE.W  #T_LLINES_VPOS, (a0)+
    ;ADDQ.W  #4, a0
    ;MOVE.W  #T_LLINES_HPOS_2, (a0)+

    ; "BOMBS"
    MOVE.W  #T_BOMBS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #T_BOMBS_HPOS_2, (a0)+

    ; upper 3 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #SCORE_DGTS_HPOS_2, (a0)+
    ; lower 4 digits of score
    MOVE.W  #SCORE_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #SCORE_DGTS_HLOW_2, (a0)+

    ; outline
    MOVE.W  #$90, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #1, (a0)+

    ; number of bombs
    MOVE.W  #BOMBS_DGTS_VPOS, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #BOMBS_DGTS_HPOS_2, (a0)+

@INIT_HUD_1P:
    LEA.L   CURSOR_SPRITE, a0
    ; menu cursor
    MOVE.W  #1, (a0)+
    ADDQ.W  #4, a0
    MOVE.W  #1, (a0)+

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
    JSR     CopyCharRAM

    ; blue
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$00, d0
    BSR     @INIT_JUNK_SR

    ; red
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$33, d0
    BSR     @INIT_JUNK_SR

    ; green
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$66, d0
    BSR     @INIT_JUNK_SR

    ; yellow
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$99, d0
    BSR     @INIT_JUNK_SR

    ; orange
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$00, d0
    BSR     @INIT_JUNK_SR

    ; pink
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$33, d0
    BSR     @INIT_JUNK_SR

    ; violet
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$66, d0
    BSR     @INIT_JUNK_SR

    ; teal
    LEA.L   JUNK_CHARS, a0
    MOVE.W  #$99, d0
    BSR     @INIT_JUNK_SR

    ; dma characters to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_JUNK_SIZE/2, d1
    MOVE.W  #VRAM_JUNK_GFX, d2
    JSR     DMADump

    RTS


; a0 points to source characters
; a1 points to destination
; d0 contains amount to add to each color byte
@INIT_JUNK_SR:
    ; nasty hack for first byte:
    ; first pixel is the empty corner pixel
    MOVE.B  (a0)+, d1
    SUBI.B  #$05, d1
    LSL.W   #4, d0
    LSR.B   #4, d0
    ADD.B   d0, d1
    MOVE.B  d1, (a1)+
    LSL.B   #4, d0
    LSR.W   #4, d0

    ; for 5 chars * (32 - 1) bytes
    MOVE.W  #32*5-2, d7
@IJ_CHAR_LOOP:
    MOVE.B  (a0)+, d1
    SUBI.B  #$55, d1
    ADD.B   d0, d1
    MOVE.B  d1, (a1)+
    DBRA    d7, @IJ_CHAR_LOOP
    RTS
