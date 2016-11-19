;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Bomb, by imamelia
;;
;; This sprite will explode upon contact with a surface.  It can either fall, move
;; vertically, move horizontally, or move both vertically and horizontally.
;;
;; Extra bytes: 0
;;
;; Sprite table info:
;;
;; $C2,x - sprite state
;;	0 - have gravity
;;	1 - move vertically without gravity
;;	2 - move horizontally without gravity
;;	3 - move both horizontally and vertically without gravity
;; $1602,x - animation frame/tilemap index
;;	0 - down
;;	1 - left
;;	2 - right
;;	3 - up
;;	4 - down-left
;;	5 - down-right
;;	6 - up-left
;;	7 - up-right
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
db $82,$E6,$E6,$E6,$E6,$E6,$E6,$E6

TileProps:
db $00,$00,$40,$80,$00,$40,$80,$C0

FramesV:
db $00,$03

FramesH:
db $02,$01

FramesD:
db $05,$04,$07,$06

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR BombMain
Init:
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BombMain:

LDA $1540,x
BNE NoGFX

JSR SubGFX

NoGFX:

LDA $14C8,x
CMP #$08
BNE Return0

JSL !SubOffscreenX0

LDA $1540,x
BEQ NotExploding
DEC
BNE Exploding
STZ $14C8,x
RTS

Exploding:
PHB
LDA #$02
PHA
PLB
JSL $828086
PLB
JSL $81A7DC
RTS

NotExploding:

LDA $9D
BNE Return0

JSR Movement

LDA $1588,x
BNE Contact

JSL $81A7DC
BCS Contact1

Return0:

RTS

Contact1:
JSL $80F5B7
Contact:
ASL $167A,x
LSR $167A,x
LDA #$40
STA $1540,x
LDA #$09
STA $1DFC
RTS

Movement:

LDA $C2,x
JSL $8086DF

dw FallWithGravity
dw Vertical
dw Horizontal
dw HorizontalAndVertical

FallWithGravity:
JSL $81802A
RTS

Vertical:

LDA $AA,x
ROL
ROL
AND #$01
TAY
LDA FramesV,y
STA $1602,x

JSL $81801A
JSL $819138
RTS

Horizontal:

LDA $B6,x
ROL
ROL
AND #$01
TAY
LDA FramesH,y
STA $1602,x

JSL $818022
JSL $819138
RTS

HorizontalAndVertical:

LDA $AA,x
ROL
ROL
ROL
AND #$02
PHA
LDA $B6,x
ROL
PLA
ADC #$00
TAY
LDA FramesV,y
STA $1602,x

JSL $81801A
JSL $818022
JSL $819138
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGFX:

JSL !GetDrawInfo

LDA $15F6,x
ORA $64
STA $03

LDA $1602,x
TAX

LDA $00
STA $0300,y

LDA $01
STA $0301,y

LDA Tilemap,x
STA $0302,y

LDA $03
ORA TileProps,x
STA $0303,y

LDX $15E9
LDY #$02
LDA #$00
JSL $81B7B3
RTS


dl Init,Main

