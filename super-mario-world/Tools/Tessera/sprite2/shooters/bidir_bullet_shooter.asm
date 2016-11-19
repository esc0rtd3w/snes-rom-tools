;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 2-Way Bullet Bill Shooter, by imamelia
;;
;; This is a shooter that shoots Bullet Bills in two directions simultaneously.
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

!ShootState = $00
; 00 - left/right
; 01 - up/down
; 02 - diagonally left and up/diagonally right and down
; 03 - diagonally right and up/diagonally left and down

BulletStates:
db $00,$01,$02,$03,$05,$07,$04,$06

SmokeYOffset:
db $00,$00,$00,$00,$FA,$04,$04,$FA

SmokeXOffset:
db $00,$00,$00,$00,$04,$04,$FA,$FA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR BiDirShooterMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BiDirShooterMain:

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

LDA #$01			;
STA $09				;

.ShootBulletLoop		;

LDA #!ShootState		;
ASL					;
ADC $09				;
TAY					;
LDA BulletStates,y		;
STA $08				;

JSL $82A9E4			; find a free sprite slot
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

DEC $09				;
BPL .ShootBulletLoop	;

.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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


dl $FFFFFF,Main











