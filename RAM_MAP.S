; *******************
; ***** RAM MAP *****
; -------------------
;  Allocation of RAM
; ($FF0000 - $FFFFFF)
; *******************

; as defined in HW_CONST:
; RAM_BASE = $FF0000
; RAM_SIZE = $10000

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
; non-persistent sprites:
VAR_SPRITES = $FF0790   ; Variable-length list of sprites

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
JUNK_TIMER = $FF2008    ; 2B: number of updates since last junk

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
; 16B of free space
UPDATED_1 = $FF3200     ; $30 Bytes: updated flags for each block, 2B per row
TO_CLEAR_1 = $FF3230    ; $30 Bytes: flags for blocks being cleared from the board
SCORE_BUFF_1 = $FF3260  ; $E0 Bytes: buffer for graphics that display player score

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
; 16B free space
UPDATED_2 = $FF4200     ; $30 Bytes: updated flags for each block, 2B per row
TO_CLEAR_2 = $FF4230    ; $30 Bytes: flags for blocks being cleared from the board
SCORE_BUFF_2 = $FF4260  ; $E0 Bytes: buffer for graphics that display player score

SCRATCH = $FFFFF0       ; some space for when temporary RAM is needed, like DMA
