================================================================================
 Scrolling Gradient Routines by imamelia, some modifications by ShadowFan-X
================================================================================
In this directory there should be the following files:

ScrollGradient.asm:
This is the main file. It contains the subroutines SyncColorGradientInitRt
and SyncColorGradientMainRt, which load and display a scrollable HDMA table,
respectively.
To use scrolling gradients with this file, you call the following subroutines:
 From LevelASM INIT:
	LDA #$xx
	JSR/JSL SyncColorGradientInitRt

 From LevelASM:
	JSR/JSL SyncColorGradientMainRt

ScrollGradientTables.asm:
This contains the gradient tables used by ScrollGradient.asm. You add the
scrollable "HDMA" table to this file, and then write its label below the
table SyncGradientPtrs. For example:
 dw ExampleTable

As for the scrollable "HDMA" table, you can generate that using GradientTool.

SpecifyScrollGradient.asm:
A variation of ScrollGradient.asm; this allows you to specify the address and
bank number of the "HDMA" table you want to load. This means that you can load
an "HDMA" table from a different bank.
The main difference from ScrollGradient.asm is the LevelASM INIT code:
 SEP     #$10                           ; Force 8-bit X
 REP     #$20                           ; Force 16-bit A
 LDA.w   #GradientTableName             ; Get address of gradient
 LDX.b   #GradientTableName>>16         ; Get bank # of gradient
 JSR/JSL SpecifySyncColorGradientInitRt

BothScrollGradient.asm:
A combination of ScrollGradient.asm and SpecifyScrollGradient.asm; contains
the subroutines SpecifySyncColorGradientInitRt, SyncColorGradientInitRt, and
SyncColorGradientMainRt.

-----------------------------
- About Scrolling Gradients -
-----------------------------
As you probably know, HDMA doesn't scroll with the background; in some cases,
this can be quite distracting.

Ersanio made a subroutine which shifts the gradient up and down with vertical
scrolling; however, the tables were so large only 12 would fit in a single LoROM
bank.

imamelia made a subroutine based on Ersanio's idea; however, it decompresses a
table and stores it in RAM, allowing many more gradients to be placed in a bank.
These scrolling gradient routines are modified versions of imamelia's code.

I added some code that corrects the vertical position of the gradient, so that
the top of the gradient will always coincide with the highest visible point of
BG2; this makes it compatible with Constant Scrolling mode. However, for it to
work, you need to use C0 as the BG starting position, assuming the player starts
on the lower subscreen and the FG starting position is C0. If the FG starting
position is not C0, you may need to fiddle around with the BG starting position
to get it in just the right place.

I also made a version which can load an arbitrary scrollable "HDMA" table rather
than loading one from an index.

------------------
- Gradient Sizes -
------------------
The actual height of the gradient in an emulator seems to depend on the gradient
itself. However, the following are *approximations* of how many scanlines should
be used to cover up the entire backdrop--the actual number of scanlines needed
will vary.

Scrolling Mode
 None:     ~130 scanlines (use a fixed 224-scanline HDMA gradient instead)
 Slow:     ~140 scanlines (consider using a fixed 224-scanline HDMA gradient)
 Variable: ~224 scanlines
 Constant: ~320 scanlines
