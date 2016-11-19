RLM (Recover Lunar Magic)
Copyright 2003-2009 Parasyte (parasyte@kodewerx.org)
http://www.kodewerx.org/



------------
 What's New?
 -----------

v1.4 (xx-xx-xx):
* Fixed unnecessary address masking; skipped stages when unlocking large hacks.
* Fixed early bailouts that left an empty output file.
* Fixed a double-free bug.

v1.4 beta (12-27-09):
* Fixed bug when unlocking large hacks; Unnecessary address masking made RLM
  skip stages when decrypting stage data.

v1.3 (12-26-09):
* Fixed yet another last-known-problem with (what I believe is) "Super ExGFX".
* Support for drag-n-drop (see "Using RLM").
* Readme cleanup.

v1.2 (04-18-05):
* Fixed the last known problem with OverWorld decryption.

v1.1 (01-16-05):
* Fixed a problem with OverWorld decryption.
* Changed copyright years from 2003-2004 to 2003-2005.
* Added a version number define to make version changes easier.

v1.0 (01-13-05):
* Initial release!



-------------
 What is RLM?
 ------------

Recover Lunar Magic (RLM) is a program designed to recover Super Mario World
hacks locked by Lunar Magic.  This is useful if you manage to lose your
unlocked hack, and only have a locked demo publicly available. It has
happened before, and I'm sure it's no fun.  Imagine, you lose all of the work
you put into a huge hack, only to be laughed at by an editor which refuses
to open a demo which you locked to avoid people from stealing your work!
Personally, I don't believe in attempting to keep hackers from stealing from
other hackers.  (In fact, I intend to ENCOURAGE it one day with my Metroid
(NES) hack.  The hack will be so extensive that some people may wish to hack
it into a version of their own.  I will even supply editors and other tools
to assist the interested hackers.)

The uses behind this program may seem like it's only for 'stealing' the work
of others.  And if that is what you think, you're wrong.  However, RLM does
ALLOW hackers to steal others' work.  Which is an interesting dilemma, to say
the least.  However, I am confident that hack locking is a terrible habit.  One
day, the ROM hacking scene will be free of such rubbish.

If people are stealing your work, it probably means you have done a good job on
your hack!  After all, imitation is the sincerest form of flattery.



------------------
 How Does it Work?
 -----------------

Enough with the morality issues behind RLM.  I will now discuss what it does,
how it works, and all that good stuff.

The file "level protection crack.txt" included with RLM is a bunch of my notes
from the reverse engineering project.  It contains many vague references to
data and addresses with little to no explanation of what any of it is.  It's
included mostly for a tiny bit of insight into just how much crap Lunar Magic
changes when it locks a ROM.

If you look through the RLM source code, you're bound to find many errors with
what I've named some of the stuff.  For example, I'm not at all certain if what
I call the "ExGFX Pointers" are actually ExGFX Pointers or not!  But,
decrypting did fix a lot of the ExGFX problems, so it seems like an apt name.
Honestly, I do not know what most of the data is which RLM changes.  I just
know that it all must be done.

What RLM will NOT do is recover Demo World: The Legend Continues.  That hack is
expanded, and will not work in the public Lunar Magic build, even if it were
not protected.  (You can see in the source that there is some preliminary
ExHiROM support, which I added just for this hack.  However, I've hard coded
RLM to ignore ROMs which are not standard LoROM.)  A side project I worked on
was converting Demo World: The Legend Continues to LoROM, so that it could
happily be loaded in Lunar Magic.  What I have done so far is a really terrible
mess, and not really worth mentioning.  The LoROM is able to show the little
intro screen before the title, then it goes to a black screen with the title
music playing.  After about 15 or 20 seconds of this, the ROM crashes. :D
It will take plenty of work to finish that project, but it seems [at least
mostly] doable.


RLM is the result of quite a few hours of reverse engineering Lunar-Magic-
locked ROMs.  It was a pretty fun project, over-all. And I did not have to
reverse engineer the Lunar Magic executable in any way to complete the program.
This is ALL from reversing the SNES ROMs! A nice accomplishment, if I do say so
myself!



----------
 Using RLM
 ---------

Running the program is very easy, just run from the command line:

rlm <in-file.smc> [out-file.smc]

Where <in-filesmc> is the file name of the ROM to recover, and [out-file.smc]
is the [optional] file name for the recovered output file.  If an output file
name is not explicitly defined, one will be implicitly chosen by replacing the
file extension (from the input file name) with ".unlocked.smc".

An alternative way to use RLM is by dragging the ROM file onto RLM from within
your file manager.  For example on Windows, you might have a locked ROM named
"1337 Hack.smc" -- Just click and drag "1337 Hack.smc" over to RLM and drop it.
A new file named "1337 Hack.unlocked.smc" will be created in the same directory
as "1337 Hacl.smc".

If you can't get RLM to work on your machine, it's probably because you don't
understand anything about console programs.  In the past, I've had numerous
people send me messages asking for help.  The biggest complaint is, "RLM closes
by itself when I try to open it!"  Well, that's because you're trying to use it
as if it were a GUI app.  Since it is a console app, it must be run like a
console app; start up your OS' command line, and have at it!  If you don't know
how to do that, I have no confidence that you will ever make good use of RLM,
any way.  Closing this statement, I'd like to say that if you stop being lazy
and try to GoogleIt (tm) you just might learn something!



----------------------------
 What Are All These Numbers?
 ---------------------------

The numbers produced by RLM are simply debug text implemented during the
development of the program.  For example:

Decrypting stage 0x0105...  [0x1DD786]

The first number (0x0105) is the stage number, as shown by Lunar magic.  Not
all stages are encrypted by Lunar Magic, just the ones which have been edited.
The second number (0x1DD786) is the file offset of the encrypted/compressed
stage data.  A third number may follow in some cases. This is another offset to
more encrypted/compressed data.  I do not know what this data is, exactly.  Not
all encrypted stages will have one of these offsets.

Additional numbers printed are encryption seeds (the numbers used in the simple
XOR-based encryption) and decryption counters.  An example of a counter:

192 stages decrypted



-------------------
 Honorable Mentions
 ------------------

I feel the need to apologize to FuSoYa, first of all.  Lunar Magic is a pretty
nice editor with TONS of features.  And even though I really hate the
interface, I must commend you on the work you've done on it.  Second, I should
probably apologize to Evil Peer for some reason.  Probably just because he's a
cool guy, and seems to work very closely with FuSoYa.  Third, I'm apologizing
to byuu for complaining about his emulator and its internal debugger.  These
tools *can* be used for hacking, they just aren't user/hacker friendly.

But none of that keeps me from despising this whole notion that ROM hacks
should be kept under lock and key, as if it's a work protected under copyright
law.  Custom graphic, audio, and level designs may be copyrightable.  And if
so, there is no reason you could not copyright the content of an IPS patch.
(If the IPS patch contains graphics ripped from other games or such, don't
bother with any copyright.)  But now I'm just going off-topic.  (Off-topic
within my own readme! Sweet!)



-----------
 Disclaimer
 ----------

Silly disclaimer here to get annoying pests off my back!

I (Parasyte) am not responsible for how this program is used, or any side
effects thereof.  It may attempt to burn up your computer's power supply or
monitor successfully.  It may also pee on your carpet while you sleep.  If you
have problems allowing any of these possibilities, don't bother using the
program!  It's kind of like avoiding STDs; the best way is through abstinence.
If you accept this agreement, fell free to reap the benefits of RLM.  Just
don't be a stupid bastard and use it to claim other's work as your own.
Remember that anyone can do the same to you!  It would be wise to treat others
as you wish to be treated, in this case.

Do keep in mind that hack-stealing is not commonplace.  There is a huge ROM
hacking scene outside of Super Mario World, and it experiences far less
thievery than everyone believes.  Super Mario World tends to have the most.
But OF COURSE that has nothing to do with locking people out of the hacks.
NOOOO, there's no way on earth that it constitutes reverse psychology!  Who
would ever believe that telling people they cannot do something would ever make
them want to try it?!  [Note: if you're a blathering idiot, the last few
sentences were sarcasm.  In other words, locking hacks makes people want to get
in to it even more than usual.]

Now don't go complaining to me about any problems.  I do not care what "morals"
you believe in; it's none of my business.  My business consists of giving back
the freedom which Lunar Magic takes from Super Mario World hackers.

Finally, if a hack runs at all, no matter how encrypted, or compressed, or
obfuscated, it can be cracked.  ROM locking has been a huge gimmick thus far.
Let's hope those days are OVER.
