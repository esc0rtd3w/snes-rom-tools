;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Venus Fire Trap (with special behaviors), by imamelia
;;
;; This Venus Fire Trap spits multiple fireballs in a spreadshot fashion or in an arc,
;; or other patterns.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bit 0: Direction.  0 = up/left, 1 = right/down.
;; Bit 1: Orientation.  0 = vertical, 1 = horizontal.
;; Bit 2: Stem length.  0 = long, 1 = short.
;; Bit 3: Color.  0 = green, 1 = red.
;; Bits 4-5: Sprite type.  00 = spreadshot, 01 = shower, 10 = aiming, 11 = ?.
;; Bits 6-7: Number of fireballs to spit (varies depending on sprite type).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; $1510,x = behavior setting (direction, color, etc.)
; $151C,x = holder for the sprite's initial Y position low byte
; $1528,x = holder for the sprite's initial X position low byte
; $1534,x = firing flag
; $1540,x = sprite state timer
; $1558,x = fire timer
; $1570,x = animation frame counter
; $157C,x = direction (------vh)
; $1594,x = "in pipe" flag
; $1602,x = animation frame
; $160E,x = number of fireballs to spit
; $187B,x = fireball counter
; $1FD6,x = behavior setting 2 (fireball spit pattern)

Palettes:				; palettes for the different types
db $06,$04,$0C,$00	;

FireTimers:			; frames in between spitting fireballs
db $00,$10,$10,$00	; spreadshot, arc, aim, unused

!TotalSpeed = $18		; total speed (X + Y) for the aiming one

FireballsToSpit:
db $02,$03,$04,$05	; spreadshot
db $03,$04,$05,$06	; arc
db $01,$02,$03,$04	; aim
db $00,$00,$00,$00	; ?

Speed:				; the Piranha Plant's speed for each sprite state (inverted for down and right plants)
db $00,$F0,$00,$10	; in the pipe, moving forward, resting at the apex, moving backward

TimeInState:			; the time the sprite will spend in each sprite state, indexed by bits 2, 4, and 5 of the behavior table
db $30,$20,$60,$20	; long Venus Fire Traps
db $30,$18,$60,$18	; short Venus Fire Traps

; All of these tables are indexed by -----odf,
; where f = frame, d = direction, and o = orientation.

HeadXOffset:
db $00,$00,$00,$00,$00,$00,$10,$10

HeadYOffset:
db $00,$00,$10,$10,$00,$00,$00,$00

StemXOffset:
db $00,$00,$00,$00,$10,$10,$00,$00

StemYOffset:
db $10,$10,$00,$00,$00,$00,$00,$00

; up, down, left, right
; head:
; X=00/Y=00, X=00/Y=10, X=00/Y=00, X=10/Y=00
; stem:
; X=00/Y=10, X=00/Y=00, X=10/Y=00, X=00/Y=10

StemTilemap:			; the tiles used by the stem
db $CE,$CE,$CE,$CE,$88,$88,$88,$88

HeadTilemap:			; the tiles used by the head
db $A8,$AA,$A8,$AA,$A8,$AA,$A8,$AA

TileFlip:				; the X- and Y-flip of each tile
db $00,$00,$80,$80,$00,$00,$40,$40

; These two are different.  They are indexed by ------lc, where c = color and l = length.
; Add 1 to each of these values if you want the tile to use the second graphics page.

StemPalette:			; the palette of the stem tiles
db $0A,$08,$0A,$08	;

;HeadPalette:			; the palette of the head tiles
;db $04,$04,$04,$04	;

; This tile will be invisible because it has sprite priority setting 0,
; but it will go in front of the plant tiles to cover it up when it is in a pipe.
; That way, the plant tiles don't need to have hardcoded priority.
; This tile should be as close to square as possible.
; Note: The default value WILL NOT completely hide the tiles unless you have changed its graphics!
; But the only completely square tile in a vanilla GFX00/01 is the message box tile, which is set to be overwritten by default.

!CoverUpTile = $40			; the invisible tile used to cover up the sprite when it is in a pipe

; these two tables are indexed by the direction and orientation

CoverUpXOffset:		;
db $00,$00,$00,$10	;

CoverUpYOffset:		;
db $00,$10,$00,$00	;

InitOffsetYLo:
db $FF,$EF,$08,$08

InitOffsetYHi:
db $FF,$FF,$00,$00

InitOffsetXLo:
db $08,$08,$FF,$EF

InitOffsetXHi:
db $00,$00,$FF,$FF

VenusFrames:		; which head tile the Venus Fire Trap should use for each sprite state
db $00,$00,$01,$00

Clipping:
db $01,$14

; indexed by ----odvh
; h = horizontal facing direction, v = vertical facing direction, d = movement direction, o = orientation
FireXOffsets:
db $0F,$F9,$0F,$F9,$0F,$F9,$0F,$F9
db $F9,$F9,$F9,$F9,$1F,$1F,$1F,$1F
FireYOffsets:
db $0A,$0A,$02,$02,$1A,$1A,$12,$12
db $0A,$0A,$02,$02,$0A,$0A,$02,$02

FireXOffsetsLo:
db $0F,$FA,$0E,$00,$0E,$FE,$0D,$FE,$FB,$FB,$FE,$FE,$1D,$1D,$1D,$1D
FireXOffsetsHi:
db $00,$FF,$00,$00,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
FireYOffsetsLo:
db $09,$09,$FF,$FF,$18,$18,$13,$13,$06,$06,$01,$01,$0A,$0A,$01,$01
FireYOffsetsHi:
db $00,$00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!FireArcYSpeed = $D0
!FireSpreadXSpeed = $0A

FireYSpeedPtrs:
dw FireYSpeeds2
dw FireYSpeeds3
dw FireYSpeeds4
dw FireYSpeeds5

FireYSpeeds2:
dw $05,$0A
FireYSpeeds3:
db $04,$08,$0C
FireYSpeeds4:
db $03,$06,$09,$0C
FireYSpeeds5:
db $02,$04,$06,$08,$0A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR PiranhaInit
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaInit:

LDA $7FAB40,x		;
AND #$C0			;
ROL #3				;
STA $00				;
LDA $7FAB40,x		;
AND #$30			;
LSR #2				;
PHA					;
ORA $00				;
TAY					;
LDA FireballsToSpit,y	; the number of fireballs it spits depends on the sprite type and extra byte setting
DEC					;
STA $160E,x			;
PLA					;
LSR #2				;
STA $1FD6,x			;
TAY					;
LDA Palettes,y			;
STA $15F6,x			;

LDA $7FAB40,x		; first extra byte
AND #$0F			; lower 4 bits
STA $1510,x			; into sprite behavior table
AND #$03			;
TAY					; direction and orientation used to index inital offsets
LDA $D8,x			;
CLC					;
ADC InitOffsetYLo,y	; Y position low byte
STA $D8,x			;
LDA $14D4,x			;
ADC InitOffsetYHi,y	; Y position high byte
STA $14D4,x			;
LDA $E4,x			;
CLC					;
ADC InitOffsetXLo,y	; X position low byte
STA $E4,x			;
LDA $14E0,x			;
ADC InitOffsetXHi,y	; X position high byte
STA $14E0,x			;

TYA					;
LSR					;
TAY					;
LDA Clipping,y		;
STA $1662,x			;

LDA $1510,x			; get the bits for the sprite state timer index
AND #$04			; bit 2
STA $1504,x			;

EndInit1:				;

LDA $D8,x			;
STA $151C,x			; back up the sprite's initial XY position (low bytes)
LDA $E4,x			;
STA $1528,x			;

RTS					;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR SpecialtyVenusMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EndMain:
RTS

SpecialtyVenusMain:

LDA $1594,x			; if the sprite is in a pipe and the player is near...
BNE NoGFX			; don't draw the sprite
LDA $C2,x			;
BEQ NoGFX			;

JSR VenusGFX			; draw the sprite

NoGFX:				;

JSL !SubOffscreenX0	;

LDA $9D				; if sprites are locked...
BNE EndMain			; terminate the main routine right here

LDY $C2,x			;
LDA VenusFrames,y	;
STA $1602,x			;

LDA $1594,x			; if the plant is in a pipe...
BNE NoInteraction		; don't let it interact with the player

JSL $81803A			; interact with the player and other sprites

NoInteraction:			;

JSR AlwaysFace		;

LDA $C2,x			;
CMP #$02			; make sure the sprite is in the correct sprite state (resting at the apex)
BNE NoFireCheck		;

LDA $1534,x			;
BNE Fire				;

LDA $1540,x			; if the fire timer
CMP #$19			; has reached a certain number...
BEQ SetFireFlag		; then spit fireballs

NoFireCheck:

LDA $C2,x			; use the sprite state
AND #$03			; to determine what the sprite's speed should be
TAY					;
LDA $1540,x			; if the timer for changing states has run out...
BEQ ChangePiranhaState	;

LDA $1510,x			; check whether the sprite is rightside-up/left or upside-down/right
LSR					;
LDA Speed,y			; load the base speed
BCC StoreSpeed		; if upside-down/right...
EOR #$FF				; flip its speed
INC					;
StoreSpeed:			;
TAY					; transfer the speed value to Y because we need to use A
LDA $1510,x			; check the secondary sprite state
AND #$02			; check whether the sprite is vertical or horizontal
BNE MoveHorizontally	;

STY $AA,x			; store the speed value to the sprite Y speed table
JSL $81801A			; update sprite Y position without gravity
RTS					;

MoveHorizontally:		;

STY $B6,x			; store the speed value to the sprite X speed table
JSL $818022			; update sprite X position without gravity
RTS					;

Fire:					;

INC $1540,x			; freeze the sprite state timer
LDA $1558,x			;
BEQ FireReady			;
RTS					;

SetFireFlag:			;

INC $1534,x			;
DEC $1540,x			;
LDA $160E,x			;
STA $187B,x			;
FireReady:			;
JSR SpitFireballs		;
DEC $187B,x			;
BPL StillFiring			;
STZ $1534,x			;
RTS					;

StillFiring:			;
LDY $1FD6,x			;
LDA FireTimers,y		;
STA $1558,x			;
RTS					;

ChangePiranhaState:	;

LDA $C2,x			; sprite state
AND #$03			; 4 possible states, so we need only 2 bits
STA $00				; store to scratch RAM for subsequent use
LDA $1510,x			;
AND #$08			; if the plant is a red one...
ORA $00				; or the sprite isn't in the pipe...
BNE NoProximityCheck	; don't check to see if the player is near

JSL !SubHorizPos		; get the horizontal distance between the player and the sprite

LDA #$01			;
STA $1594,x			; set the invisibility flag if necessary
LDA $0F				;
CLC					;
ADC #$1B			; if the sprite is within a certain distance...
CMP #$37			;
BCC EndStateChange	; don't change the sprite state

NoProximityCheck:		;

STZ $1594,x			; if the sprite is out of range, clear the invisibility flag
LDA $C2,x			;
INC					; increment the sprite state
AND #$03			;
STA $C2,x			;
STA $00				;
LDA $1510,x			;
AND #$04			; use the stem length bit
ORA $00				;
TAY					; to set the timer for changing sprite state
LDA TimeInState,y		;
STA $1540,x			; set the time to change state

EndStateChange:		;

RTS

SetAnimationFrame:	;

INC $1570,x			; $1570,x - individual sprite frame counter, in this context
LDA $1570,x			;
LSR #3				; change image every 8 frames
AND #$01			;
STA $1602,x			; set the resulting image
RTS

AlwaysFace:			;

JSL !SubHorizPos		;
TYA					;
STA $00				;
JSL !SubVertPos		;
TYA					;
ASL					;
TSB $00				;

LDA $1510,x			;
AND #$02			;
BEQ .NoFixH			; the sprite's horizontal direction is always the same if it is a horizontally-moving Venus Fire Trap
LDA #$01			;
TRB $00				;
LDA $1510,x			;
AND #$01			;
EOR #$01				;
STA $01				;
TSB $00				;
.NoFixH				;
LDA $1FD6,x			;
CMP #$01			;
BNE .NoFixV			;
LDA #$02			;
TSB $00				;
.NoFixV				;
LDA $00				;
STA $157C,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VenusGFX:			; I made my own graphics routine, since the Piranha Plant uses a shared routine.

JSL !GetDrawInfo		; set some variables up for writing to OAM

LDA $157C,x			;
ROR #3				;
AND #$C0			;
EOR #$40				;
STA $04				;
LDA $15F6,x			;
AND #$3F			;
ORA $04				;
STA $15F6,x			;

LDA $1510,x			;
AND #$04			; stem length
LSR					;
STA $04				;
LDA $1510,x			;
AND #$08			;
LSR #3				; plus color
TSB $04				;

LDA $1602,x			;
STA $03				; frame = bit 0 of the index
LDA $1510,x			;
AND #$03			; direction and orientation
ASL					;
TSB $03				; bits 1 and 2 of the index

LDA $1510,x			;
AND #$04			; if the plant has a short stem...
BNE AlwaysCovered		; then the stem is always partially obscured by the cover-up tile

LDA $C2,x			;
CMP #$02			; if the sprite is all the way out of the pipe...
BEQ StemOnly			; then draw just the stem

AlwaysCovered:		;

LDA $1510,x			;
AND #$01			;
STA $08				; save the direction bit for use with the cover-up routine

LDA $D8,x			;
SEC					;
SBC $151C,x			;
STA $06				;
LDA $E4,x			;
SEC					;
SBC $1528,x			;
CLC					;
ADC $06				;
LDX $08				;
BEQ NoFlipCheckVal	;
EOR #$FF				;
INC					;
NoFlipCheckVal:		;
CLC					;
ADC #$10			;
CMP #$20			;
BCC CoverUpTileOnly	;

StemAndCoverUpTile:	;

JSR DrawCoverUpTile	;
INY #4				;
JSR DrawStem			;
LDA #$02			;
EndGFX:				;
PHA					;
INY #4				;
LDX $03				;
JSR DrawHead			; the head tile is always drawn
PLA					;
LDY #$02				;
LDX $15E9			;
JSL $81B7B3			;
RTS					;

StemOnly:			;

JSR DrawStem			;
LDA #$01			;
BRA EndGFX			;

CoverUpTileOnly:		;

JSR DrawCoverUpTile	;
LDA #$01			;
BRA EndGFX			;

DrawHead:

LDA $00				;
CLC					;
ADC HeadXOffset,x	; set the X offset for the head tile
STA $0300,y			;

LDA $01				;
CLC					;
ADC HeadYOffset,x	; set the Y offset for the head tile
STA $0301,y			;

LDA HeadTilemap,x		; set the tile for the head
STA $0302,y

LDX $15E9			;
LDA $15F6,x			;
ORA $64				;
STA $0303,y			;

RTS					;

DrawStem:

LDX $03

LDA $00				;
CLC					;
ADC StemXOffset,x	; set the X offset for the stem tile
STA $0300,y			;

LDA $01				;
CLC					;
ADC StemYOffset,x	; set the Y offset for the stem tile
STA $0301,y			;

LDA StemTilemap,x		; set the tile for the stem
STA $0302,y			;

LDA TileFlip,x			; load the XY flip for the tiles
LDX $04				; load the palette index
ORA StemPalette,x		; add in the palette/GFX page bits
ORA $64				; and the level's sprite priority
STA $0303,y			;

RTS					;

DrawCoverUpTile:		;

LDX $15E9			;

LDA $1528,x			;
STA $09				;
LDA $151C,x			; make backups of the XY init positions
STA $0A				;

LDA $1510,x			;
AND #$03			;
TAX

LDA $09				;
SEC					;
SBC $1A				;
CLC					;
ADC CoverUpXOffset,x	;
STA $0300,y			;

LDA $0A				;
SEC					;
SBC $1C				;
CLC					;
ADC CoverUpYOffset,x	;
STA $0301,y			;

LDA #!CoverUpTile		;
STA $0302,y			;

LDA #$00			;
STA $0303,y			;

RTS					;

LDX $15E9			; sprite index back into X
LDY #$02				; the tiles were 16x16
LDA $05				; we drew 2 or 3 tiles
JSL $81B7B3			;

RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; various subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; fireball-spitting routine
;------------------------------------------------

SpitFireballs:

LDA $1FD6,x			;
JSL $8086DF			;

dw Fire1Spreadshot		;
dw Fire2Shower		;
dw Fire3Aiming		;
dw Fire4Unused		;

Fire1Spreadshot:		;

LDA #$02			; extended sprite number = 02
STA $14B0			;

LDA $160E,x			;
STA $08				;
DEC					;
ASL					;
TAY					;
REP #$20				;
LDA.w FireYSpeedPtrs,y	;
STA $06				;
SEP #$20				;
LDA $157C,x			;
LSR					;
LDA #!FireSpreadXSpeed	;
BCC $03				;
EOR #$FF				;
INC					;
STA $14B1			;
.Loop				;
LDY $08				;
LDA ($06),y			;
STA $14B2			;
JSR SpawnFireball		;
DEC $08				;
BPL .Loop				;
.EndFire1				;
STZ $187B,x			;
RTS					;

Fire2Shower:

LDA #$0B
STA $14B0

JSR GetHorizDistance

LDA $0E
LSR #2
LDY $0D
BNE NoInvertSpd
EOR #$FF
INC
NoInvertSpd:
LDY $00
STA $14B1
LDA #!FireArcYSpeed
STA $14B2
JMP SpawnFireball

Fire3Aiming:

LDA #$02			; extended sprite number = 02
STA $14B0			;

LDA #!TotalSpeed		;
JSR MagikoopaAimRt	;

LDA $00				;
STA $14B2			;
LDA $01				;
STA $14B1			;
JMP SpawnFireball		;

Fire4Unused:
RTS

;------------------------------------------------
; fireball spawning routine
;------------------------------------------------

SpawnFireball:

LDY #$07
ExSpriteLoop:
LDA $170B,y
BEQ FoundExSlot
DEY
BPL ExSpriteLoop
RTS

FoundExSlot:

STY $00

LDA $1510,x
AND #$03
ASL
ASL
STA $14B3
LDA $157C,x
TSB $14B3

; indexed by ----odvh
; h = horizontal facing direction, v = vertical facing direction, d = movement direction, o = orientation

LDA $14B0
STA $170B,y

STZ $0F
LDY $14B3
LDA FireXOffsets,y
BPL $02
DEC $0F
STA $14B4
STZ $0E
LDA FireYOffsets,y
BPL $02
DEC $0E
STA $14B5

LDY $00
LDA $E4,x
CLC
ADC $14B4
STA $171F,y
LDA $14E0,x
ADC $0F
STA $1733,y

LDA $D8,x
CLC
ADC $14B5
STA $1715,y
LDA $14D4,x
ADC $0E
STA $1729,y

LDA $14B1
STA $1747,y
LDA $14B2
STA $173D,y

LDA #$FF
STA $176F,y

RTS

;------------------------------------------------
; horizontal distance routine
;------------------------------------------------

GetHorizDistance:

PHY
LDY #$00
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC $94
BPL $05
EOR #$FFFF
INC
INY
STA $0E
SEP #$20
STY $0D
PLY
RTS

;------------------------------------------------
; Magikoopa's aiming routine ($01BF6A, from yoshicookiezeus's disassembly)
;------------------------------------------------

MagikoopaAimRt:

STA $01				;
PHX					;
PHY					; preserve the indexes of the spawner and the spawned sprite

JSL !SubVertPos2		; $0E = vertical distance
STY $02				; $02 = vertical direction
LDA $0E				; $0C = vertical distance (absolute value)
BPL $03				;
EOR #$FF				;
INC					;
STA $0C				;

JSL !SubHorizPos		; $0F = horizontal distance
STY $03				; $03 = horizontal direction
LDA $0F				; $0D = horizontal distance (absolute value)
BPL $03				;
EOR #$FF				;
INC					;
STA $0D				;

LDY #$00				;
LDA $0D				;
CMP $0C				;
BCS .NoSwitch			; if the vertical distance is less than the horizontal distance...
INY					; increment Y
PHA					;
LDA $0C				;
STA $0D				; and switch $0C and $0D
PLA					;
STA $0C				;
.NoSwitch			;

STZ $00				;
STZ $0B				; clear $00 and $0B

LDX $01				;
.Loop				;
LDA $0B				;
CLC					;
ADC $0C				;
CMP $0D				; if $0C + $0B < $0D, branch
BCC .Label1			; else, subtract $0D and increase $00
SBC $0D				;
INC $00				;
.Label1				;
STA $0B				;
DEX					;
BNE .Loop			;

TYA					;
BEQ .NotSwitched		; if $0C and $0D were switched...
LDA $00				; then switch $00 and $01 as well
PHA					;
LDA $01				;
STA $00				;
PLA					;
STA $01				;
.NotSwitched			;

LDA $00				;
LDY $02				;
BEQ $03				; if the horizontal distance was inverted,
EOR #$FF				; invert $00
INC					;
STA $00				;

LDA $01				;
LDY $03				;
BEQ $03				; if the vertical distance was inverted,
EOR #$FF				; invert $01
INC					;
STA $01				;

PLY					; retrieve sprite indexes
PLX					;
RTS					;

dl Init,Main











