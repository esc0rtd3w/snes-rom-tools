;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Bullet Bill Shooter, by imamelia
;;
;; This is a shooter that shoots Bullet Bills in a single direction depending on where
;; the player is.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ShootSFX = $091DFC

; time between firing
!ShootTimer = $60

!ShootState = $03
; 00 - left/right
; 01 - up/down
; 02 - diagonally left and up/diagonally right and down
; 03 - diagonally right and up/diagonally left and down

BulletStates:
db $00,$00,$01,$01,$00,$00,$01,$01	; left/right, quadrants 0-7
db $02,$02,$02,$02,$03,$03,$03,$03	; up/down, quadrants 0-7
db $05,$07,$07,$07,$05,$05,$07,$05	; left-up/right-down, quadrants 0-7
db $04,$04,$06,$04,$04,$06,$06,$06	; right-up/left-down, quadrants 0-7

; 00 - right
; 01 - left
; 02 - up
; 03 - down
; 04 - up-right
; 05 - down-right
; 06 - down-left
; 07 - up-left

; right, left, up, down, up-right, down-right, down-left, up-left
SmokeYOffset:
db $00,$00,$F6,$0A,$F6,$0A,$0A,$F6

SmokeXOffset:
db $0A,$F6,$00,$00,$0A,$0A,$F6,$F6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR BulletShooterMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BulletShooterMain:

LDA $17AB,x			; if it isn't time to generate the Bullet Bill yet...
BNE .Return			; return

LDA #!ShootTimer		; if it is time to generate...
STA $17AB,x			; reset the shoot timer

LDA $178B,x			;
CMP $1C				;
LDA $1793,x			;
SBC $1D				;
BNE .Return			; don't generate if the shooter is offscreen vertically

LDA $179B,x			;
CMP $1A				;
LDA $17A3,x			;
SBC $1B				;
BNE .Return			; don't generate if the shooter is offscreen horizontally

LDA $179B,x			;
SEC					;
SBC $1A				;
CLC					;
ADC #$10			;
CMP #$10			; don't generate if the shooter is only 8 pixels from a screen boundary
BCS ShootBullet		;

.Return				;
RTS					;

ShootBullet:			;

LDA #!ShootState		;
ASL #3				;
STA $00				;
JSR FindSubQuadrant	;
ORA $00				;
TAY					;
LDA BulletStates,y		;
STA $08				;

JSL $82A9DE			; find a free sprite slot
BMI .Return			; if "n" is set here, all slots are full; else, Y holds the next index

LDA.b #!ShootSFX>>16	; play a sound effect - sound effect number
STA.w !ShootSFX		; sound effect bank

LDA #$08			;
STA $14C8,y			; sprite status for new sprite

LDA #$1C			;
STA $009E,y			; sprite number for new sprite

LDA $179B,x			; position for new sprite
STA $00E4,y			; X position low
LDA $17A3,x			;
STA $14E0,y			; X position high
LDA $178B,x			;
SEC					;
SBC #$01				;
STA $00D8,y			; Y position low
LDA $1793,x			;
SBC #$00				;
STA $14D4,y			; Y position high

PHX					; preserve the shooter index
TYX					; spawned sprite index into X
JSL $87F7D2			; clear all old sprite table values and load new ones
PLX					;

LDA $08				; which way the bullet is going
STA $00C2,y			; sprite state
LDA #$10			;
STA $1540,y			;

JSR SubSmoke			; generate smoke from the shooter

.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----------------------------------------
; generate smoke
;----------------------------------------

SubSmoke:

LDY #$03
.FindFree
LDA $17C0,y
BEQ .FoundOne
DEY
BPL .FindFree
RTS

.FoundOne

LDA #$01
STA $17C0,y

STX $0A
LDA $178B,x
LDX $08
CLC
ADC SmokeYOffset,x
STA $17C4,y
LDX $0A

LDA $179B,x
LDX $08
CLC
ADC SmokeXOffset,x
STA $17C8,y
LDX $0A

LDA #$1B
STA $17CC,y

RTS

;----------------------------------------
; figure out which of 8 subquadrants the player is in
;----------------------------------------

; 0 - x+, y-, abs(x) > abs(y)
; 1 - x+, y-, abs(x) < abs(y)
; 2 - x-, y-, abs(x) > abs(y)
; 3 - x-, y-, abs(x) < abs(y)
; 4 - x+, y+, abs(x) > abs(y)
; 5 - x+, y+, abs(x) < abs(y)
; 6 - x-, y+, abs(x) > abs(y)
; 7 - x-, y+, abs(x) < abs(y)

FindSubQuadrant:

STZ $08			; start off at 0
LDA $96			;
SEC				;
SBC $178B,x		; first, figure out the Y distance
STA $0A			;
LDA $97			;
SBC $1793,x		; Y distance negative -> subquadrant 0, 1, 2, 3; Y distance positive -> subquadrant 4, 5, 6, 7
STA $0B			;
BMI .Bit2Clear		;
LDA #$04		; if the quadrant number is 4, 5, 6, or 7, set bit 2
TSB $08			;
.Bit2Clear			;
LDA $94			;
SEC				;
SBC $179B,x		; next, figure out the X distance
STA $0C			;
LDA $95			;
SBC $17A3,x		; X distance positive -> subquadrant 0, 1, 4, 5; X distance negative -> subquadrant 2, 3, 6, 7
STA $0D			;
BPL .Bit1Clear		;
LDA #$02		; if the quadrant number is 2, 3, 6, or 7, set bit 1
TSB $08			;
.Bit1Clear			;
REP #$20			; finally, figure out whether the absolute value of the X distance is greater than or less than the absolute value of the Y distance
LDA $0A			;
BPL .NoFlipY		;
EOR #$FFFF		; invert the Y distance if negative
INC				;
.NoFlipY			;
STA $0E			;
LDA $0C			;
BPL .NoFlipX		;
EOR #$FFFF		; invert the X distance if negative
INC				;
.NoFlipX			;
CMP $0E			; X greater than Y -> subquadrant 0, 2, 4, 6; X less than Y -> subquadrant 1, 3, 5, 7
SEP #$20			;
BCS .Bit0Clear		;
LDA #$01		; if the quadrant number is 1, 3, 5, or 7, set bit 0
TSB $08			;
.Bit0Clear			;
LDA $08			; return the resulting value
RTS				;


dl $FFFFFF,Main











