What is GPS:
	GPS is the temporary name of the next generation of block tool.
	
Features:
	1) Command line based for speed and ease of use
	2) Designed to detect duplicate files and recycle insertion pointer to save space.
	3) Includes a mechanism for shared routines for additional space savings and ease of development.
	4) Hybrid SA-1 support.
	5) Allows setting of the Acts like setting from within the tool.
	6) Include several defines which dynamically changes depending of the ROM type.
	7) All Currently accepted db $42 blocks should be compatible. So this tool is backwards compatible.
	8) Can remove BTSD from a hack for ease of upgrading
	9) You can enable a debug flag which prints the addresses of labels that are inserted.
	   Very handy for block creation if you need to set a breakpoint.
	10) DSC file generation based on descriptions that come with blocks.
	11) Optimiztion levels to decrease insertion sizes

How to use:
	From the command line you would execute the following command:
		GPS <options> <ROM>
	Options are as follow (they are optional of course):
		-d		Enable debug output
		-k		Keep debug files
		-l <listpath>	Specify a custom list file (Default: list.txt)
		-b <blockpath>	Specify a custom block directory (Default blocks/)
		-s <sharedpath>	Specify a shared routine directory (Default routines/)
		-O1		Enable optimization level 1, reduces pointer table size when possible
		-O2		Enable optimization level 2, reduces bank byte size when possible
	And lastly the ROM is required.  It may be headered or unheadered.
	
	Note: Optimization level one is usually very safe unless you feel you may fill your ROM and need to reserve
	extra space for the block table ahead of time.  Level two howeve requires more care.  Using undefined blocks
	at level two will CRASH if mario touches them.  Use level two with caution. 

The list format:
	The list format has three parts the block id, an optional acts like setting, and the ASM file to use.
	The basic structure is as follows:
		<blockid><:acts like> <file>
	Some example would be:
		200:01		power.asm
		201		power.asm
		1203:0130	power.asm
	The tabbing is optional and may be a single space instead.

FAQ:

Q) Can I use this tool if I used BTSD previously?
A) Yes.  This tool will delete the BTSD hijacks. (see features item number 6)

Q) Are BTSD blocks supported?
A) All blocks using the db $42 header are currently supported.  If you find a block without such a header please PM an
   ASM moderator for conversion. (see features item number 5)

Q) Is there a graphical interface for GPS?
A) Yes, however its not quite ready yet so was removed until alcaro has a chance to fix it.  Once it is ready I will 
   submit is as an update making the following answer relevant
A) Yes! Alcaro has made a GUI which is included with GPS.  Just double click gps_gui instead of gps.  I do recommend
   At least trying to use the command line version first -- you may just like it!

Q) Are SA-1 ROMs supported?
A) Yes, as long the new blocks and shared routines you insert are compatible with SA-1. You can convert them using the
SA-1 Convert Tool, available at the Tools section in SMW Central or by asking the block author for a SA-1 or hybrid
(both standard and SA-1) version of the block in case the tool don't work.

For developers:
	Shared routines:
		To make a shared routine:
			1) Write your code, do *not* label the routine. The tool will generate the label based on the file name.
			2) Place in routines folder with the desired routine name
			3) Done

		Using a routine:
			1) Just call "%my_routines_name()"
			2) Done

		Special notes:
			1) A label with the file name is reserved. Do not use it.
			2) A define with the name of the file is reserved. Do not use it.
			3) A macro with the name of the file is reserved. Do not use it. 
	DSC files:
		You should include a "print" statement within your block.  The first print statement will be use as the
		description in the DSC file.

	Defines:
		GPS includes several defines which changes according the ROM type, allowing compatibility on ROMs
		with special patches or chips, like SA-1 ROM. GPS for now has the following defines:
			!sa1		0 for LoROM, 1 for SA-1 ROM.
			!dp		$0000 for LoROM, $3000 for SA-1 ROM.
			!addr		$0000 for LoROM, $6000 for SA-1 ROM.
			!bank		$800000 for LoROM (FastROM), $000000 for SA-1 ROM.
			!bank8		$80 for LoROM (FastROM), $00 for SA-1 ROM.

		Additionally there's various sprite defines located in defines.asm where you can either use
		!<RAM address> or !<known name>, for example LDA !14C8,x or LDA !sprite_status,x

		It is advised when coding your block to use these defines for compatibility with special ROMs, like how
		you can see in the shared routines, but not required.

