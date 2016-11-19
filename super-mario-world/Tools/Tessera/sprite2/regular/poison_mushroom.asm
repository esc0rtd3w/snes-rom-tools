;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Poison Mushroom, by imamelia
;;
;; This is the poison mushroom sprite from SMB1.  It is different from the existing
;; one; it acts more like the original.
;;
;; Extra bytes: 0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!PoisonMushXSpeed = $0C
!PoisonMushTile = $06
!PoisonMushPal = $09
!CoverUpTile = $40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR PoisonMushMain
Init:
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PoisonMushMain:

;LDA $64
;STA $03

STZ $04

LDA $1540,x
BEQ .NotBeingSpawned
CMP #$36
BCS .Move2

JSL $819138
LDA $1528,x
BNE .NoPriorityChange
;LDA #$10
;STA $03
INC $04
.NoPriorityChange

LDA $9D
BNE Return06

JSR PoisonMushGFX

LDA #$FC
.SetYSpd
STA $AA,x
JSL $81801A
RTS

.Move2
LDA #$F9
BRA .SetYSpd

.NotBeingSpawned

JSR PoisonMushGFX

LDA $14C8,x
CMP #$08
BNE Return06
LDA $9D
BNE Return06

JSL !SubOffscreenX0

LDA #!PoisonMushXSpeed
LDY $157C,x
BEQ $03
EOR #$FF
INC
STA $B6,x

LDA $1588,x
AND #$04
BEQ .InAir

LDA #$10
STA $AA,x

.InAir

LDA $1588,x
AND #$03
BEQ .UpdatePosition
LDA $157C,x
EOR #$01
STA $157C,x
.UpdatePosition

JSL $81802A
JSL $81A7DC
BCC Return06

LDA $1490
ORA $1497
ORA $1493
BNE Return06

JSL $80F5B7
STZ $14C8,x

Return06:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PoisonMushGFX:

JSL !GetDrawInfo

LDA $04
BEQ .OneTile

LDA $00
STA $0300,y
LDA $01
STA $0301,y
LDA #!CoverUpTile
STA $0302,y
LDA #$00
STA $0303,y

INY #4

.OneTile

LDA $00
STA $0300,y
LDA $01
STA $0301,y
LDA #!PoisonMushTile
STA $0302,y
LDA #!PoisonMushPal
;ORA $03
ORA $64
STA $0303,y

LDY #$02
LDA $04
JSL $81B7B3
RTS


dl Init,Main


