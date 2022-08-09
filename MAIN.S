
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

    ; palette 1: first blocks palette
    LEA.L   BLOCK_PALETTE_1, a0
    MOVEQ   #1, d0
    JSR     LOAD_PALETTE

    ; palettes 2: second blocks palette
    LEA.L   BLOCK_PALETTE_2, a0
    MOVEQ   #2, d0
    JSR     LOAD_PALETTE

    ; palette 3: background
    LEA.L   CIRCUIT_PAL, a0
    MOVEQ   #3, d0
    JSR     LOAD_PALETTE

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
    ; WAIT_VB
    LEA.L   VBLANKON, a0
@MAIN_VB_WAIT:
    TST.W   (a0)
    BEQ.B   @MAIN_VB_WAIT
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
    INCLUDE DATA/STRING.S
    INCLUDE DATA/JUNK_PIECES.S
