;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Generic Horizontal Generator (Normal), by imamelia
;;
;; This generator generates a specific normal sprite from both sides of the screen.
;; The sprite to generate is specified by the first extra byte.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;!SpriteToGen = $01
!Frequency = $3F

XOffsetLo:
db $F0,$FF
XOffsetHi:
db $FF,$00

XSpeed:
db $10,$F0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR GenericHorizGenMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GenericHorizGenMain:

LDA $14				;
AND #!Frequency		; every so many frames...
ORA $9D				; if sprites are not locked...
BNE .Return			; generate a sprite

JSL $82A9DE			; find a free sprite slot
BMI .Return			;

TYX					; we can use X for the sprite index here, since we don't need it for the parent sprite
LDA #$01			;
STA $14C8,x			; set the sprite status to 01 (init)

LDA $7FAB90			; sprite number to generate (8-bit)
STA $9E,x			; set the normal sprite number

JSL $87F7D2			; normal sprite initialization

JSL $81ACF9			; pseudo-random number generator
AND #$7F			;
ADC #$40			;
ADC $1C				;
STA $D8,x			; give the sprite a semi-random Y position
LDA $1D				;
ADC #$00			;
STA $14D4,x			;

LDA $148E			; second random byte
AND #$01			;
TAY					;
LDA XOffsetLo,y		;
CLC					;
ADC $1A				;
STA $E4,x			; X position
LDA $1B				;
ADC XOffsetHi,y		;
STA $14E0,x			;

LDA XSpeed,y			;
STA $B6,x			; set the sprite's X speed

.Return				;
RTS					;


dl $FFFFFF,Main











