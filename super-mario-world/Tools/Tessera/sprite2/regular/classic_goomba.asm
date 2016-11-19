;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Classic Goomba, by mikeyk, modified by imamelia
;;
;; This is a Goomba that acts like the one in SMB1 and SMB3.
;;
;; Extra bytes: 0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; walking frame 1, walking frame 2, squished, star-killed
Tilemap:
db $A8,$FF,$AA,$FF,$38,$38,$A8,$FF

HorizDisp:
db $00,$FF,$00,$FF,$00,$08,$00,$FF

VertDisp:
db $00,$FF,$00,$FF,$08,$08,$00,$FF

TileProps:
db $00,$00,$00,$00,$00,$40,$00,$00

TileSize:
db $02,$FF,$02,$FF,$00,$00,$02,$FF

TilesToDraw:
db $00,$00,$01,$00

XSpeed:
db $08,$F8

KilledXSpeed:
db $10,$F0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSL !SubHorizPos		;
TYA					; make the sprite face the player
STA $157C,x			;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR ClassicGoombaMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClassicGoombaMain:

JSR ClassicGoombaGFX	;

LDA $14C8,x			;
CMP #$08			;
BNE .Return			;

JSL !SubOffscreenX0	;

LDY $157C,x			;
LDA XSpeed,y			;
STA $B6,x			;

LDA $9D				;
BNE .Return			;

INC $1570,x			;

LDA $1558,x			; if the sprite is squished...
BEQ .NotSquished		;
STA $15D0,x			;
DEC					; and it won't disappear next frame...
BNE .Return			; return
STZ $14C8,x			; erase the sprite if this is the last frame to show its remains

.Return				;
RTS					;

.NotSquished			;

LDA $1588,x			;
AND #$04			;
PHA					;
JSL $81802A			;
JSL $818032			;
LDA $1588,x			;
AND #$04			;
BEQ .InAir			;
STZ $AA,x			;
PLA					;
BRA .OnGround		;
.InAir				;
PLA					;
BEQ .WasInAir			;
LDA #$0A			;
STA $1540,x			;
.WasInAir				;
LDA $1540,x			;
BEQ .OnGround		;
STZ $AA,x			;
.OnGround			;
LDA $1588,x			;
AND #$03			;
BEQ .NoFlip			;
LDA $157C,x			;
EOR #$01				;
STA $157C,x			;
.NoFlip				;

JSL $81A7DC			;
BCC .Return			;

LDA $1490			; if the player has a star...
BNE HasStar			;

JSL !SubVertPos		; get the vertical distance between the player and the sprite
LDA $7D				;
CMP #$10			; if there is vertical contact and the player is not above the sprite...
BMI SpriteWins			; then the sprite damages the player

JSR SubStompPoints		;
JSL $81AA33			; set bounce-off speed
JSL $81AB99			; display contact GFX
LDA $140D			; check the spin-jump flag
ORA $187A			;
BNE SpinKill			; and make the sprite spin-killed if it is set
.NoSpinKill			;
LDA #$20			;
STA $1558,x			;
RTS					;

SpriteWins:			;

LDA $154C,x			; if interaction is disabled...
ORA $15D0,x			; or the sprite is being eaten...
BNE .Return			; then don't damage the player

JSL !SubHorizPos		;
TYA					;
STA $157C,x			;
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
LDA #$1F				;
STA $1540,x			; set the spin-jump animation timer
JSL $87FC3B			; show the spin-jump stars
LDA #$08			;
STA $1DF9			; play a sound effect
RTS					;

HasStar:

LDA #$02			;
STA $14C8,x			;
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

StarSounds:
db $13,$14,$15,$16,$17,$18,$19

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClassicGoombaGFX:

JSL !GetDrawInfo		;

LDA $15F6,x			;
ORA $64				;
STA $02				;
LDA $157C,x			;
ROR #3				;
AND #$40			;
EOR #$40				;
TSB $02				;

LDA $1570,x			;
LSR #2				;
AND #$02			;
STA $03				;

LDA $14C8,x			;
CMP #$02			;
BNE .NoStar			;
LDA #$06			;
STA $03				;
.NoStar				;
LDA $1558,x			;
BEQ .NoSquish			;
LDA #$04			;
STA $03				;
.NoSquish			;
LDA $03				;
LSR					;
STA $04				;

LDX $04				;
LDA.w TilesToDraw,x	;
STA $05				;
TAX					;

.Loop				;

PHX					;
TXA					;
CLC					;
ADC $03				;
TAX					;

LDA $00				;
CLC					;
ADC.w HorizDisp,x		;
STA $0300,y			;

LDA $01				;
CLC					;
ADC.w VertDisp,x		;
STA $0301,y			;

LDA Tilemap,x			;
STA $0302,y			;

LDA $02				;
EOR.w TileProps,x		;
STA $0303,y			;

PHY					;
TYA					;
LSR #2				;
TAY					;
LDA.w TileSize,x		;
STA $0460,y			;
PLY					;

INY #4				;
PLX					;
DEX					;
BPL .Loop				;

LDX $15E9			;
LDY #$FF				;
LDA $05				;
JSL $81B7B3			;
RTS					;


dl Init,Main
