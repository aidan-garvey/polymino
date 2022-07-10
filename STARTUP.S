
STARTUP_RUN:
    MOVE.W  #$2700, SR  ; disable interrupts
    MOVE.W  #1, (HOT_START)
    TST.L   ($A10008)
    BNE.B   @HotStart
    TST.W   ($A1000C)
    BNE.B   @HotStart
    CLR.W   (HOT_START)
    ; U.S. security
    MOVE.B  (HW_VERSION), d0
    ANDI.B  #$F, d0
    BEQ.B   @SecuritySkip
    MOVE.L  #"SEGA", ($A14000)
@SecuritySkip:
    
    ; when we write to VDP, we want addresses to increment by 2
    VDP_REG 15, %00000010

    JSR     CLEAR_CRAM

    ; *******************
    ; ** Clear 68k RAM **
    ; *******************
    LEA.L   RAM_BASE, a0        ; Begin clearing at start of work ram
    MOVE.W  #(RAM_SIZE/4)-1, d0 ; size of work ram in longwords minus 1
@Clear68kRAMLoop:
    MOVE.L  d1, (a0)+           ; set a LW of RAM to 0
    DBRA    d0, @Clear68kRAMLoop
    
@HotStart:
    LEA.L   STACK_END, SP   ; initialize stack pointer

    ; ********************
    ; ** Initialize Z80 **
    ; ********************
    MOVE.W  #$100, d0       ; value for controlling Z80
    LEA.L   Z80_BUSREQ, a0  ; location to remove z80 from bus
    LEA.L   Z80_RESET, a1   ; location to reset z80
    
    MOVE.W  d0, (a0)    ; request bus
    MOVE.W  d0, (a1)    ; ensure it is not resetting
    
@InitZ80Wait:
    BTST    #0, (a0)    ; check if z80 is off bus
    BNE.S   @InitZ80Wait ; if not, wait until it is
    
    ; ** TODO: SEND CODE TO Z80 **
    
    CLR.W   (a1)        ; reset Z80
    CLR.W   (a0)        ; cancel bus request
    MOVE.W  d0, (a1)    ; cancel reset request
    
    ; ***************
    ; ** Flush DMA **
    ; ***************
    MOVE.W  #$2300, SR  ; allow DMA
    WAIT_DMA            ; bug occurs here after soft reset in Exodus
    MOVE.W  #$2700, SR  ; stop DMA
    
    MOVE.L  #VBDUMMY, VBVECTOR  ; while setting up system, don't need to do anything during VBI
    
    ; ******************************
    ; ** Initialize VDP Registers **
    ; ******************************
    VDP_REG 00, %00000100   ; DISABLE H-INT, ENABLE "READ, H, V COUNTER"
    VDP_REG 01, %00000100   ; DISABLE DISPLAY, DISABLE V-INT, DISABLE DMA, V28 CELLS (NTSC)
    VDP_REG 02, (VRAM_SCROLLA>>10)  ; SCROLL A PATTERN TABLE
    VDP_REG 03, (VRAM_WINDOW>>10)   ; WINDOW PATTERN TABLE
    VDP_REG 04, (VRAM_SCROLLB>>13)  ; SCROLL B PATTERN TABLE
    VDP_REG 05, (VRAM_SPRITETBL>>9) ; SPRITE ATTRIBUTE TABLE
    VDP_REG 06, %00000000   ; UNUSED
    VDP_REG 07, %00000000   ; BACKGROUND: PALETTE 0, COLOUR 0
    VDP_REG 08, %00000000   ; UNUSED
    VDP_REG 09, %00000000   ; UNUSED
    VDP_REG 10, %11111111   ; H-INT TIMING: 255 LINES
    VDP_REG 11, %00000000   ; DISABLE EXT-INT, FULL VSCROLL, FULL HSCROLL
    VDP_REG 12, %10000001   ; H40 CELLS, DISABLE SHADOW/HILIGHT, NO INTERLACE
    VDP_REG 13, (VRAM_HSCROLL>>10)  ; HSCROLL DATA TABLE: $BC00
    VDP_REG 14, %00000000   ; UNUSED
    VDP_REG 15, %00000010   ; ADDRESSES INCREMENTED BY 2 AFTER RAM ACCESS
    VDP_REG 16, %00000001   ; SCROLL SIZE: V32*H64
    VDP_REG 17, %00010100   ; WINDOW: WHOLE HORIZONTAL SCREEN
    VDP_REG 18, %00011100   ; WINDOW: WHOLE VERTICAL SCREEN
    
    ; **********************
    ; ** Clear VDP Memory **
    ; **********************
    JSR CLEAR_CRAM
    JSR CLEAR_VSRAM
    JSR CLEAR_VRAM
    
    MOVE.W  #$2000, SR      ; Enable all interrupts
    VDP_REG 1, %01100100    ; ENABLE DISPLAY & V-INT, DISABLE DMA, V28 CELLS
    
    ; ***********************
    ; ** Prevent Reset Bug **
    ; ***********************
    TST.W   (HOT_START)
    BEQ.B   @SkipPreventResetBug

    MOVE.W  #49, d0
@PreventResetBugLoop:
    WAIT_VB
    DBRA    d0, @PreventResetBugLoop

@SkipPreventResetBug:

    ; ************************
    ; ** Initialize Joypads **
    ; ************************

;   ** SETUP S-CTRL 1, 2, EXP **
    ; Baud rate: 4800bps (max)
    ; TR: Parallel mode
    ; TL: Parallel mode
    ; Rxd ready interrupt off
    ; !RxdError
    ; !RxdReady
    ; !TxdFull
    MOVE.B  #$00, JOY1_SCTRL
    MOVE.B  #$00, JOY2_SCTRL
    MOVE.B  #$00, JOYX_SCTRL
    
;   ** SETUP CTRL 1, 2, EXP **
    ; TH-Interrupt off
    ; PD6: Input
    ; PD5..0: Output
    MOVE.B  #$40, JOY1_CTRL
    MOVE.B  #$40, JOY2_CTRL
    MOVE.B  #$40, JOYX_CTRL
    
; ** SETUP DATA 1, 2, EXP **
    ; TH = 1
    ; TR = 0
    ; TL = 0
    ; R,L,D,U = 0
    MOVE.B  #$40, JOY1_DATA
    MOVE.B  #$40, JOY2_DATA
    MOVE.B  #$40, JOYX_DATA
    
    ; ************************************************
    ; ** Initialize VDP Register Codes in DMA Queue **
    ; ************************************************
    ; Copy register codes 20, 19 to LEN, LEN + 2
    MOVE.L  #$94009300, CURR_DMA_LEN
    ; Copy register codes 23, 22, 21 to SOURCE +0, +2, +4
    MOVE.L  #$97009600, CURR_DMA_SRC
    MOVE.W  #$9500, CURR_DMA_SRC+4

    ; *****************************
    ; ** Initialize Sprite Table **
    ; *****************************
    LEA.L   VDP_DATA, a1
    ; Write to VRAM at location of sprite attribute table
    VDP_ACCESS  VDP_W_VRAM, VRAM_SPRITETBL

    ; Copy placeholder sprite to table so spritelist terminates
    MOVE.W  #1, (a1)
    MOVE.W  #0, (a1)
    MOVE.W  #0, (a1)
    MOVE.W  #1, (a1)

    ; do game-specific initialization (in MAIN.S)
    JSR     MAIN_INIT

    ; **************************
    ; ** Start Main Game Loop **
    ; **************************
    MOVE.L  #VBMAIN, VBVECTOR
    JMP     MAIN_LOOP