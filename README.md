# Beams

Puzzle game for the Sega Genesis (name pending)  
Play with 1 or 2 players!

## How to Play

Beams is a puzzle game along the lines of Tetris, Columns, Dr. Mario, etc.
Use the cursor to swap blocks horizontally or vertically. Match 3 blocks of the same color to remove them from the board, and shoot a glider in the direction of the match!
Large junk pieces periodically fall from the top of the board. Hit them with a glider to shatter them into more blocks that you can match up!
Gliders are the same color as the blocks that you matched. Some junk has a color, and you must hit it with a glider of the same color to shatter it.
If your board starts to get too crowded, use a bomb to destroy a group of blocks near your cursor!
The game is over when there is no room for the next junk piece to be placed!

### Controls

* D-Pad: move cursor
* A: swap horizontally
* B: swap vertically
* C: use a bomb
* Start: pause

## Running

Download [beams.bin](beams.bin) and run it in a Sega Genesis emulator to play!

## Building

### With ASM68K or VASMM68K_MOT
Two batch files are included to build the game with these assemblers. They output pure binary files which can be run with any Sega Genesis emulator.
If you use one of the assemblers which a batch file is included for, but don't use the batch file itself, please refer to the batch files for the flags needed to correctly assemble the game.
If you have a choice between either one, VASM seems to optimize better than ASM68k.

* [BUILD_SN.bat](BUILD_SN.BAT) will build the game with S.N. Systems SN 68k assembler, also known as ASM68k. It is intended to be used with the ASM68k executable in the same directory as the source code.
* [BUILD_VASM.bat](BUILD_VASM.BAT) will build the game with the Motorola syntax module for [VASM](http://sun.hasenbraten.de/vasm/). It is intended to be used with the VASMM68k_MOT executable in the same directory as the source code.

### With a Different Assembler
If you use an assembler not mentioned above, refer to the table below for the assembler options required to assemble the game, and the equivalents in the assemblers used above. Optimization options are not included -- you should be able to turn all of your assembler's optimizations on.

| Importance | Option | Setting | ASM68k | VASMM68k_MOT |
|:---:|:---:|:---:|:---:|:---:|
| **Required** | Pure Binary Output | Enabled | /p | -Fbin |
| **Required** | Architecture | 68000 | (default) | -m68000 |
| **Required** | Local Label Character | Underscore | /ol_ | -localu |
| **Required** | Word-align DC.W and DC.L | Disabled | /oae- | (default) |
| *May be Required in the Future* | Allow Whitespace in Assembler Operands | Enabled | /ows+ | -spaces |


## Project State

The mechanics described in How to Play are implemented and the game may be played with one or two players. A difficulty from 1-5 is selected to determine the game's speed, but the difficulty will need to be tested and balanced. Some sound effects and music have been implemented as a proof-of-concept, but more must be added for the game to feel complete.

## Roadmap

* \[ \] Playtest the game, use feedback to balance the difficulty and tweak the rules
* \[ \] Add polish to the game's graphics and menus
* \[ \] Music and sound effects
    * \[1/2\] At least two pieces of music that play during gameplay
    * \[ \] A title theme
    * \[1/10\] Sound effects for swapping and destroying blocks, for gliders, for destroying junk pieces, for bombs, for game over, for earning extra bombs, for selecting menu options, for pausing and unpausing
* \[X\] A menu system for all menus in the game, which could be reused for other games 
* \[X\] A particle system that controls all non-UI sprites, which could be reused for other games
* \[ \] Run the game on real hardware!
