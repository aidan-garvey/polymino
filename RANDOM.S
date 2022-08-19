
; *****************************************************************
; RANDOM.S
; Pseudo-random number generator, must be seeded before use.
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

; Seed the random number generator
; Thrashes d0-d2
RAND_SEED:
    MOVE.L  #$9876FEDC, d0
    MOVE.L  #$ABCD1234, d1
    MOVE.W  (FRAME_TICK), d2
    ROL.W   d2, d2
_RSEED_LOOP:
    SWAP    d0
    ADD.L   d1, d0
    ADD.L   d0, d1
    DBRA    d2, _RSEED_LOOP
    MOVEM.L d0-d1, (RAND_STATE)
    RTS

; Generate a new random number and store the state in RAM.
; Also returns the state in d0-d1.
RAND:
    MOVEM.L (RAND_STATE), d0-d1
    SWAP    d0
    ADD.L   d1, d0
    ADD.L   d0, d1
    MOVEM.L d0-d1, (RAND_STATE)
    RTS
