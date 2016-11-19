;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Alternate Timed Lift, by imamelia
;;
;; This is a Timed Lift that acts like the original (or, at least, can be made to do so),
;; but has a lot more flexibility and customizability.
;;
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
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlatTilemap:
db $8A,$8A

NumTilemap:
db $BE,$BD,$BC,$BB,$BA,$AE,$AD,$AC,$AB,$AA

XDisp:
db $00,$10,$0C

YDisp:
db $00,$00,$04

TileFlip:
db $00,$40,$00

TileSize:
db $02,$02,$00

!TimeTillDec = $40		; number of frames before the counter decrements

TimeTillDie:			; number of frames the sprite will be out of time before it disappears, explodes, etc.
db $08,$01,$08,$08	; for the four different types

!BombSprNum = $01B0	; the sprite number of the bomb

MoveSpeedIndex:
db $FF,$00,$04,$FF,$02,$01,$03,$02,$06,$07,$05,$06,$FF,$00,$04,$FF
db $FF,$08,$0C,$FF,$0A,$09,$0B,$0A,$0E,$0F,$0D,$0E,$FF,$08,$0C,$FF
; movement speed for the manual and bomber lifts
; yudlr, yudlR, yudLr, yudLR, yuDlr, yuDlR, yuDLr, yuDLR,
; yUdlr, yUdlR, yUdLr, yUdLR, yUDlr, yUDlR, yUDLr, yUDLR
; Yudlr, YudlR, YudLr, YudLR, YuDlr, YuDlR, YuDLr, YuDLR
; YUdlr, YUdlR, YUdLr, YUdLR, YUDlr, YUDlR, YUDLr, YUDLR

MoveSpeedX:
db $10,$10,$00,$F0,$F0,$F0,$00,$10
db $18,$18,$00,$E8,$E8,$E8,$00,$18
;db $08,$08,$00,$F8,$F8,$F8,$00,$08
;db $10,$10,$00,$F0,$F0,$F0,$00,$10
MoveSpeedY:
db $00,$10,$10,$10,$00,$F0,$F0,$F0
db $00,$18,$18,$18,$00,$E8,$E8,$E8
;db $00,$08,$08,$08,$00,$F8,$F8,$F8
;db $00,$10,$10,$10,$00,$F0,$F0,$F0

SineYSpeed:
db $00,$F4,$EA,$E3,$E0,$E3,$EA,$F4 
db $00,$0C,$16,$1D,$20,$1D,$16,$0C
;db $00,$04,$07,$09,$0A,$09,$07,$04
;db $00,$FC,$F9,$F7,$F6,$F7,$F9,$FC

; $C2,x is for the sprite state, where 00 = stationary before activation, 01 = moving,
;	02 = out of time, and 03 = out of time but stationary.
; $1510,x is the sprite type.
; $151C,x is the death animation.
; $1528,x is used by the platform interaction routine.
; $1534,x is used for the timer itself.
; $1540,x is the timer for how long it should explode.
; $1564,x is the time to stay in state 2 before falling, exploding, etc.
; $1570,x is used for the frame counter.
; $157C,x is the sprite direction (or alternate motion index).  This is actually 00-07.
; $160E,x is the frame counter for sine wave motion.
; $187B,x is the index to the sine speed table, 00-0F.
; $7FAB40,x is the first extra byte.
; $7FAB4C,x is the second extra byte.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR TimedLift2Init
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimedLift2Init:

LDA $7FAB40,x	; extra byte 1
AND #$0F		; lower 4 bits
STA $1534,x		; into counter
BNE .NoZeroTime	;
JSR TimeUpInit1	; if the timer is set to 0, make sure to count the sprite as having its time up already
LDA #$03		;
STA $C2,x		;
.NoZeroTime		;
LDA $7FAB40,x	;
LSR #4			; upper 4 bits
AND #$07		; bits 4-6
STA $157C,x		; into sprite direction

LDA $166E,x		;
LSR				; bit 0 of $166E,x into carry
LDA $7FAB4C,x	; extra byte 2
ROL				; x2, plus the GFX page bit
AND #$0F		;
STA $15F6,x		; into sprite palette/GFX page table

LDA $7FAB4C,x	; extra byte 2
AND #$18		; bits 3-4
LSR #3			;
STA $1510,x		; into another misc. table

LDA $7FAB4C,x	; extra byte 2
AND #$60		; bits 5-6
LSR #5			;
STA $151C,x		; into another misc. table

LDA #!TimeTillDec	;
STA $1570,x		;

LDA $D8,x		;
CLC				;
ADC #$02		; Y position +2
STA $1594,x		; this will be the stopping position for the falling platform when it sinks

RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR TimedLift2Main
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimedLift2Main:

LDA $1540,x
BEQ .NotExploding
DEC
BNE .Exploding
STZ $14C8,x
.Return
RTS

.Exploding
PHB
LDA #$02
PHA
PLB
JSL $828086
PLB
JSL $81A7DC
RTS

.NotExploding

JSR TimedLift2GFX

LDA $14C8,x
CMP #$08
BNE .Return
LDA $9D
BNE .Return

JSL !SubOffscreenX0
LDA $1510,x		; sprite type
JSL $8086DF		; pointer routine

dw Normal		; 00 - normal Timed Lift
dw Manual		; 01 - Timed Lift that can be controlled by the player
dw Bomber		; 02 - platform that can drop bombs and has an ammo counter
dw FallingPlat		; 03 - stationary platform that falls (or explodes etc.) when its counter reaches 0

TimeUpJ3:		;
JMP TimeUp		;

;------------------------------------------------
; normal movement
;------------------------------------------------

Normal:

LDA $C2,x		;
BEQ .NoDec		;
CMP #$02		; if the platform has stopped...
BEQ TimeUpJ3		; make it stationary
CMP #$03		; if it has not moved yet...
BNE .State01		; don't decrement the timer
INC $1564,x		; if it is stationary and has the time set to 0, freeze the death timer

.State01			;

LDA $1564,x		; if the timer is up...
BEQ .MaybeDec	; don't decrement any counters		
DEC				; if the "time up" timer is about to run out...
BEQ TimeUpInit2	;
BRA .NoDec		;

.MaybeDec		;

LDA $1570,x		; if the timer has run out...
BEQ .NoDec		; don't decrement it further

DEC $1570,x		; decrement the timer
BNE .NoDec		; if it has run out...

LDA #!TimeTillDec	;
STA $1570,x		; reset it

DEC $1534,x		; and decrement the counter
BEQ TimeUpInit1	;

.NoDec			;

LDA $C2,x		;
CMP #$01		; if the sprite is not moving...
BNE .SkipUpdate	; don't set its speed or update its position

LDA $7FAB40,x	; if bit 7 of the first extra byte is set,
BMI AltMotion		; use the alternate motion routines

LDY $157C,x		; use the direction to index the speed tables
LDA MoveSpeedX,y	;
STA $B6,x		; set the sprite's X speed
LDA MoveSpeedY,y	;
STA $AA,x		; set the sprite's Y speed

.UpdatePosition	;

JSL $81801A		; update sprite Y position without gravity
JSL $818022		; update sprite X position without gravity
STA $1528,x		; set the amount to move the player on the X-axis

.SkipUpdate		;

JSL $81B44F		; invisible solid block routine (used for platform interaction)
BCC .Return		; if there was no contact, return

LDA $C2,x		;
BEQ .IncState		;
CMP #$03		;
BEQ .IncState		; if the sprite state is 00 or 03...

.Return			;
RTS				;

.IncState			;
LDA #$01		;
STA $C2,x		; make the sprite start moving
RTS				;

AltMotion:		;

PEA.w Normal_UpdatePosition-1	;
LDA $157C,x					;
JSL $8086DF					;

dw Alt00_SineWaveR		; 00 - sine wave right
dw Alt01_SineWaveL		; 01 - sine wave left
dw TimedLift2Main_Return	; 02 - unused
dw TimedLift2Main_Return	; 03 - unused
dw TimedLift2Main_Return	; 04 - unused
dw TimedLift2Main_Return	; 05 - unused
dw TimedLift2Main_Return	; 06 - unused
dw TimedLift2Main_Return	; 07 - unused

TimeUpInit1:		;

LDY $1510,x		;
LDA TimeTillDie,y	;
STA $1564,x		;
STZ $1570,x		;
RTS				;

TimeUpInit2:		;

INC $C2,x		; sprite state = 02

TimeUp:			;

STZ $1570,x		;
LDA $151C,x		; death animation style
JSL $8086DF		;

dw PlatformFalls	; 00 - fall
dw Explode		; 01 - explode
dw Poof			; 02 - disappear in smoke
dw Stationary		; 03 - nothing (just remain stationary)

PlatformFalls:		;

JSL $81802A		; update sprite position with gravity

LDA $1491		; amount to move the player
STA $1528,x		;

JSL $81B44F		;

RTS				;

Explode:			;

LDA #$09		;
STA $1DFC		;

LDA $1686,x		;
AND #$F7		;
STA $1686,x		;

LDA $167A,x		;
AND #$7F		;
STA $167A,x		;

LDA #$40		;
STA $1540,x		; set the time to show the explosion

PHB				; preserve data bank
LDA #$82		;
PHA				; set data bank to 02
PLB				;
JSL $828086		; explode bomb subroutine
PLB				;
RTS				;

Poof:			;

JSR SubSmoke		;
STZ $14C8,x		;
RTS				;

Stationary:		;

STZ $1528,x		;
JSL $81B44F		;
RTS				;

SubSmoke:

LDY #$03
.Loop
LDA $17C0,y
BEQ .MakeSmoke
DEY
BPL .Loop
RTS

.MakeSmoke
LDA #$01
STA $17C0,y
LDA $D8,x
STA $17C4,y
LDA $E4,x
CLC
ADC #$08
STA $17C8,y
LDA #$1B
STA $17CC,y
RTS

;------------------------------------------------
; manual movement
;------------------------------------------------

Manual:

LDA $C2,x		;
CMP #$02		; if the platform has stopped...
BEQ TimeUpJ		; make it stationary
CMP #$01		; if it has not moved yet...
BNE CheckContact	; check to see if the player is in contact with the platform

PEI ($94)			;
JSL $81B44F		; check for contact between the sprite and the player
PLA				;
STA $94			;
PLA				;
STA $95			;
BCC .NoControl	;

JSR ControlPlat		;

.NoControl		;
LDA $1570,x		; if the timer has run out...
BEQ .NoDec		; don't decrement it further

DEC $1570,x		; decrement the timer
BNE .NoDec		; if it has run out...

LDA #!TimeTillDec	;
STA $1570,x		; reset it

DEC $1534,x		; and decrement the counter
BEQ TimeUpInit3	;

.NoDec			;
RTS				;

ControlPlat:			;

LDA $15				;
ORA $17				;
AND #$40			; get the Y/X button status
LSR #2				;
STA $00				; into scratch RAM

LDA $15				;
AND #$0F			; up/down/left/right button status
ORA $00				; ORA the Y button status
TAY					; -> speed index

LDA MoveSpeedIndex,y	; get an index for the actual speed
CMP #$FF			; if the value is FF...
BEQ .Return			; then the sprite does not move
TAY					; else, transfer *that* to Y

LDA MoveSpeedX,y		;
STA $B6,x			; set the sprite's X speed
STA $7B				;
LDA MoveSpeedY,y		;
STA $AA,x			; set the sprite's Y speed
STZ $13E0			;
STZ $13DB			;

JSL $81801A			; update sprite Y position without gravity
JSL $818022			; update sprite X position without gravity

;LDA $1491			; the amount the sprite has moved
;STA $1528,x			; amount to move the player

JSL $81B44F			;

.Return				;
RTS					;

CheckContact:			;

JSL $81B44F		;
BCC .Return		;
INC $C2,x		;
.Return			;
RTS				;

TimeUpInit3:		;
INC $C2,x		;

TimeUpJ:			;
JMP TimeUp		;

;------------------------------------------------
; bomber lift
;------------------------------------------------

Bomber:

LDA $C2,x			; check the sprite state
CMP #$02			; if the sprite is out of time...
BEQ TimeUpJ			; then make it fall/explode/etc.
CMP #$01			; if the player is on the platform...
BNE CheckContact		;

PEI ($94)				;
JSL $81B44F			; check for contact between the sprite and the player
PLA					;
STA $94				;
PLA					;
STA $95				;
BCC .Return			; return if the player is not on the platform

JSR ControlPlat			;

LDA $1534,x			;
BEQ .Return			;

LDA $16				;
ORA $18				;
AND #$40			; if the player just pressed Y or X...
BEQ .Return			;

JSR DropBomb			; make the platform drop a bomb

DEC $1534,x			; decrement the ammo counter
BNE .Return			; if the counter is at 0...

STZ $1570,x			;
INC $C2,x			;

.Return				;
RTS					;

;------------------------------------------------
; falling platform
;------------------------------------------------

FallingPlat:			;

LDA $C2,x			;
CMP #$02			;
BEQ TimeUpJ2			;

JSL $81B44F			; check contact with the player
BCC .NoContact		; return if there is none

LDA $D8,x			;
CMP $1594,x			; if the sprite is at its low point...
BEQ .Return			; don't let it sink any more

LDA #$0C			;
STA $AA,x			; make the sprite move downward
JSL $81801A			; update sprite Y position without gravity

.Return				;
RTS					;

.NoContact			;

LDA $D8,x			;
CMP $1594,x			; if the sprite is still at its low point...
BNE .NoDec			;

DEC $1534,x			;
BEQ TimeUpInit4		;

.NoDec				;

CLC					;
ADC #$02			; if the sprite is at its high point...
CMP $1594,x			;
BEQ .Return2			; don't let it rise any more

LDA #$F4				;
STA $AA,x			; make the sprite move upward
JSL $81801A			; update sprite Y position without gravity

.Return2				;
RTS					;

TimeUpInit4:			;
LDA #$02			;
STA $C2,x			;

TimeUpJ2:			;
JMP TimeUp			;

;------------------------------------------------
; alternate motion routines
;------------------------------------------------

Alt00_SineWaveR:

LDA #$10			; sprite X speed = 10
BRA SineShared		;

Alt01_SineWaveL:

LDA #$F0				; sprite X speed = F0

SineShared:			;

STA $B6,x			; set the sprite's X speed
INC $160E,x			; increment the frame counter for the sine speed index
LDA $160E,x			;
LSR #3				; frame counter / 8
AND #$0F			;
TAY					;
LDA SineYSpeed,y		; Y speed for sine wave
STA $AA,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimedLift2GFX:

JSL !GetDrawInfo		; set up some variables in preparation for drawing

LDY $1534,x			; take the counter...
LDA NumTilemap,y		; load the number tiles depending on the counter
STA $02				; save the number tile in $02

LDA $15F6,x			;
ORA $64				; save the palette/GFX page/priority settings
STA $03				; in scratch RAM

LDY $15EA,x			; load the OAM index back into Y

LDA #$02			; if we're drawing the number tile, X = 02
STA $04				;
LDA $C2,x			;
CMP #$02			;
BEQ .NoNumTile		;
LDA $1564,x			; if the timer has run out, but the platform has not yet "died"...
BEQ .LoadTileNum		;
.NoNumTile			;
DEC $04				; then X = 01 (the number tile will not be drawn)

.LoadTileNum			;

LDX $04				;

GFXLoop:				;

LDA $00				; base X position
CLC					;
ADC XDisp,x			; add the X displacement
STA $0300,y			;

LDA $01				; base Y position
CLC					;
ADC YDisp,x			; add the Y displacement
STA $0301,y			;

LDA PlatTilemap,x		; tilemap of the platform
CPX #$02				; if we're drawing the number tile...
BNE .StoreTile			;
LDA $02				; load that instead
.StoreTile				;
STA $0302,y			; set the tile number

LDA TileFlip,x			; X-flip of the tiles
ORA $03				; plus sprite priority setting, palette, and GFX page
STA $0303,y			; tile properties

PHY					; preserve the sprite OAM index
TYA					;
LSR #2				; divide the OAM index by 4
TAY					;

LDA TileSize,x			; set the size of the tile (8x8 or 16x16)
STA $0460,y			; tile size table for OAM

PLY					;

INY #4				; increment Y 4 times to get to the next OAM slot
DEX					; decrement the tile index
BPL GFXLoop			; if positive, there are more tiles to draw

LDX $15E9			;
LDY #$FF				; Y = FF, since we already set the tile size
LDA $04				; $04 = tiles drawn - 1 (either 01 or 02)
JSL $81B7B3			; finish the write to OAM
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite-spawning routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DropBomb:

JSL $82A9E4
BMI .Return

LDA #$01
STA $14C8,y

PHX
TYX
LDA.b #!BombSprNum
STA $7FAB9E,x
LDA.b #!BombSprNum>>8
ORA #$80
STA $7FAB10,x
JSL $81830B
PLX

LDA $E4,x
STA $00E4,y
LDA $14E0,x
STA $14E0,y
LDA $D8,x
CLC
ADC #$0C
STA $00D8,y
LDA $14D4,x
ADC #$00
STA $14D4,y

.Return
RTS



dl Init,Main