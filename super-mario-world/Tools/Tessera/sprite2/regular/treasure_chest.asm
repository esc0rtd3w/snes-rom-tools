;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB3 Treasure Chest, by imamelia
;;
;; This sprite acts like the treasure chests in SMB3.  It spawns an item, and it can
;; be set to end the level.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-7: Index to property tables.
;;
;; Sprite table info:
;;
;; $C2,x - sprite state
;; $1504,x - main behavior property byte
;; $1510,x - mirror of $7FAB40,x
;; $151C,x - Y offset of the item (increments until reaching a certain value)
;; $1528,x - sprite/item/subroutine number
;; $1540,x - blink timer for the spawned sprite tile, activation timer for state 04
;; $1602,x - animation frame (closed/open)
;; $160E,x - flag that determines whether or not to show the spawned sprite tile
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
db $20,$22

!AppearSFX = $101DF9
!OpenSFX = $1E1DF9
!AppearRange = $70
!TimeToBlink = $80
!TimeTillActivate = $7F

; Bits 0-1: High byte of the sprite number, if custom.
; Bits 2-3: What to do after spawning the sprite.
;	00 - nothing
;	01 - fade to overworld and activate normal exit
;	10 - fade to overworld and activate secret exit
;	11 - teleport to the level set by the screen exit of the screen the sprite is in
; Bits 4-5: What to do when spawning.
;	00 - spawn normal sprite
;	01 - spawn custom sprite
;	10 - put an item in the item box
;	11 - activate a subroutine
; Bit 6: Unused.
; Bit 7: Affect item memory.
MainProperties:
db $00,$00,$11,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite number/sprite number low byte/item box value/subroutine number
SpawnNumber:
db $78,$76,$B3,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite status
SpawnStatus:
db $08,$08,$08,$08,$08,$08,$08,$08	; values 00-07
db $08,$08,$08,$08,$08,$08,$08,$08	; values 08-0F
;db $08,$08,$08,$08,$08,$08,$08,$08	; values 10-17

; first extra byte of the spawned sprite
SpawnEB1:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; second extra byte of the spawned sprite
SpawnEB2:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; third extra byte of the spawned sprite
SpawnEB3:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; fourth extra byte of the spawned sprite
SpawnEB4:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; X speed of the spawned sprite
SpawnXSpeed:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; Y speed of the spawned sprite
SpawnYSpeed:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; sprite tile number to show coming from the box
SpawnedTile:
db $24,$00,$06,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; properties of the tile to show coming from the box (YX--CCCT)
SpawnedTileProps:
db $0A,$00,$08,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		;
STA $1510,x			;
TAY					;
LDA SpawnNumber,y	;
STA $1528,x			;
LDA MainProperties,y	;
STA $1504,x			;
BPL .EndInit			; if bit 7 is set, it will affect item memory

JSR GetItemMemoryBit	; check the item memory bits
BEQ .EndInit			; if the relevant item memory bit has not been set, then nothing happens

STZ $14C8,x			; if this sprite has already been collected, erase it

.EndInit				;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR TreasureChestMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TreasureChestMain:

LDA $C2,x
BEQ .NoGFX
JSR TreasureChestGFX
.NoGFX

LDA $14C8,x
CMP #$08
BNE .Return
LDA $9D
BNE .Return

JSL !SubOffscreenX0

LDA $C2,x
JSL $8086DF

dw State00	; 00 - waiting to appear
dw State01	; 01 - dropping down
dw State02	; 02 - sitting on the ground
dw State03	; 03 - open, sprite tile showing
dw State04	; 04 - spawned something
dw State05	; 05 - activating any necessary code after spawning something

.Return
RTS

;------------------------------------------------
; sprite state 00
;------------------------------------------------

State00:

LDA $14E0,x				;
XBA						;
LDA $E4,x				; check the distance between the player and the sprite
REP #$20					;
SEC						;
SBC $94					;
BPL $04					;
EOR #$FFFF				; invert if negative
INC						;
CMP #$0100				;
SEP #$20					;
BCS .Return				;
CMP #!AppearRange		; if the player is within range...
BCS .Return				;

INC $C2,x				; increment the sprite state
LDA.b #!AppearSFX>>16	;
STA.w !AppearSFX&$FFFF	; play a sound effect
JSR SubSmoke				; create smoke where the sprite is appearing

.Return					;
RTS						;

;------------------------------------------------
; sprite state 01
;------------------------------------------------

State01:

JSL $81802A				; update the sprite's position

LDA $1588,x				;
AND #$04				; if the sprite is on the ground...
BEQ .Return				;

INC $C2,x				; increment the sprite state

.Return					;
RTS						;

;------------------------------------------------
; sprite state 02
;------------------------------------------------

State02:

JSL $81A7DC				; check for player/sprite contact
BCC .Return				; return if there is none

INC $C2,x				; increment the sprite state
INC $1602,x				; increment the animation frame
INC $160E,x				; set the flag to show the extra sprite tile
LDA.b #!OpenSFX>>16		;
STA.w !OpenSFX&$FFFF		; play a sound effect

.Return					;
RTS						;

;------------------------------------------------
; sprite state 03
;------------------------------------------------

State03:

LDA $151C,x				; check the sprite tile Y offset
CMP #$40				; if it has reached maximum...
BCS .StartBlinking			; make the tile start blinking
INC $151C,x				; else, increment the offset
INC $151C,x				;
.Return					;
RTS						;

.StartBlinking				;
LDA $1540,x				; if the blink timer has not been set, set it
BEQ .SetBlinkTimer			;
CMP #$01				; if it is down to 01, go to the next sprite state
BEQ .IncState				;
LSR #3					;
AND #$03				;
STA $160E,x				;
RTS						;

.SetBlinkTimer				;
LDA #!TimeToBlink			;
STA $1540,x				;
RTS						;

.IncState					;
INC $C2,x				;
RTS						;

;------------------------------------------------
; sprite state 04
;------------------------------------------------

State04:

LDA $1504,x			;
BPL .NoSetItemMemory	; if the sprite affects item memory...
JSR SetItemMemoryBit	; set the relevant bit
.NoSetItemMemory		;

PEA.w .Return-$01		;
LDA $1504,x			;
LSR #4				;
AND #$03			;
JSL $8086DF			;

dw SpawnSprite		;
dw SpawnSprite		;
dw ItemInBox			;
dw ActivateSub		;

.Return				;
INC $C2,x			;
LDA #!TimeTillActivate	;
STA $1540,x			;
RTS					;

ItemInBox:

LDA $1528,x			;
STA $0DC2			;
RTS					;

ActivateSub:

LDA $1528,x			;
JSL $8086DF			;

dw CustSub00			;
dw CustSub01			;
dw CustSub02			;
dw CustSub03			;
;dw CustSub04		;
;...
;dw CustSubFF			;

CustSub00:
CustSub01:
CustSub02:
CustSub03:
RTS

;------------------------------------------------
; sprite state 05
;------------------------------------------------

State05:

LDA $1540,x			; if the activation timer is still set...
BNE .Return			; return

LDA $1504,x			;
LSR #2				;
AND #$03			;
JSL $8086DF			;

dw .Return			;
dw .EndLevel			;
dw .EndLevel			;
dw .Teleport			;

.Return				;
RTS					;

.EndLevel

LDA $1504,x			;
LSR #2				;
DEC					;
AND #$01			;
STA $0DD5			;
STA $13CE			;
INC $1DE9			;
LDA #$0B				;
STA $0100			;
RTS					;

.Teleport

LDA $5B				;
LSR					;
BCS .Vertical			;
LDY $14E0,x			;
LDX $95				;
BRA .Continue			;
.Vertical				;
LDY $14D4,x			;
LDX $97				;
.Continue				;
LDA $19B8,y			;
STA $19B8,x			;
LDA $19D8,y			;
ORA #$04			;
STA $19D8,x			;
LDX $15E9			;
LDA #$06			;
STA $71				;
STZ $88				;
STZ $89				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TreasureChestGFX:

JSL !GetDrawInfo

STZ $05

LDA $00
STA $0300,y

LDA $01
STA $0301,y

LDA $1602,x
TAX
LDA.w Tilemap,x
STA $0302,y

LDX $15E9
LDA $15F6,x
ORA $64
STA $0303,y

LDA $160E,x
BEQ .NoExtraTile
JSR DrawSpriteTile
.NoExtraTile

LDY #$02
LDA $05
JSL $81B7B3
RTS

DrawSpriteTile:

LDA $00
STA $0304,y

LDA $01
SEC
SBC $151C,x
STA $0305,y

LDA $1510,x
TAX
LDA.w SpawnedTile,x
STA $0306,y

LDA.w SpawnedTileProps,x
ORA $64
STA $0307,y

LDX $15E9
INC $05
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; spawning routines
;------------------------------------------------

SpawnSprite:

JSL $82A9E4
BPL .Continue
RTS

.Continue

LDA $1510,x
STA $07
LDA $1528,x
STA $08
LDA $1504,x
STA $09

LDA $E4,x
STA $00E4,y
LDA $14E0,x
STA $14E0,y
LDA $D8,x
SEC
SBC $151C,x
STA $00D8,y
LDA $14D4,x
SBC #$00
STA $14D4,y

LDX $07
LDA.w SpawnStatus,x
STA $14C8,y
TYX
LDY $07
LDA $09
AND #$01
BNE .SpawnCustom

.SpawnNormal

LDA $08
STA $9E,x
JSL $87F7D2
BRA .Shared

.SpawnCustom

LDA $08
STA $7FAB9E,x
LDA $09
AND #$03
ORA #$80
STA $7FAB10,x
JSL $81830B
LDA SpawnEB1,y
STA $7FAB40,x
LDA SpawnEB2,y
STA $7FAB4C,x
LDA SpawnEB3,y
STA $7FAB58,x
LDA SpawnEB4,y
STA $7FAB64,x

.Shared

LDA SpawnXSpeed,y
STA $B6,x
LDA SpawnYSpeed,y
STA $AA,x
LDX $15E9
RTS

;------------------------------------------------
; smoke routine
;------------------------------------------------

SubSmoke:

PHY
LDY #$03
.FindFree
LDA $17C0,y
BEQ .FoundOne
DEY
BPL .FindFree
PLY
RTS

.FoundOne

LDA #$01
STA $17C0,y
LDA $D8,x
STA $17C4,y
LDA $E4,x
STA $17C8,y
LDA #$1B
STA $17CC,y

PLY
RTS

;------------------------------------------------
; item memory subroutines (for sprites; adapted from the object version at $0DA8DC)
;------------------------------------------------

GetItemMemoryBit:

PHX					;
PHY					;

JSR ItemMemoryIndexRt	;

LDA ($08),y			; item memory pointer
AND $818000,x		; check a particular bit
STA $0F				;

PLY					;
PLX					;
LDA $0F				;
RTS					;


SetItemMemoryBit:

PHX					;
PHY					;

JSR ItemMemoryIndexRt	;

LDA ($08),y			; item memory pointer
ORA $818000,x		; set a particular bit
STA ($08),y			;

PLY					;
PLX					;
RTS					;


ItemMemoryIndexRt:

LDA $5B				;
LSR					;
BCS .VertLevelSetup		;

LDA $E4,x			;
STA $0A				;
LDA $D8,x			;
STA $0B				;
LDA $14E0,x			;
STA $0C				;
LDA $14D4,x			;
STA $0D				;
BRA .Continue			;

.VertLevelSetup		;
LDA $D8,x			;
STA $0A				;
LDA $E4,x			;
STA $0B				;
LDA $14D4,x			;
STA $0C				;
LDA $14E0,x			;
STA $0D				;

.Continue				;

LDX $13BE			; item memory setting
LDA #$F8				; base address low byte
CLC					;
ADC $8DA8AE,x		; plus offset
STA $08				;
LDA #$19			; base address high byte
ADC $8DA8B1,x		; plus offset
STA $09				; forms a 16-bit pointer

LDA $0C				; screen number (high byte of X position, or Y in vertical levels)
ASL #2				;
STA $0E				;
LDA $0D				;
BEQ .UpperSubscreen	; if the sprite is on the lower subscreen...
LDA $0E				;
ORA #$02			;
STA $0E				;
.UpperSubscreen		;
LDA $0A				;
AND #$80			; if the sprite is on the left half of the subscreen...
BEQ .LeftHalf			;
LDA $0E				;
ORA #$01			;
STA $0E				;
.LeftHalf				;
LDA $0A				;
LSR #4				;
AND #$07			;
TAX					; get the bit index into the table
LDY $0E				; get the byte index
RTS					;


dl Init,Main











