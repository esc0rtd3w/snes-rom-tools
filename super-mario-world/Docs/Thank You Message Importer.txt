Super Mario World - Thank You Message Importer
Version 1.1

Programmed by Smallhacker



What is this program?
	This program is used for editing the text shown
	after beating Bowser in a Super Mario World Rom.

How to use it?
	First, you need to create a .txt containing the
	new text. Then, open the program. Enter the name
	of the SMW ROM to edit and then the name of the
	.txt file containing the text.

The original font didn't contain all letters. I've added
new ones, but how do I make the program work with them?
	The program comes with a table file called
	SMWTYMI_Table.txt. If you want to add a letter,
	add a new row to the file containing the letter,
	a space and the tile number. If there's a letter
	in the file which is not in the table, tile $7F
	will be used.

Why is there a "¤" symbol in the table file? There is no
such symbol in the original font.
	The tile set to ¤ is the tile which will be used
	to pad unused room if your text is shorter than
	the original one.

How do you add delays between letters?
	The symbols $, % and \ controls the delay between
	the letter before it and the letter after it.
	The default delay value is 8.
	$ adds 8 to the delay value
	% adds 1 to the delay value
	\ subtracts 1 from the delay value
	More than one symbol can be used at a time.
	$$ gives a delay value of 24. (8+(8*2))
	$\ gives a delay value of 15. (8+(8-1))
	\\\\ gives a delay value of 4. (8+(-1*4))
	And so on...

Are there any limitations?
	Yes. You can only have up to 84 characters (not
	counting spaces). All characters after the 84th
	will be ignored. 

I belive that I've found a bug. / I've got a suggestion.
	Tell me!



Legal (a.k.a. boring) stuff:
Super Mario World is copyrighted by Nintendo. Smallhacker
is in no way affilated with Nintendo. Smallhacker takes
no reponsibility for how people use this program, nor can
he guarantee that the program won't mess up the Rom it is
used with. Making good games should be copyrighted by
Nintendo.


Version history:
1.0	First version
1.1	Added delay support


Smallhacker would like to thank the following people:

FuSoYa
Sukasa
Blitz Research Ltd.
BreakPoint Software Inc.