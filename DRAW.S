
; ==============================================
; DRAW_BOARD
; ----------------------------------------------
; Using the board data, write the representation
; of the board to the scroll plane buffer
; ----------------------------------------------
; Parameters:
;   a1 - pointer to board
;   a4 - scroll plane destination
; ----------------------------------------------
; Thrashed:
;   d0-d3
; ==============================================
DRAW_BOARD:
    PUSH    a1-a4

    MOVE.W  UI_DITHER, d3   ; d3 holds character for empty tiles

    MOVE.W  #BOARD_HEIGHT-1, d0  ; d0 will count number of rows
@BOARD_LOOP:
    MOVE.W  #BOARD_WIDTH-1, d1   ; d1 will count number of cells per row
@ROW_LOOP:
    MOVE.W  (a1)+, d2
    ; TODO: junk
    ; test for empty block
    BTST    #14, d2
    BEQ.B   @EMPTY_CELL

    ; not empty:
    LEA.L   BLOCK_PATTERNS, a2
    ; color bits will be used for offset from BLOCK_PATTERNS
    LSR.W   #7, d2
    ANDI.W  #$000E, d2  ; d2 = color * 2
    ADDA.W  d2, a2
    MOVE.W  (a2), (a4)+
    BRA.B   @ROW_STEP

@EMPTY_CELL:
    MOVE.W  d3, (a4)+

@ROW_STEP:
    DBRA    d1, @ROW_LOOP
    ADDA.W  #BOARD_ROW_OFFSET, a4
    DBRA    d0, @BOARD_LOOP

    POP     a1-a4

    RTS

; =======================================
; DRAW_CURSOR
; ---------------------------------------
; Draw one of the players' cursors
; ---------------------------------------
; Parameters:
;   a2 - player game state
;   a5 - player's cursor in sprite buffer
; Thrashed:
;   d0-d1, a0
; =======================================
DRAW_CURSOR:
    ; LEA.L   VDP_DATA, a0
    MOVEA.L a5, a0
    MOVE.W  #$1000+CURSOR_CHAR, d1 ; pri = 0, pal = 0,
                        ; vflip = 1, hflip = 0, gfx location
    ; cursor sprite
    ; VDP_ACCESS VDP_W_VRAM, VRAM_SPRITETBL
    
    ; get vertical position
    MOVE.W  (CURSOR_Y_OFF, a2), d0
    BEQ     @CURSOR_NO_V_SUB
    ; if cursor not at top, don't vflip, decrease sprite's y
    SUBQ    #1, d0
    ANDI.W  #$EFFF, d1  ; vflip = 0
@CURSOR_NO_V_SUB:
    ; multiply by 8 since each cell is 8 pixels high
    ASL.W   #3, d0
    ; add offset to move into display area
    ADD.W   #$90, d0
    ; write vertical position
    MOVE.W  d0, (a0)+
    ; skip size and link
    ADDA.W  #2, a0
    ; MOVE.W  #$0500, (a0) ; hsize = 2, vsize = 2, link = 0
    ; horizontal position
    MOVE.W  (CURSOR_X_OFF, a2), d0
    CMPI.W  #BOARD_WIDTH-1, d0
    BNE     @CURSOR_NO_H_SUB
    SUBQ    #1, d0
    ORI.W   #$0800, d1  ; hflip = 1
@CURSOR_NO_H_SUB:
    ; we now have enough info for 3rd write
    MOVE.W  d1, (a0)+
    ; multiply by 8
    ASL.W   #3, d0
    ; add offset to move into display area
    ADD.W   #$C8, d0
    ; little cheat: if a5 pointing to P2_SPRITE, add additional h offset
    CMPA.L  #P2_SPRITE, a5
    BNE     @WRITE_H_POS
    ADD.W   #$60, d0
@WRITE_H_POS:
    MOVE.W  d0, (a0)

    RTS


; ========================================
; DRAW_SCORE
; ----------------------------------------
; Copy the digits of the player's score to
; VRAM so the score sprites display them
; ----------------------------------------
; Parameters:
;   a2 - player state
; ----------------------------------------
; Thrashed:
;   a0, d0-d2
; ========================================
DRAW_SCORE:
    PUSH    a1/a3
    LEA.L   TEXT_DIGITS, a0 ;= score graphics source
    MOVE.L  a2, a1
    ADDA.W  #SCORE_BUFF_OFF, a1 ;= score graphics dest
    MOVE.L  a2, a3
    ADDA.W  #SCORE_OFF, a3 ;= BCD score

    ; first byte only uses lower 4b
    MOVE.B  (a3)+, d1
    ANDI.W  #$F, d1
    ; multiply by 32 to get character location
    LSL.W   #5, d1
    ADDA.W  d1, a0

    JSR     CopyCharRAM

    MOVEQ   #2, d3
@DRAW_SCORE_LOOP:
    MOVE.B  (a3)+, d1
    LSL.W   #5, d1
    MOVE.W  d1, d2
    ANDI.W  #$F0<<5, d2 ; first digit
    LSR.W   #4, d2
    ANDI.W  #$0F<<5, d1 ; second digit
    
    LEA.L   TEXT_DIGITS, a0
    ADDA.W  d2, a0
    JSR     CopyCharRAM
    LEA.L   TEXT_DIGITS, a0
    ADDA.W  d1, a0
    JSR     CopyCharRAM

    DBRA    d3, @DRAW_SCORE_LOOP

    POP     a1/a3
    RTS



