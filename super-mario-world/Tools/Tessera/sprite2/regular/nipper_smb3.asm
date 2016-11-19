;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB3 Nipper, by imamelia
;;
;; This is the Nipper from SMB3.  (Duh.) It is a little plant creature that stays in
;; one place until the player approaches, at which point it jumps into the air and
;; then starts moving around.  It can be found in, for example, 5-1 and 6-5.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bit 0: If this is set, the sprite will spit fireballs, like the Fire-Spitting Nipper
;; at the end of 7-8.  (There is only one of them in the game.)
;; Bits 1-7: Unused.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm	; shared subroutine definition file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StatePointers:

dw Stationary			; 00 - the sprite hasn't jumped yet
dw Waiting			; 01 - the sprite has jumped and is about to move
dw Moving			; 02 - the sprite is moving
dw SpitFire			; 03 - the sprite is spitting fire

!JumpRange = $20		; how close the player has to be to the sprite before it will jump
!JumpSpeed = $C0		; what speed the sprite will use when it jumps
!XSpeed = $0A			; what speed the sprite will use when moving around
!FireRange = $48		; how close the player has to be to the sprite before it will spit fireballs 
!FireWaitTimer = $60	; the Nipper won't spit fireballs when this is nonzero, even if the player is in range
!FireSound = $06		; the sound to play when the sprite is spitting a fireball
!FireSoundBank = $1DFC	; the sound bank this sound will come from
!FireXSpeed = $10		; the X speed to spit the fireball
!FireYSpeed = $DD		; the Y speed to spit the fireball

Tilemap:
db $CC,$CE,$EC,$EE	; closed mouth sideways, open, closed upright, open

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR NipperMain
Init:
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NipperMain:

LDA $14			;
LSR #3			;
AND #$01		;
ORA $160E,x		; make the sprite animate between open and closed frames
STA $1602,x		;

LDA $1540,x		; unless, of course, it is spitting fire,
BEQ NotOpen		; in which case it should always have an open mouth
LDA #$01		;
STA $1602,x		;
NotOpen:			;

JSR NipperGFX

LDA $14C8,x
CMP #$08
BNE Return0
LDA $9D
BNE Return0

JSL !SubOffscreenX0

LDA $C2,x		;
JSR ExecutePointer	; sprite state pointers, yay!

JSL $81802A		; update sprite position
JSL $81803A		; interact with sprites and the player

LDA $1588,x		;
AND #$03		; if the sprite is touching a wall...
BEQ Return0		;
LDA $157C,x		;
EOR #$01			; flip its direction
STA $157C,x		;
LDA $B6,x		; and its X speed
EOR #$FF			;
INC				;
STA $B6,x		;

Return0:
RTS

Stationary:

JSL !SubHorizPos	;
TYA				; make the sprite always face the player
STA $157C,x		;

LDA $1588,x		;
AND #$04		; if the sprite isn't on the ground...
BEQ NoJump1		;

LDA #$10		;
STA $AA,x		;

LDA $7FAB40,x	;
AND #$01		; if bit 0 of the first extra byte is set...
BNE CheckForSpit	; then make the Nipper spit fire instead of jumping

JSR Proximity1		; if the sprite is out of range...
BEQ NoJump1		; don't make it jump

LDA #!JumpSpeed	;
STA $AA,x		; set its jumping speed
LDA #$02		; set the frame to upright
STA $160E,x		;
LDA #$18		;
STA $1570,x		; set the timer for it to wait before moving
INC $C2,x		; set the sprite state to waiting

NoJump1:		;

RTS

CheckForSpit:		;

JSR Proximity2		;
BEQ NoSpit		;

LDA $1558,x		; if the sprite just spat already...
BNE NoSpit		; don't spit any fireballs
LDA #$30		;
STA $1540,x		; fireball timer
LDA #$05		;
STA $1528,x		; fireball counter: 5 fireballs to spit
LDA #$03		;
STA $C2,x		; change the sprite state to spitting
NoSpit:			;
RTS				;

Waiting:			;

LDA $1570,x		; if the wait timer has not run out...
BNE NoMove		; don't start moving
INC $C2,x		;
NoMove:			;

LDA $1588,x		;
AND #$04		; if the sprite is in the air...
BEQ InAir			;
DEC $1570,x		; don't decrement the wait timer
STZ $160E,x		;
InAir:			;

JSL !SubHorizPos	;
TYA				; make the sprite always face the player
STA $157C,x		;

RTS				;

Moving:			;

LDA $1588,x		;
AND #$04		; if the sprite is not on the ground...
BEQ NoClearFrame	; don't set its Y speed

LDA #$EE			;
STA $AA,x		; make the sprite hop a little

LDA #!XSpeed		; give the sprite some X speed
LDY $157C,x		;
BEQ $03			; flip the X speed value if the sprite is facing left
EOR #$FF			;
INC				;
STA $B6,x		;

JSR Proximity1		; if the sprite is out of range...
BEQ NoJump2		; don't make it jump

LDA #!JumpSpeed	;
STA $AA,x		; set its jumping speed
LDA #$02		; set the frame to upright
STA $160E,x		;
BRA NoClearFrame	;

NoJump2:		;

STZ $160E,x		;

NoClearFrame:		;

LDA $14			;
AND #$1F		; every few frames...
BNE NoFace		;
JSL !SubHorizPos	;
TYA				; make the sprite turn to face the player
STA $157C,x		;
NoFace:			;

RTS

SpitFire:			;

LDA $1540,x		; check the spit timer
AND #$07		;
BNE NoSpit2		;

JSR SubFireSpit		; fireball-spawning routine

DEC $1528,x		; decrement the fireball counter
LDA $1540,x		;
BNE NoSpit2		; if the spit timer has reached zero...

LDA #!FireWaitTimer
STA $1558,x		; reset the fire-spit timer
STZ $C2,x		;

NoSpit2:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NipperGFX:

JSL !GetDrawInfo

LDA $157C,x
ROR #3
AND #$40
EOR #$40
STA $02

LDA $00
STA $0300,y

LDA $01
STA $0301,y

PHY
LDY $1602,x
LDA Tilemap,y
PLY
STA $0302,y

LDA $15F6,x
ORA $64
ORA $02
STA $0303,y

LDY #$02
LDA #$01
JSL $01B7B3
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; fire-spitting routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireXOffsetsLo:
db $06,$FA
FireXOffsetsHi:
db $00,$FF
!FireYOffsetLo = $03
!FireYOffsetHi = $00

SubFireSpit:

LDY #$07
ExSpriteLoop:
LDA $170B,y
BEQ FoundExSlot
DEY
BPL ExSpriteLoop
RTS

FoundExSlot:

LDA #$0B
STA $170B,y

LDA $E4,x
PHY
LDY $157C,x
CLC
ADC FireXOffsetsLo,y
PLY
STA $171F,y
LDA $14E0,x
PHY
LDY $157C,x
ADC FireXOffsetsHi,y
PLY
STA $1733,y

LDA $D8,x
CLC
ADC #!FireYOffsetLo
STA $1715,y
LDA $14D4,x
ADC #!FireYOffsetHi
STA $1729,y

LDA #!FireXSpeed
PHY
LDY $157C,x
BEQ $03
EOR #$FF
INC
PLY
STA $1747,y
LDA #!FireYSpeed
STA $173D,y

LDA #$FF
STA $176F,y

LDA #!FireSound
STA !FireSoundBank

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; miscellaneous subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExecutePointer:	;

PHX				;
ASL				;
TAX				;
REP #$20			;
LDA StatePointers,x	;
STA $00			;
SEP #$20			;
PLX				;
JMP ($0000)		;

Proximity1:		;

LDA #!JumpRange	;
BRA StoreRange	;

Proximity2:		;

LDA #!FireRange	;

StoreRange:		;

STA $0A

ProximityMain:	;

LDA $14E0,x		; sprite X position high byte
XBA				; into high byte of A
LDA $E4,x		; sprite X position low byte into low byte of A
REP #$20			; set A to 16-bit mode
SEC				; subtract the player's X position
SBC $94			; from the sprite's
BPL NoInvertH		; if the result of the subtraction was negative...
EOR #$FFFF		; then invert it
INC				;
NoInvertH:		;
CMP #$0100		; if the difference is bigger than 1 screen...
SEP #$20			;
BCS RangeOut1	; then the player is out of range anyway
CMP $0A			; if not, compare the result to the desired range
BCS RangeOut1	;
RangeIn1:		;
LDA #$01		;
RTS				;
RangeOut1:		;
LDA #$00		;
RTS				;

dl Init,Main
