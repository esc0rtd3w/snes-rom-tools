
Let's face it...some people find bitwise stuff easier to understand than others.  Some people have no trouble at all, while others have a cerebral core meltdown.  So this quick little tutorial is here to promote understanding for those who fall into the latter category.  If you want to use a sprite, but it says stuff like "Bit 0 = X, bit 1 = Y", what do you do? What values do you use for the extra bytes? Well, let's have an example: the Piranha Plant/Venus Fire Trap sprite.  (It was one of the first sprites I made for Tessera, after all.) Opening up piranha_plant.asm, we find this:

;; Extra bytes: 1
;;
;; Bit 0: Direction.  0 = up/left, 1 = right/down.
;; Bit 1: Orientation.  0 = vertical, 1 = horizontal.
;; Bit 2: Stem length.  0 = long, 1 = short.
;; Bit 3: Color.  0 = green, 1 = red.  (Red ones move even when the player is near.)
;; Bit 4: Sprite type.  0 = Piranha Plant, 1 = Venus Fire Trap.
;; Bit 5: Number of fireballs.  0 = spit 1, 1 = spit 2.  This is used only if bit 4 is set.
;; Bit 6: Unused.
;; Bit 7: Unused.

The Piranha Plant uses one extra byte, and six of the eight bits within that byte are used.  The other two bits don't do anything in this particular sprite.  What extra byte setting would make this sprite act like a plain old Piranha Plant: green stem, red head, 32 pixels tall, doesn't come out of the pipe when the player is near? Well, let's look at the information given.  Bit 0 is direction, bit 1 is orientation...but what "bits"? Well, we're working with a single byte here.  One byte can take on values from 0 to 255 in decimal, 0 to FF in hexadecimal (also written as 00), or 0 to 11111111 in binary (also written as 00000000).  Each binary digit is one bit, it can equal either 0 or 1, and the bits are usually numbered from 0 to 7, bit 0 being the one with the smallest value and bit 7 being the highest, like so:

76543210
bbbbbbbb

Back to the Piranha Plant, which bits have which values? Well, let's start from the bottom. According to the .asm file, bit 0 determines the direction.  0 is up or left, and 1 is right or down.  We want the plant to go up, so let's put a 0 here:

76543210
xxxxxxx0

There's the first setting.  Next is bit 1, which determines the orientation, 0 being vertical and 1 being horizontal.  We want it to be vertical, so there will be another 0.

76543210
xxxxxx00

Then there's bit 2, which determines the stem length.  0 is long (the entire stem shows) and 1 is short (only half the stem shows).  We want the plant to be long, so put a 0 in for bit 2 as well.  We can do the same thing for bits 3, 4, and 5, and we'll find them all to be zeroes.  Bits 6 and 7 don't matter, so we'll leave them as 0 as well.  The final result is the binary number 00000000, which translates into hex as 00.  To make the sprite act like a "plain old Piranha Plant", just leave the extra byte as 00.  That's easy enough, but what about something more complex? How about an upside-down short-stemmed Venus Fire Trap that spits two fireballs? Well...bit 0 is the direction, and since we want the sprite to go down this time, we put a 1 here.

76543210
xxxxxxx1

Bit 1 is the orientation, and the sprite is still vertical, so a 0 goes here.

76543210
xxxxxx01

Bit 2 is the stem length, and we want the stem to be short, so a 1 goes here.

76543210
xxxxx101

Then the same goes for bits 3, 4, and 5.  The final result: 00110101.  If you have a calculator handy on whatever OS you run, you can find this number to be equal to 35 in hex.  So for a short-stemmed, 2-fireball-spitting, downward-facing Venus Fire Trap, the extra byte should be set to 35.  Lunar Magic even shows a "35" below the sprite number if you press the 5 key.

Now let's try something slightly more complex: the Timed Lift.  Its settings are thus:

;; Extra bytes: 2
;;
;; Byte 1:
;; Bits 0-3: Amount of time on the sprite.  (Should be 00-09.) Or, if it is a bomber
;; lift, this is the amount of ammo it has.
;; Bits 4-6: Sprite direction.  000 = right, 001 = right-down, 010 = down,
;;	011 = left-down, 100 = left, 101 = left-up, 110 = up, 111 = right-up.
;; Bit 7: Enable alternate movement patterns.  When this is set, bits 4-6 will instead
;;	be 000 = sine wave right, 001 = sine wave left, 010 = unused, 011 = unused,
;;	100 = unused, 101 = unused, 110 = unused, 111 = unused.
;;
;; Byte 2:
;; Bits 0-2: Sprite palette.
;; Bits 3-4: Sprite type.  00 = normal, 01 = manual, 10 = bomber, 11 = falling.
;; Bits 5-6: What happens when the sprite runs out of time/ammo.  00 = fall, 01 = explode,
;;	10 = disappear in smoke, 11 = stop dead in mid-air.
;; Bit 7: Unused.

This time, we have two extra bytes and 15 bits to worry about, and some of the bits are grouped together.  For this reason, you might want to split them into groups, like so:

x xxx xxxx ~ x xx xx xxx

The first group is bits 0-3 of the first extra byte.  How much time should we put on it? Let's go with 5 units.  5 in binary is 101, so let's put that in the first group (with a leading zero to fill out the other bit):

x xxx 0101 ~ x xx xx xxx

Next comes the sprite direction.  We'll make it go left, and the instructions say that 100, or 4, is left, so put 100 in the second group.

x 100 0101 ~ x xx xx xxx

We won't enable alternate movement patterns, so bit 7 will stay a 0.

0 100 0101 ~ x xx xx xxx

That's the first extra byte done, now for the second.  We'll make the sprite use palette B, the blue one.  Of course, it may be palette B in Lunar Magic, but it's really sprite palette 3.  3 in binary is 11, and since the number needs to be three bits long, make it 011.

0 100 0101 ~ x xx xx 011

We'll leave the sprite type as normal.  A manual, bomber, or falling Timed Lift could be entertaining, but it's not necessary.  But just for fun, let's make the sprite explode when its time runs out instead of just falling, shall we? That would make the last three groups 00, 01, and 0, since the last bit isn't used.  The final results are 01000101 for the first extra byte and 00100011 for the second.  Converting those into hexadecimal gives us 45 and 23, so type "4523" into the "Extension" field in Lunar Magic.  Pressing the "5" key here will make the 45 show up, since it is the first extra byte, but the 23 won't.  However, if you hover your mouse over the sprite, the tooltip will say "Extension - 4523".  And lo and behold, when you test the level, you see a Timed Lift with 5 units of time on it that is blue, moves left, and BLOWS UP AND STUFF!

The same things I did here apply to any other sprite.  One last note: You may come across some that use a single extra byte and say that it is an "index to sprite behavior tables" or the like.  This usually means that rather than all of the properties being set by the extra byte, the extra byte is used to index a table or several tables, and these tables determine what the sprite does.  The custom exploding block is one example of that; it uses six different tables to determine which sprite to spawn and how to spawn it, so that would obviously be more options than would fit within the extra bytes.

