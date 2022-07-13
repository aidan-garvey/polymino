
; For this game, each plane should only need to be big enough to
; cover the screen, scrolling won't be necessary. So, each plane
; is 64 x 32 cells = 2048 cells = $1000 bytes
VRAM_BLOCK_GFX = $0000
VRAM_UI_GFX = $1000
VRAM_BCKGND_GFX = $2000
VRAM_SPRITE_GFX = $3000
VRAM_SPRITETBL = $B800
VRAM_HSCROLL = $BC00
VRAM_WINDOW = $C000
VRAM_SCROLLA = $C000
VRAM_SCROLLB = $E000

VRAM_SPRITETBL_SIZE = $400
VRAM_HSCROLL_SIZE = $400
VRAM_SCROLLA_SIZE = $1000
VRAM_SCROLLB_SIZE = $1000

SPRITE_GFX_CHAR = VRAM_SPRITE_GFX/32

BOARD_HEIGHT = 24 ; in cells
BOARD_WIDTH = 10 ; in cells
BOARD_SIZE = 480 ; size of board in bytes

BOARD1_OFFSET = 274
BOARD2_OFFSET = BOARD1_OFFSET+24
BOARD_ROW_OFFSET = 108

HOLD_LENGTH = 6 ; held buttons are handled every HOLD_LENGTH frames
SCROLL_DIV = 2  ; divisor for background scroll amount per frame

; game state offsets
NEW_ROWS_OFF = 0
SCORE_OFF = 2
LIVES_OFF = 6
CURSOR_X_OFF = 8
CURSOR_Y_OFF = 10
JOY_H_TIMER_OFF = 12
JOY_V_TIMER_OFF = 14
UPDATED_OFF = 32
; UP_RESET_OFF = 80
TO_CLEAR_OFF = 80
; TC_RESET_OFF = 130
