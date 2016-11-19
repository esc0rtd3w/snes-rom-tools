;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Boo Ring (sprites E2 and E3), by imamelia
;;
;; This is a disassembly of sprites E2 and E3 in SMW, the rotating Boo rings.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!RotationSpeed = $01		; 01-7F -> clockwise, 80-FF -> counterclockwise

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR BooRingMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BooRingMain:

LDA #!RotationSpeed	;
LDY $18BA			;
CPY #$02				;
BCS .EndBooRing		;
STA $0F				;
LDA #$09			;
STA $0E				;
LDX #$13				; 0x14 cluster sprite indices to loop through
.FindFree				;
LDA $1892,x			;
BNE .CheckNext		;
LDA #$04			; cluster sprite number = 04
STA $1892,x			;
LDA $18BA			;
STA $0F86,x			;
LDA $0E				;
STA $0F72,x			;
LDA $0F				;
STA $0F4A,x			;
STZ $0F				;
BEQ .Skip				;
LDY $18BA			;
LDA $06				; yyyyeeSY
AND #$F0			;
STA $0FB6,y			; Y position low byte of the center of Boo ring
LDA $06				;
AND #$01			;
STA $0FB8,y			; Y position high byte of the center of Boo ring
LDA $00				;
STA $0FB2,y			; X position low byte of the center of Boo ring
LDA $01				;
STA $0FB4,y			; X position high byte of the center of Boo ring
LDA #$00			;
STA $0FBA,y			;
LDA $02				;
STA $0FBC,y			;

.Skip				;
DEC $0E				;
BMI .EndBooRing2		;
.CheckNext			;
DEX					;
BPL .FindFree			;
.EndBooRing2			;
INC $18BA			;
.EndBooRing			;
RTS					;


dl $FFFFFF,Main











