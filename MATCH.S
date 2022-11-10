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
    PUSH.L  a4-a5
    ; ****************************
    ; check for horizontal matches
    ; ****************************
    MOVE.L  a1, a0  ; a0 -> game board
    MOVE.L  a2, a4
    ADDA.W  #TO_CLEAR_OFF, a4 ; a4 -> TO_CLEAR flags
    MOVEQ   #0, d4  ; y = 0
_CHECK_H_ROW:
        MOVEQ   #0, d3  ; x = 0
        MOVEQ   #0, d6  ; number of blocks in current match = 0
        MOVE.W  (a4), d5 ; d5 := this row's TO_CLEAR flags
        MOVEQ   #0, d0  ; d0 will hold current block
_CHECK_H_BLOCK:
            CMP.W   (a0)+, d0
            BNE.B   _RESET_H_MATCH
            ; block was equal to one stored in d0:
            ADDQ.W  #1, d6
            BRA.B   _CHECK_H_B_STEP
_RESET_H_MATCH:
            ; block was not equal to d0:
            ; don't match empty blocks
            TST.W   d0
            BEQ.B   _SKIP_H_MATCH
            ; don't match junk blocks
            TST.B   d0
            BNE.B   _SKIP_H_MATCH
            ; don't allow matches smaller than 3 blocks
            CMP.W   #2, d6  ; (counting starts at 0)
            BLT.B   _SKIP_H_MATCH
            ; if it's a match:
            ; award points
            JSR     ADD_MATCH_SCORE
            ; spawn projectile
            JSR     SPAWN_H_PROJ
            ; spawn combo number
            JSR     SPAWN_COMBO_NUM
            ; set TO_CLEAR flags
            MOVE.W  d3, d7
_H_TO_CLEAR:
                SUBQ.W  #1, d7
                BSET    d7, d5
                DBRA    d6, _H_TO_CLEAR

            ; increase combo
            CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
            BGE.B   _SKIP_H_MATCH
            ADDQ.W  #1, (COMBO_OFF, a2)

_SKIP_H_MATCH:
            MOVEQ   #0, d6  ; number of blocks in current match = 0
            ; update block stored in d0
            MOVE.W  -(a0), d0
            ADDQ.W  #2, a0

_CHECK_H_B_STEP:
            ADDQ.W  #1, d3  ; x += 1
            CMP.W   #BOARD_WIDTH, d3
            BLT.B   _CHECK_H_BLOCK

        ; at end of row, check for match involving rightmost block
        CMP.W   #2, d6
        BLT.B   _CHECK_H_R_STEP
        ; don't match empty blocks
        TST.W   d0
        BEQ.B   _CHECK_H_R_STEP
        ; don't match junk
        TST.B   d0
        BNE.B   _CHECK_H_R_STEP
        ; if it's a match:
        ; award points
        JSR     ADD_MATCH_SCORE
        ; spawn projectile
        JSR     SPAWN_H_PROJ
        ; spawn combo number
        JSR     SPAWN_COMBO_NUM
        ; set TO_CLEAR flags
        MOVE.W  d3, d7
_H_LAST_CLEAR:
            SUBQ.W  #1, d7
            BSET    d7, d5
            DBRA    d6, _H_LAST_CLEAR

        ; increase combo
        CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
        BGE.B   _CHECK_H_R_STEP
        ADDQ.W  #1, (COMBO_OFF, a2)

_CHECK_H_R_STEP:
        MOVE.W  d5, (a4)+ ; save TO_CLEAR flags
        ADDQ.W  #1, d4  ; y += 1
        CMP.W   #BOARD_HEIGHT, d4
        BLT.W   _CHECK_H_ROW

    ; **********************
    ; check vertical matches
    ; **********************
    MOVEQ   #0, d3  ; x = 0
_CHECK_V_COL:
        MOVE.L  a1, a0  ; a0 -> game board
        ADDA.W  d3, a0
        ADDA.W  d3, a0  ; a0 -> top of current column
        MOVE.L  a2, a4
        ADDA.W  #TO_CLEAR_OFF, a4
        MOVEQ   #0, d4  ; y = 0
        MOVEQ   #0, d6  ; number of blocks in current match = 0
        MOVEQ   #0, d0  ; d0 will hold current block
_CHECK_V_BLOCK:
            CMP.W   (a0), d0
            BNE.B   _RESET_V_MATCH
            ; block was equal to one stored in d0:
            ADDQ.W  #1, d6
            BRA.B   _CHECK_V_B_STEP
_RESET_V_MATCH:
            ; block was not equal to d0:
            ; don't match empty blocks
            TST.W   d0
            BEQ.B   _SKIP_V_MATCH
            ; don' match junk
            TST.B   d0
            BNE.B   _SKIP_V_MATCH
            ; don't allow matches smaller than 3 blocks
            CMP.W   #2, d6
            BLT.B   _SKIP_V_MATCH
            ; if it's a match:
            ; award points
            JSR     ADD_MATCH_SCORE
            ; spawn projectile
            JSR     SPAWN_V_PROJ
            ; spawn combo number
            JSR     SPAWN_COMBO_NUM
            ; set TO_CLEAR flags
            MOVE.L  a4, a5
_V_TO_CLEAR:
                MOVE.W  -(a5), d1
                BSET    d3, d1
                MOVE.W  d1, (a5)
                DBRA    d6, _V_TO_CLEAR
            
            ; increase combo
            CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
            BGE.B   _SKIP_V_MATCH
            ADDQ.W  #1, (COMBO_OFF, a2)

_SKIP_V_MATCH:
            MOVEQ   #0, d6
            ; update block stored in d0
            MOVE.W  (a0), d0

_CHECK_V_B_STEP:
            ; move down by one row:
            ADDQ.W  #1, d4  ; y position
            ADDA.W  #BOARD_WIDTH*2, a0  ; pointer to block
            ADDQ.W  #2, a4  ; TO_CLEAR flags
            CMP.W   #BOARD_HEIGHT, d4
            BLT.B   _CHECK_V_BLOCK
        
        ; at the end of a column, check for match involving bottom block
        CMP.W   #2, d6
        BLT.B   _CHECK_V_C_STEP
        ; don't match empty blocks
        TST.W   d0
        BEQ.B   _CHECK_V_C_STEP
        ; don't match junk
        TST.B   d0
        BNE.B   _CHECK_V_C_STEP
        ; if it's a match:
        ; award points
        JSR     ADD_MATCH_SCORE
        ; spawn projectile
        JSR     SPAWN_V_PROJ
        ; spawn combo number
        JSR     SPAWN_COMBO_NUM
        ; set TO_CLEAR flags
        MOVE.L  a4, a5
_V_LAST_CLEAR:
            MOVE.W  -(a5), d1
            BSET    d3, d1
            MOVE.W  d1, (a5)
            DBRA    d6, _V_LAST_CLEAR
        
        ; increase combo
        CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
        BGE.B   _CHECK_V_C_STEP
        ADDQ.W  #1, (COMBO_OFF, a2)

_CHECK_V_C_STEP:
        ADDQ.W  #1, d3  ; x += 1
        CMP.W   #BOARD_WIDTH, d3
        BLT.W   _CHECK_V_COL

    POP.L   a4-a5
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
    PUSH.L  a1/a3-a4/d0-d6

    MOVE.L  a0, a1
    MOVE.L  a0, a3
    MOVE.W  (a3)+, d0   ; d0 := (a0), a3 points one block to the right
    
    ; move a1 to the left until (a1) != d0, but don't go further left than the board
    MOVE.W  d3, d1
    MOVEQ   #0, d2      ; so we don't break the loop instantly
    BRA.B   _CHECK_LEFT_STEP
_CHECK_LEFT_LOOP:
    CMP.W   -(a1), d0
_CHECK_LEFT_STEP:
    DBNE    d1, _CHECK_LEFT_LOOP
    ; if we exitted the loop due to the count, (a1) matches d0.
    ; if we exitted due to the NE condition, (a1 + 2) matches d0, but (a1) doesn't.
    BEQ.B   _CHECK_LEFT_DONE
    ADDA.W  #2, a1
_CHECK_LEFT_DONE:
    
    ; move a3 to the right until (a3) != d0, don't go further right than the board
    MOVE.W  #BOARD_WIDTH, d1
    SUB.W   d3, d1
    SUBQ.W  #1, d1  ; d1 := BOARD_WIDTH - CURSOR_X - 1
    MOVEQ   #0, d2  ; so we don't break the loop instantly
    BRA.B   _CHECK_RIGHT_STEP
_CHECK_RIGHT_LOOP:
    CMP.W   (a3)+, d0
_CHECK_RIGHT_STEP:
    DBNE    d1, _CHECK_RIGHT_LOOP
    ; if we exitted the loop due to the count, (a3 - 2) matches d0.
    ; if we exitted due to the NE condition, (a3 - 4) matches d0, but (a3 - 2) doesn't.
    BEQ.B   _CHECK_RIGHT_DONE
    SUBA.W  #2, a3
_CHECK_RIGHT_DONE:
    SUBA.W  #2, a3

    ; if a3 - a1 >= 4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #4, d1
    BLT     _NO_H_MATCH
    
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

_H_CLEAR_LOOP:
    BSET    d2, d5
    ; if bit was previously unset, set d6 to TRUE
    BNE.B   _NOT_NEW_H_BLOCK
    MOVEQ   #-1, d6
_NOT_NEW_H_BLOCK:
    ADDQ    #1, d2
    DBRA    d1, _H_CLEAR_LOOP

    ; store updated TO_CLEAR flags
    MOVE.W  d5, (a4)
    ; if match contained any previously-unmatched
    ; blocks, increase player's combo and award points
    TST.W   d6
    BEQ.B   _NO_H_MATCH
    ; award points
    JSR     ADD_MATCH_SCORE
    ; spawn projectile
    JSR     SPAWN_H_PROJ
    
    ; spawn particle with player's current combo
    JSR     SPAWN_COMBO_NUM
    ; if combo isn't maxed, increase it
    CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
    BGE.B   _NO_H_MATCH
    ADDQ.W  #1, (COMBO_OFF, a2)

_NO_H_MATCH:

    ; same as above, but vertical
    MOVE.L  a0, a1
    MOVE.L  a0, a3
    ; d0 still contains the block

    ; move a1 up until (a1) != d0, but don't go above the top of the board
    MOVE.W  d4, d1
    MOVE.W  #0, d2
    BRA     _CHECK_UP_STEP
_CHECK_UP_LOOP:
    SUBA.W  #BOARD_WIDTH*2, a1
    CMP.W   (a1), d0
_CHECK_UP_STEP:
    DBNE    d1, _CHECK_UP_LOOP
    ; if we exitted due to NE, go back down a row
    BEQ.B   _CHECK_UP_DONE
    ADDA.W  #BOARD_WIDTH*2, a1
_CHECK_UP_DONE:
    ; save Y position of top block to d5
    MOVE.W  d1, d5
    ; if we exitted due to NE, top block is 1 down
    ; if we exitted due to d1 = -1, we want d5 to be 0
    ADDQ.W  #1, d5

    ; move a3 down until (a3) != d0, but don't go below the board
    MOVE.W  #BOARD_HEIGHT, d1
    SUB.W   d4, d1
    SUBQ    #1, d1
    MOVE.W  #0, d2
    BRA     _CHECK_DOWN_STEP
_CHECK_DOWN_LOOP:
    ADDA.W  #BOARD_WIDTH*2, a3
    CMP.W   (a3), d0
_CHECK_DOWN_STEP:
    DBNE    d1, _CHECK_DOWN_LOOP
    ; if we exitted due to NE, go up a row
    BEQ     _CHECK_DOWN_DONE
    SUBA.W  #BOARD_WIDTH*2, a3
_CHECK_DOWN_DONE:

    ; if a3 - a1 >= BOARD_WIDTH*4, we have a match
    MOVE.W  a3, d1
    SUB.W   a1, d1
    CMPI.W  #BOARD_WIDTH*4, d1
    BLT     _NO_V_MATCH

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

_V_CLEAR_LOOP:
    MOVE.W  (a4), d5    ; d5 := current row in TO_CLEAR
    BSET    d3, d5      ; set bit representing x position of match
    ; if bit was previously unset, set d6 to TRUE
    BNE.B   _NOT_NEW_V_BLOCK
    MOVEQ   #-1, d6
_NOT_NEW_V_BLOCK:
    MOVE.W  d5, (a4)+   ; store updated flags
    SUB.W   #BOARD_WIDTH, d1
    BGT.B   _V_CLEAR_LOOP

    ; if match contained any previously-unmatched
    ; blocks, increase player's combo and award points
    TST.W   d6
    BEQ.B   _NO_V_MATCH
    ; award points
    JSR     ADD_MATCH_SCORE
    ; spawn projectile
    JSR     SPAWN_V_PROJ
    
    ; spawn particle with player's current combo
    JSR     SPAWN_COMBO_NUM
    ; if combo isn't maxed, increase it
    CMPI.W  #MAX_COMBO, (COMBO_OFF, a2)
    BGE.B   _NO_V_MATCH
    ADDQ.W  #1, (COMBO_OFF, a2)

_NO_V_MATCH:
_CHECK_MATCH_RET:
    POP.L   a1/a3-a4/d0-d6
    RTS
