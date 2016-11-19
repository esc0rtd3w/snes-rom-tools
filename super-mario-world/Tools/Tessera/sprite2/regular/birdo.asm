;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB2 Birdo, by mikeyk, modified by imamelia
;;
;; This is a sprite from SMB2 (USA) that spits eggs and fireballs.
;;
;; Extra bytes: 1
;;
;; Bits 0-2: Palette.  (Also determines behavior.)
;; Bit 3: Unused.
;; Bits 4-6: HP.
;; Bit 7: Unused.
;;
;; $C2,x - Stun flag.
;; $1504,x - Spawn timer.
;; $1510,x - Behavior settings.
;; $1528,x - HP.
;; $1534,x - Spawn timer table reset value.
;; $1540,x - State-change timer.
;; $1564,x - Stun timer.
;; $1570,x - Frame counter.
;; $157C,x - Movement direction.
;; $1602,x - Animation frame.
;; $160E,x - Which sprite to spit.
;; $163E,x - Spawn timer.
;; $187B,x - Spawn timer state (index to tables).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Bits 0-1: Spawn timer table index.
; Bits 2-3: sprites to spit (00 - first sprite, 01 - second sprite, 10 - spit both randomly, 11 - alternate between the two)
Settings:
db $00,$00,$00,$00,$09,$05,$00,$00

SpawnTimerPtrs:
dw SpawnTimerTbl1,SpawnTimerTbl2,SpawnTimerTbl3,SpawnTimerTbl4

SpawnTimerTbl1:
db $01 : db $90
SpawnTimerTbl2:
db $03 : db $90,$38,$38
SpawnTimerTbl3:
db $05 : db $90,$38,$38,$38,$38
SpawnTimerTbl4:
db $06 : db $90,$1C,$48,$1C,$48,$1C

SpritesToSpawn:
dw $01B2,$01B1

SpawnStatuses:
db $08,$FF,$01

XSpeed:
db $00,$F8,$00,$08

TimeInState:
db $50,$20,$50,$20

Tilemap:
db $C0,$E0,$C0,$E2,$C2,$E0,$C4,$E0,$C6,$E0

VertDisp:
db $F0,$00

Properties:
db $40,$00

BowXDisp:
db $FD,$02,$FB,$0C

BowYDisp:
db $E8,$F1

BowTilemap:
db $E4,$E6

!BowPalette = $0D

KilledXSpeed:
db $F0,$10

StarSounds:
db $13,$14,$15,$16,$17,$18,$19

SpawnXOffset:
dw $000E,$0002

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		;
AND #$0C			;
LSR					;
TAY					;
REP #$20				;
LDA SpawnTimerPtrs,y	;
STA $02				;
SEP #$20				;
LDA ($02)			;
STA $1534,x			;

LDA $7FAB40,x		;
AND #$07			;
STA $00				;
TAY					;
LDA Settings,y			;
STA $1510,x			;
AND #$0C			;
BEQ .SkipStartSpr		;
CMP #$04			;
BEQ .StartSpr1			;
JSL !RandomNumGen	;
AND #$02			;
STA $160E,x			;
BRA .SkipStartSpr		;
.StartSpr1				;
INC $160E,x			;
INC $160E,x			;
.SkipStartSpr			;

ASL $00				;
LDA $15F6,x			;
AND #$F1			;
ORA $00				;
STA $15F6,x			;

LDA $7FAB40,x		;
AND #$70			;
LSR #4				;
STA $1528,x			;

JSL !SubHorizPos		;
TYA					;
STA $157C,x			;

TXA					;
AND #$03			;
ASL #5				;
STA $163E,x			;
CLC					;
ADC #$22			;
STA $1504,x			;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR BirdoMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReturnMain:			;
RTS					;

BirdoMain:

JSL !SubHorizPos		;
TYA					;
STA $157C,x			; always face the player

JSR ProcessCachedHit	;

JSR BirdoGFX			;

LDA $14C8,x			;
CMP #$08			;
BNE ReturnMain		;
LDA $9D				;
BNE ReturnMain		;

JSL !SubOffscreenX0	;

INC $1570,x			;

LDA $C2,x			; if the "stunned" flag is not set...
BEQ .NormalState		; then the Birdo is in its normal state

LDA $1570,x			; if the Birdo is stunned...
LSR #3				;
AND #$01			;
CLC					;
ADC #$03			; then set the animation frame to 3 or 4
STA $1602,x			;

LDA $1564,x			; if Birdo has been hit...
BEQ .NoStunImage		;

INC $1540,x			; freeze the state-change timer
STZ $B6,x			; and clear the X speed
JMP .Shared			;

.NoStunImage			;
STZ $C2,x			;

.NormalState			;
JSR DecrementTimers	;

LDA $151C,x			;
AND #$01			; if the animation frame is normal...
BEQ .SetFrame			;
LDA $1570,x			;
LSR #3				;
AND #$01			; switch between the first and second animation frame every 8 frames
.SetFrame				;
STA $1602,x			;

LDA $1504,x			;
CMP #$10			; if the time until Birdo spits is less than 0x10...
BCS .JumpBirdo		;

LDA #$02			; set the spitting frame
STA $1602,x			;
INC $1540,x			; freeze the state-change timer
INC $163E,x			; and the jump timer
STZ $B6,x			; zero out the X speed
LDA $1504,x			; if the spawn timer is 0...
BNE .NoReset			;

JSR ResetSpawnTimer	; reset it
BRA .ApplySpeed		;

.NoReset				;
CMP #$05			; if the spawn timer is at 05...
BNE .ApplySpeed		;

JSR SubSpawnSprite		;

.JumpBirdo			;

LDA $163E,x			;
CMP #$28			;
BCS .WalkBirdo			;

INC $1540,x			;
STZ $B6,x			;
LDA $163E,x			;
CMP #$20			;
BNE .NoJump2			;
LDA #$D8			;
STA $AA,x			;
BRA .ApplySpeed		;

.NoJump2			;
CMP #$00			;
BNE .ApplySpeed		;
LDA #$FF				;
STA $163E,x			;
BRA .ApplySpeed		;

.WalkBirdo			;
LDA $151C,x			;
AND #$03			;
TAY					;
LDA $1540,x			;
BEQ .ChangeSpeed		;
LDA XSpeed,y			;
STA $B6,x			;
BRA .ApplySpeed		;

.ChangeSpeed			;
LDA TimeInState,y		;
STA $1540,x			;
INC $151C,x			;

.ApplySpeed			;
LDA $1588,x			;
AND #$03			;
BEQ .NoChangeDir		;
INC $151C,x			;
.NoChangeDir			;

JSR SpriteInteract		;

.Shared				;
JSL $81802A			;
JSL $81A7DC			;
BCC .Return			;
JSR PlayerInteract		;
.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BirdoGFX:

JSL !GetDrawInfo		;

LDA $1602,x			;
ASL					;
STA $03				;
LDA $157C,x			;
STA $02				;

LDA $15F6,x			;
ORA $64				;
STA $04				;

JSR DrawBow			;

LDX $03				;

LDA $00				;
CLC					;
ADC #$08			;
STA $0300,y			;
STA $0304,y			;

LDA $01				;
STA $0305,y			;
CLC					;
ADC #$F0			;
STA $0301,y			;

LDA.w Tilemap,x		;
STA $0302,y			;
LDA.w Tilemap+1,x	;
STA $0306,y			;

LDX $02				;
LDA.w Properties,x		;
ORA $04				;
STA $0303,y			;
STA $0307,y			;

TYA					;
LSR #2				;
TAX					;
LDA #$02			;
STA $0460,x			;
STA $0461,x			;

LDX $15E9			;
LDY #$FF				;
LDA #$02			;
JSL $81B7B3			;
RTS					;

;------------------------------------------------
; bow GFX
;------------------------------------------------

DrawBow:

PHY					;
TYA					;
CLC					;
ADC #$08			;
TAY					;

PHX					;
LDA $C2,x			;
PHA					;
ASL					;
ORA $02				;
TAX					;

LDA.w BowXDisp,x		;
CLC					;
ADC #$08			;
ADC $00				;
STA $0300,y			;

PLX					;
LDA $01				;
CLC					;
ADC.w BowYDisp,x		;
STA $0301,y			;

LDA.w BowTilemap,x	;
STA $0302,y			;

LDA #!BowPalette		;
LDX $02				;
ORA.w Properties,x		;
ORA $64				;
STA $0303,y			;

PLX					;
TYA					;
LSR #2				;
PHA					;
LDA $C2,x			;
EOR #$01				;
ASL					;
PLX					;
STA $0460,x			;
PLY					;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; supporting subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; player interaction
;------------------------------------------------

PlayerInteract:

JSL !SubVertPos		; get the vertical distance between the player and the sprite
LDA $0E				;
CMP #$DB			; if there is vertical contact and the player is not above the sprite...
BPL SpriteWins			; then the sprite damages the player

LDA $7D				; if the player's Y speed is negative...
BMI .Return			; then just return

LDA #$01			;
STA $1471			; set the "on sprite" flag
LDA #$06			;
STA $154C,x			; disable interaction for a few frames
STZ $7D				; zero out the player's Y speed

LDA #$D6			;
LDY $187A			; depending on whether or not the player is riding Yoshi,
BEQ $02				;
LDA #$C6			; offset his/her Y position by either D6 or C6 pixels
STA $00				;

LDA $00				;
CLC					;
ADC $D8,x			;
STA $96				;
LDA $14D4,x			; handle the high byte
ADC #$FF			;
STA $97				;

LDY #$00				;
LDA $1491			; $1491 - amount to move the player along the X-axis
BPL $01				;
DEY					; high byte: 00 or FF depending on direction
CLC					;
ADC $94				; synchronize the player's X position with the sprite's
STA $94				;
TYA					;
ADC $95				; handle the high byte
STA $95				;

.Return				;
RTS					;

SpriteWins:			;

LDA $154C,x			; if interaction is disabled...
ORA $15D0,x			; or the sprite is being eaten...
BNE .Return			; then don't damage the player

LDA $1490			; if the player has a star...
BNE HasStar			; then he/she doesn't take damage

JSL $80F5B7			; player hurt routine

.Return				;
RTS					;

SpinKill:

JSR SubStompPoints		;
LDA #$F8				;
STA $7D				; set the player's bounce-off Y speed
JSL $81AB99			; show contact graphic
LDA #$04			;
STA $14C8,x			; set the sprite status to 4 (spin-killed)
LDA #$1F				;
STA $1540,x			; set the spin-jump animation timer
JSL $87FC3B			; show the spin-jump stars
LDA #$08			;
STA $1DF9			; play a sound effect
RTS					;

HasStar:

LDA #$02			;
STA $14C8,x			; set the sprite status to 2 (killed, falling offscreen)
LDA #$D0			;
STA $AA,x			; set the death Y speed

JSL !SubHorizPos		;

LDA KilledXSpeed,y		; set the death X speed
STA $B6,x			;

INC $18D2			; increment the number of consecutive enemies killed
LDA $18D2			;
CMP #$08			; if the counter has reached 8...
BCC .NoReset			;
LDA #$08			;
STA $18D2			; keep it at 8
.NoReset				;

JSL $82ACE5			; give points

LDY $18D2			;
CPY #$08				; unless the counter is 08 or higher...
BCS .NoSound			;
LDA StarSounds-1,y	; play a sound effect for the star kill
STA $1DF9			;
.NoSound				;
RTS					;

;------------------------------------------------
; sprite interaction
;------------------------------------------------

SpriteInteract:

LDY #$0B				;
.Loop				;
LDA $14C8,y			;
CMP #$09			;
BCS .ProcessSprite		;
.NextSprite			;
DEY					;
BPL .Loop				;
RTS					;
	
.ProcessSprite			;
PHX					;
TYX					;
JSL $83B6E5			;
PLX					;
JSL $83B69F			;
JSL $83B72B			;
BCC .NextSprite		;

PHX					;
TYX					;
JSL $81AB72			;

LDA $14C8,x			;
CMP #$0A			;
BEQ .NoKill			;

LDA #$02			;
STA $14C8,x			;
LDA #$D0			;
STA $AA,x			;
LDY #$00				;
LDA $B6,x			;
BPL $01				;
INY					;
LDA KilledXSpeed,y		;
STA $B6,x			;

.NoKill				;
PLX					;

HandleBirdoHit:		;

LDA #$28			;
STA $1DFC			;
LDA #$01			;
STA $C2,x			;
LDA #$20			;
STA $1564,x			;

DEC $1528,x			; decrement Birdo's HP
BNE HitReturn			;

LDA #$02			;
STA $14C8,x			;
LDA #$D0			;
STA $AA,x			;
TYA					;
EOR #$01				;
TAY					;
LDA KilledXSpeed,y		;
STA $B6,x			;
LDA #$03			;
STA $1602,x			;

HitReturn:			;
RTS					;

ProcessCachedHit:

LDA $1528,x			;
BPL HitReturn			;
AND #$7F			;
STA $1528,x			;
BRA HandleBirdoHit		;

;------------------------------------------------
; sprite-spawning routine
;------------------------------------------------

SubSpawnSprite:

LDA $15A0,x			;
ORA $186C,x			;
ORA $15D0,x			;
BNE .Return			;

JSL $82A9E4			;
BMI .Return			;

LDA #$20			;
STA $1DF9			;

JSR SpawnShared1		;

PHX					;
STY $08				;
LDY $160E,x			;
LDA SpawnStatuses,y	;
LDX $08				;
STA $14C8,x			;
REP #$20				;
LDA SpritesToSpawn,y	;
SEP #$20				;
STA $7FAB9E,x		;
XBA					;
ORA #$80			;
STA $7FAB10,x		;
JSL $81830B			;
PLX					;
LDY $08				;

LDA $157C,x			;
STA $157C,y			;

LDA $160E,x			;
BNE .Return			;

;LDA #$08			;
;STA $1540,y			;

LDA #$80			;
STA $00C2,y			;

.Return				;
RTS					;

SpawnShared1:

PHY					;
LDA $157C,x			;
ASL					;
TAY					;
REP #$20				;
LDA SpawnXOffset,y	;
STA $00				;
SEP #$20				;
PLY					;
LDA $E4,x			;
CLC					;
ADC $00				;
STA $00E4,y			;
LDA $14E0,x			;
ADC $01				;
STA $14E0,y			;

LDA $D8,x			;
SEC					;
SBC #$0E				;
STA $00D8,y			;
LDA $14D4,x			;
SBC #$00				;
STA $14D4,y			;

RTS					;

;------------------------------------------------
; stomp points routine
;------------------------------------------------

SubStompPoints:

PHY
INC $1697
LDY $1697
CPY #$08
BCS .NoSound
LDA StarSounds,y
STA $1DF9
.NoSound
TYA
CMP #$08
BCC .NoReset
LDA #$08
.NoReset
JSL $82ACE5
PLY
RTS

;------------------------------------------------
; code to reset the spawn timer
;------------------------------------------------

ResetSpawnTimer:

LDA $1510,x			;
AND #$0C			;
LSR					;
TAY					;
REP #$20				;
LDA SpawnTimerPtrs,y	;
STA $00				;
SEP #$20				;
LDY $187B,x			;
INY					;
LDA ($00),y			;
STA $1504,x			;
INC $187B,x			;
LDA $187B,x			;
CMP $1534,x			;
BCC .Return			;
STZ $187B,x			;
.Return				;
RTS					;

;------------------------------------------------
; code to decrement the spawn timer
;------------------------------------------------

DecrementTimers:

LDA $1504,x			;
BEQ .Return			;
DEC $1504,x			;
.Return				;
RTS					;


dl Init,Main
