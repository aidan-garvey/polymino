
; *********************************************************************
; SUB_GENERAL.S
; General purpose subroutines intended to be usable for multiple games.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *********************************************************************

; ---------------------------
; CLEAR_CRAM: clears all CRAM
; Thrashed: d0, d1, a0
; ---------------------------
CLEAR_CRAM:
    ; write to CRAM at base addr
    MOVE.L  #VDP_W_CRAM, VDP_CTRL
    MOVEQ   #0, d1
    MOVE.W  #31, d0     ; 31 = 128 bytes / (4 bytes / long word) - 1
    LEA.L   VDP_DATA, a0
_CL_CRAM_LOOP:
    MOVE.L  d1, (a0)
    DBRA    d0, _CL_CRAM_LOOP
    
    RTS
    
; -----------------------------
; CLEAR_VSRAM: clears all VSRAM
; Thrashed: d0, d1, a0
; -----------------------------
CLEAR_VSRAM:
    MOVE.L  #VDP_W_VSRAM, VDP_CTRL
    MOVEQ   #0, d1
    MOVE.W  #19, d0     ; 19 = 80 bytes / (4 bytes / long word) - 1
    LEA.L   VDP_DATA, a0
_CL_VSRAM_LOOP:
    MOVE.L  d1, (a0)
    DBRA    d0, _CL_VSRAM_LOOP
    
    RTS
    
; ---------------------------
; CLEAR_VRAM: clears all VRAM
; Thrashed: d0, d1, a0
; ---------------------------
CLEAR_VRAM:
    MOVE.L  #VDP_W_VRAM, VDP_CTRL
    MOVEQ.L #0, d1
    MOVE.L  #$800-1, d0     ; VRAM size in bytes * 1/4 / number of writes per loop
    LEA.L   VDP_DATA, a0    ;      = $1 0000 * 1/4 / 8 = $800
_CL_VRAM_LOOP:
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    MOVE.L  d1, (a0)
    
    DBRA    d0, _CL_VRAM_LOOP
    
    RTS

; --------------------------------
; CLEAR_BUFF_PLANE:
; Clear the contents of BUFF_PLANE
; Thrashed: none
; --------------------------------
CLEAR_BUFF_PLANE:
    PUSH    a0/d0
    MOVE.W  #VRAM_SCROLLA_SIZE/16-1, d0
    LEA.L   BUFF_PLANE, a0
_CLEAR_BUFF_PLANE_LOOP:
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.L   (a0)+
    CLR.L   (a0)+
    DBRA    d0, _CLEAR_BUFF_PLANE_LOOP
    POP     a0/d0
    RTS

; ----------------------------------
; CLEAR_BUFF_SPRITES:
; Clear the contents of BUFF_SPRITES
; Thrashed: none
; ----------------------------------
CLEAR_BUFF_SPRITES:
    PUSH    a0/d0
    MOVE.W  #VRAM_SPRITETBL_SIZE/4-1, d0
    LEA.L   BUFF_SPRITES, a0
_CLEAR_BUFF_SPRITES_LOOP:
    CLR.L   (a0)+
    DBRA    d0, _CLEAR_BUFF_SPRITES_LOOP
    POP     a0/d0
    RTS

; -------------------------------------
; LOAD_PALETTE:
; Load a colour palette into colour
; palette buffer
;
; Parameters:
; d0: palette we are overwriting (0..3)
; a0: starting address of palette
;
; Thrashed: a0-a1, d0
; -------------------------------------
LOAD_PALETTE:
    ; Convert palette number into CRAM address offset
    ANDI.W  #$3, d0     ; make sure d0 contains valid number
    LSL.W   #5, d0      ; multiply d0 by 32 (i.e. 2^5)
    LEA.L   BUFF_PALETTES, a1
    ADDA.W  d0, a1
    
    ; Move palette
    MOVE.L  #$F, d0
_LOAD_PALETTE_LOOP:
    MOVE.W  (a0)+, (a1)+
    DBRA    d0, _LOAD_PALETTE_LOOP
    
    RTS

; --------------------------------------
; DUMP_PALETTES:
; Dump all colours in the palette buffer
; into CRAM. Doesn't use DMA, which
; could be improved in the future
;
; Thrashed: a0-a1, d0
; --------------------------------------
DUMP_PALETTES:
    VDP_ACCESS VDP_W_CRAM, 0
    LEA.L   VDP_DATA, a1
    LEA.L   BUFF_PALETTES, a0
    MOVE.W  #63, d0
_DUMP_PALETTES_LOOP:
    MOVE.W  (a0)+, (a1)
    DBRA    d0, _DUMP_PALETTES_LOOP
    
    RTS

; ----------------------------------
; CopyCharVRAM:
; Copy a single character into VRAM.
; For larger amount of chars, DMA
; should be used instead, especially
; during gameplay.
;
; Parameters:
; a0: starting address of char
; a1: address of VDP_DATA register
;     or RAM destination
;
; Preconditions:
;   VDP is ready to write to desired
;   address.
;
; On exit:
; a0: address after char
; d0: -1
; ----------------------------------
CopyCharVRAM:
    MOVEQ   #7, d0
_CCVRAMLoop:
    MOVE.L  (a0)+, (a1)
    DBRA    d0, _CCVRAMLoop
    RTS

; ---------------------------------
; CopyCharRAM:
; Copy a single character into RAM.
;
; Parameters:
; a0: starting address of char
; a1: destination address for char
; 
; On exit:
; a0: address after source char
; a1: address after written char
; d0: -1
; --------------------------------
CopyCharRAM:
    MOVEQ   #7, d0
_CCRAMLoop:
    MOVE.L  (a0)+, (a1)+
    DBRA    d0, _CCRAMLoop
    RTS

; -------------------------------
; ClearCharRAM:
; Clear a single character in RAM
; 
; Parameters:
; a1: destination address
; 
; On ext:
; a1: address after written char
; d0: -1
; -------------------------------
ClearCharRAM:
    MOVEQ   #7, d0
_ClearCharLoop:
    CLR.L   (a1)+
    DBRA    d0, _ClearCharLoop
    RTS
    