
; *****************************************************************
; PARTICLES.S
; Subroutines for creating and updating particle sprites.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ==================================
; INIT_PARTICLES
; ----------------------------------
; Load particle characters into VRAM
; ----------------------------------
; Thrashed:
;   a0-a1, d0-d2
; ==================================
INIT_PARTICLES:
    LEA.L   BUFF_PLANE, a1
    LEA.L   PROJECTILE_CHARS, a0
    JSR     CopyCharRAM
    JSR     CopyCharRAM
    JSR     CopyCharRAM
    JSR     CopyCharRAM

    MOVE.L  #BUFF_PLANE, d0
    MOVE.W  #VRAM_PROJ_SIZE/2, d1
    MOVE.W  #VRAM_PROJ_GFX, d2
    JSR     DMADump

; ===========================
; SPAWN_V_PROJ
; ---------------------------
; Spawn a vertical projectile
; ---------------------------
; Parameters:
;   a2 - player game state
;   d3 - column number
;   d4 - row number
; Thrashed:
;   none
; ===========================
SPAWN_V_PROJ:
    PUSH    a0/d0-d1

    POP     a0/d0-d1
    RTS

; =============================
; SPAWN_H_PROJ
; -----------------------------
; Spawn a horizontal projectile
; -----------------------------
; Parameters:
;   a2 - player game state
;   d3 - column number
;   d4 - row number
; Thrashed:
;   none
; =============================
SPAWN_H_PROJ:
    PUSH    a0/d0-d1

    POP     a0/d0-d1
    RTS
