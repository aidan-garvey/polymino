
; *****************************************************************
; RAM_MAP.S
; Addresses for all data stored in work RAM.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Note about sizes: most items are allocated an even number of
; bytes so everything is word-aligned, even if only 1 byte is used.

STACK_END = $FF0400     ; 1KB stack
VBLANKON = $FF0400      ; WORD: Has VBlank routine finished?
VBVECTOR = $FF0402      ; LONG: Location of VBlank routine

JOY1 = $FF0406          ; WORD: Joypad data for player 1
JOY2 = $FF0408          ; WORD: Joypad data for player 2
JOY1_OLD = $FF040A      ; WORD: JOY1 from previous frame
JOY2_OLD = $FF040C      ; WORD: JOY2 from previous frame
HOT_START = $FF040E     ; WORD: hot start flag
; $FF0410 - $FF0416: Extra Space

; $FF0416: WORD OF MARGIN, DMA routine writes junk here
CURR_DMA_SRC = $FF0418  ; 3B: Source Address register writes for current DMA command
CURR_DMA_LEN = $FF041E  ; WORD: Size register writes for current DMA command
DMA_QUEUE = $FF0422     ; 8B*$50 = $280 Bytes
DMA_QUEUE_END = $FF06A2 ; 12B: Space for queue overflow (1 extra cmd + LONG of zeroes)

; $FF06AE - 2B of extra space

BUFF_PALETTES = $FF06B0 ; 128B: Palettes on screen
BUFF_SPRITES = $FF0730  ; $400 Bytes: Sprite Table Buffer
; player 1 HUD:
HUD_SPRITES_1 = $FF0730
P1_SPRITE = $FF0730     ; 8B: player 1 cursor
P1_T_NEXT = $FF0738     ; 8B: "NEXT"
P1_T_SCORE = $FF0740    ; 8B: "SCORE"
P1_T_LLINES = $FF0748   ; 8B: "LIFE\nLINES"
P1_SCORE_DGTS = $FF0750 ; 16B: player 1 score, 2 sprites
; player 2 HUD (if applicable):
HUD_SPRITES_2 = $FF0760
P2_SPRITE = $FF0760     ; 8B: player 2 cursor
P2_T_NEXT = $FF0768     ; 8B: "NEXT"
P2_T_SCORE = $FF0770    ; 8B: "SCORE"
P2_T_LLINES = $FF0778   ; 8B: "LIFE\nLINES"
P2_SCORE_DGTS = $FF0780 ; 16B: player 2 score, 2 sprites
; Particles:
PART_SPRITES = $FF0790  ; Particle effect sprites, rest of sprite table
SPRITES_END = $FF0B30   ; Upper bound for sprite data

BUFF_PLANE = $FF0B30    ; $1000 Bytes: Playfield buffer for writing to VRAM
BUFF_HSCROLL = $FF1B30  ; Horizontal Scroll buffer (cell-by-cell)
                        ; 28 rows * 2 planes * 2 bytes = 112B
BUFF_HSCROLLA = $FF1B30
BUFF_HSCROLLB = $FF1B68
; $FF1BA0

MAIN_VECTOR = $FF1F00   ; 4B: Address of current main loop subroutine
MAIN_TICK = $FF1F04     ; 2B: Main loop counter
FRAME_TICK = $FF1F06    ; 2B: Frame counter
RAND_STATE = $FF1F08    ; 8B: PRNG state
SCROLL_Y = $FF1F10      ; 4B: Y scroll values for each playfield
SCROLLA_Y = $FF1F10
SCROLLB_Y = $FF1F12
; $FF1F14

; Global game state
GLOBAL_STATE = $FF2000
NUM_PLAYERS = $FF2000   ; 2B: 1 or 2 players
UPDATE_MAX = $FF2002    ; 2B: frames b/w physics updates
UPDATE_TIMER = $FF2004  ; 2B: number of frames since last update
JUNK_MAX = $FF2006      ; 2B: physics updates b/w new junk pieces
GAME_PAUSED = $FF2008

; Data for each player's game state including the board
PLAYER_1_DATA = $FF3000
BOARD_1 = $FF3000       ; $1E0 Bytes: 240 cells * 2B
GAME_STATE_1 = $FF31E0
NEW_ROWS_1 = $FF31E0    ; 2B: Rows of blocks to place next frame
SCORE_1 = $FF31E2       ; 4B: BCD 7-digit score
LIVES_1 = $FF31E6       ; 2B: Number of lifelines, BCD or bimary w/ limit of 9
CURSOR_1_X = $FF31E8    ; 2B: horizontal position of cursor
CURSOR_1_Y = $FF31EA    ; 2B: vertical position of cursor
JOY_H_TIMER_1 = $FF31EC ; 2B: frames until held L/R will take effect again
JOY_V_TIMER_1 = $FF31EE ; 2B: frames until held U/D will take effect again
COMBO_1 = $FF31F0       ; 2B: player's combo multiplier
CHECK_PROJ_1 = $FF31F2  ; 2B: should projectiles be checked? T/F

TO_CLEAR_1 = $FF3230    ; $30 Bytes: flags for blocks being cleared from the board
SCORE_BUFF_1 = $FF3260  ; $E0 Bytes: buffer for graphics that display player score
JUNK_TIMER_1 = $FF3340  ; 2B: physics updates before next junk drops
NEXT_JUNKID_1 = $FF3342 ; 2B: ID of next junk piece (only upper byte used)
JUNK_PAT_1 = $FF3344    ; 2B: index into JUNK_PIECES of next junk piece
NEXT_JUNK_X_1 = $FF3346 ; 2B: column number of left edge of next junk
JUNK_IDS_1 = $FF3348    ; 32B: bitfield that keeps track of which junk IDs are in use


PLAYER_2_DATA = $FF4000
BOARD_2 = $FF4000       ; $1E0 Bytes: 240 cells * 2B
GAME_STATE_2 = $FF41E0
NEW_ROWS_2 = $FF41E0    ; 2B: Rows of blocks to place next frame
SCORE_2 = $FF41E2       ; 4B: BCD 7-digit score
LIVES_2 = $FF41E6       ; 2B: Number of lifelines, BCD or bimary w/ limit of 9
CURSOR_2_X = $FF41E8    ; 2B: horizontal position of cursor
CURSOR_2_Y = $FF41EA    ; 2B: vertical position of cursor
JOY_H_TIMER_2 = $FF41EC ; 2B: frames until held L/R will take effect again
JOY_V_TIMER_2 = $FF41EE ; 2B: frames until held U/D will take effect again
COMBO_2 = $FF41F0       ; 2B: player's combo multiplier
CHECK_PROJ_2 = $FF41F2  ; 2B: should projectiles be checked? T/F

TO_CLEAR_2 = $FF4230    ; $30 Bytes: flags for blocks being cleared from the board
SCORE_BUFF_2 = $FF4260  ; $E0 Bytes: buffer for graphics that display player score
JUNK_TIMER_2 = $FF4340  ; 2B: physics updates before next junk drops
NEXT_JUNKID_2 = $FF4342 ; 2B: ID of next junk piece (only upper byte used)
JUNK_PAT_2 = $FF4344    ; 2B: index into JUNK_PIECES of next junk piece
NEXT_JUNK_X_2 = $FF4346 ; 2B: column number of left edge of next junk
JUNK_IDS_2 = $FF4348    ; 32B: bitfield that keeps track of which junk IDs are in use

; Data for each particle:
; - X and Y velocity (2 words)
; - X and Y acceleration (2 words)
; - if a projectile: data about color, direction, position
;   - otherwise: all zeroes
;   - 1 word
PART_DATA = $FF5000

SCRATCH = $FFFFF0       ; some space for when temporary RAM is needed
DMA_SCRATCH = $FFFFFC   ; DMA needs a long-word of RAM
