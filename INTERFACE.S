; *******************
; **** INTERFACE ****
; -------------------
; Subroutines for the
;   user interface.
; *******************

; =====================
; INIT_WINDOW
; ---------------------
; Copy patterns to VRAM
; for the WINDOW layer.
; =====================
INIT_WINDOW:
    ; temporary: use block graphics for everything

    ; horizontal layout: 1 border, 7 P1 info,
    ; 1 border, 10 P1 board, 2 border, 10 P2 board,
    ; 1 border, 7 P2 info, 1 border, 24 filler

    ; vertical layout: 2 border/filler, 24 horizontal layout, 6 border/filler

    LEA.L   BUFF_PLANE, a0
    LEA.L   PAT_TEAL, a1
    MOVE.W  (a1), d0
    SWAP    d0
    MOVE.W  (a1), d0
    ; copy 2 rows of filler - 128 cells
    MOVEQ   #63, d1
@TOP_FILLER_LOOP:
    MOVE.L  d0, (a0)+
    DBRA    d1, @TOP_FILLER_LOOP
    
    ; copy 24 rows of the horizontal layout pattern
    MOVEQ   #23, d1
@H_LAYOUT_LOOP:
    ; 1 border
    MOVE.W  d0, (a0)+
    ; 7 info
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.W  #0, (a0)+
    ; 1 border
    MOVE.W  d0, (a0)+
    ; 10 P1 board
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    ; 2 border
    MOVE.L  d0, (a0)+
    ; 10 P2 board
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    ; 1 border
    MOVE.W  d0, (a0)+
    ; 7 P2 info
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)+
    MOVE.W  #0, (a0)+
    ; 1 border
    MOVE.W  d0, (a0)+
    ; 24 filler
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+

    DBRA    d1, @H_LAYOUT_LOOP

    ; copy 6 rows of filler - 64 x 6 cells
    MOVEQ   #65, d1
@BOT_FILLER_LOOP:
    MOVE.L  d0, (a0)+
    MOVE.L  d0, (a0)+
    DBRA    d1, @BOT_FILLER_LOOP

    ; transfer plane to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_WINDOW_SIZE/2, d1
    MOVE.W  #VRAM_WINDOW, d2
    JSR     DMADump

    RTS

INIT_CURSOR:
    VDP_ACCESS VDP_W_VRAM, VRAM_SPRITE_GFX
    LEA.L   VDP_DATA, a1
    LEA.L   GAME_CURSOR_V, a0
    ; copy top and centre
    JSR     CopyChar
    JSR     CopyChar
    ; copy a blank char
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    MOVE.L  #0, (a1)
    ; copy right
    JSR     CopyChar
    ; initialize size and link data for P1 and P2 cursors (remain constant)
    MOVE.W  #$0501, (P1_SPRITE+2)
    MOVE.W  #$0502, (P2_SPRITE+2)
    ; place empty sprite in buffer afterwards
    LEA.L   P2_SPRITE+8, a0
    MOVE.L  #0, (a0)+
    MOVE.L  #0, (a0)
    
    RTS


