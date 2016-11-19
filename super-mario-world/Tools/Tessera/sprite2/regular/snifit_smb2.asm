;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Snifit (SMB2 style), by mikeyk, modified by imamelia
;;
;; This is a Snifit, a sprite from SMB2 (US) that walks back and forth and can be
;; carried and ridden on.  It also spits small projectiles or Bullet Bills at the player.
;;
;; Uses extra property bytes: YES
;;
;; If bit 0 of the extra property byte 1 is set, the sprite will use an extra frame for
;; when it turns.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-7: These form the index to the property tables.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TimeToShow = $28
!TimeTillSpit = $E8
!BallSprNum = $0D
!BulletSprNum = $1C
!JumpYSpeed = $D0

; For this table:
; Bit 0 - Move fast
; Bit 1 - Stay on ledges
; Bit 2 - Follow the player
; Bit 3 - Jump over thrown sprites
; Bit 4 - Enable spin killing (if rideable)
; Bit 5 - Can be carried (if rideable)
; Bit 6 - Giant-sized
; Bit 7 - Normal interaction (not rideable)
MainProperties1:
db $30,$32,$40,$42,$00,$40,$82,$C2	; values 00-07
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F

; For this table:
; Bit 0 - Jump instead of walk
; Bits 1-7 - Unused
MainProperties2:
db $00,$00,$00,$00,$01,$01,$00,$00	; values 00-07
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F

SpritePalette:
db $08,$06,$08,$06,$02,$02,$06,$06	; values 00-07
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F

; normal Snifit - frame 1, frame 2, turning, death
Tilemap:
db $CC,$CE,$CE,$CC

; giant Snifit
Tilemap2:
db $48,$4A,$68,$6A
db $4C,$4E,$6C,$6E
db $4C,$4E,$6C,$6E
db $48,$4A,$68,$6A

; left, right
HorizDisp2:
db $00,$10,$00,$10
db $10,$00,$10,$00

; normal, death
VertDisp2:
db $F0,$F0,$00,$00
db $00,$00,$F0,$F0

XSpeed:
db $08,$F8,$0C,$F4

KilledXSpeed:
db $10,$F0

StarSounds:
db $13,$14,$15,$16,$17,$18,$19

BallXOffsetLo:
db $08,$FC

XOffsetHi:
db $00,$FF

BallXSpeed:
db $16,$EA

BulletXOffsetLo:
db $12,$FE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA #$01			;
STA $151C,x			; set the turning flag (I don't know why mikeyk did this)

JSL !SubHorizPos		;
TYA					; make the sprite face the player
STA $157C,x			;

LDA $7FAB40,x		; first extra byte
TAY					;
LDA MainProperties1,y	; behavior property table
STA $1510,x			;
LDA MainProperties2,y	;
STA $187B,x			;
LDA $15F6,x			;
AND #$F1			;
ORA SpritePalette,y		; palette
STA $15F6,x			;

LDA $1510,x			;
BPL .NoClearBit		; if bit 7 is set...
LDA $167A,x			;
AND #$7F			; clear the non-default interaction bit
STA $167A,x			;
.NoClearBit			;

LDA $1510,x			;
AND #$40			; if bit 6 is set...
BEQ .NoChangeClip		;
LDA #$1E				;
STA $1656,x			;
.NoChangeClip		;

LDA $167A,x			; preserve the fourth Tweaker byte
STA $1528,x			;

TXA					;
AND #$03			;
ASL #6				;
STA $1504,x			; set the sprite's spit timer

RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
LDA $14C8,x
CMP #$09
BCS .HandleStunned
JSR SnifitMain
RTL

.HandleStunned

;JSR SnifitMain

LDA $14C8,x
JSL $81812B
LDA $167A,x
AND #$7F
STA $167A,x

LDY $15EA,X
PHX
LDX Tilemap
LDA $0302,y
CMP #$A8
BEQ .SetTile
LDX Tilemap+1
.SetTile
TXA
STA $0302,y
PLX	
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReturnMain:
RTS

SnifitMain:

JSR SnifitGFX			; draw the sprite

LDA $9D				;
BNE ReturnMain		; return if sprites are locked
LDA $14C8,x			;
CMP #$08			; or the sprite is not in normal status
BNE ReturnMain		;

JSL !SubOffscreenX0	; offscreen handling

INC $1570,x			; increment the frame counter

JSR DecrementTimer	;

LDA $1504,x			;
CMP #!TimeToShow	;
BCS WalkingState		;
LSR					;
AND #$01			;
STA $160E,x			;

STZ $B6,x			;

LDA $1504,x			;
BNE .NoTimeSet		;
LDA #!TimeTillSpit		;
STA $1504,x			;
.NoTimeSet			;
CMP #$01			;
BNE .NoSpit			;
JSR SubProjectileSpit	;
.NoSpit				;

JMP SharedCode		;

WalkingState:			;

LDA $14				;
LSR					;
CLC					;
ADC $15E9			;
AND #$01			;
STA $1602,x			;

LDA $187B,x			;
AND #$01			;
BEQ .NoJump			;

JSL !SubHorizPos		;
TYA					;
STA $157C,x			;

STZ $160E,x			;
STZ $B6,x			;
LDA $1588,x			;
AND #$04			;
BEQ .InAir			;
LDA $1534,x			;
AND #$FE			;
STA $1534,x			;
LDA $1570,x			;
AND #$3F			;
BNE .NoYSpeed		;

LDA #!JumpYSpeed		;
STA $AA,x			;

.NoYSpeed			;
JSL $81802A			;
BRA .Shared2			;

.InAir				;
LDA $1534,x			;
ORA #$01			;
STA $1534,x			;
DEC $1570,x			;
INC $1504,x			;
JSL $81802A			;
BRA .Shared2			;

.NoJump				;

LDY $157C,x			; set the sprite speed depending on the direction...
LDA $1510,x			;
AND #$01			; ...and the behavior properties
BEQ .NoFastSpeed		;
INY #2				;
.NoFastSpeed			;
LDA XSpeed,y			;
STA $B6,x			; set the sprite X speed

JSL $81802A			; update the sprite position

LDA $1588,x			;
AND #$03			; if the sprite is touching a wall...
BEQ .NoWallContact		;
JSR SetSpriteTurning	; make it turn around
.NoWallContact		;

JSR MaybeStayOnLedges	; stay on ledges if the relevant bit is set

.Shared2				;

LDA $1588,x			;
AND #$04			; if the sprite is on the ground...
BEQ .NotOnGround		;
STZ $AA,x			; clear the Y speed
STZ $151C,x			; and the turning flag
JSR MaybeFacePlayer	; turn to face the player if the relevant bit is set
JSR MaybeJumpShells	; jump over thrown sprites if the relevant bit is set
.NotOnGround			;

SharedCode:			;

LDA $1528,x			;
STA $167A,x			;

JSL $818032			; interact with other sprites
LDA $1510,x			;
AND #$40			;
BEQ .NoCustomClip		;
JSR CustomClippingRt	;
BRA $04				;
.NoCustomClip		;
JSL $81A7DC			; interact with the player
BCC .Return			; return if no contact was made

;------------------------------------------------
; main interaction routine starts here
;------------------------------------------------

LDA $1510,x			; if the sprite has default interaction...
BPL .NonDefault		;

PHB					;
PHK					;
PEA.w .SubRet-$01		;
PEA $8020			;
LDA #$01			;
PHA					;
PLB					;
JML $81A83B			; call the default interaction routine
.SubRet				;
PLB					;
RTS					;

.NonDefault			;

JSL !SubVertPos		; get the vertical distance between the player and the sprite
LDY #$E8				;
LDA $1510,x			;
AND #$40			;
BEQ $02				;
LDY #$D8			;
STY $00				;
LDA $0E				;
CMP $00				; if there is vertical contact and the player is not above the sprite...
BPL SpriteWins			; then the sprite damages the player

LDA $7D				; if the player's Y speed is negative...
BMI .Return			; then just return

LDA $1510,x			;
AND #$10			; if spin-killing is enabled...
BEQ .SpinKillDisabled	;
LDA $140D			; check the spin-jump flag
ORA $187A			; and the "on Yoshi" flag
BNE SpinKill			; and make the sprite spin-killed if either is set
.SpinKillDisabled		;

LDA $1510,x			;
AND #$20			; if the sprite is not carriable...
BEQ RideSprite			;
BIT $16				; ...or the player is not pressing Y...
BVC RideSprite			; ...then just ride the sprite

LDA #$0B				;
STA $14C8,x			; set carried status
LDA #$FF				;
STA $1540,x			; set recovery time

.Return				;
RTS					;

RideSprite:			;

LDA #$01			;
STA $1471			; set the "on sprite" flag
LDA #$06			;
STA $154C,x			; disable interaction for a few frames
STZ $7D				; zero out the player's Y speed

LDA #$E1				;
LDY $187A			; depending on whether or not the player is riding Yoshi,
BEQ $02				;
LDA #$D1			; offset his/her Y position by either E1 or D1 pixels
STA $00				;
LDA $1510,x			;
AND #$40			;
BEQ .NoAdd			;
LDA $00				;
SEC					;
SBC #$0D				;
STA $00				;
.NoAdd				;

LDA $00				;
CLC					;
ADC $D8,x			;
STA $96				;
LDA $14D4,x			; handle the high byte
ADC #$FF			;
STA $97				;

LDY #$00				;
LDA $1491			; $1491 - amount to move the player along the X-axis
BPL $01				;
DEY					; high byte: 00 or FF depending on direction
CLC					;
ADC $94				; synchronize the player's X position with the sprite's
STA $94				;
TYA					;
ADC $95				; handle the high byte
STA $95				;
RTS					;

SpriteWins:			;

LDA $154C,x			; if interaction is disabled...
ORA $15D0,x			; or the sprite is being eaten...
BNE .Return			; then don't damage the player

LDA $1490			; if the player has a star...
BNE HasStar			; then he/she doesn't take damage

JSL $80F5B7			; player hurt routine

.Return				;
RTS					;

SpinKill:

JSR SubStompPoints		;
LDA #$F8				;
STA $7D				; set the player's bounce-off Y speed
JSL $81AB99			; show contact graphic
LDA #$04			;
STA $14C8,x			; set the sprite status to 4 (spin-killed)
LDA #$1F				;
STA $1540,x			; set the spin-jump animation timer
JSL $87FC3B			; show the spin-jump stars
LDA #$08			;
STA $1DF9			; play a sound effect
RTS					;

HasStar:

LDA #$02			;
STA $14C8,x			; set the sprite status to 2 (killed, falling offscreen)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SnifitGFX:

JSL !GetDrawInfo		;

LDA $157C,x			;
STA $02				;

LDA $14C8,x			;
CMP #$02			;
BNE .NoKillFrame		;
LDA #$02			;
STA $03				;
LDA $15F6,x			;
ORA #$80			;
STA $15F6,x			;
BRA .DrawSprite		;
.NoKillFrame			;

LDA $7FAB28,x		;
AND #$01			;
BEQ .NotTurning		;
LDA $15AC,x			;
BEQ .NotTurning		;
LDA #$03			;
STA $03				;
BRA .DrawSprite		;
.NotTurning			;

LDA $14				;
LSR #3				;
CLC					;
ADC $15E9			;
AND #$01			;
STA $03				;

.DrawSprite			;

LDA $1510,x			;
AND #$40			;
BNE GiantGFX			;

LDA $00				;
CLC					;
ADC $160E,x			;
STA $0300,y			;
LDA $01				;
STA $0301,y			;

LDX $03				;
LDA Tilemap,x			;
STA $0302,y			;

LDX $15E9			;
LDA $15F6,x			;
LSR $02				;
BCS .NoFlip			;
ORA #$40			;
.NoFlip				;
ORA $64				;
STA $0303,y			;

LDY #$02				;
LDA #$00			;
JSL $81B7B3			;
RTS					;

GiantGFX:			;

LDA $160E,x			;
STA $07				;

LDA $03				;
ASL #2				;
ORA #$03			;
STA $03				;

STZ $06				;
LDA $14C8,x			;
CMP #$02			;
BNE $02				;
INC $06				;

LDA #$03			;
STA $05				;

.Loop				;

LDX $05				;
LDA $02				;
BNE $04				;
INX #4				;
LDA $00				;
CLC					;
ADC.w HorizDisp2,x	;
ADC $07				;
STA $0300,y			;

LDX $05				;
LDA $06				;
BEQ $04				;
INX #4				;
LDA $01				;
CLC					;
ADC.w VertDisp2,x		;
STA $0301,y			;

LDX $03				;
LDA Tilemap2,x		;
STA $0302,y			;

LDA $02				;
LSR					;
LDX $15E9			;
LDA $15F6,x			;
BCS .NoFlip			;
ORA #$40			;
.NoFlip				;
ORA $64				;
STA $0303,y			;

LDA $14C8,x			;
CMP #$02			;
BNE .NoDeathGFX		;
LDA $05				;
CLC					;
ADC #$04			;
TAX					;
LDA $01				;
CLC					;
ADC.w VertDisp2,x		;
STA $0301,y			;
LDX $15E9			;
LDA $0303,y			;
ORA #$80			;
STA $0303,y			;
.NoDeathGFX			;

INY #4				;
DEC $03				;
DEC $05				;
BPL .Loop				;

LDY #$02				;
LDA #$03			;
JSL $81B7B3			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; supporting subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;------------------------------------------------
; ledge check/set routine
;------------------------------------------------

MaybeStayOnLedges:

LDA $1510,x			; behavioral properties
AND #$02			; if bit 1 is not set...
BEQ .Return			; don't stay on ledges
LDA $1588,x			; unless the sprite is touching an object...
ORA $151C,x			; or already turning...
BNE .Return			;
JSR SetSpriteTurning	; make the sprite turn around
LDA #$01			;
STA $151C,x			; set the turning flag
.Return				;
RTS					;

;------------------------------------------------
; face player routine
;------------------------------------------------

MaybeFacePlayer:

LDA $1510,x			; behavioral properties
AND #$04			; if bit 2 is not set...
BEQ .Return			; don't face the player
LDA $1570,x			;
AND #$7F			; turn around only once every 0x80 frames
BNE .Return			;

LDA $157C,x			;
PHA					;
JSL !SubHorizPos		;
TYA					;
STA $157C,x			;
PLA					;
CMP $157C,x			;
BEQ .Return			;
LDA #$08			;
STA $15AC,x			;

.Return				;
RTS					;

;------------------------------------------------
; shell-jumping routine
;------------------------------------------------

MaybeJumpShells:

LDA $1510,x			;
AND #$08			; if the sprite isn't set to jump over shells...
BEQ .Return			; skip everything

TXA					;
EOR $13				;
AND #$03			; process every 4 frames
BNE .Return			;

LDY #$0B				;
.Loop				;
LDA $14C8,y			;
CMP #$0A			;
BEQ .JumpOver			;
.Next				;
DEY					;
BPL .Loop				;

.Return				;
RTS					;

.JumpOver

LDA $1588,x			;
AND #$04			;
BEQ .Next			;

LDA $00E4,y			; set up the clipping location
SEC					;
SBC #$1A				;
STA $00				;
LDA $14E0,y			;
SBC #$00				;
STA $08				;
LDA #$44			;
STA $02				;
LDA $00D8,y			;
STA $01				;
LDA $14D4,y			;
STA $09				;
LDA #$10			;
STA $03				;

JSL $83B69F			;
JSL $83B72B			;
BCC .Next			;

LDA $157C,y			;
CMP $157C,x			;
BEQ .Return			;

LDA #$C0			;
STA $AA,x			;
RTS					;

;------------------------------------------------
; turning set routine
;------------------------------------------------

SetSpriteTurning:

LDA #$08			;
STA $15AC,x			;
LDA $157C,x			;
EOR #$01				;
STA $157C,x			;
RTS					;

;------------------------------------------------
; stomp points routine
;------------------------------------------------

SubStompPoints:

PHY					;
LDA $1697			;
CLC					;
ADC $1626,x			;
INC $1697			;
TAY					;
INY					;
CPY #$08				;
BCS .NoSound			;
LDA StarSounds-1,y	;
STA $1DF9			;
.NoSound				;
TYA					;
CMP #$08			;
BCC .NoReset			;
LDA #$08			;
.NoReset				;
JSL $82ACE5			;
PLY					;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; custom clipping routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CustomClippingRt:

JSL $83B664			;
JSR SetSpriteClipping	;
JSR $83B72B			;
RTS					;

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:	; custom sprite clipping routine, based off $03B69F

LDA $E4,x		;
CLC				;
ADC #$03		;
STA $04			; $04 = sprite X position low byte + X displacement value
LDA $14E0,x		;
ADC #$00		;
STA $0A			; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDA #$1A		;
STA $06			; $06 = sprite clipping width
LDA $D8,x		;
CLC				;
ADC #$F3		;
STA $05			; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x		;
ADC #$FF		;
STA $0B			; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA #$1B			;
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
; decrement the spit timer
;------------------------------------------------

DecrementTimer:

LDA $1504,x			;
BEQ .Return			;
DEC $1504,x			;
.Return				;
RTS					;

;------------------------------------------------
; projectile-spitting routine
;------------------------------------------------

SubProjectileSpit:

LDA $1510,x			;
AND #$40			; if the sprite is a giant one...
BNE SpitBullet			; then spit a bullet instead of a ball

LDY #$07				;
.Loop				;
LDA $170B,y			;
BEQ .FoundSlot		;
DEY					;
BPL .Loop				;
RTS					;

.FoundSlot			;
LDA #!BallSprNum		;
STA $170B,y			;

STY $00				;
LDY $157C,x			;
STY $01				;
LDA $E4,x			;
CLC					;
ADC BallXOffsetLo,y	;
LDY $00				;
STA $171F,y			;

LDY $01				;
LDA $14E0,x			;
ADC XOffsetHi,y		;
LDY $00				;
STA $1733,y			;  

LDA $D8,x			;
CLC					;
ADC #$0F			;
STA $1715,y			;
LDA $14D4,x			;
ADC #$00			;
STA $1729,y			;

LDA #$D0			;
STA $173D,y			;
LDY $01				;
LDA BallXSpeed,y		;
LDY $00				;
STA $1747,y			;
LDA $1715,y			;
ADC #$F7			;
STA $1715,y			;
BCC .Return			;
LDA $1729,y			;
ADC #$FF			;
STA $1729,y			;

.Return				;
RTS					;

SpitBullet:

JSL $82A9E4			;
BMI .Return			;

LDA #$09			;
STA $1DFC			;

LDA #$08			;
STA $14C8,y			;

LDA #!BulletSprNum	;
STA $009E,y			;

PHX					;
TYX					;
JSL $87F7D2			;
PLX					;

STY $00				;
LDY $157C,x			;
LDA $E4,x			;
CLC					;
ADC BulletXOffsetLo,y	;
PHA					;
LDA $14E0,x			;
ADC XOffsetHi,y		;
LDY $00				;
STA $14E0,y			;
PLA					;
STA $00E4,y			;

LDA $D8,x			;
CLC					;
ADC #$FC			;
STA $00D8,y			;
LDA $14D4,x			;
ADC #$FF			;
STA $14D4,y			;

LDA $157C,x			;
STA $00C2,y			;

.Return				;
RTS					;


dl Init,Main
