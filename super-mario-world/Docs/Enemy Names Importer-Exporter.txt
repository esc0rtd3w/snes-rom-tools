Super Mario World - Enemy Names Exporter/Importer
Version 1.0

Programmed by Smallhacker



What are these programs?
	These two programs are used for editing the names
	of the enemies shown during the ending in a Super
	Mario World Rom.

How to use them?
	First, open the exporter and type the name of the
	SMW Rom you're going to hack. Then, choose the file
	name of the exported text. (A .txt file is
	recommended.) Then, open the file in Notepad and
	edit the names. When you're done, save and open the
	importer. Enter the name of the SMW Rom and the
	file again and it will be imported to the Rom.

Are there any limitations?
	Yes. The new names can't be longer than the
	original ones. The name will be cut off it it's too
	long and padded with spaces if it's too short.
	Also, only symbols shown during the original ending
	are supported by the program so far. These are:
	
	A-Z (Upper Case Only!)
	(Space)
	'
	"
	-
	.
	
	Note that the mirrored versions of ' and " are NOT
	supported. (They will be changed into the normal
	versions of them.) If you're trying to use symbols
	not supported by the program, it will most likely
	result in showing the wrong symbol.

Are there any way to choose which palette to use?
	Yes. Use a Hex Editor to edit the byte at PC
	address 6F5A1 in the Rom BEFORE inserting. Note
	that this will change ALL text shown during the
	enemy ending. The format of the byte is like this:

	(Left)
	Bit 7: Flip Y
	Bit 6: Flip X
	Bit 5: Priority
	Bit 4: Palette (Bit 2)
	Bit 3: Palette (Bit 1)
	Bit 2: Palette (Bit 0)
	Bit 1: ??Unknown??
	Bit 0: Tile number (Bit 8)
	(Right)

I belive that I've found a bug. / I've got a suggestion.
	Tell me!



Legal (a.k.a. boring) stuff:
Super Mario World is copyrighted by Nintendo. Smallhacker
is in no way affilated with Nintendo. Text extracted by
the exporter may be copyrighted by Nintendo. Smallhacker
takes no reponsibility for how people use this program,
nor can he guarantee that the programs won't mess up the
Rom they are used with. Making good games should be
copyrighted by Nintendo.




Smallhacker would like to thank the following people:

Kyouji Craw
BMF54123
Blitz Research Ltd.
BreakPoint Software Inc.