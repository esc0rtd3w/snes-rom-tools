;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Spring Board, by mikeyk and imamelia
;;
;; This is a springboard that can be set to have special properties.
;;
;; Extra bytes: 2
;;
;; Extra byte 1:
;;
;; Bits 0-2: Main behavior settings.
;;	000 - normal
;;	001 - has a limited number of uses
;;	010 - explodes after a certain number of uses
;;	011 - explodes after being carried for a certain amount of time
;;	100 - disappears after being carried for a certain amount of time
;;	101 - launches the player off the screen into the level (1)C8 bonus area
;;	110 - launches the player off the screen into another level (teleporting)
;;	111 - launches the player off the screen and ends the level
;; Bit 3: Carriable status.  0 - can be carried, 1 - stationary.
;; Bits 4-7:
;;	- For behavior settings 1 and 2: Number of uses.  (Should be no higher than 09;
;;	0A-0F will show glitched tiles.)
;;	- For behavior settings 3 and 4: Flash timer.  (Multiply this by 0x10 and add 0x0F.)
;;	- For behavior setting 6: Which screen exit to use for the teleport destination.
;;	- For behavior setting 7: Normal/secret exit status.
;;
;; Extra byte 2:
;;
;; Bits 0-1: Speed setting.  00 - low, 01 - medium, 10 - high, 11 - very high.
;; Bit 2: Horizontal speed setting.  0 - no horizontal speed, 1 - horizontal speed.
;; Bit 3: Gravity setting.  0 - the sprite has gravity, 1 - the sprite stays in mid-air.
;; Bits 4-6: Palette to use.
;; Bit 7: Launch the player offscreen and make him/her stay there for a while (as in SMB:TLL)
;;
;; Notes:
;; - To make behavior settings 6 and 7 work properly, bits 0, 1, and 7 of the second extra byte
;;	should all be set.
;;
;; Relevant sprite tables:
;;
;; $1504,x - Flags.
;;	- Bit 0: the sprite has been picked up at least once
;;	- Bit 1: the sprite is exploding
;;	- Bit 2: the player is offscreen
;;	- Bits 3-6: unused
;;	- Bit 7: don't draw the sprite this frame
;; $1510,x - Behavior subsetting.
;; $151C,x - Speed setting.
;; $1534,x - For the extra-high springboard, time for the player to stay at maximum speed.
;; $1570,x - For the "super launch" springboard, time for the player to stay offscreen.
;; $160E,x - Horizontal speed, gravity, and "super launch" flags.
;; $163E,x - Flash timer for behavior settings 1, 2, 3, and 4.
;; $187B,x - Carriable status.
;; $1FD6,x - Main behavior settings.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; speed to give the player when he/she is not holding B or A
YSpeeds1:
db $D0,$C0,$B0,$B0
XSpeeds1:
db $F8,$F0,$E0,$E0
; speed to give the player when he/she is holding B or A
YSpeeds2:
db $C0,$A0,$80,$80
XSpeeds2:
db $E0,$D0,$C0,$C0

; valid values: 00, 01, 03, 07, 0F, 1F, 3F, FF
!DecSpeed = $03		; how fast the explode and disappear timers decrement
!FlashTime = $30		; how many time units to flash before exploding or disappearing (behavior settings 3 and 4)
!FlashTime2 = $20		; how many time units to flash before exploding or disappearing (behavior settings 1 and 2)
!AscendTime = $0D	; for the extra-high-bouncing one, how long the player will remain at maximum speed
!OffscreenTime = $70	; for the one that bounces the player offscreen, how many frames the player will stay in the air / 2

FlashType:
db $00,$05,$06,$02,$01,$00,$00,$00

NumberTiles:
db $BE,$BD,$BC,$BB,$BA,$AE,$AD,$AC,$AB,$AA

FlashPalettes:
db $00,$02,$04,$06,$08,$0A,$0C,$0E

Tilemap:
db $28,$28,$28,$28
db $4C,$4C,$4C,$4C
db $6F,$6F,$6F,$6F

HorizDisp:
db $00,$08,$00,$08
db $00,$08,$00,$08
db $00,$08,$00,$08

VertDisp:
db $00,$00,$08,$08
db $02,$02,$0A,$0A
db $08,$08,$08,$08

TileProps:
db $00,$40,$80,$C0
db $00,$40,$80,$C0
db $00,$40,$00,$40

Data0197AF:
db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
db $E8,$E8,$E8,$00,$00,$00,$00,$FE
db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
db $DC,$D8,$D4,$D0,$CC,$C8

Data01E611:
db $00,$01,$02,$02,$02,$01,$01,$00,$00
Data01E61A:
db $1E,$1B,$18,$18,$18,$1A,$1C,$1D,$1E

Data01AB2D:
dw $0001,$FFFF

Data01E6FD:
db $00,$02,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x	; extra byte 1
STA $00			;
AND #$07		;
STA $1FD6,x		; $1FD6,x - main behavior settings
LDA $00			;
AND #$08		;
STA $187B,x		; $187B,x - carriable status
LDA $00			;
LSR #4			;
AND #$0F		;
STA $1510,x		; $1510,x - behavior subsetting
LDA $1FD6,x		;
CMP #$03		;
BEQ .SetTimer		;
CMP #$04		;
BNE .NoTimer		;
.SetTimer			;
LDA $1510,x		;
ASL #4			;
CLC				;
ADC #$0F		; if $1510,x is being used as a timer,
STA $1510,x		; multiply it by 0x10 and add 0x0F
.NoTimer			;

LDA $7FAB4C,x	; extra byte 2
STA $00			;
AND #$03		;
STA $151C,x		; $151C,x - speed index
LDA $00			;
LSR #3			;
AND #$0E		;
STA $01			;
LDA $15F6,x		;
AND #$F1		;
ORA $01			;
STA $15F6,x		;
LDA $00			;
AND #$8C		;
LSR #2			;
STA $160E,x		; $160E,x - horizontal speed, gravity, and "super launch" flags
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:

JSR MaybeDec

LDA $1504,x
AND #$02
BNE Exploding

LDA $14C8,x
CMP #$09
BCS HandleCarried
JSR SpringboardMain
RTL

Exploding:
PHB
LDA #$82
PHA
PLB
JSL $828086
PLB
RTL

HandleCarried:

; For whatever reason, Nintendo decided to hardcode
; the OAM index of a carried sprite to 0, which causes
; some versions of this sprite to glitch up, as the original
; routine expects 4 tiles at most, and some types of
; springboard use 5 tiles (the ones with the counter).
; This fixes that problem by preserving the given OAM index
; and restoring it after calling the original code.
LDA $15EA,x			;
PHA					;
LDA $14C8,x			;
JSL $81812B			; call the original sprite status routine
PLA					;
STA $15EA,x			;

JSR SpringboardGFX

LDA $1504,x
BPL .Return

LDY $15EA,x
LDA #$F0
STA $0301,y
STA $0305,y
STA $0309,y
STA $030D,y

.Return
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpringboardMain:

LDA $9D				;
BEQ .NotLocked		;
JMP .Label01E6F0		;
.NotLocked			;

JSL !SubOffscreenX0	;
LDA $160E,x			;
AND #$02			;
BNE .NoSpeed			;
JSL $81802A			;
.NoSpeed				;

LDA $1588,x			;
AND #$04			;
BEQ .NoGround		;
JSR SetBounce			;
.NoGround			;

LDA $1588,x			;
AND #$03			;
BEQ .NoSide			;
JSR SetSpriteTurning	;
LDA $B6,x			;
ASL					;
PHP					;
ROR $B6,x			;
PLP					;
ROR $B6,x			;
.NoSide				;

LDA $1588,x			;
AND #$08			;
BEQ .NoCeiling		;
STZ $AA,x			;
.NoCeiling			;

LDA $1534,x			;
BEQ .NoSetMax		;
LDA #$80			;
STA $7D				;
.NoSetMax			;

LDA $160E,x			;
AND #$20			;
BEQ .NoOffscreen		;
LDA $1504,x			;
AND #$04			;
BEQ .NoOffscreen		;
LDA $1570,x			;
BNE .AlreadyUp		;
REP #$20				;
LDA $1C				;
SEC					;
SBC $96				;
SBC.w #$0030			;
SEP #$20				;
BMI .SkipDec			;
LDA #!OffscreenTime	;
STA $1570,x			;
STZ $1534,x			;
LDA $1FD6,x			;
CMP #$06			;
BCC .SkipDec			;
BNE .EndLevel			;
JSR TeleportRt			;
BRA .SkipDec			;
.EndLevel				;
JSR LevelEndRt			;
BRA .SkipDec			;

.AlreadyUp			;
REP #$20				;
LDA $1C				;
SEC					;
SBC.w #$0030			;
STA $96				;
SEP #$20				;
LDA $14				;
LSR					;
BCS .SkipDec2			;
DEC $1570,x			;
BNE .SkipDec2			;
LDA #$10			;
STA $7D				;
.SkipDec2			;

.NoOffscreen			;
LDA $1534,x			;
BEQ .SkipDec			;
DEC $1534,x			;
.SkipDec				;

LDA $1540,x			;
BEQ .Label01E6B0J		;
LSR					;
TAY					;
LDA $187A			;
CMP #$01			;
LDA Data01E61A,y		;
BCC .NoYoshi			;
CLC					;
ADC #$12			;
.NoYoshi				;
STA $00				;

LDA Data01E611,y		;
STA $1602,x			;
LDA $D8,x			;
SEC					;
SBC $00				;
STA $96				;
LDA $14D4,x			;
SBC #$00				;
STA $97				;
STZ $72				;
STZ $7B				;
LDA #$02			;
STA $1471			;
LDA $1540,x			;
CMP #$07			;
BCS .Label01E6AEJ		;
STZ $1471			;
LDA $76				;
CLC					;
ADC #$7F			;
LDY $151C,x			;
LDA YSpeeds1,y		;
STA $00				;
LDA XSpeeds1,y		;
BVC $03				;
EOR #$FF				;
INC					;
STA $01				;
LDA $17				;
BPL .Label01E69A		;
LDA #$01			;
STA $140D			;
BRA .Label01E69E		;

.Label01E6AEJ			;
JMP .Label01E6AE		;
.Label01E6B0J			;
JMP .Label01E6B0		;

.Label01E69A			;
LDA $15				;
BPL .Label01E6A7		;
.Label01E69E			;
LDA #$0B				;
STA $72				;
LDA $76				;
CLC					;
ADC #$7F			;
LDY $151C,x			;
LDA YSpeeds2,y		;
STA $00				;
LDA XSpeeds2,y		;
BVC $03				;
EOR #$FF				;
INC					;
STA $01				;
LDA #$80			;
STA $1406			;
LDA $1FD6,x			;
CMP #$05			;
;BCC .Label01E6A7		;
BNE .NoBonus			;
LDA #$08			;
STA $71				;
.NoBonus				;
LDA #!AscendTime		;
STA $1534,x			;
LDA $160E,x			;
AND #$20			;
BEQ .NoSuper			;
LDA $1504,x			;
ORA #$04			;
STA $1504,x			;
BRA .Label01E6A7		;
.NoSuper				;
STZ $1534,x			;
CPY #$03				;
BNE .Label01E6A7		;
LDA $1504,x			;
AND #$FB			;
STA $1504,x			;
.Label01E6A7			;
LDA $00				;
STA $7D				;
LDA $160E,x			;
AND #$01			;
BEQ .NoXSpeed		;
LDA $01				;
STA $7B				;
.NoXSpeed			;
LDA #$08			;
STA $1DFC			;
LDA $1540,x			;
CMP #$01			;
BNE .Label01E6AE		;
LDA $1FD6,x			;
CMP #$01			;
BEQ .DecCounter		;
CMP #$02			;
BNE .Label01E6AE		;
.DecCounter			;
DEC $1510,x			;
BNE .Label01E6AE		;
LDA #!FlashTime2		;
STA $163E,x			;
.Label01E6AE			;
BRA .Label01E6F0		;

.Label01E6B0			;
LDA $14C8,x			;
CMP #$09			;
BCS .Label01E6F0		;
JSL $81A7DC			;
BCC .Label01E6F0		;
STZ $154C,x			;
LDA $D8,x			;
SEC					;
SBC $96				;
CLC					;
ADC #$04			;
CMP #$1C			;
BCC .Label01E6CE		;
BPL .Label01E6E7		;
LDA $7D				;
BPL .Label01E6F0		;
STZ $7D				;
BRA .Label01E6F0		;

.Label01E6CE			;
BIT $15				;
BVC .Label01E6E2		;
LDA $1470			;
ORA $187A			;
LDA $187B,x			;
BNE .Label01E6E2		;
LDA #$0B				;
STA $14C8,x			;
LDA $1504,x			;
ORA #$01			;
STA $1504,x			;
STZ $1602,x			;
.Label01E6E2			;
JSR Sub01AB31		;
BRA .Label01E6F0		;

.Label01E6E7			;
LDA $7D				;
BMI .Label01E6F0		;
LDA #$11			;
STA $1540,x			;

.Label01E6F0			;
LDA $1504,x			;
BMI .Return			;

JSR SpringboardGFX		;

.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpringboardGFX:

JSL !GetDrawInfo

LDA $15F6,x
ORA $64
STA $04

LDA $1602,x
ASL #2
STA $03

STZ $05

LDX #$03
STX $05

.Loop

PHX
TXA
ORA $03
TAX

LDA $00
CLC
ADC.w HorizDisp,x
STA $0300,y

LDA $01
CLC
ADC.w VertDisp,x
STA $0301,y

LDA.w Tilemap,x
STA $0302,y

LDA $04
ORA.w TileProps,x
STA $0303,y

PLX
INY #4
DEX
BPL .Loop
LDX $15E9

LDA $1FD6,x
CMP #$01
BEQ .ShowNumber
CMP #$02
BNE .NoNumber

.ShowNumber
LDA $163E,x
BNE .NoNumber
JSR DrawNumberTile
.NoNumber

LDY #$00
LDA $05
JSL $81B7B3
RTS

DrawNumberTile:

LDA $00				;
CLC					;
ADC #$04			;
STA $0300,y			;

LDA $01				;
CLC					;
ADC #$F4			;
STA $0301,y			;

PHY					;
LDY $1510,x			;
LDA NumberTiles,y		;
PLY					;
STA $0302,y			;

LDA #$03			;
ORA $64				;
STA $0303,y			;

INC $05				;
RTS					;

;------------------------------------------------
; ???
;------------------------------------------------

Sub01AB31:

STZ $7B
JSL !SubHorizPos
TYA
ASL
TAY
REP #$20
LDA $94
CLC
ADC Data01AB2D,y
STA $94
SEP #$20
RTS

;------------------------------------------------
; make the sprite turn
;------------------------------------------------

SetSpriteTurning:

LDA $15AC,x			;
BNE .Return			;
LDA #$08			;
STA $15AC,x			; set turn timer if not already set
LDA $B6,x			;
EOR #$FF				; flip sprite speed
INC					;
STA $B6,x			;
LDA $157C,x			;
EOR #$01				; flip sprite direction
STA $157C,x			;
.Return				;
RTS					;

;------------------------------------------------
; make the sprite bounce a little when it hits ground
;------------------------------------------------

SetBounce:

LDA $B6,x
PHP
BPL .Label00
EOR #$FF
INC
.Label00
LSR
PLP
BPL .Label01
EOR #$FF
INC
.Label01
STA $B6,x

LDA $AA,x
PHA
JSR SetSomeYSpeed
PLA
LSR #2
TAY
LDA $9E,x
CMP #$0F
BNE .Label02
TYA
CLC
ADC #$13
TAY
.Label02
LDA Data0197AF,y
LDY $1588,x
BMI .Return
STA $AA,x
.Return
RTS

SetSomeYSpeed:
LDA $1588,x
BMI .Label00
LDA #$00
LDY $15B8,x
BEQ .Label01
.Label00
LDA #$18
.Label01
STA $AA,x
RTS

TeleportRt:

LDY $1510,x		;
LDX $95			;
LDA $5B			;
LSR				;
BCC .NotVertical	;
LDX $97			;
.NotVertical		;
LDA $19B8,y		;
STA $19B8,x		;
LDA $19D8,y		;
ORA #$04		;
STA $19D8,x		;
LDX $15E9		;
LDA #$06		;
STA $71			;
STZ $88			;
STZ $89			;
RTS				;

LevelEndRt:

LDA $1510,x
AND #$01
INC
STA $0DD5
STA $13CE
INC $1DE9
LDA #$0B
STA $0100
Return2:
RTS

MaybeDec:

LDY $1FD6,x			;
LDA FlashType,y		;
BEQ Return2			;
STA $01				;
AND #$03			;
STA $02				;
LDA $163E,x			;
BEQ .DecTimer			;
CMP #$01			;
BEQ .SetDestructType	;
LDA $02				;
CMP #$01			;
BEQ .TimerDisappear	;

.TimerFlash			;
LDA $14				;
AND #$07			;
TAY					;
LDA $15F6,x			;
AND #$F1			;
ORA FlashPalettes,y		;
STA $15F6,x			;
BRA .DecTimer			;

.TimerDisappear		;
LDA $14				;
ROR					;
ROR					;
AND #$80			;
STA $00				;
LDA $1504,x			;
AND #$7F			;
ORA $00				;
STA $1504,x			;

.DecTimer			;
LDA $01				;
AND #$04			;
STA $01				;
LDA $1504,x			;
AND #$02			;
ORA $163E,x			;
ORA $01				;
BNE .Return			;
INC $19
LDA $1504,x			;
LSR					;
BCC .Return			;
LDA $14				;
AND #!DecSpeed		;
BNE .Return			;
DEC $1510,x			;
BNE .Return			;
LDA #!FlashTime		;
STA $163E,x			;
RTS					;

.SetDestructType		;
LDA $02				;
BEQ .Return			;
CMP #$01			;
BEQ .Disappear		;
LDA $1504,x			;
ORA #$02			;
STA $1504,x			;
LDA #$40			;
STA $1540,x			;
ASL $167A,x			;
LSR $167A,x			;
LDA #$11			;
STA $1662,x			;
LDA #$09			;
STA $1DFC			;
.Return				;
RTS					;
.Disappear			;
STZ $14C8,x			;
LDA #$19			;
STA $1DFC			;

SubSmoke:

LDA $E4,x
CMP $1A
LDA $14E0,x
SBC $1B
BNE .EndSmoke
LDA $D8,x
CMP $1C
LDA $14D4,x
SBC $1D
BNE .EndSmoke
PHY
LDY #$03
.FindFree
LDA $17C0,y
BEQ .FoundOne
DEY
BPL .FindFree
PLY
.EndSmoke
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


dl Init,Main
