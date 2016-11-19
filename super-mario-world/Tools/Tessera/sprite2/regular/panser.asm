;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Panser, by imamelia
;;
;; This is the fireball-spitting plant from SMB2.
;;
;; Number of extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-7: Index to data tables.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The bits in this table goes as follows:
; Bit 0: 0 -> stationary, 1 -> moving.
; Bit 1: 0 -> spit fireballs in an arc, 1 -> spit straight up.
; Bit 2: 0 -> fall off ledges, 0 -> stay on ledges.  (Has no effect if the sprite is stationary.)
; Bit 3: 0 -> don't face the player, 1 -> turn to face the player every so often.  (Has no effect
;	if the sprite is stationary.)
; Bit 4: 0 -> don't jump over shells, 1 -> jump over shells.
; Bits 5-7: Spit timer index.
MainProperties:
db $00,$02,$01,$03,$00,$00,$00,$00

SpritePalette:
db $08,$0A,$06,$04,$00,$00,$00,$00

XSpeed:
db $0A,$F6

Tilemap:
db $84,$84,$86

TileProps:
db $00,$40,$00

SpitTimerPtrs:
dw SpitTimerTbl1,SpitTimerTbl2,SpitTimerTbl3,SpitTimerTbl4
dw SpitTimerTbl5,SpitTimerTbl6,SpitTimerTbl7,SpitTimerTbl8

; For each of these tables, the first number is how many total fireballs
; the Panser will spit before the pattern repeats.  The rest are the timers
; between each fireball.
SpitTimerTbl1:
db $08 : db $58,$28,$58,$28,$58,$58,$28,$58
SpitTimerTbl2:
db $02 : db $58,$28
SpitTimerTbl3:
db $08 : db $58,$28,$58,$28,$28,$58,$28,$58
SpitTimerTbl4:
db $01 : db $58
SpitTimerTbl5:
db $01 : db $28
SpitTimerTbl6:
db $06 : db $10,$10,$10,$10,$60,$60
SpitTimerTbl7:
db $03 : db $10,$10,$60
SpitTimerTbl8:
db $10 : db $0C,$58,$0C,$28,$0C,$58,$0C,$28,$0C,$58,$0C,$58,$0C,$28,$0C,$58

; the Panser will open to fire when the spit timer reaches this
!TimeTillOpen = $12

; sprite number of the fireball
!FireballSprNum = $01B1|$8000

FireballXSpeed:
db $16,$EA
!FireballYSpeed = $B8

; $1510,x = behavior properties
; $151C,x = turning flag
; $1570,x = frame counter
; $157C,x = direction
; $15AC,x = turn timer
; $1602,x = animation frame
; $160E,x = spit timer table reset value
; $163E,x = spit timer
; $187B,x = index to spit timer tables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		;
TAY					;
LDA MainProperties,y	;
STA $1510,x			;
LDA $15F6,x			;
AND #$F1			;
ORA SpritePalette,y		;
STA $15F6,x			;
LDA $1510,x			;
AND #$E0			;
LSR #4				;
TAY					;
REP #$20				;
LDA SpitTimerPtrs,y	;
STA $00				;
SEP #$20				;
LDA ($00)			;
STA $160E,x			;
LDY #$01				;
LDA ($00),y			;
STA $163E,x			;

JSL !SubHorizPos		;
TYA					;
STA $157C,x			;

RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR PanserMainRt
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PanserMainRt:

JSR PanserGFX			;

LDA $14C8,x			;
CMP #$08			;
BNE .Return			;
LDA $9D				;
BNE .Return			;

JSL !SubOffscreenX0	;

INC $1570,x			; increment the frame counter

LDA $1570,x			;
LSR #3				;
AND #$01			;
STA $1602,x			;

LDY $163E,x			;
CPY.b #!TimeTillOpen+1	;
BCS .NoOpenFrame		;
LDA #$02			;
STA $1602,x			;
.NoOpenFrame			;
DEY					;
BNE .NoSpit			;
JSR SpawnFireball		;
JSR ResetSpitTimer		;
.NoSpit				;

LDA $1510,x			;
AND #$01			; if the sprite is stationary...
BEQ .NoSpeed			; don't set its speed

LDY $157C,x			;
LDA XSpeed,y			;
STA $B6,x			; sprite X speed
.NoSpeed				;

JSL $81802A			; update the sprite position

LDA $1588,x			;
AND #$03			; if the sprite is touching a wall...
BEQ .NoWallContact		;
JSR SetSpriteTurning	; make it turn around
.NoWallContact		;

JSR MaybeStayOnLedges	; stay on ledges if the relevant bit is set

LDA $1588,x			;
AND #$04			; if the sprite is on the ground...
BEQ .NotOnGround		;
STZ $AA,x			; clear the Y speed
STZ $151C,x			; and the turning flag
JSR MaybeFacePlayer	; turn to face the player if the relevant bit is set
JSR MaybeJumpShells	; jump over thrown sprites if the relevant bit is set
.NotOnGround			;

JSL $81803A			; interact with the player and with other sprites

.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PanserGFX:

JSL !GetDrawInfo		;

LDA $15F6,x			;
ORA $64				;
STA $03				;

LDA $00				;
STA $0300,y			;
LDA $01				;
STA $0301,y			;
LDA $1602,x			;
TAX					;
LDA.w Tilemap,x		;
STA $0302,y			;
LDA $03				;
ORA TileProps,x		;
STA $0303,y			;

LDX $15E9			;
LDY #$02				;
LDA #$00			;
JSL $81B7B3			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; fireball-spawning routine
;------------------------------------------------

SpawnFireball:

JSL $82A9E4
BMI .Return

LDA #$01
STA $14C8,y

PHX
TYX
LDA.b #!FireballSprNum
STA $7FAB9E,x
LDA.b #!FireballSprNum>>8
STA $7FAB10,x
JSL $81830B
PLX

LDA $E4,x
STA $00E4,y
LDA $14E0,x
STA $14E0,y
LDA $D8,x
SEC
SBC #$0C
STA $00D8,y
LDA $14D4,x
SBC #$00
STA $14D4,y

LDA $1510,x
AND #$02
BNE .NoXSpeed
PHY
JSL !SubHorizPos
LDA FireballXSpeed,y
PLY
STA $00B6,y
.NoXSpeed

LDA #!FireballYSpeed
STA $00AA,y

LDA #$03
STA $00C2,y

LDA #$27
STA $1DFC

.Return
RTS

;------------------------------------------------
; ledge check/set routine
;------------------------------------------------

MaybeStayOnLedges:

LDA $1510,x			; behavioral properties
AND #$04			; if the sprite is not set to stay on ledges...
BEQ .Return			; don't stay on ledges
LDA $1588,x			; unless the sprite is touching an object...
ORA $151C,x			; or already turning...
BNE .Return			;
JSR SetSpriteTurning	; make the sprite turn around
LDA #$01			;
STA $151C,x			; set the turning flag
.Return				;
RTS					;

;------------------------------------------------
; face player routine
;------------------------------------------------

MaybeFacePlayer:

LDA $1510,x			; behavioral properties
AND #$08			; if the sprite is not set to face the player...
BEQ .Return			; skip the routine
LDA $1570,x			;
AND #$7F			; turn around only once every 0x80 frames
BNE .Return			;

LDA $157C,x			;
PHA					;
JSL !SubHorizPos		;
TYA					;
STA $157C,x			;
PLA					;
CMP $157C,x			;
BEQ .Return			;
LDA #$08			;
STA $15AC,x			;

.Return				;
RTS					;

;------------------------------------------------
; shell-jumping routine
;------------------------------------------------

MaybeJumpShells:

LDA $1510,x			;
AND #$10			; if the sprite isn't set to jump over shells...
BEQ .Return			; skip everything

TXA					;
EOR $13				;
AND #$03			; process every 4 frames
BNE .Return			;

LDY #$0B				;
.Loop				;
LDA $14C8,y			;
CMP #$0A			;
BEQ .JumpOver			;
.Next				;
DEY					;
BPL .Loop				;

.Return				;
RTS					;

.JumpOver

LDA $1588,x			;
AND #$04			;
BEQ .Next			;

LDA $00E4,y			; set up the clipping location
SEC					;
SBC #$1A				;
STA $00				;
LDA $14E0,y			;
SBC #$00				;
STA $08				;
LDA #$44			;
STA $02				;
LDA $00D8,y			;
STA $01				;
LDA $14D4,y			;
STA $09				;
LDA #$10			;
STA $03				;

JSL $83B69F			;
JSL $83B72B			;
BCC .Next			;

LDA $1510,x			;
AND #$01			;
BEQ .MakeSpriteJump	;

LDA $157C,y			;
CMP $157C,x			;
BEQ .Return			;

.MakeSpriteJump		;
LDA #$C0			;
STA $AA,x			;
RTS					;

;------------------------------------------------
; turning set routine
;------------------------------------------------

SetSpriteTurning:

LDA #$08			;
STA $15AC,x			;
LDA $157C,x			;
EOR #$01				;
STA $157C,x			;
RTS					;

;------------------------------------------------
; turning set routine
;------------------------------------------------

ResetSpitTimer:

LDA $1510,x			;
AND #$E0			;
LSR #4				;
TAY					;
REP #$20				;
LDA SpitTimerPtrs,y	;
STA $00				;
SEP #$20				;
LDY $187B,x			;
INY					;
LDA ($00),y			;
STA $163E,x			;
INC $187B,x			;
LDA $187B,x			;
CMP $160E,x			;
BCC .Return			;
STZ $187B,x			;
.Return				;
RTS					;


dl Init,Main











