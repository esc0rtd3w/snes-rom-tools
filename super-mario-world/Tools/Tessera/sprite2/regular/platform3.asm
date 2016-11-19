;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Platform, by imamelia
;;
;; This is a platform.  It can be set to float, fall, move forward, or move back and
;; forth, and its graphics are customizable as well.
;;
;; Uses extra property bytes: YES
;;
;; If bit 0 of the extra property byte 1 is set, the sprite will appear and disappear.  This
;; will also require it to use 4 extra bytes; otherwise, it will use only 3.
;;
;; Extra bytes: 3 or 4
;;
;; Extra byte 1:
;;
;; Bits 0-2: Behavior.  000 = stationary, 001 = move forward, 010 = move back and forth, 011 = fall when stepped on,
;; 	 100 = float, 101 = move in a circle, 110 = move in a sine wave, 111 = unused.
;; Bits 3-5: Platform width.  000 = 1 tile, 001 = 2 tiles, 010 = 3 tiles, 011 = 4 tiles, 100 = 5 tiles, 101 = 6 tiles,
;; 110 = 7 tiles, 111 = 8 tiles.
;; Bits 6-7:
;;	- For platforms that move forward or back and forth, this is the speed index setting.
;;	- For platforms that move in a circle, this is the rotation speed index setting.
;;
;; Extra byte 2:
;;
;; Bits 0-2:
;;	- For platforms that move back and forth or forward, this is the direction.  000 = right, 001 = left, 010 = up,
;;	011 = down, 100 = diagonally up-right, 101 = diagonally up-left, 110 = diagonally down-right,
;;	111 = diagonally down-left.
;;	- For platforms that move in a sine wave, this is the index to the speed tables.
;;	- For platforms that move in a circle, this is the radius divided by 10, plus 8.
;;	- For platforms that fall, this is the number of frames it will fall slowly before falling quickly, divided by 4.
;; Bit 3:
;;	- For platforms that move in a circle, this is the rotation direction.
;;	- For platforms that move in a sine wave, this is the direction.
;; Bits 4-7: Tilemap/palette index.
;;
;; Extra byte 3:
;;
;; Bits 0-3:
;;	- For platforms that move back and forth, this is how long the platform should move before slowing
;;	down to reverse direction, in multiples of 0x10 frames.
;;	- For platforms that move in a circle, this is the index to the starting angle of the platform.
;; Bits 4-7: If the platform appears and disappears, this sets the frame at which it should appear.  These
;;	bits are unused otherwise.
;;
;; Extra byte 4:
;;
;; Bits 0-3: If the platform appears and disappears, this determines how long the platform should stay
;;	visible.  (This number times 0x10 frames.) These bits are unused otherwise.
;; Bits 4-7: If the platform appears and disappears, this determines how long the platform should stay
;;	invisible.  (This number times 0x10 frames.) These bits are unused otherwise.
;;
;; Notes:
;;
;; - The tilemap settings are defined in the three tilemap tables: LeftTile, MidTile, and RightTile.  If the platform
;; is only 2 tiles wide, the middle tile will not be used, and if the platform is only 1 tile wide, the left and right
;; tiles will not be used.
;; - The appearing/disappearing platform requires one more extra byte than the normal platform and a separate
;; .cfg file.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AppearSFX = $10			; sound to play when appearing
!AppearSFXBank = $1DF9	;

ClipWidth:
db $0E,$1E,$2E,$3E,$4E,$5E,$6E,$7E

Offset:
db $00,$F8,$F0,$E8,$E0,$D8,$D0,$C8

IncDecTbl:
db $01,$FF

RotationSpeed:
db $01,$02,$03,$04

DirectionFlags:
db $02,$02,$04,$04,$06,$06,$06,$06

NewDirection:
db $01,$00,$03,$02,$07,$06,$05,$04

InitXSpeed:
db $01,$FF,$00,$00,$01,$FF,$01,$FF

InitYSpeed:
db $00,$00,$FF,$01,$FF,$FF,$01,$01

MoveXSpeed:
db $08,$F8,$00,$00,$08,$F8,$08,$F8	; speed index 0
db $0C,$F4,$00,$00,$0C,$F4,$0C,$F4	; speed index 1
db $10,$F0,$00,$00,$10,$F0,$10,$F0	; speed index 2
db $14,$EC,$00,$00,$14,$EC,$14,$EC	; speed index 3

MoveYSpeed:
db $00,$00,$F8,$08,$F8,$F8,$08,$08	; speed index 0
db $00,$00,$F4,$0C,$F4,$F4,$0C,$0C	; speed index 1
db $00,$00,$F0,$10,$F0,$F0,$10,$10	; speed index 2
db $00,$00,$EC,$14,$EC,$EC,$14,$14	; speed index 3

SineXSpeed:
db $08,$0C,$10,$14,$0C,$10,$14,$18

SineYSpeed:
db $00,$F4,$EA,$E3,$E0,$E3,$EA,$F4
db $00,$0C,$16,$1D,$20,$1D,$16,$0C
db $00,$F8,$F2,$EE,$EC,$EE,$F2,$F8
db $00,$08,$0E,$12,$14,$12,$0E,$08
db $00,$FC,$F9,$F7,$F6,$F7,$F9,$FC
db $00,$04,$07,$09,$0A,$09,$07,$04
db $00,$FF,$FE,$FD,$FC,$FD,$FE,$FF
db $00,$01,$02,$03,$04,$03,$02,$01
db $00,$F4,$EA,$E3,$E0,$E3,$EA,$F4
db $00,$0C,$16,$1D,$20,$1D,$16,$0C
db $00,$F8,$F2,$EE,$EC,$EE,$F2,$F8
db $00,$08,$0E,$12,$14,$12,$0E,$08
db $00,$FC,$F9,$F7,$F6,$F7,$F9,$FC
db $00,$04,$07,$09,$0A,$09,$07,$04
db $00,$FF,$FE,$FD,$FC,$FD,$FE,$FF
db $00,$01,$02,$03,$04,$03,$02,$01 

FloatYSpeed:
db $FE,$FD,$FE,$02,$03,$02
;db $FF,$FE,$FF,$01,$02,$01
;db $02,$03,$02,$FE,$FD,$FE
;db $01,$02,$01,$FF,$FE,$FF

StartingAngle:
dw $0000,$0040,$0080,$00C0,$0100,$0140,$0180,$01C0,$0055,$00AA,$0155,$01AA,$0066,$00CC,$0133,$0199
; dw $0000
; dw $0000,$0100
; dw $0000,$00AA,$0155
; dw $0000,$0080,$0100,$0180
; dw $0000,$0066,$00CC,$0133,$0199
; dw $0000,$0055,$00AA,$0100,$0155,$01AA
; dw $0000,$0049,$0092,$00DB,$0124,$016D,$01B6
; dw $0000,$0040,$0080,$00C0,$0100,$0140,$0180,$01C0

LeftTile:
db $60,$EA,$C4,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
MidTile:
db $61,$EB,$40,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
RightTile:
db $62,$EC,$C4,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

LTileProps:
db $31,$33,$3B,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
MTileProps:
db $31,$33,$34,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
RTileProps:
db $31,$33,$7B,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

; $C2,x - sprite state (for the disappearing/reappearing platform)
; $1504,x - sprite state timer (for the disappearing/reappearing platform)
; $1510,x - behavior setting
; $151C,x - time to stay solid (for the disappearing/reappearing platform)
; $1534,x - time to stay invisible (for the disappearing/reappearing platform)
; $1564,x - misc. timer
;	- for the back-and-forth platform: time before the platform slows down to reverse direction
;	- for the falling platform: time before it starts falling faster
; $1594,x - misc. table
; 	- for the back-and-forth platform: movement state
;	- for the floating platform: sprite state frame counter
;	- for the sine-wave platform: speed state frame counter
; $1570,x - frame at which the disappearing/reappearing platform should appear
; $157C,x - misc. table
;	- for the continuous, back-and-forth, and sine-wave platforms: direction
;	- for the rotating platform: radius
; $187B,x - misc. table
;	- for the continuous, back-and-forth, and sine-wave platforms: speed index
;	- for the rotating platform: rotation speed index
;	- for the floating platform: movement state
; $1602,x - tilemap index
; $160E,x - clipping index
; $1626,x - flags
;	bit 0: the sprite has been touched by the player (all)
;	bit 1:
;		- the sprite moves horizontally (back-and-forth)
;		- the sprite is floating back up after being stood upon by the player (floating)
;	bit 2: the sprite moves vertically (back-and-forth)
;	bit 3: the player is touching the sprite on this particular frame (all)
; $1FD6,x - speed state for the sine-wave platform
; $7FAD00,x = speed
; $7FAD0C,x = X radius
; $7FAD18,x = Y radius
; $7FAD24,x = center X position low byte
; $7FAD30,x = center Y position low byte
; $7FAD3C,x = center X position high byte
; $7FAD48,x = center Y position high byte
; $7FAD54,x = angle low byte
; $7FAD60,x = angle high byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR PlatformInit
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlatformInit:

LDA $7FAB40,x		; extra byte 1
PHA					;
PHA					;
AND #$07			;
STA $1510,x			; $1510,x = behavior
PLA					;
LSR #3				;
AND #$07			;
STA $160E,x			; $160E,x = clipping width/offset index
BNE .NotOneBlock		;
LDA $190F,x			; if the platform is only one tile wide,
AND #$FE			; make it solid from the bottom and sides as well
STA $190F,x			;
.NotOneBlock			;
PLA					;
ROL #3				;
AND #$03			;
STA $187B,x			; $187B,x = speed/rotation speed index
TAY					;
LDA RotationSpeed,y	;
STA $7FAD00,x		; $7FAD00,x = rotation speed

LDA $7FAB4C,x		; extra byte 2
PHA					;
PHA					;
AND #$07			;
STA $157C,x			; $157C,x = direction/radius/fall timer
TAY					;
LDA DirectionFlags,y	;
STA $1626,x			;
PLA					;
AND #$08			;
BNE .NoFlipRotSpeed	;
LDA $7FAD00,x		;
EOR #$FF				;
INC					;
STA $7FAD00,x		;
.NoFlipRotSpeed		;
PLA					;
LSR #4				;
STA $1602,x			; $1602,x = tilemap to use

LDA $7FAB58,x		; extra byte 3
PHA					;
AND #$0F			;
ASL					;
TAY					;
LDA StartingAngle,y	;
STA $7FAD54,x		; low byte of starting angle
LDA StartingAngle+1,y	;
STA $7FAD60,x		; high byte of starting angle
TYA					;
ASL #3				;
STA $1564,x			; $1564,x - movement timer
PLA					;
AND #$F0			;
STA $1570,x			; $1570,x = frame at which the appearing/disappearing platform should appear

LDA $7FAB64,x		; extra byte 4
PHA					;
AND #$0F			;
ASL #4				;
STA $151C,x			; $151C,x - time to stay solid
PLA					;
AND #$F0			;
STA $1534,x			; $1534,x - time to stay invisible

LDA $7FAB28,x		; extra property byte 1
LSR					;
LDA #$04			; if the platform appears and disappears,
BCS .SetInitState		; it will start out in state 4
LDA #$01			;
STA $1504,x			;
LDA #$02			; if the platform doesn't appear and disappear,
.SetInitState			; it will start out in state 2
STA $C2,x			;

LDA $157C,x			; here, $157C,x indicates the radius
ASL #4				;
ADC #$08			;
STA $7FAD0C,x		; set the X radius
STA $7FAD18,x		; set the Y radius

LDA $1510,x			;
JSL $8086DF			;

dw InitS00			;
dw InitS01			;
dw InitS02			;
dw InitS03			;
dw InitS04			;
dw InitS05			;
dw InitS06			;
dw InitS07			;

InitS04:				;

LDA $D8,x			;
SEC					;
SBC #$03				;
STA $D8,x			;
LDA $14D4,x			;
SBC #$00				;
STA $14D4,x			;

STZ $187B,x			;
BRA ContinueInit		;

InitS06:				;

LDA $157C,x			;
STA $187B,x			;
LDA $7FAB4C,x		;
AND #$08			;
LSR #3				;
STA $157C,x			;

InitS00:				;
InitS03:				;
InitS05:				;
InitS07:				;

ContinueInit:			;

STZ $1626,x			; if the behavior setting isn't 1 or 2, clear all flags

InitS01:				;
InitS02:				;

LDA $E4,x			;
STA $7FAD24,x		; set the coordinates of the center of a circle
LDA $D8,x			;
STA $7FAD30,x		;
LDA $14E0,x			;
STA $7FAD3C,x		;
LDA $14D4,x			;
STA $7FAD48,x		;

RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR PlatformMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlatformMain:

LDA $C2,x			;
CMP #$02			;
BNE .NoGFX			;
JSR PlatformGFX		;
.NoGFX				;

LDA $14C8,x			;
CMP #$08			;
BNE ReturnM			;
LDA $9D				;
BNE ReturnM			;

JSL !SubOffscreenX0	;

PEA.w Continue-$01	;
LDA $1510,x			; behavior
JSL $8086DF			;

dw Stationary			; 00 - stationary
dw MoveForward		; 01 - move forward
dw BackAndForth		; 02 - move back and forth
dw FallAfterStep		; 03 - fall after being stepped on
dw FloatOnLiquid		; 04 - float on water and lava
dw MoveInCircle		; 05 - move in a circle
dw MoveInWave		; 06 - move in a sine wave
dw ReturnM			; 07 - unused

Stationary:			;
ReturnM:				;
RTS					;

Continue:			;

LDA $7FAB28,x		;
LSR					; if bit 0 of the extra property byte 1 is not set...
BCC .AlwaysSolid		; then the platform is always solid

LDA $1504,x			;
BEQ .NoDec			; if the platform appears and disappears,
DEC $1504,x			; decrement the state-change timer
.NoDec				;
;LDA $C2,x			;
;CMP #$02			; if the platform isn't solid...
;BNE .AppearStateRt		; skip the interaction routine
.AlwaysSolid			;
;JSR Interact			; platform interaction code

LDA $C2,x			; appearing/disappearing platform routine
JSL $8086DF			;

dw S00_Invisible		; state 00 - invisible
dw S01_Appearing		; state 01 - appearing
dw S02_Solid			; state 02 - solid
dw S03_Disappearing	; state 03 - disappearing
dw S04_InvisibleInit	; state 04 - invisible at start

S00_Invisible:			;

LDA $1504,x			;
BNE .NoAppear		; if the state-change timer is down to 0, then the sprite will appear
INC $C2,x			;
.NoAppear			;
RTS					;

S01_Appearing:		;

LDA #!AppearSFX		; sound effect to play
BEQ $03				;
STA !AppearSFXBank	;
LDA $151C,x			;
STA $1504,x			; set the time to remain solid
INC $C2,x			; set the sprite state to 01
RTS					;

S02_Solid:			;

LDA $1504,x			;
BNE .NoDisappear		; if the state-change timer is down to 0, then the sprite will disappear
INC $C2,x			;
.NoDisappear			;
JSR Interact			; make the sprite act like a solid block
RTS					;

S03_Disappearing:		;

LDA $1534,x			;
STA $1504,x			; set the time to remain invisible
STZ $C2,x			; reset the sprite state to 00
RTS					;

S04_InvisibleInit:		;

LDA $13				;
CMP $1570,x			; if the frame counter equals the frame on which the sprite is supposed to appear...
BNE .Return			;
LDA #$01			;
STA $C2,x			;
.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 01 - move forward continuously
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveForward:

LDA $1626,x		;
LSR				; if the player has not touched the sprite...
BCC .Return		; don't move

LDA $187B,x		; speed index
ASL #3			;
ORA $157C,x		; plus direction
TAY				;

LDA MoveXSpeed,y	;
STA $B6,x		; set the sprite X speed
LDA MoveYSpeed,y	;
STA $AA,x		; set the sprite Y speed

JSL $81801A		; update sprite Y position
JSL $818022		; update sprite X position
STA $1528,x		;

.Return			;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 02 - move back and forth
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BackAndForth:

STZ $1528,x			;
LDA $1594,x			; speed/movement state
JSL $8086DF			;

dw S200_NormalSpeed	; 00 - moving normally
dw S201_Decelerating	; 01 - slowing down
dw S202_Stationary		; 02 - stopped
dw S203_Accelerating	; 03 - speeding up

;------------------------------------------------
; state 00 - moving at normal speed
;------------------------------------------------

S200_NormalSpeed:	;

LDA $1564,x			;
BEQ .ChangeState		;

LDA $187B,x			; speed index
ASL #3				;
ORA $157C,x			; plus direction
TAY					;

LDA MoveXSpeed,y		;
STA $B6,x			; set the sprite X speed
LDA MoveYSpeed,y		;
STA $AA,x			; set the sprite Y speed

JSL $81801A			; update sprite Y position
JSL $818022			; update sprite X position
STA $1528,x			;

RTS					;

.ChangeState			;
JMP ChangeState1594	;

;------------------------------------------------
; state 01 - slowing to a stop
;------------------------------------------------

S201_Decelerating:		;

LDA $14				;
LSR					;
BCS .Return			;

LDA $1626,x			;
AND #$02			; if the sprite doesn't move horizontally...
BEQ .SkipXCheck		; don't check the X speed

LDY #$00				;
LDA $B6,x			;
BPL $01				; if the sprite X speed is positive, use index 0;
INY					; if the sprite X speed is negative, use index 1
LDA $B6,x			;
SEC					;
SBC IncDecTbl,y		;
STA $B6,x			;
BEQ .Stop				; if the speed has reached 0, reverse direction

.SkipXCheck			;
LDA $1626,x			;
AND #$04			; if the sprite doesn't move vertically...
BEQ .SkipYCheck		; don't check the Y speed

LDY #$00				;
LDA $AA,x			;
BPL $01				; repeat for the Y speed
INY					;
LDA $AA,x			;
SEC					;
SBC IncDecTbl,y		;
STA $AA,x			;
BEQ .Stop				; if the speed has reached 0, reverse direction

.SkipYCheck			;
JSL $81801A			; update sprite Y position
JSL $818022			; update sprite X position
STA $1528,x			;

.Return				;
RTS					;

.Stop				;
LDA #$08			;
STA $1564,x			;
JMP ChangeState1594	;

;------------------------------------------------
; state 02 - stopped
;------------------------------------------------

S202_Stationary:		;

LDA $1564,x			;
BNE .Return			;

LDY $157C,x			;
LDA NewDirection,y	; change the sprite direction to its opposite
STA $157C,x			;

TAY					;
LDA $1626,x			;
AND #$F9			;
ORA DirectionFlags,y	; set the necessary directional speed flags
STA $1626,x			;

LDA InitXSpeed,y		;
STA $B6,x			;
LDA InitYSpeed,y		;
STA $AA,x			;

JMP ChangeState1594	;

.Return				;
RTS					;

;------------------------------------------------
; state 03 - accelerating
;------------------------------------------------

S203_Accelerating:		;

LDA $14				;
LSR					;
BCS .Return			;

LDA $187B,x			; speed index
ASL #3				;
ORA $157C,x			; plus direction
TAY					;
LDA MoveXSpeed,y		;
STA $08				;
LDA MoveYSpeed,y		;
STA $09				;

LDA $1626,x			;
AND #$02			; if the sprite doesn't move horizontally...
BEQ .SkipXCheck		; don't check the X speed

LDY #$00				;
LDA $B6,x			;
BPL $01				; if the sprite X speed is positive, use index 0;
INY					; if the sprite X speed is negative, use index 1
LDA $B6,x			;
CLC					;
ADC IncDecTbl,y		;
STA $B6,x			;
CMP $08				;
BEQ .ChangeState		; if the speed has reached maximum, reset the movement state to 0

.SkipXCheck			;
LDA $1626,x			;
AND #$04			; if the sprite doesn't move vertically...
BEQ .SkipYCheck		; don't check the Y speed

LDY #$00				;
LDA $AA,x			;
BPL $01				; repeat for the Y speed
INY					;
LDA $AA,x			;
CLC					;
ADC IncDecTbl,y		;
STA $AA,x			;
CMP $09				;
BEQ .ChangeState		; if the speed has reached maximum, reset the movement state to 0

.SkipYCheck			;
JSL $81801A			; update sprite Y position
JSL $818022			; update sprite X position
STA $1528,x			;

.Return				;
RTS					;

.ChangeState			;

LDA $7FAB58,x		; extra byte 3
AND #$0F			;
ASL #4				;
STA $1564,x			; $1564,x - movement timer

;------------------------------------------------
; increment the movement/speed state
;------------------------------------------------

ChangeState1594:		;

LDA $1594,x			;
INC					;
AND #$03			;
STA $1594,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 03 - fall after being stepped on
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FallAfterStep:

LDA $AA,x		;
BEQ .WaitToFall	;

LDA $1564,x		;
BEQ .Accelerate	;
CMP #$01		;
BNE .NoInc		;
LDA #$2B			;
STA $1DFC		;
BRA .NoInc		;

.Accelerate		;
LDA $AA,x		;
CMP #$40		; until the Y speed reaches 40...
BCS .NoInc		;
CLC				;
ADC #$02		;
STA $AA,x		;
.NoInc			;

JSL $81801A		; update sprite Y position
JSL $818022		; update sprite X position

.Return			;
RTS				;

.WaitToFall		;

LDA $1626,x		;
LSR				; if the player has not touched the sprite...
BCC .Return		; then it won't fall
LDA #$03		;
STA $AA,x		; set the initial falling speed
LDA $157C,x		;
ASL #2			; set the fall timer
STA $1564,x		;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 04 - float on water and lava
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FloatOnLiquid:

LDA $D8,x			;
PHA					;
CLC					;
ADC #$03			;
STA $D8,x			;
LDA $14D4,x			;
PHA					;
ADC #$00			;
STA $14D4,x			;

JSL $819138			; interact with objects

PLA					;
STA $14D4,x			;
PLA					;
STA $D8,x			;

LDA $164A,x			; if the sprite is not in water or lava...
BNE .Floating			; then it is just in air

LDA #$08			;
STA $AA,x			;
JSL $81801A			; update sprite Y position
RTS					;

.Floating				;

LDA $187B,x			;
JSL $8086DF			;

dw S400_Bobbing		;
dw S401_Sinking		;
dw S402_Rising		;

;------------------------------------------------
; state 00 - bobbing on the surface
;------------------------------------------------

S400_Bobbing:

LDA $1626,x			;
AND #$08			;
BEQ .NoChangeState	;
INC $187B,x			;
STZ $1594,x			;
RTS					;

.NoChangeState		;
INC $1594,x			; increment the frame counter
LDA $1594,x			;
CMP #$30			;
BCC .NoReset			;
STZ $1594,x			;
.NoReset				;
LSR #3				;
AND #$07			;
TAY					;
LDA FloatYSpeed,y		;
STA $AA,x			;
JSL $81801A			; update sprite Y position
RTS					;

;------------------------------------------------
; state 01 - sinking down into the water
;------------------------------------------------

S401_Sinking:			;

LDA $1626,x			;
AND #$08			;
BNE .NoChangeState	;
INC $187B,x			;
RTS					;

.NoChangeState		;
LDA #$02			;
STA $AA,x			;
JSL $81801A			; update sprite Y position
RTS					;

;------------------------------------------------
; state 02 - rising back to the surface
;------------------------------------------------

S402_Rising:

LDA #$FD			;
STA $AA,x			;
LDA $7FAD30,x		;
CMP $D8,x			; if the sprite has reached its original Y position...
LDA $7FAD48,x		;
SBC $14D4,x			;
BCC .NoChangeState	;
LDA $7FAD30,x		;
STA $D8,x			;
LDA $7FAD48,x		;
STA $14D4,x			;
STZ $187B,x			;
.NoChangeState		;
JSL $81801A			; update sprite Y position
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 05 - move in a circle
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveInCircle:

LDA $E4,x				;
STA $0E					; save the current Y position (low byte)

JSR EllipseUpdateAngle		; update the angle of the circle based on the rotation speed
JSR EllipseSetUpAngle		; put the two bytes of the angle together
JSR EllipseGetCoords		; get coordinates based on the radius and angle
JSR EllipseMultiplyCoords	;
JSR EllipseOffsetPosition		; set the sprite's X and Y position based on said coordinates and the center position

LDA $E4,x				; since this form of the sprite doesn't call $018022,
SEC						; we need to set the X offset manually
SBC $0E				;
STA $1528,x				; current X position minus the X position before changing position

RTS						;

EllipseUpdateAngle:

LDA $9D
BNE .Label92

LDY #$00
LDA $7FAD00,x
BPL .Label91
DEY
.Label91
CLC
ADC $7FAD54,x
STA $7FAD54,x
TYA
ADC $7FAD60,x
AND #$01
STA $7FAD60,x

.Label92
RTS

EllipseSetUpAngle:

LDA $7FAD54,x
STA $00
LDA $7FAD60,x
STA $01

RTS

EllipseGetCoords:

REP #$30
LDA $00
CLC
ADC.w #$0080
AND #$01FF
STA $02
LDA $00
AND.w #$00FF
ASL A
TAX
LDA $07F7DB,x
STA $04
LDA $02
AND.w #$00FF
ASL A
TAX
LDA $07F7DB,x
STA $06
SEP #$30

RTS

EllipseMultiplyCoords:

LDX $15E9
LDA $04
STA $4202
LDA $7FAD0C,x
LDY $05
BNE .Label93
STA $4203
NOP #4
ASL $4216
LDA $4217
ADC #$00
.Label93
LSR $01
BCC .Label94
EOR #$FF
INC A
.Label94
STA $04

LDA $06
STA $4202
LDA $7FAD18,x
LDY $07
BNE .Label95
STA $4203
NOP #4
ASL $4216
LDA $4217
ADC #$00
.Label95
LSR $03
BCC .Label96
EOR #$FF
INC A
.Label96
STA $06

RTS

EllipseOffsetPosition:

STZ $00
LDA $04
BPL .Label97
DEC $00
.Label97
CLC
ADC $7FAD24,x
STA $E4,x
LDA $7FAD3C,x
ADC $00
STA $14E0,x

STZ $01
LDA $06
BPL .Label98
DEC $01
.Label98
CLC
ADC $7FAD30,x
STA $D8,x
LDA $7FAD48,x
ADC $01
STA $14D4,x

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 06 - move in a sine wave
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveInWave:

LDA $1626,x		;
LSR				; if the player has not touched the sprite...
BCC .Return		; don't move

INC $1594,x		;
LDA $1594,x		;
AND #$07		;
BNE .NoChange	;
LDA $1FD6,x		;
INC				;
AND #$0F		;
STA $1FD6,x		;
.NoChange		;

LDY $187B,x		; speed index
LDA $157C,x		;
LSR				;
LDA SineXSpeed,y	;
BCC $03			;
EOR #$FF			; flip the X speed value if the sprite is moving to the left
INC				;
STA $B6,x		; set the sprite X speed

TYA				;
ASL #4			;
ORA $1FD6,x		;
TAY				;
LDA SineYSpeed,y	;
STA $AA,x		; set the sprite Y speed

JSL $81801A		; update sprite Y position
JSL $818022		; update sprite X position
STA $1528,x		;

.Return			;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sprite behavior setting 07 - unused?
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlatformGFX:

JSL !GetDrawInfo

LDA $160E,x
TAX
STA $06
DEC
DEC
STA $07
LDA.w Offset,x
STA $04
STZ $05
LDX $15E9
LDA $1602,x
TAX

LDA $06
BEQ NoLeftTile
JSR DrawLeftTile
NoLeftTile:
LDA $06
CMP #$01
BEQ NoMiddleTiles
JSR DrawMiddleTiles
NoMiddleTiles:
LDA $06
BEQ NoRightTile
JSR DrawRightTile
NoRightTile:

LDX $15E9
LDY #$02
LDA $05
JSL $81B7B3
RTS

DrawLeftTile:

LDA $00
CLC
ADC $04
STA $0300,y

LDA $01
STA $0301,y

LDA.w LeftTile,x
STA $0302,y

LDA.w LTileProps,x
STA $0303,y

INY #4
INC $05
LDA $04
CLC
ADC #$10
STA $04
RTS

DrawMiddleTiles:

LDA $00
CLC
ADC $04
STA $0300,y

LDA $01
STA $0301,y

LDA.w MidTile,x
STA $0302,y

LDA.w MTileProps,x
STA $0303,y

INY #4
INC $05
LDA $04
CLC
ADC #$10
STA $04

DEC $07
BPL DrawMiddleTiles

RTS

DrawRightTile:

LDA $00
CLC
ADC $04
STA $0300,y

LDA $01
STA $0301,y

LDA.w RightTile,x
STA $0302,y

LDA.w RTileProps,x
STA $0303,y

INC $05
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; platform interaction routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Interact:				; platform interaction routine

JSL $83B664			;
JSR SetSpriteClipping	;
JSR $83B72B			;
PHB					;
LDA #$01			;
PHA					;
PLB					;
PHK					;
PEA.w .Return2-1		;
PEA $8020			;
JML $81B45A			;
.Return2				;
PLB					;
BCC .NoContact		;
LDA $1626,x			;
ORA #$09			;
STA $1626,x			;
RTS					;
.NoContact			;
LDA $1626,x			;
AND #$F7			;
STA $1626,x			;
RTS					;

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:	; custom sprite clipping routine, based off $03B69F

LDY $160E,x		; clipping
LDA Offset,y		;
INC				;
LDY #$00			;
CMP #$00		;
BPL $01			;
DEY				;
CLC				;
ADC $E4,x		;
STA $04			; $04 = sprite X position low byte + X displacement value
TYA				;
ADC $14E0,x		;
STA $0A			; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDY $160E,x		;
LDA ClipWidth,y	;
STA $06			; $06 = sprite clipping width
LDA $D8,x		;
CLC				;
ADC #$FE		;
STA $05			; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x		;
ADC #$FF		;
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



