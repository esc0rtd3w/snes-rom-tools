AddMusic v4.04
--------------

0ÅDAbout this AddMusic
~~~~~~~~~~~~~~~~~~~~~~

@First...
---------

	-This is an unofficial AddMusic written in C++.
	-I just referred to most of the released source code.
	-The credit should go the author of the original AddMusic.
	-Finally, I included the Loop Label code made by Carol as well. Thank you.


@New features
-------------

	* You can specify the file-path.
	* Searches for free space in your ROM.
	* The Music numbers where music will be inserted is now 20-9F, not 20-3F 60-7F A0-BF E0-FF.
	* Can output an .msc file.
	* You can insert custom music for P-switch, Star Man, and some other misc. songs.
	* SPC data can be beyond the bank boundary.
	* The size limit of each channel (0x800 bytes) is removed
	* The limit of the amount of the loops numbers you could have (128 loops in total) is removed.
	* The limit of the label number is removed
	* Supports sound effect editing. (see another text file)


1. How to use
~~~~~~~~~~~~~

@What you need
--------------

	- SMW ROM
	- AddMusic.exe




@1. Run AddMusic
----------------

	You can run this program from command line or a batch file.
	The usage is:

	AddMusic.exe YourROM.smc


	This program removes old stuff,
	by any AddMusic in java or my older AddMusic in C++,
	and inserts the main code automatically.

	If you had an old .ini file, this program rewrites it for the current veriosn.
	If not, this creates an .ini file.

	Open AddMusic.ini, and you'll see FreeRAM=7EC100
	This RAM is for fixing the issue with P-switch and Star music.
	You should specify the RAM address which isn't used yet for anything else.

@2. Specifying the file path
----------------------------

	Open AddMusic.ini first.

	The .txt files for the Overworld music should be in the folder named OW,
	and the ones for Level music should be in the one named LEVEL,
	and the ones for some original songs (such as P-switch) should be in the one named MISC. ( read @5 for more details)

*	0A ~ 19 in the [OVERWORLD] section are for the overworld,
	20 ~ 9F in the [LEVEL] section are for the levels.
	the numbers in the [MISC] section are for the misc music.

	Do not specify the file path like this:
	11=OW/filename.txt
	24=LEVEL/filename2.txt

	Do it like this instead:
	11=filename.txt
	24=filename2.txt

	If you didn't specify a file name, AddMusic won't try to insert it.

@3. About overworld music
-------------------------

*	Now custom overworld music numbers are 0A ~ 19.

	I updated the main code so you can use both SMW songs and custom OW music.
	Because of this update, you have to specify the title music number in .ini file.

	TitleMusic=xx


@4. .msc file
-------------

	When Create.msc=1, 
	AddMusic will output an .msc file.
	In case you don't know what an .msc file is, this is used for Lunar Magic,
	and makes Lunar Magic display the music title specified in .msc file instead of "Not Used"
	Put the .msc file in the same directory as the ROM is.

@5. About custom music for some original music
----------------------------------------------

	I call the songs which is possible to be played even if you use custom music "misc music".
	They are,
	"Mario Dies", "Game Over", "Passed Boss", "Passed Level",
	"Have Star", "Direct Coins" (P-switch), "Into Keyhole", "Zoom In", "Welcome",
	"Done Bonus Game" and "Rescue Egg".

	Custom misc music will be loaded always with custom level music.
	So, insert custom misc music as long as you insert custom level music.
	(otherwise the SPC will crash when Mario dies, or Mario passed the goal,
	 or anytime when misc music is played in the level where you use custom level music.)

	In the level where you use original SMW music, like "Here we go" and so on,
	custom misc music will not be loaded, so original misc music are used in those levels.

	In other words, if you use custom music in the level,
	the SPC doesn't have any original SMW music at all.
	Because of this, you need to insert custom misc music always.

*	Now, custom misc music will be stored to the address
*	where original AddMusic stored custom level music.
*	You can use 0x1800 bytes for custom misc music.
*	Since misc music themselves are small, having 0x1800 bytes for them is enough.
*	And also, because I moved it where custom misc music will be inserted to another location,
*	you can use 0x41C8 bytes for custom level music at the maximum.


@6. the size limit
------------------

	custom overworld music	- 0x41DE bytes
	custom misc music	- 0x1800 bytes
	custom level music	- 0x41C8 bytes (per 4 music)


2. New command for mml
~~~~~~~~~~~~~~~~~~~~~~

	I just made these commands for inserting files I included in MISC folder.
	You don't basically need to put this for your custom level music.

?0
	Specify this if you don't want music to loop. (like "Mario Dies", "Game Over", and so on)
	You need to put this only once in the .txt.

?1 and ?2
	Specifing this disables each channel to play.
	As you may know, " / " command is used as " intro / melody-will-loop "
	?1 disables intro of the channel that ?1 command is specified,
	?2 disables melody of the channel that ?2 command is specified.
	This might be useful a little for the channel which has only either of intro or melody,
	because putting only rest note in intro part or melody might be a waste.

	Refer to the files in MISC folder.


tuning[x]=y
	AddMusic automatically tunes up the instrument depending on its number. ( it's what @ command specifies)
	With this command, you can specify how high/low the instrument will be tuned yourself.
	x range is 0 - 255.
	y also can be minus.

e.g.
	tuning[2]=-5 tuning[3]=6

	But you don't also need this.

3ÅDAbout MORE.asm MORE.bin
~~~~~~~~~~~~~~~~~~~~~~~~~~

	I didn't make these, but to make them less size, so I included these as well.
	These were originally made by gocha, 757 and homing.
