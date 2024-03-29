
; *****************************************************************
; MACROS.S
; Assembler macros used throughout the source code.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Wait for VDP to finish queued DMA tasks
WAIT_DMA: MACRO
_WAIT_DMA_LOOP\@:
    BTST    #1, VDP_CTRL+1   ; check if status register says "DMA BUSY"
    BNE.B   _WAIT_DMA_LOOP\@ ; keep checking until done
    ENDM
    
; Reset VBLANKON, wait until it is set by our VB routine after the next VB
WAIT_VB: MACRO
    CLR.W   (VBLANKON)
_LOOP\@:
    TST.W   (VBLANKON)
    BEQ.B   _LOOP\@
    ENDM

; Remove the Z80 from the bus and ensure it is off before continuing
REMOVE_Z80: MACRO
    MOVE.W  #$0100, Z80_BUSREQ  ; request bus from z80
_LOOP\@:
    BTST    #0, Z80_BUSREQ      ; wait until it is off bus
    BNE.B   _LOOP\@
    ENDM
    
; Replace the Z80 on the bus (for code readability)
REPLACE_Z80: MACRO
    MOVE.W  #0, Z80_BUSREQ
    ENDM
    
; Write byte of data (\2) to a VDP register (\1)
VDP_REG: MACRO
    MOVE.W  #$8000!((\1)<<8)!((\2)&$FF),VDP_CTRL
    ENDM
    
; Set up VDP to write/read to VRAM, CRAM or VSRAM
; (code given by \1) at given 16-bit offset (\2)
VDP_ACCESS: MACRO
    MOVE.L  #\1+((\2)&$3FFF)<<16+((\2)&$C000)>>14, VDP_CTRL
    ENDM
    
; Simillar to above macro, except using a register
; for the offset instead of an immediate value
    ; \1: R/W ID code (imm)
    ; \2: Data register with 16-bit offset
VDP_ACCESS_REG: MACRO
    ; We need %0000 0000 0000 0000 AABB BBBB BBBB BBBB
    ; in form %00BB BBBB BBBB BBBB 0000 0000 0000 00AA
    ROL.L   #2, \2  ; 0000 0000 0000 00AA BBBB BBBB BBBB BB00
    ROR.W   #2, \2  ; 0000 0000 0000 00AA 00BB BBBB BBBB BBBB
    SWAP    \2      ; 00BB BBBB BBBB BBBB 0000 0000 0000 00AA
    AND.L   #$3FFF0003, \2  ; Clear any bits that should not be set
    OR.L    #\1, \2         ; Add the R/W ID Code into the data register
    MOVE.L  \2, VDP_CTRL    ; Pass our control instruction to the VDP
    ENDM

; Put the system in a state for loading graphics outside
; of VBLANK - i.e. disable interrupts
LOAD_STATE_SOFT: MACRO
    MOVE.W  #$2700, SR
    VDP_REG 1, %01000100 ; enable display, disable V-INT & DMA, use V28 cells
    ENDM

; Put the system in a state for loading graphics and colors outside
; of VBLANK - i.e. disable interrupts and the display
LOAD_STATE_HARD: MACRO
    VDP_REG 1, %00100100 ; disable display & DMA, enable V-INT, V28 cells
    ; wait until next frame so display is off
    WAIT_VB
    MOVE.W  #$2700, SR
    VDP_REG 1, %00000100 ; disable display, V-INT, DMA, use V28 cells
    ENDM

; Undo the changes made in LOAD_STATE - i.e. enable
; interrupts and the display
END_LOAD_STATE: MACRO
    MOVE.W  #$2000, SR
    VDP_REG 1, %01100100 ; enable display & V-INT, disable DMA, use V28 cells
    ENDM

END_LOAD_STATE_HARD: MACRO
    MOVE.W  #$2000, SR
    VDP_REG 1, %00100100
    WAIT_VB
    VDP_REG 1, %01100100
    ENDM

; Push registers onto stack
; \1: register list (ex: d0/d1/d2/a3/a4 or d0-d2/a3-a4)
PUSH: MACRO
    MOVEM.L \1, -(SP)
    ENDM

; Pop registers from stack
; \1: register list
POP: MACRO
    MOVEM.L (SP)+, \1
    ENDM

; Move source to dest if source is smaller
; \1: source register or immediate value
; \2: dest register
MIN: MACRO
    CMP.\0  \1, \2
    BLE.B   _END\@
    MOVE.\0 \1, \2
_END\@:
    ENDM

; Move source to dest if source is larger
; \1: source register or immediate value
; \2: dest register
MAX: MACRO
    CMP.\0  \1, \2
    BGE.B   _END\@
    MOVE.\0 \1, \2
_END\@:
    ENDM

DEMO_EXIT_CHECK: MACRO
    BTST.B  #7, (JOY1+1)
    BEQ.B   _END\@
    MOVE.L  #PAUSE_EXIT_INIT, (MAIN_VECTOR)
    BRA     _RET
_END\@:
    ENDM
