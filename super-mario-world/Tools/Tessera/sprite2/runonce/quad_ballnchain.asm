;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Quadruple Ball 'n' Chain, by imamelia
;;
;; This run-once sprite will create a group of 4 Ball 'n' Chains (sprite 9E).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BallChainSprNum = $9E

BallChainGroupAngleLo:
db $00,$80,$00,$80

BallChainGroupAngleHi:
db $00,$00,$01,$01

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR QuadBallChainMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

QuadBallChainMain:

LDA $5B					;
AND #$01				; if the level is vertical...
BNE .VertPosSetup			; then the X and Y positions are switched

LDA $00					; $00 - sprite X position low byte
STA $14B1				;
LDA $01					; $01 - sprite X position high byte
STA $14B2				;
LDA $06					; $06 - sprite Y position (yyyyeeSY)
AND #$F0				;
STA $14B3				; Y position low byte
LDA $06					;
AND #$01				;
STA $14B4				; Y position high byte
BRA .Continue				;

.VertPosSetup				;
LDA $00					; $00 - sprite Y position low byte
STA $14B3				;
LDA $01					; $01 - sprite Y position high byte
STA $14B4				;
LDA $06					; $06 - sprite X position (xxxxeeSX)
AND #$F0				;
STA $14B1				; X position low byte
LDA $06					;
AND #$01				;
STA $14B2				; X position high byte

.Continue					;

LDA #$03				; 4 Ball 'n' Chains in the group
STA $04					;

.Loop
JSL $02A9E4				;
BMI .Return				;
TYX						;

LDA #!BallChainSprNum		; sprite number
STA $9E,x				;

JSL $07F7D2				;

LDA #$01				; status 01 - init
STA $14C8,x				;

LDA $14B1				; X position low byte
STA $E4,x				;
LDA $14B2				; X position high byte
STA $14E0,x				;
LDA $14B3				; Y position low byte
STA $D8,x				;
LDA $14B4				; Y position high byte
STA $14D4,x				;

LDY $04					; index within the group
LDA BallChainGroupAngleLo,y	;
STA $1602,x				;
LDA BallChainGroupAngleHi,y	;
STA $151C,x				;

CPY #$00					;
BNE .NoSetIndex			;
LDA $02					; $02 - sprite number in the level
STA $161A,x				; loading table index (always reload)
.NoSetIndex				;

DEC $04					;
BPL .Loop					;

.Return					;
RTS						;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; [subheader for one part of a certain section]
;------------------------------------------------


dl $FFFFFF,Main











