
; *****************************************************************
; INTERRUPT.S
; Interrupt routines, mainly for the vertical blanking interrupt.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; -------------------------------
; VERTICAL BLANK INTERRUPT
; Jump to the routine in VBVECTOR
; -------------------------------
VBLANK:
    MOVE.L  (VBVECTOR), -(SP)
    RTS

; ------------------------------------------
; MAIN VBI ROUTINE
; Copies the sprite and scroll plane buffers
; to VRAM and flushes the DMA queue.
; ------------------------------------------
VBMAIN:
    PUSH    a0-a2/d0-d3

    ; Dump sprite buffer to VRAM
    MOVE.L  #BUFF_SPRITES, d0           ; source address
    MOVE.W  #VRAM_SPRITETBL_SIZE/2, d1  ; size of data in words
    MOVE.W  #VRAM_SPRITETBL, d2         ; VDP dest address
    JSR     DMADump

    ; Dump plane buffer to VRAM
    MOVE.L  #BUFF_PLANE, d0             ; source address
    MOVE.W  #VRAM_SCROLLA_SIZE/2, d1    ; size of data in words
    MOVE.W  #VRAM_SCROLLA, d2           ; VDP dest address
    JSR     DMADump

    ; Dump player score buffers
    MOVE.L  #SCORE_BUFF_1, d0
    MOVE.W  #SCORE_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_SCORE_GFX_1, d2
    JSR     DMADump

    MOVE.L  #SCORE_BUFF_2, d0
    MOVE.W  #SCORE_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_SCORE_GFX_2, d2
    JSR     DMADump

    ; Dump player bomb buffers
    MOVE.L  #BOMBS_BUFF_1, d0
    MOVE.W  #BOMBS_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_BOMBS_GFX_1, d2
    JSR     DMADump

    MOVE.L  #BOMBS_BUFF_2, d0
    MOVE.W  #BOMBS_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_BOMBS_GFX_2, d2
    JSR     DMADump

    ; Dump player outline buffers
    MOVE.L  #OUTLN_BUFF_1, d0
    MOVE.W  #OUTLN_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_OUTLINE_GFX_1, d2
    JSR     DMADump

    MOVE.L  #OUTLN_BUFF_2, d0
    MOVE.W  #OUTLN_BUFF_SIZE/2, d1
    MOVE.W  #VRAM_OUTLINE_GFX_2, d2
    JSR     DMADump

    ; scroll background if game is not paused
    TST.W   (GAME_PAUSED)
    BNE.B   @SKIP_B_SCROLL

    LEA.L   BUFF_VSCROLLB, a0
    SUBQ.W  #1, (a0)
    MOVE.W  (a0), d0
    LSR.W   #SCROLL_DIV, d0
    VDP_ACCESS VDP_W_VSRAM, 2
    MOVE.W  d0, (VDP_DATA)

@SKIP_B_SCROLL:
    ADD.W   #1, (FRAME_TICK)
    MOVE.W  #1, (VBLANKON)

    POP     a0-a2/d0-d3
    RTE

; -----------------
; DUMMY VBI ROUTINE
; -----------------
VBDUMMY:
    MOVE.W  #1, (VBLANKON)
    RTE

; --------------------------
; HORIZONTAL BLANK INTERRUPT
; --------------------------
HBLANK:
    RTE

; ------------------
; EXTERNAL INTERRUPT
; ------------------
EXTINT:
    RTE

; ----------------
; MISC. EXCEPTIONS
; ----------------
Exception:
    MOVE.W  #$2700, SR  ; disable interrupts
INF_LOOP:
    BRA.S INF_LOOP      ; infinite loop
