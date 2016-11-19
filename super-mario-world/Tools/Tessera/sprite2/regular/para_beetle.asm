;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Para-Beetle, by Romi, modified by imamelia
;;
;; This is a sprite from SMB3, a Buzzy Beetle that flies through the air and can
;; carry the player.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-1: Index to sprite palette and speed.
;; Bit 2: Sprite size.  0 -> normal, 1 -> giant.
;; Bits 3-4: Initial direction.  00 -> face the player, 01 -> left, 02 -> right, 03 ->
;; face *away* from the player.
;; Bits 5-7: Unused.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
db $40,$42

XDisp2:
db $10,$00,$10,$00
db $10,$00,$10,$00
db $00,$10,$00,$10
db $00,$10,$00,$10

YDisp2:
db $F7,$F7,$07,$07
db $F7,$F7,$07,$07
db $F7,$F7,$07,$07
db $F7,$F7,$07,$07
;db $00,$00,$10,$10
;db $00,$00,$10,$10
;db $00,$00,$10,$10
;db $00,$00,$10,$10

Tilemap2:
db $08,$0A,$28,$2A
db $0C,$0E,$2C,$2E
db $08,$0A,$28,$2A
db $0C,$0E,$2C,$2E

TileProps2:
db $40,$40,$40,$40
db $40,$40,$40,$40
db $00,$00,$00,$00
db $00,$00,$00,$00

SpritePalette:
db $08,$0A,$06,$04

XSpeed:
db $0C,$14,$1A,$06
db $0A,$12,$17,$05

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x
STA $00
AND #$07
STA $1510,x
LDA $00
AND #$03
TAY
LDA $15F6,x
AND #$F1
ORA SpritePalette,y
STA $15F6,x
LDA $00
AND #$04
STA $151C,x

.FacePlayer
LDA $94
CMP $E4,x
LDA $95
SBC $14E0,x
BPL .EndInit
INC $157C,x
.EndInit

LDA $00
AND #$18
BEQ .Return
CMP #$18
BEQ .FaceAway
LSR #3
DEC
STA $157C,x

.Return
RTL

.FaceAway
LDA $157C,x
EOR #$01
STA $157C,x
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR SpriteMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteMain:

JSR ParaBeetleGFX

LDA $14C8,x
CMP #$08
BNE .Return
LDA $9D
BNE .Return

JSL !SubOffscreenX0

INC $1570,x

LDY $1510,x
LDA XSpeed,y
LDY $157C,x
BEQ .NoFlipSpeed
EOR #$FF
INC
.NoFlipSpeed
STA $B6,x

LDA $1504,x
BNE .Update
LDA $151C,x
BNE .Update
LDA #$01
LDY $AA,x
BEQ .Update
BMI .YSpeed000
DEC
DEC
.YSpeed000
CLC
ADC $AA,x
STA $AA,x

.Update
JSL $81801A
JSL $818022
LDA $1491
STA $1528,x

LDY #$B9
LDA $1490
BEQ .StoreTo167A
LDY #$39
.StoreTo167A
TYA	
STA $167A,x
LDA $151C,x
BEQ .DefaultClipping
JSL $818032
JSR CustomClippingRt
BRA .MakeSpriteSolid
.DefaultClipping
JSL $81803A
.MakeSpriteSolid
BCC .Return2
PHK
PEA.w .Continue-1
PEA $8020
JML $81B45C
.Return
RTS

.Continue
BCC .SpriteWins
LDA $1504,x
BNE .PlayerWins000
LDA #$01
STA $1504,x
LDY #$10
LDA $151C,x
BEQ .SetYSpeed
LDY #$03
.SetYSpeed
STY $AA,x
.PlayerWins000
LDA #$08
STA $154C,x
LDA $151C,x
BNE .Return
LDA $AA,x
DEC
CMP #$F0
BMI .Return
STA $AA,x
RTS
.SpriteWins
LDA $154C,x
BNE .Return2
JSL $80F5B7
.Return2
LDA $154C,x
BNE .Return
STZ $1504,x
LDA $151C,x
BEQ .NoResetSpeed
STZ $AA,x
.NoResetSpeed
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ParaBeetleGFX:

JSL !GetDrawInfo

LDA $157C,x
STA $02
LDA $1570,x
LSR
LSR
LDY $1504,x
BNE .FastAnimation
LSR
.FastAnimation
AND #$01
STA $03
LDY $15EA,x

LDA $151C,x
BNE GiantGFX

LDA $00
STA $0300,y
LDA $01
SEC
SBC #$02
STA $0301,y
LDX $03
LDA.w Tilemap,x
STA $0302,y
LDX $15E9
LDA $15F6,x
LSR $02
BCS $02
ORA #$40
ORA $64
STA $0303,y

LDY #$02
LDA #$00
JSL $81B7B3
RTS

GiantGFX:
STA $7FB000
LDA $15F6,x
ORA $64
STA $04

LDA #$03
STA $05

LDA $03
ASL
ASL
EOR #$04
ORA #$03
STA $03
LDA $02
ASL #3
TSB $03

.Loop

LDX $03
LDA $00
CLC
ADC.w XDisp2,x
STA $0300,y
LDA $01
CLC
ADC.w YDisp2,x
STA $0301,y
LDA.w Tilemap2,x
STA $0302,y
LDA $04
ORA.w TileProps2,x
STA $0303,y

INY #4
DEC $03
DEC $05
BPL .Loop

LDX $15E9
LDY #$02
LDA #$03
JSL $81B7B3
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; custom clipping routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CustomClippingRt:

JSL $83B664			;
JSR SetSpriteClipping	;
JSL $83B72B			;
RTS					;

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:	; custom sprite clipping routine, based off $03B69F

LDA $E4,x		;
CLC				;
ADC #$01		;
STA $04			; $04 = sprite X position low byte + X displacement value
LDA $14E0,x		;
ADC #$00		;
STA $0A			; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDA #$1E			;
STA $06			; $06 = sprite clipping width
LDA $D8,x		;
;CLC				;
;ADC #$0A		;
STA $05			; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x		;
;ADC #$00		;
STA $0B			; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA #$16		;
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


dl Init,Main











