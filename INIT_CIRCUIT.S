
; *****************************************************************
; INIT_CIRCUIT.S
; Code to load the circuit backgrounds into VRAM.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

NUM_CIRC_CHARS = 34

; ==========================================================
; INIT_CIRC_CHARS
; ----------------------------------------------------------
; Uncompress the characters for the circuit board background
; and copy them to VRAM
; ==========================================================
INIT_CIRC_CHARS:
    PUSH    a0-a2/d0-d2

    ; use BUFF_PLANE as destination for uncompressed chars
    LEA.L   BUFF_PLANE, a1
    LEA.L   CIRC_COMP_ROWS, a0  ; array of unique rows used in the characters
    LEA.L   CIRC_COMP_CHARS, a2 ; each char is an index into CIRC_COMP_ROWS

    MOVE.W  #(NUM_CIRC_CHARS*8)-1, d1
@CIRC_CHAR_LOOP:
    ;MOVEA.L a0, a3
    ; convert row index into memory offset
    MOVE.B  (a2)+, d0
    EXT.W   d0
    LSL.W   #2, d0  ; each row is 4 bytes
    
    MOVE.L  (a0, d0.w), (a1)+
    ;EXT.W   d0
    ;; each row is 4 bytes
    ;LSL.W   #2, d0
    ;ADDA.W  d0, a3
    ;MOVE.L  (a3), (a1)+
    
    DBRA    d1, @CIRC_CHAR_LOOP

    ; transfer to VRAM
    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #NUM_CIRC_CHARS*16, d1
    MOVE.W  #VRAM_BCKGND_GFX, d2
    JSR     DMADump

    POP     a0-a2/d0-d2
    RTS

; ======================================
; INIT_CIRC_PLATE
; --------------------------------------
; Copy the circuit background to SCROLLB
; ======================================
INIT_CIRC_PLANE:
    PUSH    a0/a1/d0/d1/d6/d7

    LEA.L   CIRC_PATTERNS, a0
    LEA.L   BUFF_PLANE, a1

    ; d1 will be used to set color palette
    MOVE.L  #$60006000, d1

    ; copy 32 rows
    MOVEQ   #31, d7
@CIRC_PLANE_LOOP:
    ; copy 40 patterns (20 long words) and 24 blanks (12 longs) per row
    MOVEQ   #19, d6
@CIRC_PLANE_LOOP_1:
    ; MOVE.L  (a0)+, (a1)+
    MOVE.L  (a0)+, d0
    OR.L    d1, d0
    MOVE.L  d0, (a1)+
    DBRA    d6, @CIRC_PLANE_LOOP_1
    
    MOVEQ   #11, d6
@CIRC_PLANE_LOOP_2:
    CLR.L   (a1)+
    DBRA    d6, @CIRC_PLANE_LOOP_2

    DBRA    d7, @CIRC_PLANE_LOOP

    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_SCROLLB_SIZE/2, d1
    MOVE.W  #VRAM_SCROLLB, d2
    JSR     DMADump

    POP     a0/a1/d0/d1/d6/d7
    RTS
    
