  _____            _ _    _______ _____ _____  
 / ____|          (_) |  |__   __|_   _|  __ \ 
| (___  _ __  _ __ _| |_ ___| |    | | | |__) |
 \___ \| '_ \| '__| | __/ _ \ |    | | |  ___/ 
 ____) | |_) | |  | | ||  __/ |   _| |_| |     
|_____/| .__/|_|  |_|\__\___|_|  |_____|_|     
       | |                                     
       |_|    Version 1.0 by Vitor Vilela     
       

SpriteTip (aka Sprite Tips, Sprite Hint) is a extremely complex
tool that allows you to view all custom sprites correctly on
Lunar Magic directly without much work. This tool includes a
custom build of bsnes which together, scans your ROM for all
custom sprites inserted, including custom generators and shooters,
and extracts from them the tiles which later is converted into
.mwt, .mw2, .ssc and .s16 automatically, allowing to you view the
custom sprites correctly on Lunar Magic.

This tool is only compatible with standard and SA-1 version of
Romi's Sprite Tool.

There is two tools included: SpriteTip and CSCG. CSCG (aka Custom
Sprite Collection Generator) is a tool that lets you easily insert
custom collection of sprites on Lunar Magic using only a single .txt
file and nothing else. You won't have to mess with Sprite Map16, nor
with other steps required, just a single .txt file. This tool is used
by SpriteTip, which its job is extract the tiles from your ROM directly,
leaving to you just give a name and/or a description for the custom
sprite.

--- FEATURES ---

 -> Accurate ASM emulation
 -> Automatic extra bit detection
 -> Position change detection
 -> Shooter and generator support
 -> Dynamic Sprite detection
 -> Dynamic LM Sprite Map16 allocation.
 -> Native SA-1 support

--- USAGE ---

First of all, insert all custom sprites, shooters and generators on
your ROM, of course! SpriteTip actually extracts all information
directly from your ROM so I recommend running it once your add a new
custom sprite on your ROM.

Once you have inserted the custom sprites, create a .txt file. This
.txt file will contain the name and/or the description of every sprite
you have inserted. This is important since SpriteTip only extracts the
tile data, not the name or description information since obviously inside
ROM there is only ASM instructions.

The .txt file uses the following format:
sprite number (space/tab) extra bit (space/tab) 0 or 1 (space/tab) text

If the third value is 0, then the text refers to the NAME of the sprite,
which will get displayed on "Add Sprites" dialog. Otherwise if it is 1,
then the text refers to the tooltip (aka description) of the sprite,
which gets displayed when you hover the sprite on Lunar Magic.

For example, if you inserted the YI Shyguy on slot 30:
30	2	0	YI Shyguy
30	2	1	Shyguy from Yoshi's Island

The first line defines the sprite name and the second line defines the
sprite description.

Note that, all of that information is optional. If sprite's description
is not present, LM will display the default tooltip for custom sprites
(i.e. "An undefined custom sprite.") and if sprite's name is not present,
the tool will simply put "Unnamed Sprite" on Custom Sprite Collection List.

When you're done, open SpriteTip. Type the ROM name (including extension)
then press enter and then type the .txt list if you made one and press
enter again. The tool should start scanning your ROM for all sprites
inserted. Once it finishes scanning, it will call automatically CSCG and
it will output 4 files used by Lunar Magic to identify your sprite:
romname.ssc, romname.mwt, romname.mw2 and romname.s16. Just open your
ROM on Lunar Magic with the files on same folder and all custom sprites
should have the correct display.

To add custom sprites, open the "Add sprites" window and on tab select
"Custom Collections of Sprites". All custom sprites the tool detected
should be in! Have fun!

--- Advanced Usage: SpriteTip ---

You can also run SpriteTip though line command, of course. The parameters
are the following:

SpriteTip <rom path> [txt list path] [options]

Where rom path is required, while txt list path and options are optional.
You have the following options available:
      -x: Run SpriteTip normally, but instead of calling CSCG automatically,
          it will generate instead a .txt list FOR CSCG with all tile and
	  name/description data, useful if you want to modify manually for
	  some reason. See "Advanced Usage: CSCG" to learn more about CSCG.
	  
      -e: Force extra bit 3 generation. While the program automatically
          detects the presence of extra bit 3 on sprites, there is some
	  cases that the tool will fail detection, for example on Venus
	  sprite where it only checks for extra bit 3 when the enemy
	  shoots fire. While the sprite still display correctly when you
	  insert manually, it won't appear on "Add sprites" window. If
	  some sprite's extra bit 3 is not appearing on the window, you
	  can try using this option. The only problem is using this
	  command is, obviously, all other sprites that doesn't use
	  extra bit 3 will get listed too, making lot of unnecessary
	  duplicates.
	  
      -l: Logging mode. This options makes SpriteTip output traces of
          every sprite processed. This one is only really useful for
	  debugging purposes. Be aware that generators and shooters
	  will have a rather big log, since SpriteTip runs multiple
	  times to capture all sprites generatared. Also occasionally
	  SpriteTip can also output trace log of regular sprites, in
	  case some generator/shooter spawn them.
	  
Note that you can only specify an option if you specify a .txt list
file too, even if you just put a empty .txt file!

--- Advanced Usage: CSCG ---

CSCG means for Custom Sprites Collection Generator. It's the tool
responsible to convert from a simple .txt list file to LM's .s16,
.mwt, .mw2 and .ssc files. Normally you shouldn't use this tool
but SpriteTip instead, but if for some reason you want to access
all options available, you may want make SpriteTip generate the
CSCG file (see option -x) and edit yourself before running CSCG.

CSCG is only available though command line. The parameters are:
CSCG <rom path> <list file>

<rom path> is the path to the ROM file. The ROM isn't really
access, but CSCG uses the path to store the files used by Lunar
Magic.

<list file> is the list where it contains all information about
sprite name, description, position, OAM tiles, behavior and
much more. The format is the following:

number[,x][,y] (space/tab) extra bit[+] (space/tab) type (space/tab) data

"number" is the sprite number.
"extra bit" is the sprite's extra bit. Note that here you can also
set to 0 or 1 too if you want to edit how vanilla sprites gets
displayed. Have you noticed the [+]? It's optional, but if you
placed + after the extra bit, it will affect both first and second
extra bit. For example, if you want to something affect sprite 20's
extra bits 2 and 3, you do this:
20	2+	[...]

"type" is the type of data to be inserted. The following values are
valid:
	0: "data" is sprite name.
	1: "data" is sprite description.
	2: "data" sets the sprite OAM. The format is same as OAM
	   ($0300,y). You must put the data in hex data. Each "pack"
	   is of 4 bytes, the first one is X position, the second
	   is Y position, the third is tile and the last is YXPPCCCT.
	   Example: 00 00 24 08.
	3: "data" sets the OAM tile size. Same as $0460,y. One byte
	   for each tile. The first bit determines if the sprite will
	   appear transparent on LM, while the second tile defines
	   if the sprite is 8x8 or 16x16. Example: 02 to make the
	   tile 16x16 and 03 to make the tile both 16x16 and transparent.
	4: This option is useful for generators. Instead of playing tiles
	   (for types "2" and "3") it will display a text instead. "data"
	   then is a sprite name/action to be displayed inside Lunar Magic.
	   You don't need to add spaces or line breaks (\n), CSCG will
	   automatically center the text.
	   
Now have you noticed the [,x] and [,y]? They lets you to set different
tooltip, tiles or text depending on X/Y position, like on autoscroll
generators. Example:

C0	2+	0	Super Auto-Scroll Generator
C0,0	2+	1	Mega Slow Scroll
C0,1	2+	1	Mega Lazy! Scroll
C0,2	2+	1	Mega NORMAL!! Scroll
C0,3	2+	1	Mega Mega!!! Scroll

You can use the x/y change for any "type" with exception of "0", because
that type applies for the "Add sprites" window.

Oh and most important, you can only set x/y from range "0" to "F". Also
you have only have 2, 4, 8 or 16 possible settings, since LM interprets
like a AND mask, i.e 2^x.

--- Credits ---

byuu: For his excellent bsnes emulator.
Lui37: Testing.
Vitor Vilela: For coding the tools.

If you have some question or bug report, feel free to drop me a PM.