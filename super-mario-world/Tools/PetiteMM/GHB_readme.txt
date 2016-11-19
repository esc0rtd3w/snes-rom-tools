permission (in text):
https://github.com/loveemu/loveemu-lab/issues/1

Thanks to Erik557 for helping me with the batch file for testing it out.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
What you need:
	-A batch file (already included)
	-Java script: http://java.com/en/download/help

How to convert midi -> MML:

Simple, drag the midi file you have downloaded or created to here (the same
directory as the tool) and run "working_batch_file.bat". It should create a
mml version of it. Each channel are represented by semicolons (";") when
viewing it.

The reason why I included this new batch file is because its really confusing
on the origional help (that it displays when running "PetiteMM.bat"), doesn't
work. One time, I run a batch file that has the commands:

PetiteMM -O blah.mml cinnabar_mansion_for_smw.mid

And what it does is it modify THE MIDI file instead of outputting the mml,
thus deleting the midi file information. But thanks to Erik557 (on the IRC)
about this, Here is the correct code:

java -jar PetiteMM.jar --octave-reverse *.mid

Kinda less intutive, isn't it.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
version history: (M/D/Y, from oldest to newest).

07/10/15:
Included a batch to make usage easier for users.

10/5/2015:
Include a better working batch file (but left the old one just in case) named
"working_batch_file.bat" that is fully functional, I have tested it on my
computer and it doesn't work, even if I follow the instructions correctly
about the "-o" setting.