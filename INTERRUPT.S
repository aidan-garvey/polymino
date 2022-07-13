; ******************
; INTERRUPT HANDLING
; ------------------
; Code that gets
; executed upon an
; interrupt occuring
; (see ROM header)
; ******************

; ------------------------
; VERTICAL BLANK INTERRUPT
; ------------------------
VBLANK:
    MOVE.L  VBVECTOR, -(SP) ; push address stored in VBVECTOR to SP
    RTS                     ; jump to VBVECTOR

; -----------------------------
; MAIN VBI ROUTINE
; If VBVECTOR contains #VBMAIN,
; this is what will be executed
; after a VBI. VBDUMMY is also
; executed after, since all it
; does is set VBLANKON and
; return from the VB exception.
; -----------------------------
VBMAIN:
    PUSH    a0-a2/d0-d3

    ; Dump sprite buffer to VRAM
    MOVE.L  #BUFF_SPRITES, d0           ; source address
    MOVE.W  #VRAM_SPRITETBL_SIZE/2, d1  ; size of data (in words)
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

    ; perform other DMAs in queue
    ; JSR     FlushDMAQueue

    ; horizontally scroll background
    ADD.W   #1, (BUFF_HSCROLLB)
    MOVE.W  (BUFF_HSCROLLB), d0
    LSR.W   #SCROLL_DIV, d0
    VDP_ACCESS VDP_W_VRAM, VRAM_HSCROLL+2
    MOVE.W  d0, (VDP_DATA)
    LSR.W   #1, d0
    VDP_ACCESS VDP_W_VSRAM, 2
    MOVE.W  d0, (VDP_DATA)

    ADD.W   #1, (FRAME_TICK)

    POP     a0-a2/d0-d3

; INTENTIONAL FALL-THRU TO VBDUMMY

; -------------------------------
; DUMMY VBI ROUTINE
; If VBVECTOR contains #VBDUMMY,
; or after executing VBMAIN,
; this will be executed. Sets
; indicator that VBI routine is
; done and returns to what was
; executing before the interrupt.
; -------------------------------
VBDUMMY:
    MOVE.W  #1, VBLANKON
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
