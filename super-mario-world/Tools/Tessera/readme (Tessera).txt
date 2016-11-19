
**********************************
~~~Tessera (version 0.52)~~~
**********************************

This is Tessera, a tool for inserting custom sprites into a Super Mario World ROM.  You may think of it as "Sprite Tool 2.0" or "imamelia's Sprite Tool" or whatever; it doesn't really have an "official" name.  It has more features than mikeyk's or Romi's Sprite Tool, it can insert more sprites, and it allows more options for those sprites.  The downside is that it isn't very compatible with the other Sprite Tools; it uses completely different hacks and different locations for certain pointers and the like.


(You may skip this part if you're new to sprite insertion.)

**********************************
* Features
**********************************

- It can insert unique sprites for almost every possible sprite number/extra bit setting.  (For this reason, I choose to think of the extra bits as a high byte of the sprite number.) This allows for 788 unique sprites not counting the ones in the original SMW, as opposed to 192 in the old Sprite Tool.
- It can utilize "extra bytes", which are additional bytes added to the sprite data in the level that can be used within sprite code.  Before, you had one extra bit to work with that could be used to modify the behavior of a sprite; now, you essentially have 32 "extra bits".
- It can insert many more custom shooters and generators than could be inserted before.  While this might not affect most people, you can now have upward of 200 of each instead of just 16.
- It can insert custom run-once sprites and cluster sprite generators.  Run-once sprites run a code once when they are loaded; they are commonly used to place several other sprites in the level at once, such as the group of 5 Eeries in SMW.  Cluster sprite generators place cluster sprites in the level.  The rotating Boo rings and background candle flames are examples of these in SMW.  (Technically, run-once sprites and cluster sprite generators are exactly the same thing except that the latter also sets $18B8.)
- You can put 128 sprites in the same sublevel instead of just 85, due to the way the new loading routine is set up.
- It is cross-platform.  Tessera should work on any operating system without any emulators or other external tools (such as WINE), at least with minimal editing.
- You can specify defaults for the ROM and sprite list, which will be used if not specified in the command prompt.
- You can use several different formats for the sprite list with respect to the sprite number and extra bit setting.
- You can specify "duplicate" or "clone" sprites, i.e., you can point more than one .cfg file to the same .asm file.  This isn't terribly useful for custom sprites because of the extra bytes, but it also works for duplicating the original sprites.  (This is how you make "tweaks" with this tool.)
- The tool can insert No Sprite Tile Limits automatically.  It can also insert my shared subroutine patch.
- It works with unheadered ROMs.  Unheadered ROMs *should* end in .sfc, but it is not strictly necessary for the tool to work.
- It fixes that weird bug that happened in the old Sprite Tool when certain tables weren't getting initialized.  At least, it should; the tool doesn't assume anything to have a certain value before using it.
- It allows you to make custom sprites respawn just like the Lakitu and Magikoopa do in the original SMW.

**********************************
* Caveats
**********************************

- The tool can only insert sprites in xkas format.  I would have added TRASM support as well, but TRASM, being the piece of junk that it is, doesn't support a certain feature that I needed for the tool.  Future releases may support other assemblers as well (but still probably not TRASM).
- The tool is not compatible with other Sprite Tools.  In fact, if you've used mikeyk's or Romi's tool on a ROM, you'll need to port over before you can use mine.  It was supposed to remove anything from the old tools automatically, but there were some technical difficulties.
- Even xkas-formatted sprites require a couple adjustments before they can be used with the tool.  See "Making sprites" below for details.
- A couple of subroutines that the old tools used have been changed.  See "Making sprites" below for details.
- If you've use sprite 7B or any sprites over C8, you'll need to remove them before running the tool.  (You can reinsert the former.)
- You can no longer use the extra property byte 2 for custom settings.  It is used by the tool to indicate which statuses to run custom code in (and possibly other things in the future).

**********************************
* Choosing configuration settings
**********************************

Tessera.ini (in the "sprite2" folder) contains some information for the tool.  You can change these options if you wish:
- DefaultROMFile is the name of the ROM (or path to it) that will be used if a ROM name is not specified when running the tool.
- DefaultSpriteList is the name of the sprite list (or path to it) that will be used if a sprite list name is not specified when running the tool.
- ListFormat determines how the sprite number from the sprite list will be parsed.  Valid values are 1, 2, and 3:
	- Format 1 looks like this: 42_1 sprite.cfg.  The sprite number is followed by an underscore, which is followed by the extra bit setting.  The underscore can actually be any character.
	- Format 2 looks like this: 142 sprite.cfg.  The sprite number and extra bit setting are treated as a single three-digit number.  (My preferred setting.)
	- Format 3 looks like this: 42 x1 sprite.cfg.  The sprite number is followed by a space and an "x", which is followed by the extra bit setting.  The space and X can actually be any two characters.
- SpecialLevel is the overworld level number of the level that will cause the Koopas to change colors (see RAM address $13BF for the format; the default is 49, or level 125 in SMW).  Note that this DOES NOT handle the graphic swap; for that, you'll need to change SNES $00AA74-75 as well.  Setting this to 60 or above will cause the color change never to happen.
- InstallSub is a boolean value that indicates whether or not my shared subroutine patch will be installed.  (This patch inserts some common subroutines, many of them used by sprites, into the ROM for future use.) 0 -> don't install, 1 (or any nonzero value) -> install.
- InstallNSTL is a bitwise value that indicates whether or not to install the No (More) Sprite Tile Limits patch, either edit1754's original or my Extended NSTL patch.  0 -> install neither, 1 -> install only the regular NSTL patch, 2 -> install only the extended NSTL patch, 3 -> install both.
- SubFreespaceU is the SNES address where the jumps to the shared subroutines will be placed.  It shouldn't be necessary to change this, unless you happen to be using the space at or around the default value ($04A200).

**********************************
* Preliminary stuff
**********************************

1) First of all, I highly recommend backing up your ROM before using this tool for the first time, just in case.  If something goes wrong, such as overlooking some instances of certain sprites that should be deleted beforehand, some sprite data could become corrupted.

2) You may need to install a certain Perl module for the tool to run.  On Windows, type "cpan install DBI" into the command prompt, and on Linux or Mac OS X, type "perl -MCPAN -e 'install DBI'" into the terminal (no quotes in either case).

3) Before running the tool on any ROM for the first time, you'll need to delete all instances of sprite 7B (goal tape), C9 (Bullet Bill shooter), CA (Torpedo Ted launcher), CB (Eerie generator), CC (Para-Goomba generator), and CD (Para-Bomb generator) in the ROM.  You will be able to reinsert them - or their equivalents - later.

4) Also, if you happen to have used the tool on a previous ROM with the same name as a new one (for instance, if you ran it on smwhack.smc, smwhack.smc somehow got corrupted, you deleted it, and now you have a fresh ROM also called smwhack.smc), you must delete the old "romname_spritedata.bin" file (it will be in the "sprite2" folder), or the tool will not work correctly.  (In my example, it would be called smwhack_spritedata.bin.)

**********************************
* Inserting sprites
**********************************

1) Put Tessera.pl in the same folder as your ROM and xkas, along with subroutinedefs.asm and subroutinemaincode.asm if you plan to use shared subroutines.  (More about this later.)

2) Put the sprite numbers and filenames in the sprite list (a .txt file of your choice).
	- The sprite number and extra bit setting should be formatted according to the ListFormat option discussed in the previous section.
	- The sprite .cfg filename does not require an absolute path, only the name of the .cfg, regardless of which kind of sprite it is.  Unlike in the previous tools, sprite .cfg names may contain spaces.
	- Following the sprite .cfg name are the settings for extra bytes and a duplicate.  A single-digit number placed after the .cfg (or after the duplicate specification) will determine how many extra bytes the sprite uses.  Valid values are 0, 1, 2, 3, and 4; not specifying a value will make the tool assume a value of 0.  A triple-digit number placed after the .cfg (or after the extra byte specification) will cause the sprite to use the same pointer as the sprite with the specified number/extra bit setting.  For instance, putting 142 here will make the sprite mimic sprite 42, extra bit setting 1.  This MUST be three digits; use zeroes if necessary.  To make a sprite act like original SMW sprite 14, for example, you would put 014.  You could achieve the same effect by simply making multiple .cfg files use the same .asm file, but that would also cause that .asm file to be inserted multiple times.
	- The sprite list should end in a blank line.  This is just a quirk of my parsing routine, I suppose.
	
3) Type "Tessera.pl -r ROMname.smc -l spritelistname.txt" in the command prompt.  If you are using the default ROM name or sprite list name (specified in the .ini file, as discusses in the previous section), you can leave that part out in the command prompt.  For example, if you use the default sprite list, all you need to type is "Tessera.pl -r ROMname.smc".  Actually, the ROM name, sprite list name, "-r", and "-l" can be in any order.

4) To insert a sprite in Lunar Magic, enable sprite-editing mode (the green shell button in the toolbar).  If you've already set up some custom sprites in the "Custom Collections of Sprites" window (which is somewhat lengthy to be explained here), you can use that, but if not, press the "Insert" key.  Put the sprite number (or low byte of the sprite number, if you prefer) in the "Command" box, the extra bit setting (or high byte of the sprite number, if you prefer) in the "Extra Bits" box, and any extra bytes in the "Extension" box in order.  You can leave the other two boxes alone; they set the sprite's position in the level, but you can just move the sprite once you insert it (the default position is the top left corner of screen 00, so you might want to at least set the screen number). If the sprite uses more than one extra byte, only the first one will show up when you view sprite data (the "5" key in Lunar Magic), but the full set of extra bytes will appear in the sprite tooltip in order.  Note that if you use the "Custom Collections of Sprites" option, you can't specify extra byte settings.

5) Shooters, generators, run-once sprites, cluster sprite generators, and scroll sprites have special handling:
	- To insert a shooter with the tool, specify the shooter number (03-FF are custom) with a high byte of 4.  For instance, using sprite list format 2, shooter 03 would have the sprite number specified as 403.
	- To insert a generator with the tool, specify the generator number (10-FF are custom) with a high byte of 5.  For instance, using sprite list format 1, generator 12 would have the sprite number specified as 12_5.
	- To insert a run-once sprite with the tool, specify the run-once sprite number (07-FF are custom) with a high byte of 6.  For instance, using sprite list format 3, run-once sprite 10 would have the sprite number specified as 10 x6.
	- To insert a cluster sprite generator with the tool, specify the cluster sprite generator number (06-FF are custom) with a high byte of 7.  For instance, using sprite list format 2, cluster sprite generator 0F would have the sprite number specified as 70F.
	
6) These sprites have special treatment in Lunar Magic as well (not because of Lunar Magic itself, but because of the tool):
	- To insert a shooter in Lunar Magic, you must use the "Insert" key.  Use C9 as the sprite number and 0 as the extra bit setting, then put the shooter number in the "Extension" field.  Yes, this means that shooters will not show up correctly in Lunar Magic, and in fact, neither will generators, run-once sprites, cluster sprite generators, or scroll sprites either.  FuSoYa has not put that feature in yet.  (But it never hurts to let him know...)
	- Inserting a generator is much the same, except the sprite number is different.  Use CA as the sprite number and 0 as the extra bit setting, then put the generator number in the "Extension" field.
	- To insert a run-once sprite, follow the same process, but use CB as the sprite number.
	- To insert a cluster sprite generator, follow the same process, but use CC as the sprite number.
	- Scroll sprites are a bit different.  To insert a scroll sprite, start by following the same process with CD as the sprite number...but now, you need to put TWO extra bytes in the "Extension" field.  The first byte is the scroll sprite number, and the second byte is its settings.  The "Special notes" section has a list of which numbers correspond to which original SMW sprites.
	
7) Keep in mind the formatting changes!! Sprites that were made for the old tools cannot be inserted as-is with the new one.  (See "Making sprites" below for more information.)

**********************************
* Making sprites
**********************************

1) Making sprites for this tool is much the same as making sprites for the other Sprite Tools.  Start by creating a new .asm and .cfg file.  You can use base.asm and base.cfg in the "misc" folder as a template, if you wish.

2) Set up the settings in the sprite .cfg file.  This is the same as it is for Romi's Sprite Tool, except for two things: a) currently, you don't have to set which assembler to use (it will always be xkas, at least until I add support for other assemblers) and b) the extra property byte 2 now has a different function.  Bits 0-2 determine in which sprite statuses (values of $14C8,x) the sprite will run custom code.  (Statuses 08 and 01 always run custom code.) spritedatatables.asm has a list of which values do what, in case you would like to take advantage of this in your own sprites.  Bits 3-7 aren't used by the tool, but just for the sake of safety, don't use them.  It is entirely possible that I'll use them for something in the future. 

3) Put 24-bit pointers to the sprite's init and main routines at the end of the sprite's .asm file.  You can do it like this:
		dl Init,Main
or this:
		dl Init
		dl Main
or any other way you like, but these two pointers always have to be after all other code in the .asm file, and the init pointer always has to come before the main one.  It also doesn't matter what you call the labels, as long as you actually have the corresponding labels in there and in the correct place.  You can also use 24-bit addresses that aren't labels; for instance, if your init routine just returns, you could use "dl $018021,Main". These pointers will not actually go into the ROM.

4) It is no longer necessary to change the data bank in a sprite's main (or init) wrapper.  My code does that automatically.

5) Using the extra bytes in sprite code is simple enough.  In normal sprites, $7FAB40,x contains the value of the first extra byte, $7FAB4C,x is the second extra byte, $7FAB58,x is the third extra byte, and $7FAB64,x is the fourth extra byte.  You can reference them just as you would reference any other sprite table.  For setting their values and letting the tool (and Lunar Magic) know how many extra bytes a sprite uses, see "Inserting Sprites" above.

6) Now, other types of sprites can have extra bytes as well.  In shooters, $7FAC00,x is the second extra byte, $7FAC08,x is the third, and $7FAC10,x is the fourth.  (The first is already used for the shooter number.) The extra bytes for generators are $7FAB04, $7FAB05, and $7FAB06; the extra bytes for run-once sprites and cluster sprite generators are $7FAB07, $7FAB08, and $7FAB09; and the extra bytes for scroll sprites are $7FAB0A and $7FAB0B.  Note that not all four are represented because some of them are already used for other purposes...and that the scroll sprite extra bytes are unused because Tessera does not yet support custom scroll sprites.  Also note that you cannot change the number of extra bytes used by other sprite types; all of them use all four.

7) If you want one sprite to spawn another sprite, the format is slightly different.  Spawning a normal sprite is exactly the same as it was for previous Sprite Tools, but custom sprites do it slightly differently than they did before: you now have to set $7FAB10,x *before* initialization, and instead of a JSL $07F7D2 followed by a JSL $0187A7, you use JSL $01830B (or $81830B).  Also, bits 0 and 1 of $7FAB10,x now hold the extra bits/sprite number high byte (before, it was bits 2 and 3), and bit 7 of $7FAB10,x should also be set.  (While that bit really should only affect sprites that run custom code in statuses other than 8 and 1, it never hurts to be safe.)

8) Making shooters, generators, run-once sprites, and cluster sprite generators is much the same as making regular sprites (except for the obvious code differences).  There are only two differences in the setup.  First, you don't need to worry about the .cfg settings.  The .cfg file should still point to the correct .asm file, but none of the hex data matters; none of it is used or inserted.  Second, the init pointer is not used in other types of sprites.  It should still be there (if you have only one pointer instead of two, things will break), but it doesn't matter where it goes.  I usually just use "dl $FFFFFF,Main".

**********************************
* Special notes
**********************************

- Do not confuse extra bits, extra bytes, and extra property bytes! Extra property bytes are set in the .cfg file, and there are always two per sprite.  Extra bytes are set in Lunar Magic, and there can be from 0 to 4 per sprite.  Extra bits are also set in Lunar Magic, but the extra bit setting is always a value from 0-3, and it is used as a high byte for the sprite number.
- The extra property byte 2 now has a different function.  Before, you could use the lower 6 bits for anything (the highest 2 bits were already used).  Now, bits 0-2 are used by the tool, and bits 3-7, while unused, may be used in the future.
- $7FAB10,x has also been changed slightly.  Now, bits 0-1 hold the extra bits/sprite number high byte (instead of bits 2-3), and bit 7 determines whether or not the sprite is custom.  (0 is normal, 1 is custom.)
- You can now make custom sprites respawn, like the Lakitu and Magikoopa do.   Store the time it will take until the respawn happens to $18C0 (it decrements every other frame), #$FF to $18C1, the Y position to $18C3-$18C4, the X position to $7FAB8A-$7FAB8B, the values of the extra bytes to $7FAB8C-$7FAB8F (any extra bytes not used by the respawned sprite can be skipped), and the sprite number to $7FAB88-$7FAB89.

**********************************
* Tutorials
**********************************

Sorry, no tutorials for Tessera yet, unless you count the information in this readme and the other.  I do, however, plan to include a section about sprite coding in my ASM tutorial.

**********************************
* Lists of non-normal sprites
**********************************

Because some people will probably have trouble figuring out what the correct settings for shooters and the like are, I have made this list.  First comes the sprite number: I have given it as a 3-digit number, so you should put the first digit in the "Extra Bits" box and the other two digits in the "Command" box (in Lunar Magic, of course).  The "x##" is the extra byte setting.  This is what you type into the "Extension" field.  (Don't type the x.) Shooters, generators, run-once sprites, and cluster sprite generators have a 2-digit extension setting (1 extra byte), while scroll sprites have a 4-digit extension setting (2 extra bytes).

Shooters:

0C9 x00 - nothing
0C9 x01 - Bullet Bill shooter
0C9 x02 - Torpedo Ted launcher
0C9 x03-xFF - custom shooters

Generators:

0CA x00 - nothing
0CA x01 - Eerie generator
0CA x02 - Para-Goomba generator
0CA x03 - Para-Bomb generator
0CA x04 - Para-Goomba and Para-Bomb generator
0CA x05 - dolphin left generator
0CA x06 - dolphin right generator
0CA x07 - jumping fish generator
0CA x08 - Turn Off Generator 2
0CA x09 - Super Koopa generator
0CA x0A - sprite in bubble generator
0CA x0B - Bullet Bill generator (horizontal only)
0CA x0C - Bullet Bill generator (horizontal and vertical)
0CA x0D - Bullet Bill generator (diagonal)
0CA x0E - Bowser statue fireball generator
0CA x0F - Turn Off Generators
0CA x10-xFF - custom generators

Run-once sprites:

0CB x00 - green Koopa shell
0CB x01 - red Koopa shell
0CB x02 - blue Koopa shell
0CB x03 - yellow Koopa shell
0CB x04 - green Para-Koopa shell
0CB x05 - group of 5 Eeries
0CB x06 - group of 3 rotating platforms
0CB x07-xFF - custom run-once sprites

Cluster sprite generators:

0CC x00 - Boo ring (clockwise)
0CC x01 - Boo ring (counterclockwise)
0CC x02 - Boo ceiling
0CC x03 - death bat ceiling
0CC x04 - reappearing Boos
0CC x05 - background candle flames
0CC x06-xFF - custom cluster sprite generators

Scroll sprites:

0CD x00xx - nothing (might crash if used, or possibly just run another scroll sprite's code)
0CD x01xx - special auto-scroll
- x0100 - Auto-Scroll Special 1
- x0101 - Auto-Scroll Special 2
- x0102 - Auto-Scroll Special 3
- x0103 - Auto-Scroll Special 4
- x0104 - Auto-Scroll Special 1-A
- x0105 - Auto-Scroll Special 2-A
0CD x02xx - Layer 2 Smash
- x0200 - Layer 2 Smash 1
- x0201 - Layer 2 Smash 2
- x0202 - Layer 2 Smash 3
0CD x03xx - Layer 2 Scroll
- x0300 - Layer 2 Scroll, Range 12
- x0301 - Layer 2 Scroll, Range 08
- x0302 - Layer 2 Scroll, Range 05
- x0303 - Layer 2 Scroll, Range 06
- x0304 - Layer 2 Scroll, Range 05
- x0307 - Layer 2 Scroll, Smash Range 11
0CD x04xx - unused (may crash)
0CD x05xx - unused (may crash)
0CD x0600 - Layer 2 Falls
0CD x07xx - unused (may crash)
0CD x08xx - Layer 2 Scroll Sideways
- x0800 - Layer 2 Scroll Sideways Short
- x0801 - Layer 2 Scroll Sideways Long
0CD x09xx - unused (may crash)
0CD x0Axx - unused (may crash)
0CD x0B00 - Layer 2 On/Off Switch
0CD x0Cxx - auto-scroll
- x0C00 - Slow Auto-Scroll
- x0C04 - Medium Auto-Scroll (technically just pulls a garbage value)
- x0C08 - Fast Auto-Scroll (technically just pulls a garbage value)
0CD x0D00 - Fast BG Scroll
0CD x0Exx - Layer 2 sink/rise
- x0E00 - Layer 2 Sink Short
- x0E01 - Layer 2 Sink Long
- x0E02 - Layer 2 Rise Up
- x0E03 - Layer 2 Give Some
0CD x0Fxx-xFFxx - unused (Tessera does not support custom scroll sprites...yet.)


Does it all seem confusing? It really isn't.  If you've used mikeyk's or Romi's Sprite Tool, then you shouldn't find it too hard to use mine.  There's just more to explain because mine, well, does more stuff.  The new features are easier to get the hang of than they might seem at first glance.  Also, I'm always open for input, feedback, and suggestions.   (I can think of several features that this tool may have in the future, such as custom scroll sprites, custom sprite and object clipping tables, two more Tweaker tables, and support for other sprite types...we shall see.)

**********************************
* Bugfixes and feature suggestions
**********************************

If you find any bugs in Tessera or any of my sprites, please mention them (particularly if you already know how to fix the problem).  I'd like not to have buggy tools and sprites, and I sometimes overlook things in testing.  If you have any suggestions for future versions of the tool, feel free to mention them as well, unless it's something stupid.

**********************************
* Credits and other notes
**********************************

I would like to thank the following people for helping make this possible:

- Kipernal and yoshicookiezeus, for beta-testing
- DaxterSpeed and K3fka, for helping me get it working on Linux
- mikeyk, Davros, and Sonikku, for use of some of their sprites
- ...and probably several people I forgot.

Yeah, this list is by no means exhaustive.  I'm sure I forgot some people, so anyone is welcome to remind me.

Should you have any questions about the tool or my sprites, you may send me a PM (my user ID on SMW Central is 3471).  You could also just post the question on the forums, and then somebody else might be able to answer it if I am busy.










