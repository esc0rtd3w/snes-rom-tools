LevelASMTool - Version 1.0.1

Coded by edit1754

Requires .NET 2.0 Framework or above

--------------------------------
 Contents
--------------------------------

	1. Credits
	2. Introduction
	3. Change Log
	4. Usage
	5. Contact Information

--------------------------------
 1. Credits
--------------------------------

Programming:		edit1754

Base Patch:		Ersanio, BMF54123

Xkas.exe:		Byuu

Freespace finder code:	smkdan

--------------------------------
 2. Introduction
--------------------------------

	LevelASMTool is a utility designed to insert code into Super Mario World
	that will run during specific levels.

--------------------------------
 3. Change Log
--------------------------------

	Version 1.0.1 November 3, 2011
	- Now depends on xkas in the exe's directory rather than searching for it
	  in the ROM's directory.

	Version 1.0.0 March 26, 2011
	- First Release.

--------------------------------
 4. Usage
--------------------------------

    Requirements:
	- xkas.exe must be in the same directory as LevelASMTool.exe
	- In the same directory as [ROMName].smc, the following must exist in the same directory:
		- a directory named [ROMName]_LevelASM/
		- a text file namnd [ROMName]_LevelASM.txt

    [ROMName]_LevelASM.txt contains entries each on a different line, in the following format:
	- ### FileName.asm
		- where ### is the level number in hex,
		- and FileName.asm is the name of a file that exists inside [ROMName]_LevelASM/
	- An asm file may be re-used across multiple levels (which will save space)
	- A level cannot be associated with multiple asm files

    ASM file format:
	- Init code must be preceded with {InitCodeLabel}:
	- Main code must be preceded with {MainCodeLabel}:
	- macros must contain {CodeID} to avoid redefining two macros with the same name
		- examples: %{CodeID}_macroName(), %macroName_{CodeID}()
	- Init and Main code must end in RTL, not RTS!
	- sublabels should be used, e.g.:
			LDA #something
			BEQ .Label
			INC #something
		.Label	RTL
	  Rather than:
			LDA #something
			BEQ Label
			INC #something
		Label:	RTL
	- If not using sublabels, label names must contain {CodeID} just as macros do.
	- To access another level's code, you can do the following:
		JML {MainCodeLabel ###} where ### is the number of the level you want to access, in hex
		JML {MainCodeLabel ###}_SubLabel where SubLabel is the name of a sublabel (described above)
		{InitCodeLabel ###} and {CodeID ###} are also valid
	- Variable/Defined names can be reused across levels, as xkas allows them to be redefined.
	- incbin/incsrc commands must point to [ROMName]_LevelASM/FileName.bin
		- because it is the relative path from tmp.asm, in the same directory as the ROM

--------------------------------
 5. Contact Information
--------------------------------

    edit1754:
	SMWC: http://smwcentral.net/?p=member&id=14 (this may change)
	Email: edit1754@gmail.com
	MSN: edit1754@live.com (occasionally online)