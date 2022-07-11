; *******************
; **** INTERFACE ****
; -------------------
; Subroutines for the
; user interface and
; background
; *******************

; =====================
; INIT_WINDOW
; ---------------------
; Copy patterns to VRAM
; for the WINDOW layer.
; ---------------------
; Thrashed:
;   d0-d3
; =====================
INIT_SCROLLA:
    ; load characters into VRAM
    MOVE.L  #UI_BRDR_CHARS, d0
    MOVE.W  #3*16, d1
    MOVE.W  #VRAM_UI_GFX, d2
    JSR     DMADump

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
    ; MOVE.W  #VRAM_WINDOW_SIZE/2, d1
    ; MOVE.W  #VRAM_WINDOW, d2
    MOVE.W  #VRAM_SCROLLA_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLA, d2
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

INIT_BACKGROUND:
    ; load star graphics into VRAM
    MOVE.L  #BCKGND_NIGHT_CHARS, d0 ; address
    MOVE.W  #32, d1     ; 16 words * 2 chars
    MOVE.W  #$2000, d2  ; start at tile $100 (address $2000)
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

