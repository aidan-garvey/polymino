
; *****************************************************************
; CONST_ADDR.S
; VRAM addresses and RAM address offsets used throughout the game.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; For this game, each plane should only need to be big enough to
; cover the screen, so each plane is 64 x 32 cells = $1000 bytes
VRAM_BLOCK_GFX = $0020
VRAM_JUNK_GFX = $0800
VRAM_UI_GFX = $1000
VRAM_BCKGND_GFX = $2000
VRAM_SPRITE_GFX = $3000
VRAM_SCORE_GFX_1 = $32A0 ; P1_SCORE_DGTS
VRAM_SCORE_GFX_2 = $3380 ; P2_SCORE_DGTS
VRAM_PROJ_GFX = $3460    ; projectile characters, 8*32 bytes
VRAM_DEBRIS_GFX = $3560  ; debris characters, 4*32 bytes
VRAM_OUTLINE_GFX_1 = $35E0 ; P1 outline chars, 16*32 bytes
VRAM_OUTLINE_GFX_2 = $37E0 ; P2 outline chars, 16*32 bytes
VRAM_BOMBS_GFX_1 = $39E0 ; P1_BOMBS_DGTS
VRAM_BOMBS_GFX_2 = $3A20 ; P2_BOMBS_DGTS
VRAM_COMBO_GFX = $3A60   ; Floating numbers when combos earned, 10*32 bytes
VRAM_DEMO_GFX = $3BA0    ; D-pad and ABC buttons, 11*32 bytes
; $3D00
VRAM_LETTER_GFX = $4000  ; letters, 26*32 bytes
VRAM_DIGIT_GFX = $4340   ; digits, 10*32 bytes
VRAM_GAMEOVR_GFX = $4480 ; "GAME OVER" sprites, 32*32 bytes
; $4880
VRAM_TITLE_GFX = $4800  ; title screen graphics, overlaps w/ GAMEOVR_GFX
                        ; but they aren't used at the same time
VRAM_SPRITETBL = $B800
VRAM_HSCROLL = $BC00
VRAM_WINDOW = $C000
VRAM_SCROLLA = $C000
; Free space: $D000 - $DFFF
VRAM_SCROLLB = $E000
; Free space: $F000 - $FFFF

VRAM_SPRITETBL_SIZE = $400
VRAM_HSCROLL_SIZE = $400
VRAM_SCROLLA_SIZE = $1000
VRAM_SCROLLB_SIZE = $1000
VRAM_JUNK_SIZE = $5A0
VRAM_PROJ_SIZE = 32*8
VRAM_DEBRIS_SIZE = 32*4
VRAM_COMBO_SIZE = 32*10

BOARD1_OFFSET = 274
BOARD2_OFFSET = BOARD1_OFFSET+24
BOARD_ROW_GAP = 108 ; number of bytes between board rows in screen buffer

; length, in bytes, of each particle's sprite attributes
PART_SPRITE_SIZE = 8
; length, in bytes, of each particle's other data
PART_DATA_SIZE = 10

; game state offsets
NEW_ROWS_OFF = NEW_ROWS_1-GAME_STATE_1
SCORE_BCD_OFF = SCORE_BCD_1-GAME_STATE_1
BOMBS_OFF = BOMBS_1-GAME_STATE_1
CURSOR_X_OFF = CURSOR_1_X-GAME_STATE_1
CURSOR_Y_OFF = CURSOR_1_Y-GAME_STATE_1
JOY_H_TIMER_OFF = JOY_H_TIMER_1-GAME_STATE_1
JOY_V_TIMER_OFF = JOY_V_TIMER_1-GAME_STATE_1
COMBO_OFF = COMBO_1-GAME_STATE_1
CHECK_PROJ_OFF = CHECK_PROJ_1-GAME_STATE_1
GAME_OVER_OFF = GAME_OVER_1-GAME_STATE_1
GAME_OVER_T_OFF = GAME_OVER_T_1-GAME_STATE_1
SCORE_BIN_OFF = SCORE_BIN_1-GAME_STATE_1
BOARD_TX_OFF = BOARD_TX_1-GAME_STATE_1
PART_P_FLAG_OFF = PART_P_FLAG_1-GAME_STATE_1
OUTLINE_SP_OFF = OUTLINE_SP_1-GAME_STATE_1
TO_CLEAR_OFF = TO_CLEAR_1-GAME_STATE_1
SCORE_BUFF_OFF = SCORE_BUFF_1-GAME_STATE_1
JUNK_TIMER_OFF = JUNK_TIMER_1-GAME_STATE_1
NEXT_JUNKID_OFF = NEXT_JUNKID_1-GAME_STATE_1
JUNK_PAT_OFF = JUNK_PAT_1-GAME_STATE_1
NEXT_JUNK_X_OFF = NEXT_JUNK_X_1-GAME_STATE_1
JUNK_IDS_OFF = JUNK_IDS_1-GAME_STATE_1
OUTLN_BUFF_OFF = OUTLN_BUFF_1-GAME_STATE_1
BOMBS_BUFF_OFF = BOMBS_BUFF_1-GAME_STATE_1
