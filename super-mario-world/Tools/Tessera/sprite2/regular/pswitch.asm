;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; P-Switch, by Davros, modified by imamelia
;;
;; This is a P-switch that can have different behaviors depending on its palette.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-2: Sprite palette (also determines behavior).
;; Bits 3-6: Unused.
;; Bit 7: If set, the sprite cannot be carried.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BlueTimer = $B0		; length of the blue timer in frames
!GrayTimer = $B0		; length of the gray timer in frames
!QuakeTimer1 = $20	; time to shake the ground when the player presses the blue or gray switch
!QuakeTimer2 = $20	; time to shake the ground when the player presses the red switch
!Sound1 = $0B1DF9	; sound to generate when the player lands on the sprite
!Sound2 = $091DFC	; sound to generate when the earthquake effect happens
!Sound3 = $021DFC	; sound to generate when a sprite is spawned
!Sound4 = $101DF9	; sound to generate when a block is spawned

CarryOffset:
dw $0001,$FFFF

YSpeed:
db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
db $E8,$E8,$E8,$00

!Tilemap1 = $42

HorizDisp2:
db $00,$08
Tilemap2:
db $FE,$FE
TileProps2:
db $00,$40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x	;
AND #$07		;
ASL				;
STA $00			;
LDA $15F6,x		;
AND #$F1		;
ORA $00			;
STA $15F6,x		;

LDA $167A,x		;
STA $1528,x		;

RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:

LDA $14C8,x
CMP #$09
BCS HandleStunned
JSR PSwitchMain

RTL

HandleStunned:

LDA $14C8,x			;
JSL $81812B			;

LDA $167A,x			;
AND #$7F			;
STA $167A,x			;

JSR PSwitchGFX		;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PSwitchMain:

JSR PSwitchGFX		;

LDA $14C8,x			;
CMP #$09			;
BCS JustSpatOut		;

LDA $9D				;
BNE Return2			;

LDA $1558,x			;
BEQ NotSquished		; if the sprite is squished...
STA $15D0,x			;
DEC					; and it isn't supposed to disappear next frame...
BNE Return2			; return
STZ $14C8,x			; if it is about to disappear, erase it
JSR SubSmoke			; and generate smoke

LDA $15F6,x			; run a death routine depending on the sprite palette
LSR					;
AND #$07			; 8 possible routines
JSL $8086DF			;

dw DeathRtPal8		; 00 - palette 8
dw DeathRtPal9		; 01 - palette 9
dw DeathRtPalA		; 02 - palette A
dw DeathRtPalB		; 03 - palette B
dw DeathRtPalC		; 04 - palette C
dw DeathRtPalD		; 05 - palette D
dw DeathRtPalE		; 06 - palette E
dw DeathRtPalF		; 07 - palette F

JustSpatOut:

LDA #$08			;
STA $14C8,x			;
LDA #$08			;
STA $1540,x			;

Return2:				;
RTS					;

NotSquished:

JSL !SubOffscreenX3	;
LDA $1588,x			;
AND #$03			; if the sprite is touching a wall...
BEQ CeilingContact		;

LDA $157C,x			;
EOR #$01				; flip its direction
STA $157C,x			;
LDA $B6,x			;
EOR #$FF				; and its X speed
STA $B6,x			;

CeilingContact:		;

LDA $1588,x			;
AND #$08			; if the sprite is in contact with the ceiling...
BEQ Ground			;
STZ $AA,x			; zero out its Y speed
BRA SetGroundSpeed	;

Ground:				:

LDA $1588,x			;
AND #$04			; if the sprite is not touching the ground...
BEQ InAir				; then it is in the air

SetGroundSpeed:		;
JSR GroundSpeed		;

InAir:				;

JSL $81802A			;

LDA $1528,x			;
STA $167A,x			; don't hurt the player when he/she touches the sprite

JSL $81A7DC			; check for player/sprite contact
BCC ReturnMain		; return if no contact was made

JSL !SubVertPos		; check the vertical distance between the player and the sprite

LDA $0E				;
CMP #$E6			; if there is vertical contact, but the player is not above the sprite...
BPL MaybeCarry		; then the sprite might get picked up
LDA $7D				;
CMP #$10			; if the player's Y speed is less than 10...
BMI MaybeCarry		; then the sprite might get picked up

BIT $15				; if the player is pressing Y or X...
BVS Carry2			; ...then the sprite might get picked up

JSL $81AA33			; set the player's bounce-off speed
JSL $81AB99			; display contact graphic

LDA #$20			;
STA $1558,x			; time to show the squished switch
LDA.b #!Sound1>>16	;
STA.w !Sound1			; play a sound effect

LDA $15F6,x			; run a routine depending on the sprite palette
LSR					;
AND #$07			; 8 possible routines
JSL $8086DF			;

dw MainRtPal8			; 00 - palette 8
dw MainRtPal9			; 01 - palette 9
dw MainRtPalA			; 02 - palette A
dw MainRtPalB			; 03 - palette B
dw MainRtPalC			; 04 - palette C
dw MainRtPalD			; 05 - palette D
dw MainRtPalE			; 06 - palette E
dw MainRtPalF			; 07 - palette F

ReturnMain:			;
RTS					;

MaybeCarry:			;

BIT $15				; don't pick up the sprite if...
BVC NoCarry			; ...the player is not pressing Y or X
Carry2:				;
LDA $7FAB40,x		;
AND #$80			; ...bit 7 of the first extra byte is set
ORA $1470			; ...the player is already carrying something
ORA $187A			; ...the player is on Yoshi
BNE NoCarry			;

LDA #$0B				; set carried status
STA $14C8,x			;
BRA KeepXSpeed		; for some reason, Davros cleared the player's X speed even when he/she is picking the sprite up

NoCarry:				;
STZ $7B				; zero out the player's X speed
KeepXSpeed:			;
JSL !SubHorizPos		;
TYA					;
ASL					;
TAY					;
REP #$20				;
LDA $94				;
CLC					;
ADC CarryOffset,y		; offset the player's X position
STA $94				;
SEP #$20				;
RTS					;

;------------------------------------------------
; routines that run when the player hits the switch
;------------------------------------------------

MainRtPal8:
RTS

MainRtPal9:

JSR SetPSwitchMusic	; set the P-switch music (terminate if necessary)
LDA #!GrayTimer		; set the gray P-switch timer
STA $14AE			;
JSL $82B9BD			; turn all sprites on the screen into silver coins
RTS					;

MainRtPalA:

JSL $80FA80			;
RTS					;

MainRtPalB:

JSR SetPSwitchMusic	; set the P-switch music (terminate if necessary)
LDA #!GrayTimer		; set the blue P-switch timer
STA $14AD			;
RTS					;

MainRtPalC:

LDA #!QuakeTimer2	; time to shake Layer 1
STA $1887			;
LDA.b #!Sound2>>16	; play a sound effect
STA.w !Sound2			;
JSL $8294C1			; earthquake routine
RTS

MainRtPalD:
MainRtPalE:
MainRtPalF:
RTS

SetPSwitchMusic:

LDA $163E,x			;
BNE .Return2			; return if the timer is set
LDA $0DDA			;
BMI .SetTimer			; or the music is already playing
LDA #$0E				;
STA $1DFB			;
.SetTimer				;
LDA #$20			;
STA $163E,x			;
LDA #!QuakeTimer1	; time to shake ground
STA $1887			;
RTS					;

.Return2				;
PLA					;
PLA					;
RTS					;

;------------------------------------------------
; routines that run when the switch disappears
;------------------------------------------------

DeathRtPal8:
DeathRtPal9:
DeathRtPalA:
DeathRtPalB:
DeathRtPalC:
DeathRtPalD:
DeathRtPalE:
DeathRtPalF:
RTS

;------------------------------------------------
; ground speed routine
;------------------------------------------------

GroundSpeed:

LDA $B6,x		;
PHP				;
BPL .SkipFlip		;
EOR #$FF			;
INC				;
.SkipFlip			;
LSR				;
PLP				;
BPL .StoreXSpeed	;
EOR #$FF			;
INC				;
.StoreXSpeed		;
STA $B6,x		;

LDA $AA,x		;
PHA				;
JSR SetSomeYSpeed	;
PLA				;
LSR #2			;
TAY				;
LDA YSpeed,y		;
LDY $1588,x		;
BMI .Return		;
STA $AA,x		;
.Return			;
RTS				;

SetSomeYSpeed:	;

LDA $1588,x		;
BMI .SetYSpeed	;
LDA #$00		;
LDY $15B8,x		;
BEQ .StoreYSpeed	;
.SetYSpeed		;
LDA #$18		;
.StoreYSpeed		;
STA $AA,x		;
RTS				;

;------------------------------------------------
; create a puff of smoke
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; normal
;------------------------------------------------

PSwitchGFX:

JSL !GetDrawInfo		;

LDA $1558,x			;
BNE SquishedGFX		;

LDA $00				;
STA $0300,y			;
LDA $01				;
STA $0301,y			;
LDA #!Tilemap1		;
STA $0302,y			;
LDA $15F6,x			;
ORA $64				;
STA $0303,y			;

LDA #$F0				;
STA $0305,y			;
STA $0309,y			;
STA $030D,y			;

LDY #$02				;
LDA #$00			;
JSL $81B7B3			;
RTS					;

SquishedGFX:			;

LDA $15F6,x			;
ORA $64				;
STA $02				;

LDX #$01				;

.Loop				;

LDA $00				;
CLC					;
ADC.w HorizDisp2,x	;
STA $0300,y			;
LDA $01				;
CLC					;
ADC #$08			;
STA $0301,y			;
LDA.w Tilemap2,x		;
STA $0302,y			;
LDA $02				;
ORA.w TileProps2,x		;
STA $0303,y			;

INY #4				;
DEX					;
BPL .Loop				;

LDX $15E9			;
LDY #$00				;
LDA #$01			;
JSL $81B7B3			;
RTS					;


dl Init,Main


