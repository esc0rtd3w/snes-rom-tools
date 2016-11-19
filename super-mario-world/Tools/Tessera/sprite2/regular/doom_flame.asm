;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB3 Doomship Flame, by imamelia
;;
;; This is the flame that is emitted from Bullet Bill shooters in some of the airships
;; in Super Mario Bros. 3.
;;
;; Number of extra bytes: 2
;;
;; Extra byte 1:
;;
;; Bits 0-1: These indicate which direction the sprite will go.  00 = left, 01 = right,
;; 	10 = up, 11 = down.
;; Bit 2: Unused.
;; Bits 3-7: These indicate the frame number on which the sprite will first appear.
;;
;; Extra byte 2:
;;
;; Bits 0-3: These bits indicate how long the sprite will stay out once it has appeared.
;;	Multiply this by 16 (0x10) and add 8 to get the number of frames.
;; Bits 4-7: These indicate how long the sprite will stay invisible once it has disappeared.
;;	Multiply this by 16 (0x10) to get the number of frames.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SFX = $17		; This is the sound effect that will play when the flame appears.
!SFXBank = $1DFC	; This is the sound effect flame to use.
!Time1 = $06		; This is how long the sprite will stay as a small flame when appearing or disappearing.
!Time2 = $06		; This is how long the sprite will stay as a medium-sized flame when appearing or disappearing.

ClipWidth:
db $2C,$2C,$0C,$0C
ClipHeight:
db $0C,$0C,$2C,$2C
ClipXOffsetLo:
db $D4,$10,$02,$02
ClipXOffsetHi:
db $FF,$00,$00,$00
ClipYOffsetLo:
db $02,$02,$D4,$10
ClipYOffsetHi:
db $00,$00,$FF,$00

HorizDisp1:
HorizDisp2:
db $F8,$F0,$E8,$E0,$D8
HorizDisp3:
HorizDisp4:
db $F0,$E0,$D0
HorizDisp5:
HorizDisp6:
db $10,$18,$20,$28,$30
HorizDisp7:
HorizDisp8:
db $10,$20,$30
HorizDisp9:
HorizDisp10:
HorizDisp13:
HorizDisp14:
db $04,$04,$04,$04,$04
HorizDisp11:
HorizDisp12:
HorizDisp15:
HorizDisp16:
db $00,$00,$00

VertDisp1:
VertDisp2:
VertDisp5:
VertDisp6:
db $04,$04,$04,$04,$04
VertDisp3:
VertDisp4:
VertDisp7:
VertDisp8:
db $00,$00,$00
VertDisp9:
VertDisp10:
db $F8,$F0,$E8,$E0,$D8
VertDisp11:
VertDisp12:
db $F0,$E0,$D0
VertDisp13:
VertDisp14:
db $10,$18,$20,$28,$30
VertDisp15:
VertDisp16:
db $10,$20,$30

Tilemap1:
Tilemap5:
db $B0,$B1,$B2
Tilemap2:
Tilemap6:
db $A0,$A1,$A2,$A3,$A4
Tilemap3:
Tilemap4:
Tilemap7:
Tilemap8:
db $80,$82,$84
Tilemap9:
Tilemap13:
db $E4,$D4,$C4
Tilemap10:
Tilemap14:
db $E5,$D5,$C5,$B5,$A5
Tilemap11:
Tilemap12:
Tilemap15:
Tilemap16:
db $D6,$B6,$96

TileProps1:
TileProps2:
db $49,$49,$49,$49,$49
TileProps3:
db $49,$49,$49
TileProps4:
db $C9,$C9,$C9
TileProps5:
TileProps6:
db $09,$09,$09,$09,$09
TileProps7:
db $09,$09,$09
TileProps8:
db $89,$89,$89
TileProps9:
TileProps10:
db $09,$09,$09,$09,$09
TileProps11:
db $09,$09,$09
TileProps12:
db $49,$49,$49
TileProps13:
TileProps14:
db $89,$89,$89,$89,$89
TileProps15:
db $89,$89,$89
TileProps16:
db $C9,$C9,$C9

TileSize1:
TileSize2:
TileSize5:
TileSize6:
TileSize9:
TileSize10:
TileSize13:
TileSize14:
db $00,$00,$00,$00,$00

TileSize3:
TileSize4:
TileSize7:
TileSize8:
TileSize11:
TileSize12:
TileSize15:
TileSize16:
db $02,$02,$02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x	; first extra byte
AND #$F8		; upper 5 bits
STA $1570,x		; frame to appear
LDA $7FAB40,x	;
AND #$03		; lower 2 bits
;ASL #2			; x10
STA $187B,x		; sprite direction

LDA $7FAB4C,x	;
PHA				;
ASL #4			;
CLC				;
ADC #$08		;
STA $1504,x		;
PLA				;
AND #$F0		;
STA $151C,x		; time to stay invisible

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR DoomFlameMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NoGFX:
JMP PastGFX

DoomFlameMain:

LDA $187B,x			;
ASL					;
ASL					;
STA $00				;
LDA $1602,x			;
AND #$03			;
ORA $00				;
STA $1602,x			;

LDA $C2,x			; don't show any graphics if the sprite is invisible
BEQ NoGFX			;
CMP #$06			;
BEQ NoGFX			;
PEA.w PastGFX-$01		; push the real return address
JSL !GenericSprGFX		;
;JSR SubGFX			;

dw HorizDisp1,VertDisp1,Tilemap1,TileProps1,TileSize1 : db $02			; frame 1, left
dw HorizDisp2,VertDisp2,Tilemap2,TileProps2,TileSize2 : db $04			; frame 2, left
dw HorizDisp3,VertDisp3,Tilemap3,TileProps3,TileSize3 : db $02			; frame 3, left
dw HorizDisp4,VertDisp4,Tilemap4,TileProps4,TileSize4 : db $02			; frame 4, left
dw HorizDisp5,VertDisp5,Tilemap5,TileProps5,TileSize5 : db $02			; frame 1, right
dw HorizDisp6,VertDisp6,Tilemap6,TileProps6,TileSize6 : db $04			; frame 2, right
dw HorizDisp7,VertDisp7,Tilemap7,TileProps7,TileSize7 : db $02			; frame 3, right
dw HorizDisp8,VertDisp8,Tilemap8,TileProps8,TileSize8 : db $02			; frame 4, right
dw HorizDisp9,VertDisp9,Tilemap9,TileProps9,TileSize9 : db $02			; frame 1, up
dw HorizDisp10,VertDisp10,Tilemap10,TileProps10,TileSize10 : db $04	; frame 2, up
dw HorizDisp11,VertDisp11,Tilemap11,TileProps11,TileSize11 : db $02	; frame 3, up
dw HorizDisp12,VertDisp12,Tilemap12,TileProps12,TileSize12 : db $02	; frame 4, up
dw HorizDisp13,VertDisp13,Tilemap13,TileProps13,TileSize13 : db $02	; frame 1, down
dw HorizDisp14,VertDisp14,Tilemap14,TileProps14,TileSize14 : db $04	; frame 2, down
dw HorizDisp15,VertDisp15,Tilemap15,TileProps15,TileSize15 : db $02	; frame 3, down
dw HorizDisp16,VertDisp16,Tilemap16,TileProps16,TileSize16 : db $02	; frame 4, down

PastGFX:

LDA $14C8,x			;
CMP #$08			; return if the sprite is not in normal status
BNE Return00			;
LDA $9D				;
BNE Return00			;

JSL !SubOffscreenX0	; offscreen processing code

LDA $C2,x			;
JSL $0086DF			;

dw InvisibleInit		; 00 - invisible (first time)
dw Appearing1		; 01 - just starting to appear
dw Appearing2		; 02 - partway out
dw FullyOut			; 03 - fully out
dw Disappearing1		; 04 - just starting to disappear (partway out)
dw Disappearing2		; 05 - mostly gone
dw Invisible			; 06 - invisible

InvisibleInit:			;

LDA $13				;
CMP $1570,x			; if the frame counter equals the frame on which the sprite is supposed to appear...
BEQ StartAppear		; then make it appear

Return00:
RTS

StartAppear:			;

LDA #!SFX			; sound effect to play
STA !SFXBank			; sound effect bank to use
LDA #!Time1			;
STA $1540,x			; set the time to change state
INC $C2,x			; set the sprite state to 01
RTS					;

Appearing1:			;

STZ $1602,x			;
LDA $1540,x			; if the timer is not up...
BNE .End				; return
LDA #!Time2			;
STA $1540,x			; set the time to change state
INC $C2,x			; set the sprite state to 02
.End					;
RTS					;

Appearing2:			;

LDA #$01			;
STA $1602,x			;
LDA $1540,x			; if the timer is not up...
BNE .End				; return
LDA $1504,x			;
STA $1540,x			; set the time to change state
INC $C2,x			; set the sprite state to 03
.End					;
RTS					;

FullyOut:				;

LDA $14				;
LSR #3				;
AND #$01			;
INC					;
INC					;
STA $1602,x			; make the sprite animate between frames 3 and 4

LDA $1540,x			;
BEQ StartDisappear		; if the solidity timer is down to 0, then the sprite will disappear

JSR Interact			; make the sprite interact with the player
RTS					;

StartDisappear:		;

LDA #!Time2			;
STA $1540,x			;
INC $C2,x			;
LDA #$01			;
STA $1602,x			;
RTS					;

Disappearing1:		;

LDA $1540,x			;
BNE .End				;
LDA #!Time1			;
STA $1540,x			;
INC $C2,x			;
STZ $1602,x			;
.End					;
RTS					;

Disappearing2:		;

LDA $1540,x			;
BNE .End				;
INC $C2,x			;
LDA $151C,x			;
STA $1540,x			;
.End					;
RTS					;

Invisible:				;

LDA $1540,x			;
BNE .End				;
LDA #!SFX			; sound effect to play
STA !SFXBank			; sound effect bank to use
LDA #!Time1			;
STA $1540,x			; set the time to change state
LDA #$01			;
STA $C2,x			; set the sprite state to 01
.End					;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; interaction routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Interact:

;LDA $167A,x			;
;AND #$20			;
;BNE ProcessInteract	;
TXA					;
EOR $13				;
AND #$01			;
ORA $15A0,x			;
BEQ ProcessInteract		;
NoContact:			;
CLC					;
RTS					;

ProcessInteract:		;

JSL !SubHorizPos		;

LDA $0F				;
CLC					;
ADC #$50			;
CMP #$A0			;
BCS NoContact		;

;JSR SubVertPos2		;

;LDA $0E				;
;CLC					;
;ADC #$60			;
;CMP #$C0			;
;BCS NoContact		;

LDA $71				;
BNE NoContact		;
LDA #$00			;
BIT $0D9B			;
BVS SkipCheckP		;
LDA $13F9			;
EOR $1632,x			;
SkipCheckP:			;
BNE NoContact2		;

JSR GetPlayerClipping	; get player clipping routine
JSR GetSpriteClippingA	; use custom sprite clipping values here
JSR CheckForContact	;
BCC NoContact2		;

JSL $80F5B7			;
RTS					;

NoContact2:			;
CLC					;
RTS					;

GetPlayerClipping:		; modified player clipping routine, equivalent to and based off $03B664

PHX					;
REP #$20				;
LDA $94				;
CLC					;
ADC #$0002			;
STA $00				; $00-$01 = player X position plus X displacement
LDA #$000C			;
STA $04				; $04-$05 = player clipping width
SEP #$20				;
LDX #$00				;
LDA $73				;
BNE .Inc1				;
LDA $19				;
BNE .Next1			;
.Inc1				;
INX					;
.Next1				;
LDA $187A			;
BEQ .Next2			;
INX #2				;
.Next2				;
LDA $83B660,x		;
STA $06				; $06-$07 = player clipping height
STZ $07				;
LDA $83B65C,x		;
REP #$20				;
AND #$00FF			;
CLC					;
ADC $96				;
STA $02				; $02-$03 = player Y position plus Y displacement
SEP #$20				;
PLX					;
RTS					;

GetSpriteClippingA:		; custom sprite clipping routine, equivalent to $03B69F

LDY $187B,x			; all clipping tables are indexed by the sprite direction
LDA ClipXOffsetLo,y	;
CLC					;
ADC $E4,x			;
STA $08				; $08 = sprite X position low byte + X displacement value
LDA $14E0,x			;
ADC ClipXOffsetHi,y	;
STA $09				; $09 = sprite X position high byte + X displacement high byte (00 or FF)
LDA ClipWidth,y		;
STA $0C				; $0C-$0D = sprite clipping width
STZ $0D				;
LDA ClipYOffsetLo,y	;
CLC					;
ADC $D8,x			;
STA $0A				; $0A = sprite Y position low byte + Y displacement value
LDA $14D4,x			;
ADC ClipYOffsetHi,y	;
STA $0B				; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA ClipHeight,y		;
STA $0E				; $0E-$0F = sprite clipping width
STZ $0F				;

CheckForContact:		; custom contact check routine, equivalent to $03B72B

REP #$20				;
.CheckX				;
LDA $00				; if the sprite's clipping field is to the right of the player's,
CMP $08				; subtract the former from the latter;
BCC .CheckXSub2		; if the player's clipping field is to the right of the sprite's,
.CheckXSub1			; subtract the latter from the former
SEC					;
SBC $08				;
CMP $0C				;
BCS .ReturnNoContact	;
BRA .CheckY			;
.CheckXSub2			;
LDA $08				;
SEC					;
SBC $00				;
CMP $04				;
BCS .ReturnNoContact	;

.CheckY				;
LDA $02				; if the sprite's clipping field is below the player's,
CMP $0A				; subtract the former from the latter;
BCC .CheckYSub2		; if the player's clipping field is above the sprite's,
.CheckYSub1			; subtract the latter from the former
SEC					;
SBC $0A				;
CMP $0E				;
BCS .ReturnNoContact	;
.ReturnContact		;
SEC					;
SEP #$20				;
RTS					;
.CheckYSub2			;
LDA $0A				;
SEC					;
SBC $02				;
CMP $06				;
BCC .ReturnContact		;
.ReturnNoContact		;
CLC					;
SEP #$20				;
RTS					;


dl Init,Main
