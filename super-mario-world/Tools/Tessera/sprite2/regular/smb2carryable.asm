;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB2 Carriable Sprite, by mikeyk, modified by imamelia
;;
;; This is a vegetable or egg from SMB2.  It can be carried and (in the case of the egg)
;; ridden on.
;;
;; Extra bytes: 0
;;
;; Sprite table info:
;;
;; $C2,x:
;;	Bits 0-6: Sprite tilemap index.
;;	Bit 7: 0 -> does not hurt the player, 1 -> hurts the player if he/she touches
;;		the side or bottom.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 00 - egg
; 01 - small vegetable
; 02 - large vegetable
; 03-FF - unused
Tilemap:
db $E8,$C8,$CA

Palette:
db $03,$0B,$0B

XSpeed:
db $20,$E0

KilledXSpeed:
db $F0,$10

StarSounds:
db $13,$14,$15,$16,$17,$18,$19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:

LDA $14C8,x
CMP #$09
BCS HandleCarried
JSR CarriableItemMain
Init:
RTL

HandleCarried:

;JSR CarriableItemMain

LDA $14C8,x
JSL $81812B
LDA $167A,x
AND #$7F
STA $167A,x

LDA $C2,x
AND #$7F
TAY
LDA Tilemap,y
LDY $15EA,x
STA $0302,y
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReturnMain:
RTS

CarriableItemMain:

JSR CarriableItemGFX

LDA $14C8,x			;
CMP #$08			;
BNE ReturnMain		;

JSL !SubOffscreenX0	;

LDY $157C,x			;
LDA XSpeed,y			;
STA $B6,x			;
LDA $9D				;
BNE ReturnMain		;

STZ $AA,x			;
JSL $81802A			;

LDA $1588,x			;
AND #$03			;
BEQ .NoObjContact		;
LDA $157C,x			;
EOR #$01				;
STA $157C,x			;
.NoObjContact			;

JSL $81A7DC			; interact with the player
BCC .Return			; return if no contact was made

;------------------------------------------------
; main interaction routine starts here
;------------------------------------------------

JSL !SubVertPos		; get the vertical distance between the player and the sprite
LDA $0E				;
CMP #$E6			; if there is vertical contact and the player is not above the sprite...
BPL SpriteWins			; then the sprite damages the player

LDA $7D				; if the player's Y speed is negative...
BMI .Return			; then just return

LDA $140D			; check the spin-jump flag
BNE SpinKill			; and make the sprite spin-killed if it is set
.SpinKillDisabled		;

LDA $187A			; if the player is on Yoshi...
BNE RideSprite			;
BIT $16				; ...or the player is not pressing Y...
BVC RideSprite			; ...then just ride the sprite

LDA #$0B				;
STA $14C8,x			; set carried status

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

LDA $C2,x			;
AND #$80			;
EOR #$80				;
ORA $154C,x			; if interaction is disabled...
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

CarriableItemGFX:

JSL !GetDrawInfo		;

PHY					;
LDA $C2,x			;
AND #$7F			;
TAY					;
LDA Tilemap,y			;
STA $02				;
LDA Palette,y			;
ORA $64				;
STA $03				;
PLY					;

LDA $14C8,x			;
CMP #$02			;
BNE .NoVFlip			;
LDA #$80			;
TSB $03				;
.NoVFlip				;

LDA $00				;
STA $0300,y			;

LDA $01				;
STA $0301,y			;

LDA $02				;
STA $0302,y			;

LDA $03				;
STA $0303,y			;

LDY #$02				;
LDA #$00			;
JSL $81B7B3			;
RTS					;

;------------------------------------------------
; stomp points routine
;------------------------------------------------

SubStompPoints:

PHY
INC $1697
LDY $1697
CPY #$08
BCS .NoSound
LDA StarSounds,y
STA $1DF9
.NoSound
TYA
CMP #$08
BCC .NoReset
LDA #$08
.NoReset
JSL $82ACE5
PLY
RTS


dl Init,Main