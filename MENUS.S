
; *****************************************************************
; MENUS.S
; Subroutines for the game's menu system.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; ===========================
; UPDATE_PAUSED
; ---------------------------
; Pause/unpause the game when
; player 1 presses start
; ---------------------------
; Thrashed:
; ===========================
UPDATE_PAUSED:
    MOVE.W  (JOY1), d0    ; current joypad inputs
    MOVE.W  (JOY1+4), d1   ; previous frame's inputs
    ; to get buttons pressed this frame but not held:
    ; XOR new inputs into old inputs, then AND result with new inputs
    EOR.W   d0, d1
    AND.W   d0, d1  ; d1 indicates buttons pressed for the first frame

    ; if start not pressed, return
    BTST    #7, d1
    BEQ     @UPDATE_PAUSED_RET
    BCHG    #0, (GAME_PAUSED) ; toggle game pause

@UPDATE_PAUSED_RET:
    RTS