
; *****************************************************************
; REF_CIRCUIT.S
; Reference for the circuit background characters used in the game.
; This file is not included in the ROM, only with the source code.
; The characters in this file appear in the ROM in compressed form,
; in CHARS_CIRCUIT.S
;
; Copyright (C) 2022 Aidan Garvey - see MAIN.S for license details.
; *****************************************************************

CIRCUIT_PAL:
    DC.W    $0444 ; 0: medium gray
    DC.W    $0222 ; 1: dark gray
    DC.W    $0666 ; 2: light gray
    DC.W    $0000 ; 3

    DC.W    $04A4 ; 4: dark wire
    DC.W    $04C4 ; 5: light wire
    DC.W    $04A4 ; 6: dark wire
    DC.W    $04C4 ; 7: light wire
    
    DC.W    $0000 ; 8
    DC.W    $0000 ; 9
    DC.W    $0000 ; A
    DC.W    $0000 ; B
    
    DC.W    $0000 ; C
    DC.W    $0000 ; D
    DC.W    $0000 ; E
    DC.W    $0000 ; F

CIRCUIT_CHARS:
    ; 0: horizontal wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $44444444
    DC.L    $55555555

    DC.L    $44444444
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 1: vertical wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    
    ; 2: tl corner wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00044444
    DC.L    $00455555

    DC.L    $00454444
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    
    ; 3: tr corner wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $44440000
    DC.L    $55554000

    DC.L    $44454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    
    ; 4: bl corner wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454444
    DC.L    $00455555

    DC.L    $00044444
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    ; 5: br corner wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $44454000
    DC.L    $55554000

    DC.L    $44440000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    ; 6: h. t-junction wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $44454444
    DC.L    $55555555

    DC.L    $44444444
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    ; 7: v. t-junction wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454444
    DC.L    $00455555

    DC.L    $00454444
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000


    ; 8: horizontal plate
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    DC.L    $22222222
    DC.L    $00000000
    DC.L    $01000000
    DC.L    $00000000

    ; 9: vertical plate
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00021000

    DC.L    $00021000
    DC.L    $00021000
    DC.L    $01021000
    DC.L    $00021000

    ; A: corner plate
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    DC.L    $22210000
    DC.L    $00021000
    DC.L    $01021000
    DC.L    $00021000

    ; B: h. plate with wire
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000

    DC.L    $22222222
    DC.L    $00000000
    DC.L    $01000000
    DC.L    $00000000

    ; C: v. plate with wire
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00024444
    DC.L    $00025555

    DC.L    $00024444
    DC.L    $00021000
    DC.L    $01021000
    DC.L    $00021000

    ; D: left h. plate with chip
    DC.L    $00001111
    DC.L    $00001111
    DC.L    $00001111
    DC.L    $00001111
    
    DC.L    $22221111
    DC.L    $00001111
    DC.L    $01001111
    DC.L    $00001111

    ; E: right h. plate with chip
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000

    DC.L    $11112222
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000

    ; F: v. plate with chip
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00021000

    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111


    ; 10: chip centre
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111

    ; 11: chip corner
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    
    DC.L    $11100000
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000

    ; 12: h. chip edge
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111

    ; 13: v. chip edge
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000
    
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000

    ; 14: h. chip edge with wire
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000
    DC.L    $00454000

    ; 15: v. chip edge with wire
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11114444
    DC.L    $11115555

    DC.L    $11114444
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000

    ; 16: P2 horizontal wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $66666666
    DC.L    $77777777

    DC.L    $66666666
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 17: P2 vertical wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    ; 18: P2 tl corner wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00066666
    DC.L    $00677777

    DC.L    $00676666
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    ; 19: P2 tr corner wire
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $66660000
    DC.L    $77776000

    DC.L    $66676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    ; 1A: P2 bl corner wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676666
    DC.L    $00677777

    DC.L    $00066666
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 1B: P2 br corner wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $66676000
    DC.L    $77776000

    DC.L    $66660000
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 1C: P2 h. t-junction wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $66676666
    DC.L    $77777777

    DC.L    $66666666
    DC.L    $00000000
    DC.L    $00000000
    DC.L    $00000000

    ; 1D: P2 v. t-junction wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676666
    DC.L    $00677777

    DC.L    $00676666
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    ; 1E: P2 h. plate with wire
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    DC.L    $22222222
    DC.L    $00000000
    DC.L    $01000000
    DC.L    $00000000

    ; 1F: P2 v. plate with wire
    DC.L    $00021000
    DC.L    $00021000
    DC.L    $00026666
    DC.L    $00027777

    DC.L    $00026666
    DC.L    $00021000
    DC.L    $01021000
    DC.L    $00021000

    ; 20: P2 h. chip edge with wire
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    DC.L    $11111111
    
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000
    DC.L    $00676000

    ; 21: P2 v. chip edge with wire
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11116666
    DC.L    $11117777

    DC.L    $11116666
    DC.L    $11110000
    DC.L    $11110000
    DC.L    $11110000
