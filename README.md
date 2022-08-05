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

## Building

Two batch files are included to build the game with different assemblers. They output pure binary files which can be run with any Sega Genesis emulator.

* [BUILD_SN.bat](BUILD_SN.BAT) will build the game with S.N. Systems SN 68k assembler, also known as ASM68k. It is intended to be used with the ASM68k executable in the same directory as the source code.
* [BUILD_VASM.bat](BUILD_VASM.BAT) will build the game with the Motorola syntax module for [VASM](http://sun.hasenbraten.de/vasm/). It is intended to be used with the VASM executable in the same directory as the source code.
* If you build the binary with a different assembler, ensure the output is a pure binary file. Then, you should be able to run it with the emulator of your choice.

## Project State

The mechanics described in How to Play are implemented, and the game may be played with one or two players. A difficulty from 1-5 is selected to determine the game's speed, but the difficulty will need to be tested and balanced.

## Roadmap

* Playtest the game, use feedback to balance the difficulty and tweak the rules
* Add polish to the game's graphics and menus
* Music and sound effects
* A menu system for all menus in the game, which could be reused for other games 
* A particle system that controls all non-UI sprites, which could be reused for other games
* Run the game on real hardware!
