
; *****************************************************************
; PARTICLES.S
; Subroutines for creating and updating particle sprites.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Projectile particle data format:
; X, Y velocity (4 bytes)
; X, Y acceleration (4 bytes)
; Extra data (2 bytes)
;   1DU- -CCC ---P PPPP
;   * First bit always set
;   D = direction, vertical = 0, horizontal = 1
;   U = player, 0 = P1, 1 = P2
;   C = color
;   P = row or column number, depending on D

; ==================================
; INIT_PARTICLES
; ----------------------------------
; Load particle characters into VRAM
; ----------------------------------
; Thrashed:
;   a0-a1, d0-d2
; ==================================
INIT_PARTICLES:
    MOVE.L  #PROJECTILE_CHARS, d0
    MOVE.W  #VRAM_PROJ_SIZE/2, d1
    MOVE.W  #VRAM_PROJ_GFX, d2
    JSR     DMADump
    MOVE.L  #DEBRIS_CHARS, d0
    MOVE.W  #VRAM_DEBRIS_SIZE/2, d1
    MOVE.W  #VRAM_DEBRIS_GFX, d2
    JSR     DMADump
    RTS

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
    PUSH    a0/d1-d7

    ; ************************
    ; spawn upwards projectile
    ; ************************

    ; save column number for extra data
    MOVE.W  d3, d7

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
    ADDI.W  #P1_BOARD_COL_OFFSET, d3
    ; if a2 points to player 2's game state, add additional distance
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_ADD_V
    ADDI.W  #(P2_BOARD_COL_OFFSET-P1_BOARD_COL_OFFSET), d3
@SKIP_P2_ADD_V:
    ; multiply by 8 to get pixel position
    LSL.W   #3, d3
    ; add left screen bound
    ADDI.W  #$80, d3

    ; d4 := y position
    ; add number of cells b/w top edge and board
    ADDQ.W  #BOARD_ROW_OFFSET, d4
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

    ; d7 := extra data described at top of file
    ; column number was already saved
    ; ANDI.W  #$001F, d7
    ; we know that the block data is not junk, its lower byte is set to 0
    OR.W    d0, d7  ; color for blocks in same place as color for projectiles
    ANDI.W  #$071F, d7 ; isolate color and column number
    BSET    #15, d7 ; MSB is always 1 for projectiles
    BCLR    #14, d7 ; set direction bit to 0, for vertical
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_FLAG_V
    BSET    #13, d7
@SKIP_P2_FLAG_V:

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
    ; d7 does not change
    JSR     ADD_PARTICLE

    POP     a0/d1-d7
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
    PUSH    a0/d1-d7

    ; ****************************
    ; spawn right-facing projectile
    ; ****************************

    ; save row number for extra data
    MOVE.W  d4, d7

    ; d1 := 2nd sprite attribute word (no link data)
    MOVE.W  #$0000, d1  ; 1x1 size

    ; d2 := 3rd sprite attribute word
    ; first color bit is the color palette,
    ; last two are multiplied for character index
    MOVE.W  d0, d2
    ANDI.W  #$0300, d2
    LSR.W   #8, d2      ; d2 := color[1:0]
    ADDI.W  #PROJ_CHAR+4, d2
    BTST    #10, d0
    BNE.B   @SHP_PAL2
    BSET    #13, d2     ; palette 1
    BRA.B   @SHP_D2_DONE
@SHP_PAL2:
    BSET    #14, d2     ; palette 2
@SHP_D2_DONE:

    ; d3 := x position
    ; add number of cells b/w left edge and P1 board
    ADDI.W  #P1_BOARD_COL_OFFSET, d3
    ; if a2 points to player 2's game state, add additional distance
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_ADD_H
    ADDI.W  #(P2_BOARD_COL_OFFSET-P1_BOARD_COL_OFFSET), d3
@SKIP_P2_ADD_H:
    ; multiply by 8 to get pixel position
    LSL.W   #3, d3
    ; add left screen bound
    ADDI.W  #$80, d3

    ; d4 := y position
    ; add number of cells b/w top edge and board
    ADDQ.W  #BOARD_ROW_OFFSET, d4
    ; multiply by 8 to get pixel position
    LSL.W   #3, d4
    ; add upper screen bound
    ADDI.W  #$80, d4

    ; d5 := x, y velocity
    MOVE.L  #PROJ_X_VEL, d5
    SWAP    d5
    ; d6 := x, y acceleration
    MOVE.L  #PROJ_X_ACCEL, d6
    SWAP    d6

    ; d7 := extra data described at top of file
    ; row number was already saved
    ; ANDI.W  #$001F, d7
    ; we know that the block data is not junk, so its lower byte is set to 0
    OR.W    d0, d7  ; color for blocks in same place as color for projectiles
    ANDI.W  #$071F, d7 ; isolate color and row number
    BSET    #15, d7 ; MSB is always 1 for projectiles
    BSET    #14, d7 ; set direction bit to 1, for horizontal
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_FLAG_H
    BSET    #PART_PLAYER_FLAG, d7 ; set player 2 flag
@SKIP_P2_FLAG_H:
    JSR     ADD_PARTICLE

    ; *****************************
    ; spawn left-facing projectile
    ; *****************************

    ; d1 unchanged
    ; d2 gets h flipped
    ORI.W   #$0800, d2
    ; d3 and d4 unchanged
    ; d5 and d6 use opposite x direction
    SWAP    d5
    NEG.W   d5
    SWAP    d5
    SWAP    d6
    NEG.W   d6
    SWAP    d6
    ; d7 does not change

    JSR     ADD_PARTICLE

    POP     a0/d1-d7
    RTS

; ==================================
; SPAWN_DEBRIS
; ----------------------------------
; Spawn a debris particle at a block
; ----------------------------------
; Parameters:
;   a2 - player game state
;   d0 - block data
;   d3 - column number
;   d4 - row number
; Thrashed:
;   none
; ==================================
SPAWN_DEBRIS:
    PUSH    a0/d1-d7

    ; we will use random data for velocity,
    ; generate it now to preserve registers
    PUSH    d0
    JSR     RAND
    MOVE.L  d0, d5
    POP     d0

    ; d2 := 3rd sprite attribute word
    ; first color bit is the color palette,
    ; last two are multiplied for character index
    MOVE.W  d0, d2
    ANDI.W  #$0300, d2
    LSR.W   #8, d2      ; d2 := color[1:0]
    ADDI.W  #DEBRIS_CHAR, d2
    ; use the random data from RAND to randomly flip the debris
    ANDI.W  #$1800, d1  ; 1x1 size
    OR.W    d1, d2
    BTST    #10, d0
    BNE.B   @SD_PAL2
    BSET    #13, d2     ; palette 1
    BRA.B   @SD_D2_DONE
@SD_PAL2:
    BSET    #14, d2     ; palette 2
@SD_D2_DONE:

    ; d1 := 2nd sprite attribute word
    MOVE.W  #0, d1      ; 1x1 size

    ; d3 := x position
    ; add number of cells b/w left edge and P1 board
    ADDI.W  #P1_BOARD_COL_OFFSET, d3
    ; if a2 points to player 2's game state, add additional distance
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_ADD_D
    ADDI.W  #(P2_BOARD_COL_OFFSET-P1_BOARD_COL_OFFSET), d3
@SKIP_P2_ADD_D:
    ; multiply by 8 to get pixel position
    LSL.W   #3, d3
    ; add left screen bound
    ADDI.W  #$80, d3

    ; d4 := y position
    ; add number of cells b/w top edge and board
    ADDQ.W  #BOARD_ROW_OFFSET, d4
    LSL.W   #3, d4
    ADDI.W  #$80, d4

    ; d5 := x, y velocity
    ; d5 already contains random data, limit x and y velocity
    ANDI.L  #DEBRIS_VEL_MASK, d5
    SWAP    d5
    ; x velocity will be in range [-$10, +$F]
    SUBI.W  #$10, d5
    SWAP    d5
    ; y velocity will be in range [-$1F, 0]
    SUBI.W  #$1F, d5

    ; d6 := x, y acceleration
    MOVEQ   #GRAVITY, d6

    ; d7 := extra particle data - for debris, just player number
    MOVEQ   #0, d7
    CMPA.L  #GAME_STATE_2, a2
    BNE.B   @SKIP_P2_FLAG_D
    BSET    #PART_PLAYER_FLAG, d7
@SKIP_P2_FLAG_D:
    JSR     ADD_PARTICLE

    POP     a0/d1-d7
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
;   d7 - additional particle data
; Thrashed: none
; ===============================================
ADD_PARTICLE:
    PUSH    a0-a1/d0

    ; find first empty spot in sprite table
    LEA.L   PART_SPRITES, a0
    LEA.L   PART_DATA, a1
    ; d0 tracks the link data for the sprite we place
    MOVEQ   #(PART_SPRITES-BUFF_SPRITES)/8, d0

@ADD_PARTICLE_LOOP:
    TST.W   (a0)
    BEQ.B   @PLACE_PARTICLE
    ; iterate until empty slot found
    ADDQ.W  #1, d0
    ADDA.W  #PART_SPRITE_SIZE, a0
    ADDA.W  #PART_DATA_SIZE, a1
    ; don't go past end of sprite table
    CMPA.L  #SPRITES_END, a0
    BLT.B   @ADD_PARTICLE_LOOP
    BRA.B   @ADD_PARTICLE_RET
@PLACE_PARTICLE:
    ; sprite attributes
    MOVE.W  d4, (a0)+
    MOVE.W  d1, (a0)+
    MOVE.W  d2, (a0)+
    MOVE.W  d3, (a0)+
    ; particle velocity & acceleration
    MOVE.L  d5, (a1)+
    MOVE.L  d6, (a1)+
    ; extra particle data
    MOVE.W  d7, (a1)+

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
;   a0-a2, d0-d3
; ============================================
UPDATE_PARTICLES:
    LEA.L   PART_SPRITES, a0
    LEA.L   PART_DATA, a1
    ; a2 points to the most recent non-deleted sprite
    LEA.L   PART_SPRITES-8, a2

    ; for each particle:
    ; - add acceleration to velocity
    ; - add velocity/16 to position
    ; - if position is out-of-bounds, delete the particle

@UPDATE_PARTICLES_LOOP:
    TST.W   (a0)
    BEQ.B   @UPDATE_PARTICLES_STEP

    ; update x and y velocity
    MOVE.L  (a1), d1    ; d1 := x, y velocity
    MOVE.L  4(a1), d2   ; d2 := x, y accel
    ADD.W   d2, d1
    SWAP    d1
    SWAP    d2
    ADD.W   d2, d1
    SWAP    d1
    MOVE.L  d1, (a1)    ; save new velocity

    ; update and check y position, delete if off screen
    ; ASR.W   #4, d1
    MOVE.W  (a0), d2
    ROL.W   #4, d2
    ADD.W   d1, d2
    ROR.W   #4, d2
    MOVE.W  d2, d3
    ANDI.W  #$0FFF, d3
    CMPI.W  #BOUNDS_TOP, d3
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #BOUNDS_BOTTOM, d3
    BGT.B   @DELETE_PARTICLE
    MOVE.W  d2, (a0)

    ; update and check x position
    SWAP    d1
    ; ASR.W   #4, d1
    MOVE.W  6(a0), d2
    ROL.W   #4, d2
    ADD.W   d1, d2
    ROR.W   #4, d2
    MOVE.W  d2, d3
    ANDI.W  #$0FFF, d3
    BTST.B  #PART_PLAYER_FLAG-8, 8(a1) ; check which player the particle belongs to
    BNE.B   @P2_X_CHECK
    ; player 1:
    CMPI.W  #P1_LEFT_BOUND, d3
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #P1_RIGHT_BOUND, d3
    BGT.B   @DELETE_PARTICLE
    BRA.B   @X_CHECK_DONE
@P2_X_CHECK:
    ; player 2:
    CMPI.W  #P2_LEFT_BOUND, d3
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #P2_RIGHT_BOUND, d3
    BGT.B   @DELETE_PARTICLE
@X_CHECK_DONE:
    MOVE.W  d2, 6(a0)
    
    ; if we didn't delete this sprite, a2 will track it
    MOVE.L  a0, a2
    
    BRA.B   @UPDATE_PARTICLES_STEP

@DELETE_PARTICLE:
    ; to delete a particle:
    ; - set the first word of the sprite data to zero
    ; - set the previous sprite's link data to the deleted sprite's link data
    MOVE.W  #0, (a0)
    MOVE.B  3(a0), 3(a2)

@UPDATE_PARTICLES_STEP:
    ADDA.W  #PART_SPRITE_SIZE, a0
    ADDA.W  #PART_DATA_SIZE, a1
    ; if we aren't out of bounds, iterate again
    CMPA.L  #SPRITES_END, a0
    BLT.W   @UPDATE_PARTICLES_LOOP

    RTS

; ==========================================
; SHATTER_JUNK
; ------------------------------------------
; Given a pointer to a junk block, begin its
; shatter animation, as well as the other
; blocks of the junk piece.
; TODO: shatter whole piece, free junk's ID
; in JUNK_IDS
; ------------------------------------------
; Parameters:
;   a3 - pointer to block
; Thrashed:
;   none
; ==========================================
;SHATTER_JUNK:
    BSET.B  #SHATTER_FLAG-8, (a3)
    MOVE.B  #1, 1(a3)
    RTS
