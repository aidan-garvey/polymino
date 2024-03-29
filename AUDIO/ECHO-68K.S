; *********************************************************************
; ECHO-68K.S
; Modified copy of ECHO.68K from https://github.com/sikthehedgehog/Echo
; Modified to include ECHO-Z80.BIN, which is also from the above repo,
; and replace the '@' symbol with '_' for local labels.
; See AUDIO/ECHO_LICENSE for the license of the original Echo software.
; *********************************************************************

;****************************************************************************
; Echo_Z80Request
; Requests the Z80 bus
;****************************************************************************

Echo_Z80Request macro
    move.w  #$100, ($A11100)        ; Request Z80 bus
_Echo_WaitZ80\@:
    btst.b  #0, ($A11100)           ; Did we get it yet?
    bne.s   _Echo_WaitZ80\@         ; Keep waiting
    endm                            ; End of macro

;****************************************************************************
; Echo_Z80Release
; Releases the Z80 bus
;****************************************************************************

Echo_Z80Release macro
    move.w  #$000, ($A11100)        ; Release Z80 bus
    endm                            ; End of macro

;****************************************************************************
; Echo_Z80Reset
; Resets the Z80 and YM2612
;****************************************************************************

Echo_Z80Reset macro
    move.w  #$000, ($A11200)        ; Assert reset line
    rept    $10                     ; Wait until hardware resets
    nop                               ; ...
    endr                              ; ...
    move.w  #$100, ($A11200)        ; Release reset line
    endm                            ; End of macro

;****************************************************************************
; Echo_SendCommand
; Sends an Echo command (no address parameter)
;
; input d0.b ... Echo command
;****************************************************************************

Echo_SendCommand:
    movem.l d1/a1, -(sp)            ; Save registers
_Try:
    Echo_Z80Request                 ; We need the Z80 bus

    lea     ($A01FFF), a1           ; First try the 1st slot
    tst.b   (a1)                    ; Is 1st slot available?
    beq.s   _Ready                    ; If so, move on
    subq.l  #4, a1                  ; Try 2nd slot otherwise

    tst.b   (a1)                    ; Check if 2nd slot is ready
    beq.s   _Ready                  ; Too busy?
    Echo_Z80Release                   ; Let Echo continue
    move.w  #$1FF, d1                 ; Give it some time
    dbf     d1, *                       ; ...
    bra.s   _Try                      ; Try again

_Ready:
    move.b  d0, (a1)                ; Write command ID
    Echo_Z80Release                 ; We're done with the Z80 bus

    movem.l (sp)+, d1/a1            ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo_SendCommandAddr
; Sends an Echo command (with address parameter)
;
; input d0.b ... Echo command
; input a0.l ... Address parameter
;****************************************************************************

Echo_SendCommandAddr:
Echo_SendCommandEx:
    movem.l d0-d1/a1, -(sp)         ; Save registers
_Try:
    Echo_Z80Request                 ; We need the Z80 bus

    lea     ($A01FFF), a1           ; First try the 1st slot
    tst.b   (a1)                    ; Is 1st slot available?
    beq.s   _Ready                    ; If so, move on
    subq.l  #4, a1                  ; Try 2nd slot otherwise

    tst.b   (a1)                    ; Check if 2nd slot is ready
    beq.s   _Ready                  ; Too busy?
    Echo_Z80Release                   ; Let Echo continue
    move.w  #$1FF, d1                 ; Give it some time
    dbf     d1, *                       ; ...
    bra.s   _Try                      ; Try again

_Ready:
    move.b  d0, (a1)                ; Write command ID

    move.l  a0, d0                  ; Easier to manipulate here
    move.b  d0, -2(a1)              ; Store low address byte
    lsr.l   #7, d0                  ; Get high address byte
    lsr.b   #1, d0                    ; We skip one bit
    bset.l  #7, d0                    ; Point into bank window
    move.b  d0, -1(a1)              ; Store high address byte

    lsr.w   #8, d0                  ; Get bank byte
    move.w  d0, d1                    ; Parse 32X bit separately
    lsr.w   #1, d1                    ; Put 32X bit in place
    and.b   #$7F, d0                  ; Filter out unused bit from addresses
    and.b   #$80, d1                  ; Filter out all but 32X bit
    or.b    d1, d0                    ; Put everything together
    move.b  d0, -3(a1)              ; Store bank byte

    Echo_Z80Release                 ; We're done with the Z80 bus

    movem.l (sp)+, d0-d1/a1         ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo_SendCommandByte
; Sends an Echo command (with a byte parameter)
;
; input d0.b ... Echo command
; input d1.b ... Byte parameter
;****************************************************************************

Echo_SendCommandByte:
    movem.l d1-d2/a1, -(sp)         ; Save registers

_Try:
    Echo_Z80Request                 ; We need the Z80 bus

    lea     ($A01FFF), a1           ; First try the 1st slot
    tst.b   (a1)                    ; Is 1st slot available?
    beq.s   _Ready                    ; If so, move on
    subq.l  #4, a1                  ; Try 2nd slot otherwise

    tst.b   (a1)                    ; Check if 2nd slot is ready
    beq.s   _Ready                  ; Too busy?
    Echo_Z80Release                   ; Let Echo continue
    move.w  #$1FF, d2                 ; Give it some time
    dbf     d2, *                       ; ...
    bra.s   _Try                      ; Try again

_Ready:
    move.b  d0, (a1)                ; Write command ID
    move.b  d1, -3(a1)              ; Write parameter
    Echo_Z80Release                 ; We're done with the Z80 bus

    movem.l (sp)+, d1-d2/a1         ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo_PlaySFX
; Plays a SFX
;
; input a0.l ... Pointer to SFX data
;****************************************************************************

Echo_PlaySFX:
    move.w  d0, -(sp)               ; Save register
    move.b  #$02, d0                ; Command $02 = play SFX
    bsr     Echo_SendCommandAddr    ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    
    rts                             ; End of subroutine

;****************************************************************************
; Echo_StopSFX
; Stops SFX playback
;****************************************************************************

Echo_StopSFX:
    move.w  d0, -(sp)               ; Save register
    move.b  #$03, d0                ; Command $03 = stop SFX
    bsr     Echo_SendCommand        ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    
    rts                             ; End of subroutine

;****************************************************************************
; Echo_PlayBGM
; Plays a BGM
;
; input a0.l ... Pointer to BGM data
;****************************************************************************

Echo_PlayBGM:
    move.w  d0, -(sp)               ; Save register
    move.b  #$04, d0                ; Command $04 = play BGM
    bsr     Echo_SendCommandAddr    ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    
    rts                             ; End of subroutine

;****************************************************************************
; Echo_StopBGM
; Stops BGM playback
;****************************************************************************

Echo_StopBGM:
    move.w  d0, -(sp)               ; Save register
    move.b  #$05, d0                ; Command $05 = stop BGM
    bsr     Echo_SendCommand        ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    
    rts                             ; End of subroutine

;****************************************************************************
; Echo_PauseBGM
; Pauses BGM playback
;****************************************************************************

Echo_PauseBGM:
    move.w  d0, -(sp)               ; Save register
    move.b  #$08, d0                ; Command $08 = pause BGM
    bsr     Echo_SendCommand        ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    rts                             ; End of subroutine

;****************************************************************************
; Echo_ResumeBGM
; Resumes BGM playback
;****************************************************************************

Echo_ResumeBGM:
    move.w  d0, -(sp)               ; Save register
    move.b  #$06, d0                ; Command $06 = resume BGM
    bsr     Echo_SendCommand        ; Send command to Echo
    move.w  (sp)+, d0               ; Restore register
    rts                             ; End of subroutine

;****************************************************************************
; Echo_PlayDirect
; Injects events into the BGM stream for the next tick.
;
; input a0.l ... Pointer to stream data
;****************************************************************************

Echo_PlayDirect:
    Echo_Z80Request                 ; We need the Z80 bus
    movem.l d0-d1/a0-a2, -(sp)      ; Save registers

_Check:
    moveq   #0, d0                  ; Retrieve direct stream length
    move.b  ($A01F80), d0
    bpl.s   _StreamOk               ; Is it valid?
_Wait:
    Echo_Z80Release                 ; If not, let the Z80 run until it's
    move.w  #$1FF, d0                 ; done processing the direct stream
    dbf     d0, *                     ; ...
    Echo_Z80Request                 ; Take over Z80 bus again
    bra.s   _Check                  ; Retry

_StreamOk:
    lea     ($A01F00), a1           ; Get pointer to last event in the
    lea     (a1,d0.w), a1           ; direct stream

    lea     _ArgTable(pc), a2       ; Copy stream into the direct buffer
_LoadLoop:
    move.b  (a0)+, d0                 ; Get byte from source stream...
    move.b  d0, (a1)+                 ; ...and store it into direct stream
    cmp.b   #$FF, d0                  ; Was it the STOP event?
    beq.s   _LoadEnd                    ; If so, we're done
    moveq   #0, d0                    ; Check how many argument bytes it has
    move.b  (a2,d0.w), d0
    subq.w  #1, d0                      ; Adjust for DBF
    bmi.s   _LoadLoop                   ; No arguments?
_LoadArgLoop:
    move.b  (a0)+, (a1)+              ; Copy the arguments
    dbf     d0, _LoadArgLoop
    bra.s   _LoadLoop                 ; Keep copying
_LoadEnd:

    move.w  a1, d0                  ; Update stream length
    subq.b  #1, d0
    move.b  d0, ($A01F80)

    movem.l (sp)+, d0-d1/a0-a2      ; Restore registers
    Echo_Z80Release                 ; We're done with the Z80 bus
    rts                             ; End of subroutine

;----------------------------------------------------------------------------
; Look-up table used to know how many bytes each event has as argument
;----------------------------------------------------------------------------

_ArgTable:
    dc.b    1,1,1,0, 1,1,1,0, 1,1,1,1, 1,0,0,0      ; $00-$0F (key on)
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $10-$1F (key off)
    dc.b    1,1,1,0, 1,1,1,0, 1,1,1,1, 0,0,0,0      ; $20-$2F (set volume)
    dc.b    2,2,2,0, 2,2,2,0, 2,2,2,1, 0,0,0,0      ; $30-$3F (set frequency)
    dc.b    1,1,1,0, 1,1,1,0, 1,1,1,1, 0,0,0,0      ; $40-$4F (set instrument)
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $50-$5F
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $60-$6F
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $70-$7F
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $80-$8F
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $90-$9F
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $A0-$AF
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $B0-$BF
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $C0-$CF
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $D0-$DF (quick delay)
    dc.b    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0      ; $E0-$EF (lock channel)
    dc.b    1,1,1,0, 1,1,1,0, 2,2,1,1, 0,0,1,0      ; $F0-$FF (miscellaneous)

;****************************************************************************
; Echo_SetPCMRate
; Sets the playback rate of PCM
;
; input d0.b ... New rate (timer A value)
;****************************************************************************

Echo_SetPCMRate:
    movem.l d0-d1, -(sp)            ; Save registers
    move.b  d0, d1                  ; Put parameter in place
    move.b  #$07, d0                ; Command $07 = set PCM rate
    bsr     Echo_SendCommandByte    ; Send command to Echo
    movem.l (sp)+, d0-d1            ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo_SetStereo
; Sets whether stereo is enabled or not
;
; input d0.b ... 0 to disable, otherwise to enable
;****************************************************************************

Echo_SetStereo:
    movem.l d0-d1, -(sp)            ; Save registers
    tst.b   d0                      ; Check what we want to do
    seq.b   d1                      ; Put parameter in place
    move.b  #$09, d0                ; Command $09 = set stereo
    bsr     Echo_SendCommandByte    ; Send command to Echo
    movem.l (sp)+, d0-d1            ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo_SetVolume
; Changes the global volume for every channel.
;
; input d0.b ... New volume (0 = quietest, 255 = loudest)
;****************************************************************************

Echo_SetVolume:
    Echo_Z80Request                 ; We need the Z80 bus
    movem.l d0-d1/a0-a1, -(sp)      ; Save registers
    
    lea     Echo_FMVolTable(pc), a0 ; Determine FM volume
    moveq   #0, d1
    move.b  d0, d1
    lsr.b   #2, d1
    move.b  (a0,d1.w), d1
    
    lea     ($A01FE0), a1           ; Copy new FM volume values
    move.b  d1, (a1)+                 ; FM channel 0
    move.b  d1, (a1)+                 ; FM channel 1
    move.b  d1, (a1)+                 ; FM channel 2
    move.b  d1, (a1)+                 ; FM channel 3
    move.b  d1, (a1)+                 ; FM channel 4
    move.b  d1, (a1)+                 ; FM channel 5
    move.b  d1, (a1)+                 ; FM channel 6
    move.b  d1, (a1)+                 ; FM channel 7
    
    lea     Echo_PSGVolTable(pc),a0 ; Determine PSG volume
    moveq   #0, d1
    move.b  d0, d1
    lsr.b   #2, d1
    move.b  (a0,d1.w), d1
    
                                    ; Copy new PSG values
    move.b  d1, (a1)+                 ; PSG channel 0
    move.b  d1, (a1)+                 ; PSG channel 1
    move.b  d1, (a1)+                 ; PSG channel 2
    move.b  d1, (a1)+                 ; PSG channel 3
    
    cmp.b   #$40, d0                ; Determine whether PCM should be enabled
    shs     d1                        ; (we do an heuristic for enabling PCM
    and.b   #1, d1                    ; based on the volume value)
    move.b  d1, (a1)+
    
    move.b  #1, ($A01FF1)           ; Tell Echo to update the volume levels
    
    movem.l (sp)+, d0-d1/a0-a1      ; Restore registers
    Echo_Z80Release                 ; We're done with the Z80 bus
    rts                             ; End of subroutine

;----------------------------------------------------------------------------

Echo_FMVolTable:
    dc.b    $7F,$7B,$77,$73,$70,$6C,$68,$65,$61,$5E,$5A,$57,$54,$50,$4D,$4A
    dc.b    $47,$44,$41,$3F,$3C,$39,$36,$34,$31,$2F,$2D,$2A,$28,$26,$24,$22
    dc.b    $20,$1E,$1C,$1A,$18,$16,$15,$13,$12,$10,$0F,$0D,$0C,$0B,$0A,$09
    dc.b    $08,$07,$06,$05,$04,$04,$03,$02,$02,$01,$01,$01,$00,$00,$00,$00

Echo_PSGVolTable:
    dc.b    $0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0B,$0B,$0A,$0A,$0A,$09,$09
    dc.b    $08,$08,$08,$07,$07,$07,$06,$06,$06,$06,$05,$05,$05,$04,$04,$04
    dc.b    $04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01
    dc.b    $01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;****************************************************************************
; Echo_SetVolumeEx
; Changes the global volume for each individual channel.
;
; input a0.l ... Pointer to 16 bytes
;                  8 bytes with FM volumes (0..127)
;                  4 bytes with PSG volumes (0..15)
;                  1 byte with PCM toggle (0/1)
;                  3 reserved (unused for now)
;****************************************************************************

Echo_SetVolumeEx:
    Echo_Z80Request                 ; We need the Z80 bus
    movem.l a0-a1, -(sp)            ; Save registers
    
    lea     ($A01FE0), a1           ; Copy new volume values
    move.b  (a0)+, (a1)+              ; FM channel 0
    move.b  (a0)+, (a1)+              ; FM channel 1
    move.b  (a0)+, (a1)+              ; FM channel 2
    move.b  (a0)+, (a1)+              ; FM channel 3
    move.b  (a0)+, (a1)+              ; FM channel 4
    move.b  (a0)+, (a1)+              ; FM channel 5
    move.b  (a0)+, (a1)+              ; FM channel 6
    move.b  (a0)+, (a1)+              ; FM channel 7
    move.b  (a0)+, (a1)+              ; PSG channel 0
    move.b  (a0)+, (a1)+              ; PSG channel 1
    move.b  (a0)+, (a1)+              ; PSG channel 2
    move.b  (a0)+, (a1)+              ; PSG channel 3
    move.b  (a0)+, (a1)+              ; PCM channel toggle
    move.b  (a0)+, (a1)+              ; (reserved)
    move.b  (a0)+, (a1)+              ; (reserved)
    move.b  (a0)+, (a1)+              ; (reserved)
    
    move.b  #1, ($A01FF1)           ; Tell Echo to update the volume levels
    
    movem.l (sp)+, a0-a1            ; Restore registers
    Echo_Z80Release                 ; We're done with the Z80 bus
    rts                             ; End of subroutine

;****************************************************************************
; Echo_GetStatus
; Gets the current status of Echo
;
; output d0.w ... Echo status
;                   Bit #0: SFX is playing
;                   Bit #1: BGM is playing
;                   Bit #14: direct events not played
;                   Bit #15: command still not parsed
;****************************************************************************

Echo_GetStatus:
    movem.l d1-d2/a1, -(sp)         ; Save registers

    clr.w   d0                      ; Set all needed bits to 0
    Echo_Z80Request                 ; We need the Z80 bus
    move.b  ($A01FF0), d0           ; Get the status flags

    tst.b   ($A01FFB)               ; Check if any commands can be sent
    beq.s   _NotBusy                ; Any room left for new commands?
    bset.l  #15, d0                 ; If not, set the relevant flag
_NotBusy:

    cmpi.b  #$FF, ($A01F00)         ; Check if the direct buffer is empty
    beq.s   _DirectEmpty            ; Any direct events still to be played?
    bset.l  #14, d0                 ; If so, set the relevant flag
_DirectEmpty:

    cmpi.b  #$C9, ($A00008)         ; Check if ch6 is in FM or PCM mode
    beq.s   _PcmOff                 ; PCM playback active? (i.e. not RET)
    bset.l  #13, d0                 ; If so, set the relevant flag
_PcmOff:

    moveq   #0, d1                  ; Clear unused bits from index
    lea     _AndTable(pc), a1       ; Get pointer to look-up tables
    
    move.b  ($A01FFF), d1           ; Get next pending command (if any)
    beq.s   _QueueChecked           ; No commands left to process?
    move.b  (a1,d1.w), d2           ; Get mask of flags to leave
    and.b   d2, d0                  ; Remove flags that should be clear
    move.b  _OrTable-_AndTable(a1,d1.w), d2 ; Get mask of flags to set
    or.b    d2, d0                  ; Insert flags that should be set

    move.b  ($A01FFB), d1           ; Repeat that with 2nd pending command
    beq.s   _QueueChecked
    move.b  (a1,d1.w), d2
    and.b   d2, d0
    move.b  _OrTable-_AndTable(a1,d1.w), d2
    or.b    d2, d0

_QueueChecked:
    Echo_Z80Release                 ; Let the Z80 go!
    movem.l (sp)+, d1-d2/a1         ; Restore registers
    rts                             ; End of subroutine

;----------------------------------------------------------------------------
; Look-up tables used to readjust the status flags based on pending commands
; that haven't been processed yet (normally they wouldn't be updated yet, but
; this can catch programmers off guard so we cheat it).
;
; Every byte represents a possible command.
;----------------------------------------------------------------------------

_AndTable:  dc.b $FF,$FF, $FF,$FE,$FF,$FD, $FF,$FF,$FF
_OrTable:   dc.b $00,$00, $01,$00,$02,$00, $00,$00,$00
            even

;****************************************************************************
; Echo_GetFlags
; Gets the current values of the flags.
;
; output d0.b ... Bitmask with flags
;****************************************************************************

Echo_GetFlags:
    Echo_Z80Request                 ; Request Z80 bus
    move.b  ($A01FF2), d0           ; Get the flags
    Echo_Z80Release                 ; Done with Z80 RAM
    rts                             ; End of subroutine

;****************************************************************************
; Echo_SetFlags
; Sets flags from the 68000.
;
; input d0.b ... Bitmask of flags to be set (1 = set, 0 = intact)
;****************************************************************************

Echo_SetFlags:
    subq.w  #4, sp                  ; Buffer for the events
    move.b  #$FA, (sp)                ; Set flags
    move.b  d0, 1(sp)                 ; <bitmask>
    move.b  #$FF, 2(sp)               ; End of stream
    
    move.l  a0, -(sp)               ; Issue the events
    lea     4(sp), a0
    bsr     Echo_PlayDirect
    move.l  (sp)+, a0
    
    addq.w  #4, sp                  ; Done with the buffer
    rts                             ; End of subroutine

;****************************************************************************
; Echo_ClearFlags
; Clear flags from the 68000.
;
; input d0.b ... Bitmask of flags to be cleared (1 = clear, 0 = intact)
;****************************************************************************

Echo_ClearFlags:
    not.b   d0                      ; Bitmask is inverted
    subq.w  #4, sp                  ; Buffer for the events
    move.b  #$FB, (sp)                ; Set flags
    move.b  d0, 1(sp)                 ; <bitmask>
    move.b  #$FF, 2(sp)               ; End of stream
    not.b   d0                      ; Restore register
    
    move.l  a0, -(sp)               ; Issue the events
    lea     4(sp), a0
    bsr     Echo_PlayDirect
    move.l  (sp)+, a0
    
    addq.w  #4, sp                  ; Done with the buffer
    rts                             ; End of subroutine

;****************************************************************************
; Echo_ListEntry
; Defines an entry in a pointer list
;****************************************************************************

Echo_ListEntry macro
    dc.b    $80|((\1)>>8&$7F)                 ; High byte of address
    dc.b    (\1)&$FF                          ; Low byte of address
    dc.b    ((\1)>>15&$7F)|((\1)>>16&$80)   ; Bank number
    endm

;****************************************************************************
; Echo_ListEnd
; Ends a pointer list
;****************************************************************************

Echo_ListEnd macro
    dc.b    $00                     ; End of list mark
    even                            ; Just in case...
    endm

;****************************************************************************
; Echo_Init
; Initializes Echo
;
; input a0.l ... Address of pointer list
;****************************************************************************

Echo_Init:
    movem.l d0/a0-a1, -(sp)         ; Save registers

    Echo_Z80Reset                   ; May not work without this...
    Echo_Z80Request                 ; We need the Z80 bus

    move.b  #$01, ($A01FFF)         ; Command: load pointer list
    move.b  #$00, ($A01FFB)         ; No other command yet

    move.l  a0, d0                  ; Easier to manipulate here
    move.b  d0, ($A01FFD)           ; Store low address byte
    lsr.l   #7, d0                  ; Get high address byte
    lsr.b   #1, d0                    ; We skip one bit
    bset.l  #7, d0                    ; Point into bank window
    move.b  d0, ($A01FFE)           ; Store high address byte
    lsr.w   #8, d0                  ; Get bank byte
    move.w  d0, d1                    ; Parse 32X bit separately
    lsr.w   #1, d1                    ; Put 32X bit in place
    and.b   #$7F, d0                  ; Filter out unused bit from addresses
    and.b   #$80, d1                  ; Filter out all but 32X bit
    or.b    d1, d0                    ; Put everything together
    move.b  d0, ($A01FFC)           ; Store bank byte

    lea     _Z80Program(pc), a0     ; Where Z80 program starts
    lea     ($A00000), a1           ; Where Z80 RAM starts
    move.w  #_Z80ProgSize-1, d0     ; Size of Z80 program (DBF adjusted)
_LoadLoop:                          ; Go through all the program
    move.b  (a0)+, (a1)+              ; Copy byte into Z80 RAM
    dbf     d0, _LoadLoop             ; Go for next byte

    moveq   #0, d0                  ; Set default global volumes
    lea     ($A01FE0), a0
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  #1, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, (a0)+
    move.b  d0, ($A01FF1)

    move.b  #$FF, ($A01F00)         ; No direct events to execute
    move.b  #$00, ($A01F80)

    Echo_Z80Reset                   ; Now reset for real
    Echo_Z80Release                 ; Let the Z80 go!

    movem.l (sp)+, d0/a0-a1         ; Restore registers
    rts                             ; End of subroutine

;****************************************************************************
; Echo Z80 program
;****************************************************************************

_Z80Program: incbin "AUDIO/ECHO-Z80.BIN"
_Z80ProgSize equ *-_Z80Program
    even
