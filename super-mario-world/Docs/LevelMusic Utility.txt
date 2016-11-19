================================================================================
 LevelMusic Utility v1.3.2 - Super Music Bypass, by ShadowFan-X
================================================================================

--------
Overview
--------
LevelMusic is a custom level music bypass that I made to cover for the two main
issues with the standard Music Bypass feature in Lunar Magic:

 - Custom music does not work with mode 7 bosses.
 - The music does not fade between levels that have different music.

LevelMusic, on the other hand, has neither of these limitations.

This Utility allows you to apply, reconfigure, and remove LevelMusic without
boring you with the nitty gritty details; changing level music is now convenient
and can be done without even leaving Lunar Magic.

The Utility will automatically apply the equivalent of Levelnum.ips if
necessary, as it is required for LevelMusic to work.

Note: Make sure you back up your ROM before applying/removing LevelMusic!

-----
Usage
-----
This Utility is intended to be used from Lunar Magic.
Insert this into your usertoolbar.txt to run it from LM:

***START***
"lvmus.exe" -lm "%1" "%7"
0,LevelMusic Utility
LM_CLOSE_ON_CLOSE, LM_NOTIFY_ON_NEW_ROM, LM_NOTIFY_ON_NEW_LEVEL
***END***

However, the Utility can be run on its own, either with the command line:
> lvmus "[romname.smc]"

or simply double-click the icon and you will be prompted to locate your ROM.

------------
SA-1 Support
------------
This Utility supports custom SA-1 layouts. Add your ROM to sa1.cfg if you do not
want to use the standard layout:

path_to_rom-> CXB, DXB, EXB, FXB

Note that by default, the mapping mode for 6+MiB ROMs are used, even when the
ROM being patched is 4MiB or less. This allows you to easily expand your ROM to
6 or 8 MiB without removing LevelMusic first.

----------------
Auto Export Mode
----------------
This Utility allows you to export a ROM's LevelMusic table every time you change
the music in a level, allowing you to easily insert your desired music setup
with the patch version of LevelMusic using a batch file or other mass patch
application tools such as EasyP.

Add your ROM to export.cfg if you want to enable this behaviour:

path_to_rom->table_file

---------------------
Technical Information
---------------------
LevelMusic hijacks the following addresses:

$00:971A - Loads music
$00:D276 - Music transition
$05:D8B9 - Redirected to $05:DC46, where the level number is put into $010B.

To make a custom LevelMusic patch detectable by the Utility, you need to follow
these rules so the Utility can know where to find your music tables:

 - Put a long jump (JML or JSL) at $00:971A;
    - The target of the long jump should immediately follow the identifier tag,
      "!@LvMusMAIN" + an absolute address, which points to the music table.
    - The identifier tag may follow only a RATS tag, and optionally a PROT tag.
      However, if you use a PROT tag, the Utility will not follow and delete
      them.
    - An arbitrary amount of code can follow after the identifier tag.
 - The level music table should be following nothing but a RATS tag and the
   identifier, "!@LvMusTBL". Anything can follow the level music table.
    - As an exception, the level music table can be within the RATS tag of the
      main code block, in which case the RATS tag is not needed.

----------
Known bugs
----------
 - The music fade transition gives undefined results on unmodified levels. This
   shouldn't ever be a problem, but if it is, all you have to do is save the
   level in LM.
 - Not fully compatible with SMW's original sound engine. You will need to run
   an Addmusic on your ROM at least once, or the music will always restart when
   you go between levels.

---------
Changelog
---------
October 6, v1.3.2:
 - It is now possible to automatically export LevelMusic tables whenever you
   change the music in a level using the Utility. Now you can keep an updated
	 .asm or .bin file that can be inserted with a batch file or mass patch
	 application tool using the Asar version of LevelMusic.

May 11, v1.3.1:
 - SA-1 ROMs now use $610B to get the level number rather than $010B.
 - The freespace finder will now scan the ROM only once, which is much faster.

April 21, 2013, v1.3.0:
 - Now supports ExLoROM and ExHiROM, in theory.
 - Fixed incompatibilities with SA-1 ROMs larger than 2 MiB.
 - ROMs are loaded into memory to reduce the chances of corruption due to bugs.
 - Fixed a checksum bug that happens with non-power-of-2 ROM sizes.

October 28, v1.2:
 - Now compatible with SA-1.

October 26, v1.1:
 - Fixed a possible crash when the loaded ROM is moved or deleted.

October 25, 2012, v1.0: initial release
