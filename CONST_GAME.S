
; For this game, each plane should only need to be big enough to
; cover the screen, scrolling won't be necessary. So, each plane
; is 64 x 32 cells = 2048 cells = $1000 bytes
VRAM_BLOCK_GFX = $0000
VRAM_SPRITE_GFX = $4000
VRAM_SPRITETBL = $A800
VRAM_HSCROLL = $AC00
VRAM_WINDOW  = $B000
VRAM_SCROLLA = $E000 ; SCROLL A only appears if A and B are at the same address????
VRAM_SCROLLB = $E000

VRAM_SPRITETBL_SIZE = $400
VRAM_HSCROLL_SIZE = $400
VRAM_WINDOW_SIZE  = $1000
VRAM_SCROLLA_SIZE = $1000
VRAM_SCROLLB_SIZE = $1000

SPRITE_GFX_CHAR = VRAM_SPRITE_GFX/32

BOARD_HEIGHT = 24 ; in cells
BOARD_WIDTH = 10 ; in cells
BOARD_SIZE = 480 ; size of board in bytes

BOARD1_OFFSET = 274
BOARD2_OFFSET = BOARD1_OFFSET+24
BOARD_ROW_OFFSET = 108
