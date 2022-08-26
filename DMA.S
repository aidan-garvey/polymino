
; *****************************************************************
; DMA.S
; Subroutines for enqueuing and performing DMA requests.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ---- NOTE: --------------------------------------
; Having a0 be the next empty DMA queue space might
; not be very helpful. Could write a subroutine to
; scan for it, or have a spot in memory for it.
; -------------------------------------------------

; --------------------------------
; AddToDMAQueue
;   * d0.L = 68k source address
;   * d1.W = size of data in words
;   * d2.W = VDP dest address
;   * a0.L = next DMA queue dest
;
;   After execution:
;   * d0.L = 68k source address of
;       last submitted command
;   * d1.W = size of last command
;   * d2.W = VDP dest of last cmd
;   * a0.L = next empty DMA queue
;       index
; --------------------------------
AddToDMAQueue:
    MOVE.L  d3, -(SP)
    
    ; Check if room in queue
    MOVE.L  a0, d3
    CMPI.L  #DMA_QUEUE_END, d3
    ; if our address is >= end of queue, no room
    BGE.B   _AddToDMAQueue_RETURN
    
    ; Check if we're crossing a 128KB boundary ($010000, $020000, etc)
    ; If so, we need to split the DMA request at that boundary
    MOVEQ   #0, d3  ; clear d3 so we can perform long operations with it later
    MOVE.W  d0, d3
    ADD.W   d1, d3
    ADD.W   d1, d3  ; add d1 twice because it contains the size in words
    ; d3 = source + size = end of source data
    ; note d3 points to the first byte AFTER what we're transferring.
    ;   (ex: array of length 10 has indices 0..9)
    ; so, if d3 = 0, we aren't crossing a 128KB boundary
    ; if d3 > 0 but the carry bit isn't set, we aren't crossing a boundary
    ; if d3 > 0 and the carry bit is set, we are crossing a boundary 
    
    BEQ.B _DMANoSplit  ; d3 = 0 (end of source could be $10000, $20000, etc)
    BCS.B _DMASplit    ; d3 > 0 and carry set means we went from $0xxxx - $1xxxx, or $1xxxx - $2xxxx, etc
    BRA.B _DMANoSplit  ; d3 > 0 and carry isn't set means we stayed in $0xxxx, or $1xxxx, etc
    
_DMASplit:
    ; from previous calculations, d3 is already the
    ; space we have before hitting the boundary
    MOVE.W  d1, -(SP)
    
    MOVE.W  d3, d1  ; use d3 for our size so we don't cross boundary
    BSR     _SubmitDMAReq

    MOVE.W  (SP)+, d1
    
    ; calculate new src, length, VDP dest
    ; a0 was incremented in SubmitDMAReq,
    ; so it already points to next spot in queue
        ; note queue has space for overflow of 1 DMA request
        ; so we don't have to check if there's room, and
        ; we can always submit the whole original request
;   ADD.L   d3, d0  ; increase source address

    ; get d0 to next multiple of $10000
    ADD.L   #$10000, d0
    CLR.W   d0          
    SUB.W   d3, d1  ; get size of remaining data
    ADD.W   d3, d2  ; VDP dest
    
    ; fall thru to NoSplit to submit 2nd part of data
    
_DMANoSplit:
    BSR     _SubmitDMAReq
    
_AddToDMAQueue_RETURN:
    MOVE.L  (SP)+, d3
    RTS

; Put a DMA command in the queue
; d0.L = source address
; d1.W = data size, words
; d2.W = VDP dest address
; a0 = queue address
; after execution, a0 = next queue address
_SubmitDMAReq:
    ; copy source address
    MOVE.L  d0, (a0)+
    ; copy data size
    MOVE.W  d1, (a0)+
    ; copy VDP dest
    MOVE.W  d2, (a0)+
    ; copy all zeroes to next long
    ; to indicate end of queue
    MOVE.L  #0, (a0)
    
    RTS
  
; -----------------------------------------
; FlushDMAQueue
; Flush contents of DMA queue by retrieving
; values from queue and calling DMADump
; until the end of the queue is reached.
; Thrashed: a0-a2, d0-d3
; -----------------------------------------
FlushDMAQueue:
    ; put queue address in a2
    LEA.L   DMA_QUEUE, a2
    ; put size of queue in d3 (minus 1)
    MOVE.W  #$49, d3
_FLUSH_LOOP:
    ; get source address
    MOVE.L  (a2), d0
    ; if it's zero, return
    BEQ     _END_OF_QUEUE
    ; set to zero because we're consuming the item
    MOVE.L  #0, (a2)+
    ; get size
    MOVE.W  (a2)+,d1
    ; get VDP dest
    MOVE.W  (a2)+,d2
    ; perform DMA
    BSR     DMADump
    ; go back to start of loop if we aren't at end of queue
    DBRA    d3, _FLUSH_LOOP
_END_OF_QUEUE:
    RTS

; --------------------------------
; DMADump
;   * d0.L = 68k source address
;   * d1.W = size of data in words
;   * d2.W = VDP dest address
; Precondition: Not crossing a
;   128KB ROM boundary
; Thrashed: a0-a1, d0-d2
; --------------------------------
DMADump:
    LEA.L   VDP_CTRL, a1
    ANDI.L  #$00FFFFFF, d0  ; don't allow invalid address
    LEA.L   CURR_DMA_SRC+10, a0
    
    ; take Z80 off bus
    REMOVE_Z80
    ; enable DMA
    VDP_REG 1, %01110100

    ; source address lowest bit is bit 1, not 0
    LSR.L   #1, d0
    ; need to rearrage dest address
    LSL.L   #2, d2
    LSR.W   #2, d2
    SWAP    d2
    ; make sure only valid bits set
    ANDI.W  #$3, d2
    ; add info to VDP_CTRL write: RAM selection, DMA mode
    ORI.L   #$40000080, d2
    
    ; move high byte of size to (a0 - 3), low byte to (a0 - 1)
    MOVEP.W d1, -3(a0)
    ; d0 distributed to (a0 - 11), (a0 - 9), (a0 - 7), (a0 - 5)
    MOVEP.L d0, -11(a0)
    ; note the highest byte of d0 is not needed, as the source address is 24 bits.
    ; this is why there's a word-length buffer before CURR_DMA_SRC
    
    ; (a0 - 10), (a0 - 8), ..., (a0 - 2) contain the register
    ; codes for writing to VDP registers
    
    ; CURR_DMA_SRC contents, byte by byte:
    ; reg code 23
    ; source address [23..17]
    ; reg code 22
    ; source address [16..9]
    ; reg code 21
    ; source address [8..1]
    ; CURR_DMA_LEN:
    ; reg code 20
    ; size [15..8]
    ; reg code 19
    ; size [7..0]
    
    ; transfer SRC and LEN contents
    MOVE.W -(a0), (a1)
    MOVE.W -(a0), (a1)
    MOVE.W -(a0), (a1)
    MOVE.W -(a0), (a1)
    MOVE.W -(a0), (a1)
    
    ; move dest address to RAM then to VDP,
    ; prevents "occaisional hardware feature"
    ; that makes DMA fail
    MOVE.L  d2, (DMA_SCRATCH)
    MOVE.W  (DMA_SCRATCH), (a1)
    MOVE.W  (DMA_SCRATCH+2), (a1)
    ; DMA begins
    
    ; wait until DMA finished
    WAIT_DMA
    
    ; disable DMA
    VDP_REG 1, %01100100
    ; put Z80 back on bus
    REPLACE_Z80
    
    RTS

;DMA_VSRAM_A:
;    ; to write to only scroll A, increment
;    ; by 4 after each word write
;    VDP_REG 15, 4
;    ; LEA.L   VDP_CTRL, a1
;    ; take Z80 off bus
;    REMOVE_Z80
;    ; enable DMA
;    VDP_REG 1, %01110100
;    ; we will move 20 words, 1 for every 2 cells
;    VDP_REG 19, 20
;    VDP_REG 20, 0
;    ; DMA source address
;    VDP_REG 21, (BUFF_VSCROLLA>>1)&$FF
;    VDP_REG 22, (BUFF_VSCROLLA>>9)&$FF
;    VDP_REG 23, (BUFF_VSCROLLA>>17)&$FF
;    ; write to VSRAM, address 0
;    MOVE.L  #$40000090, (DMA_SCRATCH)
;    MOVE.W  (DMA_SCRATCH), (VDP_CTRL)
;    MOVE.W  (DMA_SCRATCH+2), (VDP_CTRL)
;    ; wait until finished
;    WAIT_DMA
;    ; disable DMA
;    VDP_REG 1, %01100100
;    ; put Z80 back on bus
;    REPLACE_Z80
;    ; restore VDP address increment
;    VDP_REG 15, 2
;
;    RTS

;DMA_VSRAM_B:
;    ; to write to only scroll B, increment
;    ; by 4 after each word write
;    VDP_REG 15, 4
;    LEA.L   VDP_CTRL, a1
;    ; take Z80 off bus
;    REMOVE_Z80
;    ; enable DMA
;    VDP_REG 1, %01110100
;    ; we will move 20 words, 1 for every 2 cells
;    VDP_REG 19, 20
;    VDP_REG 20, 0
;    ; DMA source address
;    VDP_REG 21, (BUFF_VSCROLLB>>1)&$FF
;    VDP_REG 22, (BUFF_VSCROLLB>>9)&$FF
;    VDP_REG 23, (BUFF_VSCROLLB>>17)&$FF
;    ; write to VSRAM, address 2
;    MOVE.L  #$40020090, (DMA_SCRATCH)
;    MOVE.W  (DMA_SCRATCH), (a1)
;    MOVE.W  (DMA_SCRATCH+2), (a1)
;    ; wait until finished
;    WAIT_DMA
;    ; disable DMA
;    VDP_REG 1, %01100100
;    ; put Z80 back on bus
;    REPLACE_Z80
;    ; restore VDP address increment
;    VDP_REG 15, 2
;
;    RTS
