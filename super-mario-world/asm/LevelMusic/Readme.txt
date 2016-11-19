================================================================================
 LevelMusic v1.0.3 - Super Music Bypass, by ShadowFan-X
================================================================================

LevelMusic is a custom level music bypass that I made to cover for the two main
issues with the standard Music Bypass feature in Lunar Magic:

 - Custom music does not work with mode 7 bosses.
 - The music does not fade between levels that have different music.

LevelMusic, on the other hand, has neither of these limitations.

How to apply:

 1. Configure the patch using config.asm:
     - !FadeSlot: Allows you to change the music slot used for fade transitions.
                  This is only important for Addmusic 4.05 users.
     - !FadeConfig: Allows you to configure when you don't want fade transitions
                    to occur. Disabled by default.
     - !FadeFlag: Points to memory that can be set to either zero or non-zero to
                  disable fade transitions, depending on !FadeConfig.
                  Not used when !FadeConfig is turned off.
 2. Edit musictables.asm; each line is the music setting for one level.
    To opt out of the music bypass for a level, set the music to $00. To have no
    music playing in a level, set the music to $FF.
 3. Use Asar to patch levelmusic.asm to your ROM.
    You can re-apply the patch as many times as you need. You will need to do
    this every time you want to change the music for a level.
 4. If you haven't patched LevelASM, uberASM, or any other patch that sets $010B
    to the current level number, you will need to apply levelnum.asm to your ROM
    as well (also uses Asar). After applying it once, you don't need to apply it
    again.

Note:
 - If you used the beta version of LevelMusic, and you had !ApplyLevelNumIps
   turned on, you will need to apply levelnum.asm once or your ROM will crash.
 - It is safe to use LevelASM or uberASM after applying levelnum.asm; in fact,
   LevelASM's hijack does the exact same thing as levelnum.asm. uberASM will
   overwrite (or even skip) it completely, not breaking anything.
 - If you are using LevelMusic with AddmusicK, you will need to run AMK at least
   once on your ROM before patching LevelMusic. This is because the music fade
   slot is $FF rather than $80. The ROM will crash if you don't.
   If you forget, don't fret; just re-apply LevelMusic, and it will detect AMK
   the second time around.
 - In AddmusicM, you CANNOT use music slot $80. The results may vary from
   playing music during level transitions to crashing.
   In Addmusic 4.05, you can use slot $80, but you MUST change !FadeSlot to $A0.
   This issue is entirely absent from AddmusicK.

Known bugs:
 - The music fade transition gives undefined results on unmodified levels. This
   shouldn't ever be a problem, but if it is, all you have to do is save the
   level in LM.
 - Not fully compatible with SMW's original sound engine. You will need to run
   an Addmusic on your ROM at least once, or the music will always restart when
   you go between levels.


I am too lazy to make an xkas version. If you don't want to use Asar for some
reason, don't worry. I have made a GUI tool for inserting LevelMusic. In fact,
it is a sort of "plug-in" for Lunar Magic. Just look for "LevelMusic Utility" on
SMWCentral.
Actually, the only advantages this Asar patch has over the Utility is that it is
more configurable, and it can be used on SuperFX and DSP-1 ROMs.

Levelnum.ips (disassembled version included with LevelMusic) was made by BMF.
