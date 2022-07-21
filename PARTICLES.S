
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
    BSET    #13, d7 ; set player 2 flag
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
;   a0-a2, d0-d2
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
    BTST.B  #PART_PLAYER_FLAG-8, 8(a1) ; check which player the particle belongs to
    BNE.B   @P2_X_CHECK
    ; player 1:
    CMPI.W  #P1_LEFT_BOUND, d2
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #P1_RIGHT_BOUND, d2
    BGT.B   @DELETE_PARTICLE
    BRA.B   @X_CHECK_DONE
@P2_X_CHECK:
    ; player 2:
    CMPI.W  #P2_LEFT_BOUND, d2
    BLT.B   @DELETE_PARTICLE
    CMPI.W  #P2_RIGHT_BOUND, d2
    BGT.B   @DELETE_PARTICLE
@X_CHECK_DONE:
    ;CMPI.W  #BOUNDS_LEFT, d2
    ;BLT.B   @DELETE_PARTICLE
    ;CMPI.W  #BOUNDS_RIGHT, d2
    ;BGT.B   @DELETE_PARTICLE
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
    BLT.B   @UPDATE_PARTICLES_LOOP

    RTS

; ========================================
; PROJ_COLLISION
; ----------------------------------------
; If a projectile is in contact with junk,
; begin its shattering animation.
; This subroutine also deletes projectiles
; that go out of a board's bounds.
; ----------------------------------------
; Parameters:
;   a0 - points to sprite data
;   a1 - points to particle data
;   d0 - old x/y position
; Thrashed:
;   d0-d4, d7
; ========================================
;PROJ_COLLISION:
    MOVEQ   #0, d7  ; if d7 is set to TRUE, delete the projectile afterwards

    BTST.B  #6, 8(a1)
    BNE.W   @V_PROJ_COLLISION

    ; horizontal projectile: d0 is the old x position,
    ;   9(a1) is the row number, need board's x offset

    MOVE.W  6(a0), d3   ; d3 := new x position
    MOVE.B  9(a1), d4   
    ANDI.W  #$001F, d4  ; d4 := row number

    ; determine which board the projectile is at
    ; CMPI.W  #1, (NUM_PLAYERS)
    BTST.B  #6, 8(a1)
    BEQ.B   @H_PLAYER_1
    
    ; two players: depending on old x, projectile
    ; belongs to P1 or P2
    ; CMPI.W  #P1_RIGHT_BOUND, d0
    ; BLT.B   @H_PLAYER_1
    
    ; projectile is in P2's board
    LEA.L   BOARD_2, a3
    ; subtract player 2 offset
    SUBI.W  #P2_LEFT_BOUND, d0
    SUBI.W  #P2_LEFT_BOUND, d3

    BRA.B   @H_CHECK_COLLISION

@H_PLAYER_1:
    ; projectile is in P1's board
    LEA.L   BOARD_1, a3
    ; subtract player 1 offset
    SUBI.W  #P1_LEFT_BOUND, d0
    SUBI.W  #P1_LEFT_BOUND, d3

@H_CHECK_COLLISION:
    ; convert in-board x coordinates to row numbers
    LSR.W   #3, d0
    LSR.W   #3, d3
    ; to always check left-to-right, ensure d0 is the smaller value
    CMP.W   d0, d3
    BGE.B   @H_X_SORTED
    EXG     d0, d3
@H_X_SORTED:
    ; clamp to bounds
    TST.W   d0
    BGE.B   @H_D0_VALID
    MOVEQ   #-1, d7
    MOVEQ   #0, d0
@H_D0_VALID:
    CMPI.W  #BOARD_WIDTH-1, d3
    BLE.B   @H_D3_VALID
    MOVEQ   #-1, d7
    MOVEQ   #BOARD_WIDTH-1, d3
@H_D3_VALID:

    MULU    #BOARD_WIDTH*2, d4
    ADD.W   d0, d4
    ADD.W   d0, d4
    ADDA.W  d4, a3  ; a3 -> block at (d0, d4)

    ; loop over each block b/w x = d0 to x = d3
    MOVE.W  d3, d2
    SUB.W   d0, d2  ; d2 := loop counter
@H_CHECK_LOOP:
    MOVE.W  (a3)+, d1   ; d1 := current block
    ; if it is not junk, don't shatter
    TST.B   d1
    BNE.B   @H_CHECK_STEP
    ; if already shattering, do not shatter again
    BTST    #SHATTER_FLAG, d1
    ;BNE.B   @H_CHECK_STEP
    ;; otherwise, shatter it
    ;JSR     SHATTER_JUNK

@H_CHECK_STEP:
    DBRA    d2, @H_CHECK_LOOP

    ; if d7 was set, we need to delete the particle
    TST.W   d7
    BEQ.W   @PROJ_COLLISION_RET

    ; delete the particle:
    ; - set the first word of the sprite data to zero
    ; - set the previous sprite's link data to the deleted sprite's link data
    MOVE.W  #0, (a0)
    MOVE.B  3(a0), -5(a0)

    BRA.B   @PROJ_COLLISION_RET

@V_PROJ_COLLISION:
    ; vertical projectile: d0 is the old y position,
    ;   9(a1) is the column number, need board's y offset

    MOVE.W  (a0), d4    ; d4 := new y position
    MOVE.B  9(a1), d3
    ANDI.W  #$001F, d3  ; d3 := column number

    LEA.L   BOARD_1, a3 ; assume player 1 until proven player 2

    ; determine which board the projectile is at
    ; CMPI.W  #1, (NUM_PLAYERS)
    BTST.B  #6, 8(a1)
    BEQ.B   @V_CHECK_COLLISION
    ; two players: depending on sprite x,
    ; projectile belongs to P1 or P2
    ; CMPI.W  #P1_RIGHT_BOUND, d0
    ; BLT.B   @V_CHECK_COLLISION
    ; projectile is in P2's board
    LEA.L   BOARD_2, a3

@V_CHECK_COLLISION:
    ; convert d0, d4 to row numbers
    SUBI.W  #$90, d0
    SUBI.W  #$90, d4
    LSR.W   #3, d0
    LSR.W   #3, d4
    ; to always check top-to-bottom, ensure d0 is the smaller value
    CMP.W   d0, d4
    BGE.B   @V_Y_SORTED
    EXG     d0, d4
@V_Y_SORTED:
    ; clamp to bounds
    TST.W   d0
    BGE.B   @V_D0_VALID
    MOVEQ   #-1, d7
    MOVEQ   #0, d0
@V_D0_VALID:
    CMPI.W  #BOARD_HEIGHT-1, d4
    BLE.B   @V_D4_VALID
    MOVEQ   #-1, d7
    MOVEQ   #BOARD_HEIGHT-1, d4
@V_D4_VALID:

    MOVE.W  d0, d1
    MULU    #BOARD_WIDTH*2, d1
    ADD.W   d3, d1
    ADD.W   d3, d1
    ADDA.W  d1, a3  ; a3 -> block at (d3, d0)

    MOVE.W  d4, d2
    SUB.W   d0, d2  ; d2 := loop counter
@V_CHECK_LOOP:
    MOVE.W  (a3), d1   ; d1 := current block
    ; if it is not junk, don't shatter
    TST.B   d1
    BNE.B   @V_CHECK_STEP
    ; if already shattering, do not shatter again
    BTST    #SHATTER_FLAG, d1
    ;BNE.B   @V_CHECK_STEP
    ;; otherwise, shatter it
    ;JSR     SHATTER_JUNK

@V_CHECK_STEP:
    ADDA.W  #BOARD_WIDTH*2, a3
    DBRA    d2, @V_CHECK_LOOP

    ; if d7 was set, we need to delete the particle
    TST.W   d7
    BEQ.B   @PROJ_COLLISION_RET

    ; delete the particle:
    ; - set the first word of the sprite data to zero
    ; - set the previous sprite's link data to the deleted sprite's link data
    MOVE.W  #0, (a0)
    MOVE.B  3(a0), -5(a0)

@PROJ_COLLISION_RET:
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
