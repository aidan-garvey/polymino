
; *********************************************************************
;         Beams: A 1-2 player puzzle game for the Sega Genesis
;                   Copyright (C) 2022 Aidan Garvey
; *********************************************************************
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.
; *********************************************************************

    ORG $0000

; ****************************************
; Include files which don't take up memory
; ****************************************
    INCLUDE CONST/RAM_MAP.S
    INCLUDE CONST/CONST_ADDR.S
    INCLUDE CONST/CONST_GAME.S
    INCLUDE CONST/CONST_HW.S
    INCLUDE CONST/CHAR_INDEX.S
    INCLUDE CONST/SPRITE_INDEX.S
    INCLUDE MACROS.S

; **************************************
; Cartridge header, general-purpose code
; **************************************
    INCLUDE HEADER.S
    INCLUDE INTERRUPT.S
    INCLUDE STARTUP.S
    INCLUDE SUB_GENERAL.S
    INCLUDE DMA.S
    INCLUDE INPUT.S
    INCLUDE RANDOM.S 
    INCLUDE DRAW_STRING.S

; *****************
; Echo sound engine
; *****************
    INCLUDE AUDIO/ECHO-68K.S

; =============================
; MAIN_INIT
; -----------------------------
; Subroutine to set up the game
; before the main loop is run
; =============================
MAIN_INIT:
    ; palette 0: UI palette
    LEA.L   UI_PALETTE, a0
    MOVEQ   #0, d0
    JSR     LOAD_PALETTE

    ; palettes 1-3: initialized when needed

    JSR     DUMP_PALETTES

    ; prepare to show intro screen
    MOVE.L  #INTRO_INIT, (MAIN_VECTOR)

    RTS

; ===============================================
; MAIN_LOOP
; -----------------------------------------------
; Executed once per frame. Reads joypad input and
; calls whichever subroutine is in MAIN_VECTOR.
; ===============================================
MAIN_LOOP:
    ; only execute once per frame
    LEA.L   VBLANKON, a0
_MAIN_VB_WAIT:
    TST.W   (a0)
    BEQ.B   _MAIN_VB_WAIT
    CLR.W   (a0)
    ADDQ.W  #1, (MAIN_TICK)
    JSR     READ_INPUT
    MOVE.L  (MAIN_VECTOR), a0
    JSR     (a0)
    BRA.B   MAIN_LOOP

; ***********
; SUBROUTINES
; ***********
    INCLUDE MENUS.S
    INCLUDE INIT_GRAPHICS.S
    INCLUDE INIT_CIRCUIT.S
    INCLUDE BOARD.S 
    INCLUDE MATCH.S
    INCLUDE DRAW.S 
    INCLUDE PARTICLES.S
    INCLUDE SCORE.S
    INCLUDE SUB_JUNK.S
    INCLUDE GAME_OVER.S
    INCLUDE INTRO.S
    INCLUDE GAME.S
    INCLUDE PAUSE.S

; ******
; ASSETS
; ******
    INCLUDE DATA/DATA_SETUP.S
    INCLUDE DATA/GFX_UI.S 
    INCLUDE DATA/GFX_BLOCK.S 
    INCLUDE DATA/GFX_BCKGRND.S
    INCLUDE DATA/CHARS_CIRCUIT.S
    INCLUDE DATA/PAT_CIRCUIT.S
    INCLUDE DATA/GFX_TEXT.S
    INCLUDE DATA/GFX_JUNK.S
    INCLUDE DATA/GFX_PARTICLE.S
    INCLUDE DATA/GFX_OUTLINE.S
    INCLUDE DATA/GFX_LETTERS.S
    INCLUDE DATA/GFX_COMBO.S

    ; binary data for title screen
TITLE_MAP_1:
    INCBIN  TITLE/map_1.bin
TITLE_PAL_1:
    INCBIN  TITLE/pal_1.bin
TITLE_TILES_1:
    INCBIN  TITLE/tiles_1.bin
TITLE_MAP_2:
    INCBIN  TITLE/map_2.bin
TITLE_PAL_2:
    INCBIN  TITLE/pal_2.bin
TITLE_TILES_2:
    INCBIN  TITLE/tiles_2.bin
TITLE_MAP_3:
    INCBIN  TITLE/map_3.bin
TITLE_PAL_3:
    INCBIN  TITLE/pal_3.bin
TITLE_TILES_3:
    INCBIN  TITLE/tiles_3.bin
TITLE_DATA_END:

    ; stuff that doesn't need to be word-aligned
    INCLUDE AUDIO/INSTRMNT.S
    INCLUDE AUDIO/ESF/SFX_ESF.S
    INCLUDE DATA/JUNK_PIECES.S
    INCLUDE DATA/STRING.S

    ; ensure BGM data is aligned to 2^15 byte boundary so it fits in one Z80 RAM bank
_BGM_PC_1 EQU (*)%($8000) ; PC mod $8000
    IF _BGM_PC_1
        DS.B    $8000-_BGM_PC_1 ; fill space with zeroes until we get to next boundary
    ENDIF
    INCLUDE AUDIO/ESF/BGM_1_ESF.S

_BGM_PC_2 EQU (*)%($8000) ; PC mod $8000
    IF _BGM_PC_2
        DS.B    $8000-_BGM_PC_2 ; fill space with zeroes until we get to next boundary
    ENDIF
    INCLUDE AUDIO/ESF/BGM_2_ESF.S
