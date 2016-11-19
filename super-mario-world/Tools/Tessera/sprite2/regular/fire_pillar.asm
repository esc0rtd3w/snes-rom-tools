;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Fire Pillar, by imamelia
;;
;; This sprite creates a 1-tile wide pillar of fire that bursts up, stays up for a bit,
;; and then goes back down, over and over again.
;;
;; Extra bytes: 1
;;
;; Bits 0-3: How many tiles the sprite will rise before stopping.
;; Bits 4-5: The priority setting of the sprite's tiles.
;; Bits 6-7: Unused.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TimeToStayUp = $70	; number of frames it will stay at maximum height
!TimeToStayDown = $A0	; number of frames that it will stay on the ground
!YSpeed = $10			; its movement speed
!TopTile = $C0		; the tile used for the top of the sprite
!BottomTile = $E0		; the tile used for all other tiles
!CoverUpTile = $C0		; the tile (on page 0) used to cover up the bottom tiles
; Note: This tile should be as square as possible.  The message box tile is the default;
; it can completely cover up any tile put below it when it is using vanilla graphics.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA #!TimeToStayDown	; set the time to stay down
STA $1558,x			;

LDA $D8,x			;
CLC					;
ADC #$10			;
STA $1528,x			;
LDA $E4,x			;
STA $1534,x			;

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR GiantFirePillarMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GiantFirePillarMain:

LDA $1570,x			; rising/falling frame timer
CLC					;
ADC #$0F			;
LSR #4				;
INC					;
STA $151C,x			; this will indicate the number of tiles to draw

JSR GiantFirePillarGFX	;

LDA $14C8,x			;
CMP #$08			;
BNE Return00			; return if the sprite is not in normal status or if sprites are locked
LDA $9D				;
BNE Return00			;

JSL !SubOffscreenX0	;

LDA $C2,x			; sprite state
JSL $8086DF			; 16-bit pointer routine

dw RestAtBottom		; 00 - at minimum height
dw MovingUp			; 01 - spreading upward
dw RestAtTop			; 02 - at maximum height
dw MovingDown		; 03 - retreating back

Return00:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite state 00: at minimum height
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RestAtBottom:

LDA $1558,x	; if it is time to start going up...
BNE Return01	;
INC $C2,x	; then change the sprite state to 01
LDA #$17	;
STA $1DFC	; and play a fiery sound effect
Return01:	;
RTS			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite state 01: shooting up
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MovingUp:

INC $1570,x			; increment the height counter
LDA $7FAB40,x		; extra byte 1, bits 0-3 (height)
ASL #4				; x16
CMP $1570,x			; if the sprite has reached maximum height...
BEQ AtMax			; then change the sprite state

LDA #!YSpeed			; set the sprite Y speed for moving up
EOR #$FF				;
INC					; flip it, since the sprite is going upward
STA $AA,x			;
JSL $81801A			; update sprite Y position
JSR Interact			; interact with the player
RTS					;

AtMax:				;
INC $C2,x			; change the sprite state to 02
LDA #!TimeToStayUp	; set the time to stay at maximum height
STA $1558,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite state 02: at maximum height
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RestAtTop:

LDA $1558,x			; if the sprite is not supposed to stay up any longer...
BEQ BackDown			; then make it start moving back down
JSR Interact			; otherwise, just interact with the player
RTS					; and return
BackDown:			;
INC $C2,x			; change the sprite state to 03
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite state 03: ebbing back down
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MovingDown:

DEC $1570,x			; decrement the height counter
BEQ AtMin			; if the sprite is back at 0 height, change the sprite state
LDA #!YSpeed			; set the sprite Y speed for moving down
STA $AA,x			;
JSL $81801A			; update sprite Y position
JSR Interact			; interact with the player
RTS					;

AtMin:				;
STZ $C2,x			; change the sprite state to 00
LDA #!TimeToStayDown	; set the time to stay at maximum height
STA $1558,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GiantFirePillarGFX:

JSL !GetDrawInfo		;

LDA $14				;
ASL #4				;
AND #$40			; make the sprite animate by X-flipping
STA $02				;

LDA $15F6,x			; sprite palette and GFX page
AND #$CF			;
STA $03				;
LDA $7FAB40,x		; extra byte 1, bits 4-5 (priority setting)
AND #$30			;
TSB $03				;

LDA $151C,x			;
STA $04				;

LDA $1570,x			; height frame counter
AND #$0F			; pixel offsets
SEC					;
SBC #$10				;
STA $06				;
STZ $05				;

LDX #$00				; start the tile counter at 0

GFXLoop:				;

INY #4				;

LDA $00				; base X position
STA $0300,y			; no X displacement for the tiles on the left

LDA $01				; base Y position
CPX #$01				; if the tile counter is 00...
BCC NoYDisp			; there is no need to set any Y displacement for the tiles
CLC					;
ADC $05				;
NoYDisp:				;
STA $0301,y			;

LDA #!TopTile			;
CPX #$01				;
BCC StoreTile			;
LDA #!BottomTile		;
StoreTile:				;
STA $0302,y			;

LDA $03				;
ORA $02				;
STA $0303,y			;

LDA $05				;
CLC					;
ADC #$10			;
STA $05				;

INX					; increment the tile counter
CPX $04				; compare to the wanted number of tiles
BCC GFXLoop			; loop the routine if there are more tiles to draw

LDX $15E9			;
LDY $15EA,x			;

LDA $1534,x			;
SEC					;
SBC $1A				;
STA $0300,y			;

LDA $1528,x			;
SEC					;
SBC $1C				;
STA $0301,y			;

LDA #!CoverUpTile		;
STA $0302,y			;
LDA #$00			;
STA $0303,y			;

LDY #$02				; all tiles were 16x16
LDA $151C,x			; number of tiles drawn
INC					; plus 1 for the cover-up tile
JSL $81B7B3			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite interaction/hit routine (includes player interaction)
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

;JSL $83B664			; get player clipping routine

JSR SetPlayerClipping	;
JSR SetSpriteClipping	; use custom sprite clipping values here
JSR CheckForContact	;
PHK					;
PER $0006			;
PEA $8020			;
JML $01A830			; finish up with the regular code

RTS

NoContact2:			;
CLC					;
RTS					;

SetPlayerClipping:

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

SetSpriteClipping:		; custom sprite clipping routine, based off $03B69F

LDA $14E0,x			;
XBA					;
LDA $E4,x			;
REP #$20				;
CLC					;
ADC #$0002			;
STA $08				; $08-$09 = sprite X position plus X displacement
LDA #$000C			;
STA $0C				; $0C-$0D = sprite clipping width
SEP #$20				;
LDA $14D4,x			;
XBA					;
LDA $D8,x			;
REP #$20				;
CLC					;
ADC #$0006			;
STA $0A				; $0A-$0B = sprite Y position plus Y displacement
SEP #$20				;
LDA $1570,x			;
STA $0E				; $0E-$0F = sprite clipping height
STZ $0F				;
RTS					;

CheckForContact:		;

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
.End					;
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


