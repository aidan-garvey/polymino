; *****************************************************************
; MATCH.S
; Game logic code for checking matches and handling their effects.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ==================================
; CHECK_ALL_MATCHES
; ----------------------------------
; Check the entire board for matches
; ----------------------------------
; Parameters:
;   a1 - points to game board
;   a2 - player game state
; Thrashed:
;   a0, d0-d7
; ==================================
CHECK_ALL_MATCHES:
    MOVE.L  a2, a0
    MOVE.W  #BOARD_HEIGHT-1, d4 ; y pos
@CHECK_ROW_LOOP:
    MOVE.W  #BOARD_WIDTH-1, d3 ; x pos
@CHECK_CELL_LOOP:
    ; don't check empty blocks
    TST.W   -(a0)
    BEQ.B   @SKIP_CHECK_MATCH
    ; don't check junk blocks
    TST.B   1(a0)
    BNE.B   @SKIP_CHECK_MATCH
    JSR     CHECK_MATCH
@SKIP_CHECK_MATCH:
    DBRA    d3, @CHECK_CELL_LOOP
    DBRA    d4, @CHECK_ROW_LOOP
    RTS

; =============================================
; CHECK_MATCH
; ---------------------------------------------
; Check for a match that includes a given block
; ---------------------------------------------
; Precondition: block is not empty nor junk
; ---------------------------------------------
; Parameters:
;   a0 - pointer to block
;   a2 - player game state
;   d3 - x position of block
;   d4 - y position of block
; Thrashed:
;   none
; Locals:
;   a1 - pointer up/left
;   a3 - pointer down/right
;   a4 - pointer to TO_CLEAR
;   d0 - block data
;   d1 - loop counter
;   d2 - misc
;   d5 - misc
;   d6 - tracks if match is a repeat or not
; =============================================
CHECK_MATCH:
    PUSH    a1/a3-a4/d0-d6

    MOVE.L  a0, a1
    MOVE.L  a0, a3
    MOVE.W  (a3)+, d0   ; d0 := (a0), a3 points one block to the right
    ;; if piece is junk, it can't be matched, so return
    ;TST.B   d0
    ;BNE.W   @CHECK_MATCH_RET
    
    ; move a1 to the left until (a1) != d0, but don't go further left than the board
    MOVE.W  d3, d1
    MOVEQ   #0, d2      ; so we don't break the loop instantly
    BRA.B   @CHECK_LEFT_STEP
@CHECK_LEFT_LOOP:
    CMP.W   -(a1), d0
@CHECK_LEFT_STEP:
    DBNE    d1, @CHECK_LEFT_LOOP
    ; if we exitted the loop due to the count, (a1) matches d0.
    ; if we exitted due to the NE condition, (a1 + 2) matches d0, but (a1) doesn't.
    BEQ.B   @CHECK_LEFT_DONE
    ADDA.W  #2, a1
@CHECK_LEFT_DONE:
    
    ; move a3 to the right until (a3) != d0, don't go further right than the board
    MOVE.W  #BOARD_WIDTH, d1
    SUB.W   d3, d1
    SUBQ    #1, d1  ; d1 := BOARD_WIDTH - CURSOR_X - 1
    MOVEQ   #0, d2  ; so we don't break the loop instantly
    BRA.B   @CHECK_RIGHT_STEP
@CHECK_RIGHT_LOOP:
    CMP.W   (a3)+, d0
@CHECK_RIGHT_STEP:
    DBNE    d1, @CHECK_RIGHT_LOOP
    ; if we exitted the loop due to the count, (a3 - 2) matches d0.
    ; if we exitted due to the NE condition, (a3 - 4) matches d0, but (a3 - 2) doesn't.
    BEQ.B   @CHECK_RIGHT_DONE
    SUBA.W  #2, a3
@CHECK_RIGHT_DONE:
    SUBA.W  #2, a3

    ; if a3 - a1 >= 4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #4, d1
    BLT     @NO_H_MATCH
    
    ; clear the blocks
    ; >= 4 words is >= 2 blocks of space, >= 2+1 blocks to clear
    LSR.W   #1, d1
    
    ; d2 will be x coordinate of leftmost block in the match
    MOVE.W  a1, d2
    SUB.W   a0, d2  ; d2 := address of left block - address of cursor
    ASR.W   #1, d2  ; d2 := pos of left block - pos of cursor
    ADD.W   d3, d2  ; d2 := pos of left block
    MOVE.L  a2, a4
    ADD.W   #TO_CLEAR_OFF, a4
    ADDA.W  d4, a4
    ADDA.W  d4, a4  ; a4 := pointer to word in TO_CLEAR for current row
    MOVE.W  (a4), d5; d5 := contents of TO_CLEAR for current row

    ; d6 will be set to TRUE if any previously
    ; unmatched block is included in the match
    MOVEQ   #0, d6

@H_CLEAR_LOOP:
    BSET    d2, d5
    ; if bit was previously unset, set d6 to TRUE
    BNE.B   @NOT_NEW_H_BLOCK
    MOVEQ   #-1, d6
@NOT_NEW_H_BLOCK:
    ADDQ    #1, d2
    DBRA    d1, @H_CLEAR_LOOP

    ; store updated TO_CLEAR flags
    MOVE.W  d5, (a4)
    ; if match contained any previously-unmatched
    ; blocks, increase player's combo and award points
    TST.W   d6
    BEQ.B   @NO_H_MATCH
    ; award points
    JSR     ADD_MATCH_SCORE
    ; spawn projectile
    JSR     SPAWN_H_PROJ
    
    ; spawn particle with player's current combo
    JSR     SPAWN_COMBO_NUM
    ; if combo isn't maxed, increase it
    CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
    BGE.B   @NO_H_MATCH
    ADDQ.W  #1, (COMBO_OFF, a2)

@NO_H_MATCH:

    ; same as above, but vertical
    MOVE.L  a0, a1
    MOVE.L  a0, a3
    ; d0 still contains the block

    ; move a1 up until (a1) != d0, but don't go above the top of the board
    MOVE.W  d4, d1
    MOVE.W  #0, d2
    BRA     @CHECK_UP_STEP
@CHECK_UP_LOOP:
    SUBA.W  #BOARD_WIDTH*2, a1
    CMP.W   (a1), d0
@CHECK_UP_STEP:
    DBNE    d1, @CHECK_UP_LOOP
    ; if we exitted due to NE, go back down a row
    BEQ     @CHECK_UP_DONE
    ADDA.W  #BOARD_WIDTH*2, a1
@CHECK_UP_DONE:
    ; save Y position of top block to d5
    MOVE.W  d1, d5
    ; if we exitted due to NE, top block is 1 down
    ; if we exitted due to d1 = -1, we want d5 to be 0
    ADDQ    #1, d5

    ; move a3 down until (a3) != d0, but don't go below the board
    MOVE.W  #BOARD_HEIGHT, d1
    SUB.W   d4, d1
    SUBQ    #1, d1
    MOVE.W  #0, d2
    BRA     @CHECK_DOWN_STEP
@CHECK_DOWN_LOOP:
    ADDA.W  #BOARD_WIDTH*2, a3
    CMP.W   (a3), d0
@CHECK_DOWN_STEP:
    DBNE    d1, @CHECK_DOWN_LOOP
    ; if we exitted due to NE, go up a row
    BEQ     @CHECK_DOWN_DONE
    SUBA.W  #BOARD_WIDTH*2, a3
@CHECK_DOWN_DONE:

    ; if a3 - a1 >= BOARD_WIDTH*4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #BOARD_WIDTH*4, d1
    BLT     @NO_V_MATCH

    ; clear the blocks
    MOVE.L  a2, a4
    ADD.W   #TO_CLEAR_OFF, a4
    ADDA.W  d5, a4  ; d5 is the pos of the top block, saved in CHECK_UP_LOOP
    ADDA.W  d5, a4  ; a4 := pointer to word in TO_CLEAR for current row
    LSR.W   #1, d1  ; d1 := BOARD_WIDTH * (MATCH_HEIGHT-1)
    ADD.W   #BOARD_WIDTH, d1 ;= BOARD_WIDTH * MATCH_HEIGHT

    ; d6 will be set to TRUE if any previously
    ; unmatched block is included in the match
    MOVEQ   #0, d6

@V_CLEAR_LOOP:
    MOVE.W  (a4), d5    ; d5 := current row in TO_CLEAR
    BSET    d3, d5      ; set bit representing x position of match
    ; if bit was previously unset, set d6 to TRUE
    BNE.B   @NOT_NEW_V_BLOCK
    MOVEQ   #-1, d6
@NOT_NEW_V_BLOCK:
    MOVE.W  d5, (a4)+   ; store updated flags
    SUB.W   #BOARD_WIDTH, d1
    BGT.B   @V_CLEAR_LOOP

    ; if match contained any previously-unmatched
    ; blocks, increase player's combo and award points
    TST.W   d6
    BEQ.B   @NO_V_MATCH
    ; award points
    JSR     ADD_MATCH_SCORE
    ; spawn projectile
    JSR     SPAWN_V_PROJ
    
    ; spawn particle with player's current combo
    JSR     SPAWN_COMBO_NUM
    ; if combo isn't maxed, increase it
    CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
    BGE.B   @NO_V_MATCH
    ADDQ.W  #1, (COMBO_OFF, a2)

@NO_V_MATCH:
@CHECK_MATCH_RET:
    POP     a1/a3-a4/d0-d6
    RTS
    