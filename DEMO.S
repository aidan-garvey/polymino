
; ********************************************************************
; DEMO.S
; Initialization and loop routines for running the "how to play" demo.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; ********************************************************************

_BTNS_XOFF = 2
_BTNS_YOFF = 18
BUFF_DEMO_DPAD = BUFF_PLANE+BOARD2_OFFSET+128*_BTNS_YOFF+2*_BTNS_XOFF
BUFF_DEMO_ABTN = BUFF_DEMO_DPAD+128+12
BUFF_DEMO_BBTN = BUFF_DEMO_ABTN+6
BUFF_DEMO_CBTN = BUFF_DEMO_BBTN+6

DEMO_HINT_TX = 21
DEMO_HINT_TY = 5

; the numbered DEMO_INIT subroutines (ex: DEMO_INIT_2) are near the
; bottom of the file, after DEMO_LOOP and its helpers
DEMO_INIT:
_HTP_TX = 25
_HTP_TY = 3

    ; dump controller button graphics to VRAM
    MOVE.L  #DEMO_DPAD_CHARS, d0
    MOVE.W  #11*16, d1
    MOVE.W  #VRAM_DEMO_GFX, d2
    JSR     DMADump
    
    ; initialize a 1-player game with difficulty 3
    MOVE.W  #1, (NUM_PLAYERS)
    ; frames b/w physics updates = 15 - 3 * (difficulty - 1)
    MOVE.W  #9, (UPDATE_MAX)

    JSR     GAME_INIT
    ; clear the generated blocks
    LEA.L   BOARD_1, a0
    MOVE.W  #(BOARD_WIDTH*BOARD_HEIGHT/2)-1, d0
_CLEAR_DATA:
    CLR.L   (a0)+
    DBRA    d0, _CLEAR_DATA

    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    MOVEQ   #BOARD_WIDTH-1, d3
_CLEAR_COL:
    MOVEQ   #BOARD_HEIGHT-1, d4
    REPT    5
    JSR     ERASE_BLOCK
    SUBQ.W  #1, d4
    ENDR
    DBRA    d3, _CLEAR_COL

    ; write "HOW TO PLAY" in extra space
    LEA.L   STR_HOWTO, a0
    MOVEQ   #_HTP_TX, d3
    MOVEQ   #_HTP_TY, d4
    JSR     DRAW_STRING

    ; draw controller buttons near bottom of extra space
    
    ; d-pad
    LEA.L   DEMO_DPAD_PATS, a0
    LEA.L   BUFF_DEMO_DPAD, a1

    REPT 4
    MOVE.L  (a0)+, (a1)+
    MOVE.L  (a0)+, (a1)
    ADDA.W  #124, a1
    ENDR

    ; a button
    LEA.L   DEMO_A_PATS, a0
    LEA.L   BUFF_DEMO_ABTN, a1

    MOVE.L  (a0)+, (a1)
    ADDA.W  #128, a1
    MOVE.L  (a0), (a1)

    ; b button
    LEA.L   DEMO_B_PATS, a0
    LEA.L   BUFF_DEMO_BBTN, a1

    MOVE.L  (a0)+, (a1)
    ADDA.W  #128, a1
    MOVE.L  (a0), (a1)
    
    ; c button
    LEA.L   DEMO_C_PATS, a0
    LEA.L   BUFF_DEMO_CBTN, a1

    MOVE.L  (a0)+, (a1)
    ADDA.W  #128, a1
    MOVE.L  (a0), (a1)


    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_1), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_1+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    ; reset joypad inputs
    CLR.W   (JOY1)
    CLR.W   (JOY1_OLD)

    ; FALL THROUGH TO DEMO_LOOP
    ; BRA.B   DEMO_LOOP

DEMO_LOOP:
    DEMO_EXIT_CHECK

    ; prevent any junk from spawning
    MOVE.W  #1, (JUNK_TIMER_1)

    ; stream inputs to JOY1
    MOVEA.L (DEMO_INPUTS), a0
    ADDA.W  (MAIN_TICK), a0
    MOVE.B  (a0), (JOY1+1)

    BSR.B   DEMO_DRAW_INPUTS

    JSR     GAME_LOOP

    MOVE.W  (DEMO_LEN), d0
    CMP.W   (MAIN_TICK), d0
    BGE.B   _RET
    ; to advance, get the address at the end of the inputs
    MOVEA.L (DEMO_INPUTS), a0
    ADDA.W  (DEMO_LEN), a0
    MOVE.L  (a0), (MAIN_VECTOR)
_RET:
    RTS

DEMO_DRAW_INPUTS:
    ; d0 := current frame's inputs,
    ; d1 := inputs changed since last frame
    MOVE.W  (JOY1), d0
    MOVE.W  (JOY1_OLD), d1
    EOR.W   d0, d1

    ; d-pad
    
    ; up
    BTST    #BUTTON_UP, d1
    BEQ.B   _SKIP_UP
    LEA.L   BUFF_DEMO_DPAD+2, a1
    BTST    #BUTTON_UP, d0
    BNE.B   _UP_PRESS
    ; unpress up
    SUBQ.W  #3, (a1)+
    SUBQ.W  #3, (a1)
    BRA.B   _SKIP_DOWN
_UP_PRESS:
    ; press up
    ADDQ.W  #3, (a1)+
    ADDQ.W  #3, (a1)
    BRA.B   _SKIP_DOWN
_SKIP_UP:

    ; down
    BTST    #BUTTON_DOWN, d1
    BEQ.B   _SKIP_DOWN
    LEA.L   BUFF_DEMO_DPAD+128*3+2, a1
    BTST    #BUTTON_DOWN, d0
    BNE.B   _DOWN_PRESS
    ; unpress down
    SUBQ.W  #3, (a1)+
    SUBQ.W  #3, (a1)
    BRA.B   _SKIP_DOWN
_DOWN_PRESS:
    ; press down
    ADDQ.W  #3, (a1)+
    ADDQ.W  #3, (a1)
_SKIP_DOWN:

    ; left
    BTST    #BUTTON_LEFT, d1
    BEQ.B   _SKIP_LEFT
    LEA.L   BUFF_DEMO_DPAD+128, a1
    BTST    #BUTTON_LEFT, d0
    BNE.B   _LEFT_PRESS
    ; unpress left
    SUBQ.W  #3, (a1)
    ADDA.W  #128, a1
    SUBQ.W  #3, (a1)
    BRA.B   _SKIP_RIGHT
_LEFT_PRESS:
    ; press left
    ADDQ.W  #3, (a1)
    ADDA.W  #128, a1
    ADDQ.W  #3, (a1)
    BRA.B   _SKIP_RIGHT
_SKIP_LEFT:

    ; right
    BTST    #BUTTON_RIGHT, d1
    BEQ.B   _SKIP_RIGHT
    LEA.L   BUFF_DEMO_DPAD+128+6, a1
    BTST    #BUTTON_RIGHT, d0 
    BNE.B   _RIGHT_PRESS
    ; unpress right
    SUBQ.W  #3, (a1)
    ADDA.W  #128, a1
    SUBQ.W  #3, (a1)
    BRA.B   _SKIP_RIGHT
_RIGHT_PRESS:
    ; press right
    ADDQ.W  #3, (a1)
    ADDA.W  #128, a1
    ADDQ.W  #3, (a1)
_SKIP_RIGHT:

    ; A
    BTST    #BUTTON_A, d1
    BEQ.B   _SKIP_A
    LEA.L   BUFF_DEMO_ABTN, a1
    BTST    #BUTTON_A, d0
    BNE.B   _A_PRESS
    ; unpress A
    SUBQ.W  #1, (a1)+
    SUBQ.W  #1, (a1)
    ADDA.W  #128-2, a1
    SUBQ.W  #1, (a1)+
    SUBQ.W  #1, (a1)
    BRA.B   _SKIP_A
_A_PRESS:
    ; press A
    ADDQ.W  #1, (a1)+
    ADDQ.W  #1, (a1)
    ADDA.W  #128-2, a1
    ADDQ.W  #1, (a1)+
    ADDQ.W  #1, (a1)
_SKIP_A:

    ; B
    BTST    #BUTTON_B, d1
    BEQ.B   _SKIP_B
    LEA.L   BUFF_DEMO_BBTN, a1
    BTST    #BUTTON_B, d0
    BNE.B   _B_PRESS
    ; unpress B
    SUBQ.W  #1, (a1)+
    SUBQ.W  #1, (a1)
    ADDA.W  #128-2, a1
    SUBQ.W  #1, (a1)+
    SUBQ.W  #1, (a1)
    BRA.B   _SKIP_B
_B_PRESS:
    ; press B
    ADDQ.W  #1, (a1)+
    ADDQ.W  #1, (a1)
    ADDA.W  #128-2, a1
    ADDQ.W  #1, (a1)+
    ADDQ.W  #1, (a1)
_SKIP_B:

    RTS

; teach the player how to move the cursor
DEMO_INIT_2:
    LEA.L   STR_CURSOR_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_CURSOR_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_CURSOR_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_2), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_2+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    ; run DEMO_LOOP the first time
    BRA.W   DEMO_LOOP

DEMO_INIT_3:
    ; place some blocks to match up
    LEA.L   GAME_STATE_1, a0    ; points to right after board data
    LEA.L   DEMO_BLOCKS, a1     ; block data to copy
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    
    MOVEQ   #BOARD_HEIGHT-1, d4
    MOVEQ   #3, d5
_ROW_LOOP:
    MOVEQ   #BOARD_WIDTH-1, d3
_BLOCK_LOOP:
    MOVE.B  (a1)+, -(SP)
    MOVE.W  (SP)+, d0
    ANDI.W  #$FF00, d0
    BEQ.S   _SKIP_PLACE
    JSR     PLACE_BLOCK
_SKIP_PLACE:
    MOVE.W  d0, -(a0)
    DBRA    d3, _BLOCK_LOOP
    SUBQ.W  #1, d4
    DBRA    d5, _ROW_LOOP

    ; write hint to text area
    LEA.L   STR_A_SWAP_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_A_SWAP_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING
    
    LEA.L   STR_DEMO_CLR, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING
    
    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_3), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_3+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    ; run DEMO_LOOP the first time
    BRA.W   DEMO_LOOP

DEMO_INIT_4:
    ; write hint to text area
    LEA.L   STR_B_SWAP_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY+3, d4
    JSR     DRAW_STRING

    LEA.L   STR_B_SWAP_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_4), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_4+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

DEMO_INIT_5:
    LEA.L   STR_JUNK_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_JUNK_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_JUNK_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    REPT    2
    LEA.L   STR_DEMO_CLR, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING
    ENDR

    ; reset RNG to make following calls predicatble
    MOVE.L  #$9876FEDC, d0
    MOVE.L  #$ABCD1234, d1
    MOVEM.L d0-d1, (RAND_STATE)

    LEA.L   BOARD_1, a1
    LEA.L   GAME_STATE_1, a2
    JSR     PLACE_NEW_JUNK
    JSR     DRAW_JUNK_OUTLINE

    ; generate more rows of blocks
    MOVE.W  #5, (a2)
    LEA.L   BUFF_PLANE+BOARD1_OFFSET, a4
    JSR     GENERATE_ROWS
    
    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_5), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_5+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

DEMO_INIT_6:
    LEA.L   STR_GOAL_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY+4, d4
    JSR     DRAW_STRING

    LEA.L   STR_GOAL_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_GOAL_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_GOAL_4, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   BOARD_1, a1
    LEA.L   GAME_STATE_1, a2
    JSR     PLACE_NEW_JUNK
    JSR     DRAW_JUNK_OUTLINE

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_6), (DEMO_LEN)  ; first word is length of phase
    MOVE.L  #DEMO_INPUT_6+2, (DEMO_INPUTS)  ; afterwards, inputs begin
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

DEMO_INIT_7:
    LEA.L   STR_COLOR_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_COLOR_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_COLOR_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_COLOR_4, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_DEMO_CLR, a0
    REPT    4
    ADDQ.W  #1, d4
    JSR     DRAW_STRING
    ENDR

    LEA.L   PLAYER_1_DATA, a1
    LEA.L   GAME_STATE_1, a2
    JSR     PLACE_NEW_JUNK
    JSR     DRAW_JUNK_OUTLINE

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_7), (DEMO_LEN)
    MOVE.L  #DEMO_INPUT_7+2, (DEMO_INPUTS)
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

DEMO_INIT_8:
    LEA.L   STR_BOMB_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_BOMB_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_BOMB_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_DEMO_CLR, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   PLAYER_1_DATA, a1
    LEA.L   GAME_STATE_1, a2
    JSR     PLACE_NEW_JUNK
    JSR     DRAW_JUNK_OUTLINE

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_8), (DEMO_LEN)
    MOVE.L  #DEMO_INPUT_8+2, (DEMO_INPUTS)
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

DEMO_INIT_9:
    ; once the game ends, switch phases
    TST.W   (GAME_OVER_1)
    BNE.B   DEMO_INIT_10

    LEA.L   STR_LOSE_1, a0
    MOVEQ   #DEMO_HINT_TX, d3
    MOVEQ   #DEMO_HINT_TY, d4
    JSR     DRAW_STRING

    LEA.L   STR_LOSE_2, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   STR_LOSE_3, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING
    
    LEA.L   STR_LOSE_4, a0
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    LEA.L   PLAYER_1_DATA, a1
    LEA.L   GAME_STATE_1, a2
    JSR     PLACE_NEW_JUNK
    JSR     DRAW_JUNK_OUTLINE

    MOVE.L  #DEMO_LOOP, (MAIN_VECTOR)
    MOVE.W  (DEMO_INPUT_9), (DEMO_LEN)
    MOVE.L  #DEMO_INPUT_9+2, (DEMO_INPUTS)
    CLR.W   (MAIN_TICK)

    BRA.W   DEMO_LOOP

; switch to the game over animation and tell the player
; to exit the demo by pressing start
DEMO_INIT_10:
    LEA.L   STR_START, a0
    MOVEQ   #DEMO_HINT_TX+3, d3
    MOVEQ   #DEMO_HINT_TY+6, d4
    JSR     DRAW_STRING

    LEA.L   STR_DEMO_EXIT, a0
    ADDQ.W  #2, d3
    ADDQ.W  #1, d4
    JSR     DRAW_STRING

    MOVE.W  #-1, (GAME_OVER_2)
    MOVE.L  #GAME_OVER_WAIT_1, (MAIN_VECTOR)
    CLR.W   (MAIN_TICK)

    RTS
