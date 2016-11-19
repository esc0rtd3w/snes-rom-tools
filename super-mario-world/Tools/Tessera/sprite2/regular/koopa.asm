;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Koopa, by imamelia
;;
;; This is a sprite that acts like the Koopas in SMW or SMB3.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bit 0: 0 -> SMW style (spawn shell and shell-less Koopa), 1 -> SMB3 style (become
;;	stunned).
;; Bit 1: 0 -> normal Koopa, 1 -> Koopa shell.
;; Bits 2-3: Unused.
;; Bits 4-6: Sprite palette (also determines behaviors such as staying on ledges).
;; Bit 7: Unused.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; behavior table
; bit 0: stay on ledges
; bit 1: move fast
; bit 2: follow the player
; bit 3: jump over thrown sprites
Behavior:
db $00,$00,$06,$03,$01,$00,$00,$00

XSpeed:
db $08,$F8,$0C,$F4

VertDisp:
db $F0,$00,$F1,$01,$00,$00,$00,$00

Tilemap:
db $82,$A0,$82,$A2,$8A,$8C,$8A,$8E

TileProp:
db $40,$00,$40,$00,$00,$00,$40,$00

SpriteToSpawn:
db $00,$00,$03,$02,$01,$00,$00,$00

SpawnXOffsetLo:
db $0C,$F4

SpawnXOffsetHi:
db $00,$FF

SpawnXSpeed:
db $40,$C0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR KoopaInit
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KoopaInit:

PHY				;
JSL !SubHorizPos	;
TYA				;
STA $157C,x		; face the player initially
PLY				;
LDA $1588,x		;
ORA #$04		; set the sprite as being on ground (?)
STA $1588,x		;

LDA $7FAB40,x	;
LSR #3			;
AND #$0E		;
STA $00			;
LDA $15F6,x		;
AND #$F1		;
ORA $00			;
STA $15F6,x		;
LDA $00			;
LSR				; sprite palette and GFX page
TAY				;
LDA Behavior,y	;
STA $1510,x		; into behavior index

LDA $7FAB40,x	;
AND #$02		; if the extra bit is set...
BEQ EndInit		;

LDA #$09		; make the sprite stunned
STA $14C8,x		;

EndInit:			;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR KoopaMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KoopaMain:

LDA $14C8,x			;
CMP #$07			; if the sprite status is 07...
BEQ InMouth			; then the sprite is in Yoshi's mouth
LDA #$11			;
STA $9E,x			; if not, it acts like a Buzzy Beetle
LDA $14C8,x			;
CMP #$09			; if the sprite status is 09...
BCS InShell			; then the sprite is in its shell
CMP #$04			; if the sprite has been spin-jump-killed...
BEQ Return00			;
CMP #$06			; or turned into a coin...
BNE NormalRt			; then terminate the code

Return00:			;
RTS					;

InMouth:				;

LDA $14C8,x			;
JSL $81812B			;

LDA $1510,x			; check the palette behavior handler
CMP #$03			; if this is a blue Koopa...
BNE NoYWings			;
LDA #$02			;
STA $141E			; set the Yoshi wings flag
NoYWings:			;
LDA #$04			;
STA $9E,x			; it acts like a Koopa if it is in Yoshi's mouth
RTS					;

InShell:				;

LDA $14C8,x			;
JSL $81812B			;

LDA #$04			;
STA $1602,x			;

LDY $15EA,x			; sprite OAM index

LDA $0302,y			;
CLC					;
ADC #$06			;
STA $0302,y			;
LDA $0306,y			;
CLC					;
ADC #$06			;
STA $0306,y			;

LDA $030A,y			;
CMP #$8A			;
BCS Return00			;
CLC					;
ADC #$06			;
STA $030A,y			;

Return02:			;
RTS					;

NormalRt:			;

JSR KoopaGFX			; draw the sprite

LDA $9D				; if sprites are locked...
BNE Return02			;
LDA $14C8,x			; or the sprite status is not normal...
CMP #$08			;
BNE Return02			; return

INC $1570,x			;
	
JSL !SubOffscreenX0	; offscreen processing 

LDA $1588,x			;
AND #$03			; if the sprite is touching a wall...
BEQ NoObjContact		;
LDA $157C,x			;
EOR #$01				; flip its direction
STA $157C,x			;
NoObjContact:		;
	
LDA $1510,x			; behavior properties
AND #$01			; if the sprite doesn't stay on ledges...
BEQ NoChange			; skip the next part

LDA $1588,x			; if the sprite is in the air...
ORA $151C,x			; and not already turning...
BNE NoChange			;

JSR SubChangeDir		; change its direction

LDA #$01			;
STA $151C,x			; and set the turning flag

NoChange:			;

LDA $1588,x			;
AND #$04			; if the sprite is not in the air...
BEQ InAir				;
STZ $151C,x			; clear the turn flag
STZ $AA,x			; and zero the Y speed
InAir:				;

LDY $157C,x			; sprite direction
LDA $1510,x			; extra property byte 1
AND #$02			; if the sprite moves fast...
BEQ NotFast			;
INY #2				; increment the speed index to use faster speeds
NotFast:				;
LDA XSpeed,y			;
STA $B6,x			; set the sprite X speed

LDA $1510,x			;
AND #$04			; if the sprite is supposed to follow the player...
BEQ NoFollow			;
LDA $1570,x			;
AND #$7F			;
BNE NoFollow			;
JSL !SubHorizPos		; turn to face the player
TYA					;
STA $157C,x			;
NoFollow:			;

JSL $81802A			; update sprite position
JSL $818032			; interact with other sprites
JSL $81A7DC			; interact with the player

LDA $7FAB40,x		;
AND #$01			;
BNE Return01			;

LDA $1540,x			; if the sprite stun timer was set...
BEQ Return01			;

STZ $1540,x			; clear it

JSR SpawnKoopa		; and spawn a shell-less Koopa

Return01:			;
RTS

SpawnKoopa:			;

JSL $82A9E4			;
BMI Return01			;

LDA #$08			;
STA $14C8,y			;

PHX					;
LDA $15F6,x			;
LSR					;
AND #$07			;
TAX					;
LDA SpriteToSpawn,x	;
STA $009E,y			;
PLX					;

JSR Spawn

LDA #$10			;
STA $1564,y			;
STA $1528,y			;

PHY					;
JSL !SubHorizPos		;
TYA					;
EOR #$01				;
PLY					;
STA $157C,y			;
STA $01				;

LDA $15F6,x			;
AND #$0E			;
CMP #$04			;
BNE NoSpawnCoin		;

JSL $82A9E4			;
BMI Return01			;

LDA #$08			;
STA $14C8,y			;

LDA #$21			;
STA $009E,y			;

LDA $157C,x			;
PHA					;
EOR #$01				;
STA $157C,x			;

JSR Spawn			;

PLA					;
STA $157C,x			;
LDA #$D8			;
STA $00AA,y			;

NoSpawnCoin:			;
RTS

Spawn:

STY $00				;

LDA $157C,x			;
TAY					;
STY $01				;
LDY $00				;
LDA $E4,x			;
STA $00E4,y			;
LDA $14E0,x			;
STA $14E0,y			;

LDA $D8,x			;
STA $00D8,y			;
LDA $14D4,x			;
STA $14D4,y			;

LDA $15F6,x			; original SMW code beginning at $01A99D
AND #$0E			;
STA $0F				;
PHX					;
TYX					;
LDY $01				;
JSL $87F7D2			;
LDA $15F6,x			;
AND #$F1			;
ORA $0F				;
STA $15F6,x			;
LDY $01				;
LDA SpawnXSpeed,y	;
STA $B6,x			;
PLX					;
LDY $00				;

LDA #$10			;
STA $154C,y			;

RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KoopaGFX:			;

JSL !GetDrawInfo		; set up some variables

LDA $15F6,x			;
ORA $64				;
STA $02				;
PHX					;
LDA $157C,x			;
TAX					;
LDA $02				;
ORA TileProp,x		; tile properties depending on direction
STA $02				;
PLX					;

LDA $14C8,x			;
CMP #$08			;
BEQ NormalStatusGFX	;

LDA #$04			;
STA $1602,x			;
LDA $02				;
ORA #$80			;
STA $02				;
BRA SetUpGFXLoop		;

NormalStatusGFX:

LDA $1588,x		;
AND #$04		;
BEQ SetFrame		;

LDA $1570,x		;
LSR #3			;
EOR $15E9		;
AND #$01		;
ASL				;
SetFrame:		;
STA $1602,x		;

SetUpGFXLoop:	;

LDA $1602,x		;
STA $03			;
LDA #$01		;
STA $04			;
STA $05			;

LDA $14C8,x		;
CMP #$08		;
BEQ GFXLoop		;
DEC $04			;
DEC $05			;

GFXLoop:			;

LDA $03			;
ORA $04			;
TAX				;

LDA $00			;
STA $0300,y		;

LDA $01			;
CLC				;
ADC VertDisp,x	;
STA $0301,y		;

LDA Tilemap,x		;
STA $0302,y		;

LDA $02			;
STA $0303,y		;

INY #4			;
DEC $04			;
BPL GFXLoop		;

LDX $15E9		;
LDY #$02			;
LDA $05			;
JSL $81B7B3		;
RTS				;

SubChangeDir:

LDA $B6,x		;
EOR #$FF			; flip the sprite X speed
INC				;
STA $B6,x		;
LDA $157C,x		;
EOR #$01			; and direction
STA $157C,x		;
RTS				;

dl Init,Main
