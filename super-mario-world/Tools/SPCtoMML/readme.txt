  _____ _____   _____ _        __  __ __  __ _      
 / ____|  __ \ / ____| |      |  \/  |  \/  | |     
| (___ | |__) | |    | |_ ___ | \  / | \  / | |     
 \___ \|  ___/| |    | __/ _ \| |\/| | |\/| | |     
 ____) | |    | |____| || (_) | |  | | |  | | |____ 
|_____/|_|     \_____|\__\___/|_|  |_|_|  |_|______|
     Version 1.0            by Vitor Vilela

------------------------------------------------------

SPCtoMML is a tool that allows converting .spc files
to MML (.txt) files + BRR samples.

This is a project being done for almost 3 years. After
various failed attempts, finally I managed to generate
a stable tool with fairly conversion accuracy.

------------------------------------------------------

To use it, first open a SPC file. Specify how many
seconds to you want to dump (aka "listen") it. By
default, it puts the amount of seconds in the SPC
divided by 2 or 60 seconds if such information is not
present. You may want to increase it since most songs
have intros and simply dividing the seconds by 2 won't
handle them.

Once you finished, click in "Analyze SPC" button. It
will dump/play SPC for the specified amount of seconds.
Once it's done, you can do the following:

 - Export the BRR samples;
 - Play the analysis (play the saved dump data); or
 - Export to MML file + BRR samples.

In case you want to export to a MML file, you may want
to take a look on the additional options:

 - Staccato:
    - Allow simple staccato: Remove any short rests
      but always use q7X.

    - Allow full staccato: Remove any short rests, but
      the tool will test all possible Y parameters for
      the qYX command, when possible.

    - Disable staccato. It won't remove any short rest.

    - Remove small rests: Even after doing the staccato
      process, some extremely small rests (r192) can
      still appear. Check this option to the tool truncate
      them. Note that it has no effect if you selected
      "Disabled staccato" command.

 - Pitch:
    - Accurate tuning ($EE) support: This option will
      ensure maximum pitch accuracy, by using the
      "tuning" command when needed. Disabling this
      command will make the MML files (and their
      insert sizes) much smaller. Normally disabling
      it won't have any audible side-effects, unless
      if you have ~1 Hz precise ears.

    - Vibrato emulation: This will try detecting vibrato
      commands when a sequence of repeated pitches are
      detected on a note. Note that this is not 100%
      accurate, so in case of a pitch bend/slide act
      like a vibrato, you can disable this command to
      disable vibrato support.

 - Volume:
    - Amplify support. $FA $03 $XX command. Normally
      only insanely loud songs will really need it.
      Disabled by default.

 - MML Tempo:
    - Automatic: Tries detecting the tempo based on
      amount of beats per minute of the SPC.

    - Manual: If you're having slowdown issues or if
      the song is going slower or faster, you can
      set the tempo yourself. To convert the value
      to beats per minute => BPM = value*625/256.

 - General Settings:
    - Seconds to dump: Put how many seconds you want
      to dump the song. ***NOTE THAT IF YOU CHANGE
      THIS VALUE YOU MUST ***ANALYZE*** THE SPC
      OR IT WON'T HAVE EFFECT***.

 - Output Settings: You can specify where the MML
   and samples the tool will be saving to. If you're
   ripping multiple songs, be sure to change every
   value before exporting MML or Samples again.

    - #path folder: Which path will be used inside
      "samples" folder on AddmusicK. The tool will try
      guessing it when you specify the folder where
      the samples will be saved to, but nothing avoids
      you from changing it manually, if you need.


------------------------------------------------------

The process done there is very complex. It involves
emulating/playing the SPC file and grabbing all DSP
events and later converting into notes using various
algorithms and steps. In the end, using this tool it's
possible to generate a MML file and extract all relevant
BRR files, making it almost ready to use with AddmusicK.

It works though four steps:
 - Open a SPC file. The tool will make the initial
examination, check for security issues and collect some
initial information about the SPC (like how many seconds
it seems to last).

 - Deep SPC analyze. This step the tool will invoke
SNESAPU and start playing the SPC at fastest speed
possible. While playing, the tool will collect every
single DSP write and Sample Directory changes and write
to a buffer file. After the process is done, the buffer
will something like a complete dump of the SPC file,
containing all DSP writes and a copy of the ARAM.

 - MML generation. This step converts the dump generated
into notes and all relevant commands (echo, volume
changes, pitch bend, pitch slides, remote command, ADSR,
GAIN, sample changes, etc.) to a MML file. This process
has various sub-steps, which first it tunes every sample
detected to the best value possible (pitch accuracy then
smallest amount of $EE commands per note). Later it will
calculate the tempo based on average number of beats per
minute of every channel. And finally, it will generate
the final MML data.

 - BRR samples generation. After the MML is generated,
another function start looking the dump for every sample
change and rips all BRR samples used with loop point and
outputs to the requested note.

After these steps, the song generation is done.

------------------------------------------------------

You may want to note that:

 - The MML output IS NOT LOOPED. Due of how the tool
works, it is not possible the loop the song correctly
without breaking everything. You will have to loop it
yourself.

 - The MML DOES NOT LOOP AUTOMATICALLY. You will have
to put a loop point yourself or the song will restart
to the intro when it finishes playing.

 - The MML note length is IRREGULAR. What do you mean?
It's pretty simple: Imagine the song was possible to
have the following sequence of notes: c8 d8 c8 d8 c8
Since it is not possible to contain a perfect note,
either because the game will write a bit early or later
a note or because of a inaccurate tempo detection. To
avoid the song from losing sync, occasionally "sync"
ticks are used, which makes the note sequence irregular.
In the case, "c8 d8 c8 d8 c8" would turn into "c8 d=23
c8 d8 c=25" instead. the =25 is a 8th note PLUS one
tick and =23 is a 8th note MINUS one tick. If you want
to the song be smallest if possible, you will have to
figure the note sequence and fix it yourself and change
tempo if anything. This includes staccato. In fact, you
can change if you want to use "simple" staccato, that is
always use q7X, "full" staccato where the 7 can be
between 0 and 7 and disabling staccato completely, which
will throw lot of rests every note.

 - Pitch slides, legato and vibrato. Unlike MIDI format
or any other command-based music format, the S-DSP engine
receives RAW PITCH instead of notes + commands. This
means the SPC700 does the process of pitch manually and
of course that can't be emulated properly. The tool must
guess what a array of pitches sticked to every note do.
While on simple cases it can get some fair results, in
more complex songs it will generate horrible outputs.
It's because you can't really detect what's going
exactly. And the worse: two or even all of these pitch
events can occur. The tool simply can't handle that.
Legato is not supported at all right now. You will have
to do it manually. You can disable vibrato emulation in
case the slides are acting like vibratos, but obviously
all vibratos will be translated to $DDs, which wastes
much more space than it should. Nothing than a human
intervention can solve it. Welp.

 - Tremolo, volume slide and pan side aren't supported
at all right now. It's a bit overkill to a tool handle
and guess what's going with a array of volume changes
right now. Unlike pitch, you have both L and R volume,
so two values for guessing possible three common commands.
Yeah, not possible at all.

 - The tool supports remote commands, but not insanity
commands. Some games likes to change the envelope (ADSR
or GAIN) multiple times into a note. While the tool can
handle one envelope change, thanks to AMK's remote
commands, it can't handle multiple changes.

 - "On the fly" samples: Of course SPCtoMML can't detect
(nor emulate) them. Some games like F-Zero, Chrono Trigger
and Romancing Saga 3 edits their samples dynamically. You
will have to do... whatever it's needed for getting them
working.

 - And of course, while the tool will still rip them
normally, AMK won't be able to insert BRR files with
size over ~31kB.

------------------------------------------------------

I wanted to thanks all people which motivated me in some
way to code this, including Lui37 and Sinc-X. And all
people that tested the WIP version of the tool like
ggamer77, lolyoshi, MercuryPenny and Sayuri.

And of course, to Degrade Factory and Alpha-II for making
the SNES APU DLL. This tool wouldn't be possible without
their work.

------------------------------------------------------

The source code of this tool is available at:
 - https://github.com/VitorVilela7/SPCtoMML -

Feel free to edit it if you're interested in improving
the tool. Please fork or create a new branch first
though :V

That's all. Any question feel free to PM me, Vitor Vilela.