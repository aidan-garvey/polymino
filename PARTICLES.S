
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
;   d0 - matched block data
;   d3 - column number
;   d4 - row number
; Thrashed:
;   none
; ===========================
SPAWN_V_PROJ:
    PUSH    a0/d1-d6

    ; ************************
    ; spawn upwards projectile
    ; ************************

    ; d1 := 2nd sprite attribute word (no link data)
    MOVE.W  #$0000, d1  ; 1x1 size

    ; d2 := 3rd sprite attribute word
    ; first color bit is the color palette,
    ; last two are multiplied for character index
    MOVE.W  d0, d2
    ANDI.W  #$0300, d2
    LSR.W   #8, d2      ; d2 := color[1:0]
    ADDI.W  #PROJ_CHAR, d2
    BTST    #10, d0
    BNE.B   @SVP_PAL2
    BSET    #13, d2     ; palette 1
    BRA.B   @SVP_D2_DONE
@SVP_PAL2:
    BSET    #14, d2     ; palette 2
@SVP_D2_DONE:

    ; d3 := x position
    ; add number of cells b/w left edge and P1 board
    ADDI.W  #P1_BOARD_X_OFFSET, d3
    ; if a2 points to player 2's game state, add additional distance
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_ADD
    ADDI.W  #(P2_BOARD_X_OFFSET-P1_BOARD_X_OFFSET), d3
@SKIP_P2_ADD:
    ; multiply by 8 to get pixel position
    LSL.W   #3, d3
    ; add left screen bound
    ADDI.W  #$80, d3

    ; d4 := y position
    ; add number of cells b/w top edge and board
    ADDQ.W  #BOARD_Y_OFFSET, d4
    ; multiply by 8 to get pixel position
    LSL.W   #3, d4
    ; add upper screen bound
    ADDI.W  #$80, d4

    ; d5 := x, y velocity
    MOVEQ   #0, d5
    MOVE.W  #-PROJ_Y_VEL, d5
    ; d6 := x, y acceleration
    MOVEQ   #0, d6
    MOVE.W  #-PROJ_Y_ACCEL, d6

    JSR     ADD_PARTICLE

    ; **************************
    ; spawn downwards projectile
    ; **************************

    ; d1 stays unchanged
    ; d2 requires a vertical flip
    ORI.W   #$1000, d2
    ; d3 and d4 stay unchanged
    ; d5 will use opposite y direction, x stays unchanged
    NEG.W   d5
    ; d6 will use opposite y direction, x stays unchanged
    NEG.W   d6
    JSR     ADD_PARTICLE

    POP     a0/d1-d6
    RTS

; =============================
; SPAWN_H_PROJ
; -----------------------------
; Spawn a horizontal projectile
; -----------------------------
; Parameters:
;   a2 - player game state
;   d0 - matched block data
;   d3 - column number
;   d4 - row number
; Thrashed:
;   none
; =============================
SPAWN_H_PROJ:
    PUSH    a0/d1-d1

    POP     a0/d1-d1
    RTS

; ===============================================
; ADD_PARTICLE
; -----------------------------------------------
; Add a particle to the game
; -----------------------------------------------
; Parameters:
;   d1 - 2nd sprite attribute word (no link data)
;   d2 - 3rd sprite attribute word
;   d3 - x coordinate (4th sprite attribute word)
;   d4 - y coordinate (1st sprite attribute word)
;   d5 - x and y velocity (1 word each)
;   d6 - x and y acceleration (1 word each)
; Thrashed: none
; ===============================================
ADD_PARTICLE:
    PUSH    a0-a1/d0

    ; find first empty spot in sprite table
    LEA.L   PART_SPRITES, a0
    LEA.L   PART_DATA, a1
    ; d0 tracks the link data for the sprite we place
    MOVEQ   #(PART_SPRITES-BUFF_SPRITES)/8, d0

    TST.W   (a0)
    BEQ.B   @PLACE_PARTICLE
    ; iterate until empty slot found
    ADDQ.W  #1, d0
    ADDA.W  #$8, a0
    ADDA.W  #$8, a1
    ; don't go past end of sprite table
    CMPA.L  #SPRITES_END, a0
    BGE.B   @ADD_PARTICLE_RET
@PLACE_PARTICLE:
    ; sprite attributes
    MOVE.W  d4, (a0)+
    MOVE.W  d1, (a0)+
    MOVE.W  d2, (a0)+
    MOVE.W  d3, (a0)+
    ; particle velocity & acceleration
    MOVE.L  d5, (a1)+
    MOVE.L  d6, (a1)+

    ; point new sprite's link data to same as previous sprite,
    ; point previous sprite's link data to new sprite
    MOVE.L  a0, a1
    MOVE.B  -13(a0), -5(a1)
    MOVE.B  d0, -13(a0)

@ADD_PARTICLE_RET:
    POP     a0-a1/d0
    RTS

; ============================================
; UPDATE_PARTICLES
; --------------------------------------------
; Update all particles' velocity and position,
; remove any out-of-bounds particles
; --------------------------------------------
; Thrashed:
;   a0-a2, d1-d2
; ============================================
UPDATE_PARTICLES:
    LEA.L   PART_SPRITES, a0
    LEA.L   PART_DATA, a1
    ; a2 points to the most recent non-deleted sprite
    LEA.L   PART_SPRITES-8, a2

    ; for each particle:
    ; - add acceleration to velocity
    ; - add velocity/16 to position
    ; - if position is off-screen, delete the particle

@UPDATE_PARTICLES_LOOP:
    TST.W   (a0)
    BEQ.B   @UPDATE_PARTICLES_STEP

    MOVE.L  (a1), d1    ; d1 := x, y velocity
    MOVE.L  4(a1), d2   ; d2 := x, y accel
    ADD.W   d2, d1
    SWAP    d1
    SWAP    d2
    ADD.W   d2, d1
    SWAP    d1
    MOVE.L  d1, (a1)    ; save new velocity
    
    ; update and check y position
    ASR.W   #4, d1
    MOVE.W  (a0), d2
    ADD.W   d1, d2
    CMPI.W  #BOUNDS_TOP, d2
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #BOUNDS_BOTTOM, d2
    BGT.B   @DELETE_PARTICLE
    MOVE.W  d2, (a0)
    ; update and check x position
    SWAP    d1
    ASR.W   #4, d1
    MOVE.W  6(a0), d2
    ADD.W   d1, d2
    CMPI.W  #BOUNDS_LEFT, d2
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #BOUNDS_RIGHT, d2
    BGT.B   @DELETE_PARTICLE
    MOVE.W  d2, 6(a0)

    ; if we didn't delete this sprite, a2 will track it
    MOVE.L  a0, a2

    BRA.B   @UPDATE_PARTICLES_STEP

@DELETE_PARTICLE:
    ; to delete a particle:
    ; - set the first word of the sprite data to zero
    ; - make the previous sprite's link data point to the deleted sprite's link data
    MOVE.W  #0, (a0)
    MOVE.B  3(a0), 3(a2)

@UPDATE_PARTICLES_STEP:
    ADDA.W  #8, a0
    ADDA.W  #8, a1
    ; if we aren't out of bounds, iterate again
    CMPA.L  #SPRITES_END, a0
    BLT.B   @UPDATE_PARTICLES_LOOP

    RTS
