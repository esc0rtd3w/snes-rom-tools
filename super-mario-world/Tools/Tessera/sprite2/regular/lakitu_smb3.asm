;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB3 Lakitu, by imamelia
;;
;; This is a Lakitu that acts like the one in Super Mario Bros. 3.
;;
;; Uses extra property bytes: YES
;;
;; Bit 0 of the extra property byte 1 determines whether it will be a normal Lakitu
;; or a boss version.  The normal one requires 2 extra bytes, while the boss requires
;; 3 extra bytes.
;;
;; Extra bytes: 2 or 3
;;
;; Extra byte 1:
;;
;; Bits 0-7: Index to sprite settings tables.
;;
;; Extra byte 2:
;;
;; Bits 0-3: Unused.
;; Bits 4-6: Throw timer settings, table offset.
;; Bit 7: 0 -> spawn a single sprite, 1 -> spawn sprites randomly from a table.
;;
;; Extra byte 3:
;;
;; Bits 0-3: What to do when the boss is defeated (chosen from a pointer table).
;; Bits 4-7: Boss HP.
;;
;; Sprite table info:
;;
;; $1504,x - Boss defeated pointer index.
;; $1510,x - Spawned sprite table index.
;; $1528,x - Boss HP.
;; $1534,x - Throw timer table reset value.
;; $1540,x - Hurt timer.
;; $1558,x - "Boss defeated" timer.
;; $1570,x - Frame counter.
;; $157C,x - Movement direction.
;; $1594,x - Timer for ducking down to throw.
;; $1602,x - Animation frame.
;; $160E,x - Flags.
;;	- Bit 0 - decelerating
;;	- Bits 1-6 - unused
;;	- Bit 7 - spawn sprites randomly
;; $163E,x - Throw timer.
;; $187B,x - Throw timer state (index to tables).
;; $1FD6,x - Y displacement of the head
;;
;; Other relevant RAM addresses:
;;
;; $7FAB88-$7FAB89 - In the respawning routine, the (custom) sprite number to respawn.
;; $7FAB8A-$7FAB8B - In the respawning routine, the X position of the sprite when it respawns.
;; $7FAB8C-$7FAB8F - In the respawning routine, the four extra bytes of the respawning sprite.
;;	(The last two are not used here, because the boss version does not respawn and the regular
;;	version uses only 2 extra bytes.)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TimeTillRespawn = $FF	; after the non-boss Lakitu is defeated, number of frames that will pass before it respawns
!TimeToStun = $30		; how long the boss version will be stunned after being hit (also the number of frames that
					; will pass between the boss version losing its last hit and a "defeated" subroutine activating)
!Boundary = $30		; how far away from the player the sprite has to be before it will slow down and reverse direction

!HeadTile = $80		;
!CloudTile = $A0		;
!HurtCloudTile = $A2	;

YDisp:
db $00,$01,$02,$03,$04,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$04,$03
db $02,$01

!PaletteTop = $05		; palette and GFX page
!PaletteBottom = $03	; of the two tiles

; palettes to flash when the boss version is hit (top, bottom)
FlashPalettes1:
db $05,$09,$05,$09,$05,$09,$05,$09
FlashPalettes2:
db $03,$03,$03,$03,$03,$03,$03,$03

ThrowTimerPtrs:		;
dw ThrowTimerTbl1,ThrowTimerTbl2,ThrowTimerTbl3,ThrowTimerTbl4
dw ThrowTimerTbl5,ThrowTimerTbl6,ThrowTimerTbl7,ThrowTimerTbl8

; For each of these tables, the first number is how many sprites
; the Lakitu will throw before the pattern repeats.  The rest are the timers
; between each throw.
ThrowTimerTbl1:
db $01 : db $60
ThrowTimerTbl2:
db $02 : db $60,$F0
ThrowTimerTbl3:
db $03 : db $60,$60,$F0
ThrowTimerTbl4:
db $04 : db $60,$60,$60,$F0
ThrowTimerTbl5:
db $04 : db $40,$60,$80,$A0
ThrowTimerTbl6:
db $04 : db $40,$40,$60,$80
ThrowTimerTbl7:
db $03 : db $20,$20,$60
ThrowTimerTbl8:
db $01 : db $A0

XSpeed:				;
db $1A,$E6			; sprite X speed for right and left

IncDecTbl:			;
db $01,$FF			; amount to decrement the sprite's speed when it is slowing down to reverse direction

MinSpeed:			;
db $03,$FD			;

NewSpeed:			;
db $FD,$03			; speed to set the sprite to after reversing direction

KilledXSpeed:
db $10,$F0

StarSounds:
db $13,$14,$15,$16,$17,$18,$19

; Bits 0-1: High byte of the sprite number, if custom.
; Bits 2-6: Unused.
; Bit 7: Normal/custom sprite.  0 -> normal, 1 -> custom.
SpawnProperties:
db $00,$00,$81,$81,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite number (low byte of the sprite number if custom)
SpawnNumber:
db $14,$0D,$B0,$B3,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite status
SpawnStatus:
db $08,$01,$08,$08,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; first extra byte of the spawned sprite
SpawnedEB1:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; second extra byte of the spawned sprite
SpawnedEB2:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; third extra byte of the spawned sprite
SpawnedEB3:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; fourth extra byte of the spawned sprite
SpawnedEB4:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

SpawnedXSpeed:
db $10,$F0

RandomThrowPtrs:
dw RandomTbl1,RandomTbl2,RandomTbl3,RandomTbl4
dw RandomTbl5,RandomTbl6,RandomTbl7,RandomTbl8

RandomTbl1:
RandomTbl2:
RandomTbl3:
RandomTbl4:
RandomTbl5:
RandomTbl6:
RandomTbl7:
RandomTbl8:
db $03 : db $00,$02,$03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		;
STA $1510,x			; sprite table index

LDA $7FAB4C,x		;
STA $00				;
AND #$70			; bits 4-6 - throw timer table index
LSR #3				;
TAY					;
REP #$20				;
LDA ThrowTimerPtrs,y	;
STA $02				;
SEP #$20				;
LDA ($02)			;
STA $1534,x			;
LDY #$01				;
LDA ($02),y			;
STA $163E,x			;
LDA $00				;
AND #$80			; bit 7 -  single/random sprite flag
STA $160E,x			;

LDA $7FAB58,x		;
PHA					;
AND #$0F			; bits 0-3 - "boss defeated" routine index
STA $1504,x			;
PLA					;
LSR #4				; bits 4-7 - boss HP
STA $1528,x			;

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR SMB3LakituMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReturnMain:			;
RTS					;

SMB3LakituMain:

JSR SMB3LakituGFX		;

LDA $14C8,x			;
CMP #$08			;
BNE ReturnMain		;
LDA $9D				;
BNE ReturnMain		;

JSR HandleOffscreen	;

INC $1570,x			;

JSR InteractP			;
JSR InteractS			;

LDA $1540,x			; if the sprite has just been hit...
BEQ .NoDisableSpeed	;
LDA $1528,x			; and its HP is down to 0...
BEQ .NoSpeed			; don't set its speed or update its position

.NoDisableSpeed		;
LDA $160E,x			;
BIT #$01				; if the sprite is already slowing down...
BNE .Decelerate		;
BIT #$02				; or is speeding back up...
BNE .Accelerate		; skip this check
LDY $157C,x			;
LDA XSpeed,y			; set the sprite's X speed
STA $B6,x			;

JSL !SubHorizPos		; check which side of the player the sprite is on
TYA					;
CMP $157C,x			; if the sprite is moving toward the player...
BEQ .SetSpeed			; skip the check
LDA $0F				; player X position minus sprite X position
BPL .NoInvert			;
EOR #$FF				;
INC					;
.NoInvert				;
CMP #!Boundary		; if the sprite is outside the boundary area...
BCC .SetSpeed			;
LDA $160E,x			; then set the "slowing down" flag
ORA #$01			;
STA $160E,x			;
BRA .SetSpeed			;

.Decelerate			;
;LDA $14				;
;AND #$00			;
;BNE .SetSpeed			;
LDY $157C,x			;
LDA $B6,x			;
SEC					;
SBC IncDecTbl,y		; decrement the sprite's X speed
STA $B6,x			;
CMP MinSpeed,y		;
BNE .SetSpeed			; if it has reached minimum...
LDA $160E,x			;
EOR #$03				; then clear the "slowing down" flag and set the "speeding up" flag
STA $160E,x			;
LDA $157C,x			;
EOR #$01				; and flip the sprite's direction
STA $157C,x			;
LDA NewSpeed,y		;
STA $B6,x			;
BRA .SetSpeed			;

.Accelerate			;
LDY $157C,x			;
LDA $B6,x			;
CLC					;
ADC IncDecTbl,y		; decrement the sprite's X speed
STA $B6,x			;
CMP XSpeed,y			;
BNE .SetSpeed			; if it has reached normal speed...
LDA $160E,x			;
AND #$FD			; then clear the "speeding up" flag
STA $160E,x			;

.SetSpeed				;
JSL $818022			; update sprite X position without gravity

.NoSpeed				;

LDA $1570,x			;
LSR #3				;
AND #$01			; set the animation frame
STA $1602,x			;

LDA $163E,x			; if the Lakitu is about to throw a sprite...
BNE .NoThrowFrame	;
INC $1594,x			;
LDA $1594,x			;
CMP #$16			;
BNE .NoThrowSprite		;
JSR ThrowSprite		; then make the Lakitu throw a sprite
.NoThrowSprite		;
LDA $1594,x			;
CMP #$24			;
BCC .NoResetThrow		;
JSR ResetThrowTimer	;
.NoResetThrow		;
LDA $1594,x			;
LSR					;
STA $1602,x			;
.NoThrowFrame		;

LDA $7FAB28,x		;
AND #$01			; if the sprite is the boss version...
BEQ .Return			; then it has special handling for when it runs out of HP

LDA $1528,x			; if the sprite is out of HP...
ORA $1540,x			; and the stun timer is up...
BNE .Return			;

STZ $14C8,x			; erase the sprite

JSR SubSmoke			; create smoke at its position

LDA $1504,x			; and execute a specified routine
JSL $8086DF			;

dw .Return			; 0 - nothing
dw EndLevelN			; 1 - end the level, set normal exit
dw EndLevelS			; 2 - end the level, set secret exit (doesn't work in vertical levels)
dw SetScroll			; 3 - (re)enable horizontal and vertical scrolling
dw SwitchOnOff		; 4 - switch the On/Off switch
dw DefeatRoutine5		; 5 - available for custom use
dw DefeatRoutine6		; 6 - available for custom use
dw DefeatRoutine7		; 7 - available for custom use
dw DefeatRoutine8		; 8 - available for custom use
dw DefeatRoutine9		; 9 - available for custom use
dw DefeatRoutineA		; A - available for custom use
dw DefeatRoutineB		; B - available for custom use
dw DefeatRoutineC		; C - available for custom use
dw DefeatRoutineD		; D - available for custom use
dw DefeatRoutineE		; E - available for custom use
dw DefeatRoutineF		; F - available for custom use

.Return				;
RTS					;

EndLevelN:			;

LDA #$00
BRA EndLevelShared	

EndLevelS:

LDA #$01

EndLevelShared:
STA $141C
STA $13CE
LDA #$FF
STA $1493
STA $0DDA
DEC $13C6
LDA #$0B
STA $1DFB
RTS

SetScroll:

INC $1411
INC $1412
RTS

SwitchOnOff:

LDA $14AF
EOR #$01
STA $14AF
RTS

DefeatRoutine5:
DefeatRoutine6:
DefeatRoutine7:
DefeatRoutine8:
DefeatRoutine9:
DefeatRoutineA:
DefeatRoutineB:
DefeatRoutineC:
DefeatRoutineD:
DefeatRoutineE:
DefeatRoutineF:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SMB3LakituGFX:

JSL !GetDrawInfo		;

LDA $00				;
STA $0304,y			; no X displacement for either tile
STA $0300,y			;

LDA $7FAB28,x		;
AND #$01			; if the sprite is a boss version...
BEQ .NotDefeated		;
LDA $1528,x			; and its HP is down to 0...
BNE .NotDefeated		; then its frame is always 0
STZ $1602,x			;
.NotDefeated			;

LDA $1602,x			;
TAX					;
LDA.w YDisp,x		;
LDX $15E9			;
STA $1FD6,x			;
CLC					;
ADC $01				;
STA $0305,y			; no Y displacement for the first tile
LDA $01				;
CLC					;
ADC #$10			;
STA $0301,y			; 16 pixels for the second

LDA #!HeadTile		; tile number of the first tile
STA $0306,y			;
LDA #!CloudTile		; tile number of the second tile
STA $0302,y			;

LDA #!PaletteTop		; palette and GFX page of the first tile
ORA $64				;
STA $0307,y			;
LDA #!PaletteBottom	; palette and GFX page of the second tile
ORA $64				;
STA $0303,y			;

LDA $1540,x			; if the boss version has been hit...
BEQ .NoHurtFrame		;
LSR #2				;
AND #$07			; then use the hurt timer as an index
TAX					; to the palette tables
LDA.w FlashPalettes1,x	;
ORA $64				;
STA $0307,y			;
LDA.w FlashPalettes2,x	;
ORA $64				;
STA $0303,y			;
LDA #!HurtCloudTile	;
STA $0302,y			;
LDX $15E9			;
.NoHurtFrame			;

LDY #$02				;
LDA #$01			;
JSL $81B7B3			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; supporting subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; player/sprite interaction
;------------------------------------------------

InteractP:

JSL $83B664			;
JSR SetSpriteClipping	;
JSL $83B72B			; check for contact between the player and the sprite
BCC .Return			; return if there is none

LDA $1490			; if the player has a star...
BNE HasStar			;

JSL !SubVertPos		; get the vertical distance between the player and the sprite
LDA #$E6				;
CLC					;
ADC $1FD6,x			;
STA $00				;
LDA $0E				;
CMP $00				; if there is vertical contact and the player is not above the sprite...
BPL SpriteWins			; then the sprite damages the player

JSL $81AA33			; set bounce-off speed
JSL $81AB99			; display contact GFX
LDA $1540,x			; if the sprite is still flashing...
BNE .BounceOff		; don't make it get hit
JSR SubStompPoints		;
LDA $7FAB28,x		;
AND #$01			; if the sprite is the boss version...
BNE .NoSpinKill		; then it cannot be spin-killed
LDA $140D			; check the spin-jump flag
ORA $187A			;
BNE SpinKill			; and make the sprite spin-killed if it is set
.NoSpinKill			;
JSR HitSprite			;
.Return				;
RTS					;

.BounceOff			;
LDA #$02			;
STA $1DF9			;
RTS					;

SpriteWins:			;

LDA $154C,x			; if interaction is disabled...
ORA $15D0,x			; or the sprite is being eaten...
BNE .Return			; then don't damage the player

JSL $80F5B7			; player hurt routine

.Return				;
RTS					;

SpinKill:

JSR SubStompPoints		;
LDA #$F8				;
STA $7D				; set the player's bounce-off Y speed
JSL $81AB99			; show contact graphic
LDA #$04			;
STA $14C8,x			;
JSR RespawnSet		;
LDA #$1F				;
STA $1540,x			; set the spin-jump animation timer
JSL $87FC3B			; show the spin-jump stars
LDA #$08			;
STA $1DF9			; play a sound effect
RTS					;

HasStar:

JSR HitSprite			;
LDA #$D0			;
STA $AA,x			; set the death Y speed

JSL !SubHorizPos		;

LDA KilledXSpeed,y		; set the death X speed
STA $B6,x			;

INC $18D2			; increment the number of consecutive enemies killed
LDA $18D2			;
CMP #$08			; if the counter has reached 8...
BCC .NoReset			;
LDA #$08			;
STA $18D2			; keep it at 8
.NoReset				;

JSL $82ACE5			; give points

LDY $18D2			;
CPY #$08				; unless the counter is 08 or higher...
BCS .NoSound			;
LDA StarSounds-1,y	; play a sound effect for the star kill
STA $1DF9			;
.NoSound				;
RTS					;

;------------------------------------------------
; stomp points routine
;------------------------------------------------

SubStompPoints:

PHY
INC $1697
LDY $1697
CPY #$08
BCS NoSound3
LDA StarSounds,y
STA $1DF9
NoSound3:
TYA
CMP #$08
BCC NoReset3
LDA #$08
NoReset3:
JSL $82ACE5
PLY
RTS

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:	; custom sprite clipping routine, based off $03B69F

LDA $1FD6,x		;
STA $0C			;
LDA $E4,x		;
CLC				;
ADC #$01		;
STA $04			; $04 = sprite X position low byte + X displacement value
LDA $14E0,x		;
ADC #$00		;
STA $0A			; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDA #$0E			;
STA $06			; $06 = sprite clipping width
LDA $D8,x		;
INC				;
INC				;
CLC				;
ADC $0C			;
STA $05			; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x		;
ADC #$00		;
STA $0B			; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA #$1C		;
SEC				;
SBC $0C			;
STA $07			; $07 = sprite clipping height
RTS				;

;------------------------------------------------
; check if the player is touching the sprite
;------------------------------------------------

CheckForContact:	;

PHX				;
LDX #$01			;

.Loop			;

LDA $04,x		;
SEC				;
SBC $00,x		;
CLC				;
ADC $06,x		;
STA $0F			;
LDA $02,x		;
CLC				;
ADC $06,x		;
CMP $0F			;
BCC .EndLoop		;
DEX				;
BPL .Loop			;

.EndLoop			;
PLX				;
RTS				;

;------------------------------------------------
; sprite/sprite interaction
;------------------------------------------------

InteractS:

LDY #$0B				; 12 sprite slots to loop through
.Loop				;
CPY $15E9			; if the sprite is the current sprite...
BEQ .NextSprite		; don't process interaction
LDA $14C8,y			;
CMP #$0A			; if the sprite is thrown (or carried)...
BCS .ProcessSprite		; process its interaction
CMP #$09			; if the sprite is stunned...
BNE .NextSprite		; process its interaction only if it is moving upward
LDA $00AA,y			;
BMI .ProcessSprite		;
.NextSprite			;
DEY					; otherwise, go to next sprite slot and loop
BPL .Loop				;
RTS 					;

.ProcessSprite			;
PHX					; push current sprite index
TYX					; get the new sprite's index into X
JSL $83B6E5			; get sprite clipping B routine
PLX					; X back to old sprite index
JSL $83B69F			; get sprite clipping A routine
JSL $83B72B			; check for contact routine
BCC .NextSprite		; if the code continues past this point, then there is contact

LDA $7FAB28,x		;
AND #$01			; if the sprite is the boss version...
BEQ NormalHit			; then decrement its HP

PHX					;
TYX					;
STZ $14C8,x			; erase the thrown sprite
JSR SubSmoke			;
PLX					;

HitSprite:				;

LDA $7FAB28,x		;
AND #$01			; if the sprite is the boss version...
BNE DecBossHP		; then decrement its HP

NormalHit:			;
LDA	#$02			;
STA $14C8,x			; else, just set the new sprite status (02, falling offscreen)
JSR SubStompPoints		;
JMP RespawnSet		; and set its respawn timer

DecBossHP:			;
DEC $1528,x			; decrement the boss's HP
LDA #!TimeToStun		;
STA $1540,x			; set the time to flash palettes
LDA #$28			;
STA $1DFC			; play the "boss hit" sound effect
RTS					;

;------------------------------------------------
; sprite-spawning routine
;------------------------------------------------

ThrowReturn:			;
RTS					;

ThrowSprite:

JSL $82A9E4			;
BMI ThrowReturn		;

STY $00				; $00 - spawned sprite index
LDA $7FAB40,x		;
STA $01				; $01 - index to sprite spawn tables

LDA $160E,x			; if the "random spawn" flag is set...
BPL .NoRandom		; spawn sprites randomly

LDA $01				; random pointer index
REP #$20				;
ASL					; x2 (16-bit pointers)
AND #$01FF			;
TAY					;
LDA RandomThrowPtrs,y	;
STA $02				; $02-$03 - pointer to random tables
SEP #$20				;
LDA ($02)			; the first byte is the range of numbers, 00 to (X)
STA $00				;
JSL !RandomNumGen	;
INC					; add 1 to the result, because the rest of the data starts at index 1
TAY					; into Y to index the tables
LDA ($02),y			;
STA $01				; set the new spawn table index
LDY $00				; and load the spawned sprite index back into Y

.NoRandom			;

JSR SpawnShared		;

LDY $01				;
LDA SpawnProperties,y	; if bit 7 of the property table is set...
BMI .SpawnCustom		; spawn a custom sprite

LDA SpawnNumber,y	; sprite number to spawn
PHX					; preserve the index of the spawner
LDX $00				; and put the spawned sprite index into X
STA $9E,x			;
JSL $87F7D2			; for the initialization routine
BRA .EndSpawn		;

.SpawnCustom			;
AND #$03			; A still has the byte from the property table
PHX					; preserve the index of the spawner
ORA #$80			;
LDX $00				; spawned sprite index into X
STA $7FAB10,x		; custom sprite number high byte
LDA SpawnNumber,y	;
STA $7FAB9E,x		; custom sprite number low byte
JSL $81830B			; for the initialization routine
LDA SpawnedEB1,y		;
STA $7FAB40,x		; first extra byte
LDA SpawnedEB2,y		;
STA $7FAB4C,x		; second extra byte
LDA SpawnedEB3,y		;
STA $7FAB58,x		; third extra byte
LDA SpawnedEB4,y		;
STA $7FAB64,x		; fourth extra byte

.EndSpawn			;
PHX					;
LDX $15E9			;
JSL !SubHorizPos		; set the X speed of the spawned sprite
LDA SpawnedXSpeed,y	; depending on which side the player is on
PLX					;
STA $B6,x			;
LDA #$D8			;
STA $AA,x			;
PLX					;
RTS					;

SpawnShared:			;

LDA $E4,x
STA $00E4,y
LDA $D8,x
STA $00D8,y
LDA $14E0,x
STA $14E0,y
LDA $14D4,x
STA $14D4,y

LDY $01
LDA SpawnStatus,y
LDY $00
STA $14C8,y

RTS

;------------------------------------------------
; code to set variables for respawning
;------------------------------------------------

RespawnSet:

LDA #!TimeTillRespawn	;
STA $18C0			; time until the sprite respawns
LDA #$FF				;
STA $18C1			; this is a custom sprite, so set $18C1 to FF

LDA $7FAB9E,x		;
STA $7FAB88			; set the sprite number to respawn
LDA $7FAB10,x		;
STA $7FAB89			;

LDA #$E0				;
STA $7FAB8A			; set the X position of the sprite when it respawns
LDA #$FF				;
STA $7FAB8B			;

LDA $D8,x			;
STA $18C3			; set the Y position of the sprite when it respawns
LDA $14D4,x			;
STA $18C4			;

LDA $7FAB40,x		;
STA $7FAB8C			; set the extra bytes
LDA $7FAB4C,x		;
STA $7FAB8D			;

RTS					;

;------------------------------------------------
; code to reset the throw timer
;------------------------------------------------

ResetThrowTimer:

STZ $1594,x			;
LDA $7FAB4C,x		;
AND #$70			;
LSR #3				;
TAY					;
REP #$20				;
LDA ThrowTimerPtrs,y	;
STA $00				;
SEP #$20				;
LDY $187B,x			;
INY					;
LDA ($00),y			;
STA $163E,x			;
INC $187B,x			;
LDA $187B,x			;
CMP $1534,x			;
BCC .Return			;
STZ $187B,x			;
.Return				;
RTS					;

;------------------------------------------------
; offscreen handling
;------------------------------------------------

HandleOffscreen:

LDA $E4,x			;
STA $00				;
LDA $14E0,x			;
STA $01				;
REP #$20				;
LDA $1A				;
SEC					;
SBC $00				; if the sprite is too far offscreen, set its position to just beyond the screen boundary
BMI .RightOfScreen		; (this is to prevent the player "outrunning" the sprite)
CMP.w #$0020			;
BCC .NoShift			;
LDA $1A				;
SEC					;
SBC.w #$001F			;
SEP #$20				;
STA $E4,x			;
XBA					;
STA $14E0,x			;
RTS					;
.NoShift				;
SEP #$20				;
RTS					;

.RightOfScreen			;
CMP #$FEE0			;
BCS .NoShift			;
LDA $1A				;
CLC					;
ADC.w #$011F			;
SEP #$20				;
STA $E4,x			;
XBA					;
STA $14E0,x			;
RTS					;


;------------------------------------------------
; smoke routine
;------------------------------------------------

SubSmoke:

PHY
LDY #$03
.FindFree
LDA $17C0,y
BEQ .FoundOne
DEY
BPL .FindFree
PLY
RTS

.FoundOne

LDA #$01
STA $17C0,y
LDA $D8,x
STA $17C4,y
LDA $E4,x
STA $17C8,y
LDA #$1B
STA $17CC,y

PLY
RTS

;------------------------------------------------
; 
;------------------------------------------------




dl Init,Main
