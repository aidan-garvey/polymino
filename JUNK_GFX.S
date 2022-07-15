
; gray junk uses the UI palette, the others use the blocks palette

JUNK_DARK EQU 6
JUNK_LIGHT EQU 7

JUNK_CHARS:
    ; 6: dark gray
    ; 7: light gray

    ; corner
    DC.L    $06666666
    DC.L    $66667776
    DC.L    $66777777
    DC.L    $67767777

    DC.L    $66777777
    DC.L    $67777777
    DC.L    $67777767
    DC.L    $66777777

    ; top/bottom edge
    DC.L    $66666666
    DC.L    $67776676
    DC.L    $77777777
    DC.L    $77777767

    DC.L    $76777777
    DC.L    $77777777
    DC.L    $77777677
    DC.L    $77777777

    ; left/right edge
    DC.L    $67777777
    DC.L    $67777777
    DC.L    $67776777
    DC.L    $66777777

    DC.L    $66777767
    DC.L    $67777777
    DC.L    $67767777
    DC.L    $66777777

    ; middle block
    DC.L    $77777777
    DC.L    $77777767
    DC.L    $76777777
    DC.L    $77777777

    DC.L    $77777777
    DC.L    $77777677
    DC.L    $77677777
    DC.L    $77777777

JUNK_PATTERNS:
    

