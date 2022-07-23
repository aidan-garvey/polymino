
; ====================================
; PLACE_NEW_JUNK
; ------------------------------------
; Place the next piece of junk on the
; game board, then generate a new next
; piece and display it in the UI.
; ------------------------------------
; Parameters:
;   a1 - game board
;   a2 - game state
; Thrashed:
;   a0, d0-d7
; ====================================
PLACE_NEW_JUNK:
    PUSH    a3/a5

    TST.W   (NEXT_JUNKID_OFF, a2)
    BEQ.W   @SKIP_JUNK_SPAWN

    ; ****************
    ; spawn junk piece
    ; ****************

    ; place junk at NEXT_JUNK_X
    MOVE.L  a1, a0
    MOVE.W  (NEXT_JUNK_X_OFF, a2), d0
    LSL.W   #1, d0
    ADDA.W  d0, a0  ; a0 -> top left of junk destination

    MOVE.W  (JUNK_PAT_OFF, a2), d0  ; d0 := index of junk piece data
    LSL.W   #4, d0  ; each piece is 16 bytes
    LEA.L   JUNK_PIECES, a3
    ADDA.W  d0, a3  ; a3 points to next junk piece
    MOVE.B  (a3)+, d6   ; d6 := width of piece
    MOVE.B  (a3)+, d7   ; d7 := height of piece
    EXT.W   d6
    EXT.W   d7
    SUBQ.W  #1, d6  ; width and height will
    SUBQ.W  #1, d7  ; be used as loop counters

    MOVEQ   #0, d4  ; d4 := y position of junk's top

    MOVE.W  (NEXT_JUNKID_OFF, a2), d0 ; d0 := junk block data

@PLACE_JUNK_LOOP:
    MOVE.W  d6, d2  ; d2 := width-1
    MOVE.W  (NEXT_JUNK_X_OFF, a2), d3 ; d3 := x position of junk's left
@PLACE_ROW_LOOP:
    MOVE.B  (a3)+, d1       ; d1 := junk block pattern index
    BGE.B   @JUNK_NOT_EMPTY ; -1 == empty block
    ADDA.W  #2, a0
    BRA.B   @PLACE_ROW_STEP
@JUNK_NOT_EMPTY:
    ; convert pattern ID into RAM offset
    LEA.L   JUNK_GRAY, a5
    ANDI.W  #$FF, d1
    LSL.W   #1, d1
    ADDA.W  d1, a5 ; a5 := JUNK pattern
    ; check if block should be colored
    BTST    #JUNK_COLOR_FLAG, d0
    BEQ.B   @BLOCK_COLOR_DONE
    ; check if block uses second palette
    BTST    #10, d0
    BEQ.B   @BLOCK_PAL_1 
    ; depending on palette, patterns are 26 or 52 bytes after the gray patterns
    ADDA.W  #26, a5
@BLOCK_PAL_1:
    ADDA.W  #26, a5
    MOVE.W  (a5), (SCRATCH)
    LEA.L   SCRATCH, a5
    ; we need to add the color % 4 * 5 to the pattern data
    MOVE.W  d0, d5
    ANDI.W  #$0300, d5  ; isolate lower 2 bits of color
    LSR.W   #6, d5      ; d5 := color * 4
    ADD.W   d5, (a5)
    LSR.W   #2, d5
    ADD.W   d5, (a5)
    
@BLOCK_COLOR_DONE:
    ; place pattern in screen buffer
    JSR     PLACE_JUNK_BLOCK
    ; place block data in board
    MOVE.W  d0, (a0)+

@PLACE_ROW_STEP:
    ADDQ.W  #1, d3
    DBRA    d2, @PLACE_ROW_LOOP
    
    ; jump to next row for a0
    SUBA.W  d6, a0 ; go back to left side of junk piece
    SUBA.W  d6, a0 ; keep in mind d6 = width-1
    ADDA.W  #(BOARD_WIDTH*2)-2, a0 ; go down 1 row
    ; move y down by 1
    ADDQ.W  #1, d4
    DBRA    d7, @PLACE_JUNK_LOOP

    ; ************************
    ; generate next junk piece
    ; ************************

@SKIP_JUNK_SPAWN:
    ; cycle through IDs until we find an unused one
    MOVE.L  a2, a0
    ADDA.W  #JUNK_IDS_OFF, a0 ; a0 points to bitfield
    MOVE.W  (NEXT_JUNKID_OFF, a2), d0 ; d0 is current index in bitfield
    ; decrement d0, if result is 0 roll over to 255
    SUBQ.B  #1, d0
    BNE.B   @SKIP_ROLLOVER
    SUBQ.B  #1, d0
@SKIP_ROLLOVER:

    ANDI.W  #$00FF, d0  ; don't let d0 contain extra block data
    MOVE.W  d0, d1      ; d1 := bit index (when modulo 8)
    LSR.W   #3, d0      ; d0 := byte index
    ADDA.W  d0, a0
    BSET.B  d1, (a0)
    ; if bit was 0, the id is free
    BEQ.B   @ID_CYCLE_DONE
    
    ; if bit was 1, we have to try the next bit
    MOVE.W  d1, (NEXT_JUNKID_OFF, a2)
    BRA.B   @SKIP_JUNK_SPAWN

@ID_CYCLE_DONE:
    ; write next junk ID, first byte is zeroes
    MOVE.W  d1, (NEXT_JUNKID_OFF, a2)
    ; replace empty first byte with random block data
    JSR     RAND
    ANDI.B  #$47, d0 ; clear invalid bits
    MOVE.B  d0, (NEXT_JUNKID_OFF, a2) ; overwrite first byte

    ; randomly choose pattern of next block
    JSR     RAND
    ANDI.W  #3, d0
    MOVE.W  d0, (JUNK_PAT_OFF, a2)

    ; randomly choose next x coordinate
    JSR     RAND
    ANDI.W  #$000F, d0  ; limit d0 to 15
    ; while d0 > (BOARD_WIDTH - PIECE_WIDTH),
    ; d0 -= (BOARD_WIDTH - PIECE_WIDTH)
    MOVE.W  (JUNK_PAT_OFF, a2), d2  ; d2 := pattern number
    LSL.W   #4, d2                  ; d2 := pattern offset
    LEA.L   JUNK_PIECES, a0
    ADDA.W  d2, a0                  ; a0 -> pattern
    MOVE.B  (a0), d2
    ANDI.W  #$00FF, d2              ; d2 := pattern width
    MOVEQ   #BOARD_WIDTH, d1
    SUB.W   d2, d1                  ; d1 := BOARD_WIDTH - PIECE_WIDTH
@CHECK_RAND_X:
    CMP.W   d1, d0
    BLE.B   @RAND_X_IN_RANGE
    SUB.W   d1, d0
    BRA.B   @CHECK_RAND_X
@RAND_X_IN_RANGE:
    MOVE.W  d0, (NEXT_JUNK_X_OFF, a2)

    ; ***************************
    ; display new next junk in UI
    ; ***************************

    JSR     CLEAR_UI_NEXT

    ; get destination in screen buffer for P1 or P2
    LEA.L   P_NEXT_POS_1, a0
    CMP.L   #GAME_STATE_1, a2
    BEQ.B   @SKIP_P2_POS
    LEA.L   P_NEXT_POS_2, a0
@SKIP_P2_POS:
    MOVE.W  (JUNK_PAT_OFF, a2), d0  ; d0 := index of junk piece data
    LSL.W   #4, d0  ; each piece is 16 bytes
    LEA.L   JUNK_PIECES, a3
    ADDA.W  d0, a3
    MOVE.B  (a3)+, d6   ; d6 := width
    MOVE.B  (a3)+, d7   ; d7 := height
    EXT.W   d6
    EXT.W   d7
    SUBQ.W  #1, d6  ; width and height will
    SUBQ.W  #1, d7  ; be used as loop counters

    ; if junk is <= 3 tiles wide, shift the position to the right by 1
    CMPI.W  #2, d6
    BGT.B   @NO_H_SHIFT
    ADDA.W  #2, a0
@NO_H_SHIFT:

    MOVE.W (NEXT_JUNKID_OFF, a2), d0 ; d0 := junk block data

@NEXT_PIECE_LOOP:
    MOVE.W  d6, d2  ; d2 := width-1
@NEXT_ROW_LOOP:
    MOVE.B  (a3)+, d1       ; d1 := junk block pattern index
    BGE.B   @NEXT_NOT_EMPTY ; -1 == empty block
    ADDA.W  #2, a0
    BRA.B   @NEXT_ROW_STEP
@NEXT_NOT_EMPTY:
    ; convert pattern ID into RAM offset
    LEA.L   JUNK_GRAY, a5
    ANDI.W  #$FF, d1
    LSL.W   #1, d1
    ADDA.W  d1, a5  ; a5 -> junk pattern
    ; check if block should be colored
    BTST    #JUNK_COLOR_FLAG, d0
    BEQ.B   @NBLOCK_COLOR_DONE
    ; check if block uses second palete
    BTST    #10, d0
    BEQ.B   @NBLOCK_PAL_1
    ; depending on palette, patterns are 26 or 52 bytes after the gray patterns
    ADDA.W  #26, a5
@NBLOCK_PAL_1:
    ADDA.W  #26, a5
    MOVE.W  (a5), (SCRATCH)
    LEA.L   SCRATCH, a5
    ; we need to add the color % 4 * 5 to the pattern data
    MOVE.W  d0, d5
    ANDI.W  #$0300, d5  ; isolate lower 2 bits of color
    LSR.W   #6, d5      ; d5 := color * 4
    ADD.W   d5, (a5)
    LSR.W   #2, d5      ; d5 := color
    ADD.W   d5, (a5)

@NBLOCK_COLOR_DONE:
    ; place pattern in screen buffer
    MOVE.W  (a5), (a0)+

@NEXT_ROW_STEP:
    DBRA    d2, @NEXT_ROW_LOOP
    
    ; jump to next row for a0
    SUBA.W  d6, a0 ; go back to left side of junk piece
    SUBA.W  d6, a0 ; keep in mid d6 = width-1
    ADDA.W  #126, a0 ; go down 1 row
    DBRA    d7, @NEXT_PIECE_LOOP

    POP     a3/a5
    RTS

    
