# PC Workout Tool (PCWO) v2

Author: Homero Trevino <homerotl@gmail.com>

## Description
The purpose of this tool is to be able to test features available in vintage 
x86 computers running MS-DOS. The "workout" part comes from the idea that hardware 
parts, like floppy drives can break down more quickly if not used frequently. 

With this program, you can flex some of your computer's capabilities to ensure 
they are still in working order.

As a side benefit, I have always been curious about Assembly language, and 
this project is my pretext to learn it.

## Available Tests

 * CPU Information
 * PC Speaker buzzer test
 * Screen geometry test


## Usage
The program is portable. No installation is needed. Just copy the `PCWO2.EXE` 
file and run it from the command line. Follow the instructions.

## Binary
Use the following [link](http://homerotl.com/downloads/pcwo2/pcwo2_build001.zip) to download the 
latest public build of this program. 

## Compiling PCWO2
Currently, I am using Borland's Turbo Assembler (TASM) Version 4.0. Once 
TASM is installed and configured on your path, simply download the source code
to your local dirive, open a command line, go to the directory where the source
code is and type `make`. This should generate the executable
file `PCWO2.EXE`

## Future Test ideas

  * 3.5" 2.88MB disk test
  * 3.5" LS-120 disk test
  * Screen color test (calibration in general)
  * Add more graphic modes to test
  * Graphics card detection (CGA/EGA/VGA)
  * AdLib Sound card test
  * SoundBlaster (16) Sound card test
  * MIDI (General) test
  * Gravis Sound card test
  * Keyboard test
  * Mouse test
  * CPU speed test (benchmark)
  * Math Co-processor detection and speed test (benchmark)
  * CD-ROM / DVD-ROM detection and test
  * ZIP Drive test
 
## Other feature ideas

  * Play a tune on the PC Speaker
  * Auto-increment release numbers
  * Graphical interface
  * Interactive menu vs. sequence
  * Run with a pre-programmed sequence (no prompts)
  * Better error handling
  * Able to cancel or pause a test
  * Be able to detect if you are in a real machine or DOSBox

## Recommended reading
  * PC Interrupts, Ralf Brown & Jim Kyle, Addison Wesley
  * Peter Norton's Assembly Language Book for the IBM PC, Peter Norton and John Socha, Brady New York