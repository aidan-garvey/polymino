# Beams

Puzzle game for the Sega Genesis (name pending)  
Play with 1 or 2 players!

## How to Play

Beams is a puzzle game along the lines of Tetris, Columns, Dr. Mario, etc.
Use a cursor to swap blocks horizontally or vertically. Match 3 blocks of the same color to remove them from the board, and shoot a wave in the direction of the match!
Large junk pieces periodically fall from the top of the board. Hit them with a wave to shatter them into more blocks that you can match up!
Waves are the same color as the blocks that you matched. Some junk has a color, and you must hit it with a wave of the same color to shatter it.
If your board starts to get too crowded, use a bomb to destroy a group of blocks near your cursor!
The game is over when there is no room for the next junk piece to be placed!

### Controls

* D-Pad: move cursor
* A: swap horizontally
* B: swap vertically
* C: use a bomb
* Start: pause

## Running

Download and open [beams.bin](beams.bin) in a Sega Genesis emulator to play!  
This binary has been tested with the emulators Gens KMod (and should therefore work with stock Gens) and Exodus (which emulates the Genesis down to the clock cycle, but is overkill unless you are debugging a game).

## Building

Two batch files are included to build the game with different assemblers. They output pure binary files which can be run with any Sega Genesis emulator.

* [BUILD_SN.bat](BUILD_SN.BAT) will build the game with S.N. Systems SN 68k assembler, also known as ASM68k. It is intended to be used with the ASM68k executable in the same directory as the source code.
* [BUILD_VASM.bat](BUILD_VASM.BAT) will build the game with the Motorola syntax module for [VASM](http://sun.hasenbraten.de/vasm/). It is intended to be used with the VASM executable in the same directory as the source code.
* If you build the binary with a different assembler, ensure the output is a pure binary file. Then, you should be able to run it with the emulator of your choice.

## Project State and Goals

Currently, not all of the features in the How To Play section are implemented.
Ultimately, the goals of this project are:

* Complete all of the features described in How To Play
* Music and sound effects
* A menu system for all menus in the game, which could be reused for other games 
* A particle system that controls all non-UI sprites, which could be reused for other games
* Run the game on real hardware!
