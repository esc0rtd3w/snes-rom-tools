;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Door, by imamelia
;;
;; This is a door sprite that can be set to have various dimensions.  It will teleport
;; the player to a specified level number when activated.
;;
;; Extra bytes: 3
;;
;; Extra byte 1:
;;
;; Bits 0-7: Low byte of level number to teleport to.
;;
;; Extra byte 2:
;;
;; Bit 0: High bit of level number to teleport to.
;; Bit 1: Secondary exit flag.
;; Bit 2: Water level flag.
;; Bits 3-4: Door lock settings.
;;	00 - not locked
;;	01 - locked and can be opened with any key
;;	10 - locked and can be opened only with a key of the same color
;;	11 - locked and can be opened with any key, but sets a bit of free RAM
;; Bits 5-7: Door appearance settings.
;;	000 - normal
;;	001 - appears only when the blue P-switch is active
;;	010 - appears only when the blue P-switch is not active
;;	011 - appears only when the gray P-switch is active
;;	100 - appears only when the gray P-switch is not active
;;	101 - appears only when the on/off switch is on
;;	110 - appears only when the on/off switch is off
;;	111 - appears only if the level has been passed
;;
;; Extra byte 3:
;;
;; Bits 0-2: Which "locked" flag to use, for lock setting 3.
;; Bit 3: Affected by item memory.  If set, the door will stay unlocked after being unlocked once.
;;	This does not affect lock setting 3.
;; Bits 4-7: Tilemap and clipping index.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; X displacement, Y displacement, width, height
ClippingTbl:
db $04,$F6,$08,$1A	; 00 - 16x32 yellow door
db $00,$F6,$10,$1A	; 01 - 32x32 red door
db $00,$E6,$10,$2A	; 02 - 32x48 red door

; which palette number to check for each tilemap setting
; (relevant only if the lock setting is 2)
CheckPalettes:
db $06,$08,$08

HorizDisp1A:
HorizDisp1B:
db $00,$00,$00
VertDisp1A:
VertDisp1B:
db $F0,$00,$F8
Tilemap1A:
Tilemap1B:
db $14,$24,$26
TileProps1A:
TileProps1B:
db $07,$07,$07
TileSize1A:
TileSize1B:
db $02,$02,$02

HorizDisp2A:
HorizDisp2B:
db $00,$00,$00
VertDisp2A:
VertDisp2B:
db $F0,$00,$F8
Tilemap2A:
Tilemap2B:
db $14,$24,$26
TileProps2A:
TileProps2B:
db $09,$09,$09
TileSize2A:
TileSize2B:
db $02,$02,$02

HorizDisp3A:
HorizDisp3B:
db $F8,$08,$F8,$08,$F8,$08,$00
VertDisp3A:
VertDisp3B:
db $E0,$E0,$F0,$F0,$00,$00,$F0
Tilemap3A:
Tilemap3B:
db $82,$82,$92,$92,$A2,$A2,$A4
TileProps3A:
TileProps3B:
db $09,$49,$09,$49,$09,$49,$09
TileSize3A:
TileSize3B:
db $02,$02,$02,$02,$02,$02,$02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		; extra byte 1
STA $1528,x			; $1528,x - low byte of teleport settings
LDA $7FAB4C,x		; extra byte 2
STA $00				;
AND #$07			;
STA $1534,x			; $1534,x - high byte of teleport settings
LDA $00				;
AND #$18			;
LSR #3				;
STA $1504,x			; $1504,x - lock settings
LDA $00				;
LSR #5				;
STA $187B,x			; $187B,x - door appearance settings
LDA $7FAB58,x		; extra byte 3
STA $00				;
AND #$07			;
STA $151C,x			; $151C,x - which lock flag to use
LDA $00				;
LSR #4				;
STA $160E,x			; $160E,x - GFX/clipping index
LDA $00				;
AND #$08			; item memory bit
STA $1594,x			; $1594,x - item memory flag
BEQ .EndInit			; if it is affected by item memory, check if it should be unlocked

LDA $1504,x			;
BEQ .EndInit			; if it was unlocked in the first place, skip the check
CMP #$03			;
BEQ .LockedFlagCheck	; if its lock status depends on free RAM, use a different check

JSR GetItemMemoryBit	; check the item memory bits
BEQ .EndInit			; if the relevant item memory bit has not been set, then nothing happens

STZ $1504,x			; if the relevant item memory bit has been set, clear the locked status

.EndInit				;
RTL					;

.LockedFlagCheck		;
LDA $151C,x			; which bit of free RAM to use
TAX					;
LDA $818000,x		;
LDX $15E9			;
AND !RAM_LockedFlags	; if the relevant bit is set...
BEQ .EndInit			;
STZ $1504,x			; clear the locked status
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR DoorMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoorMain:

JSR CheckStatus		;
LDA $160E,x			; tilemap index
ASL					; x2 for locked/unlocked status
LDY $1504,x			; check the locked status
CPY #$01				; if the door is locked in any way...
ADC #$00			; then carry will be set here and the tilemap will increase by 1
STA $1602,x			;
PEA.w .PastGFX-$01	; push the real return address
JSL !GenericSprGFX		; shared GFX routine

dw HorizDisp1A,VertDisp1A,Tilemap1A,TileProps1A,TileSize1A : db $01	; tilemap setting 00 (unlocked)
dw HorizDisp1B,VertDisp1B,Tilemap1B,TileProps1B,TileSize1B : db $02	; tilemap setting 00 (locked)
dw HorizDisp2A,VertDisp2A,Tilemap2A,TileProps2A,TileSize2A : db $03	; tilemap setting 01 (unlocked)
dw HorizDisp2B,VertDisp2B,Tilemap2B,TileProps2B,TileSize2B : db $04	; tilemap setting 01 (locked)
dw HorizDisp3A,VertDisp3A,Tilemap3A,TileProps3A,TileSize3A : db $05	; tilemap setting 02 (unlocked)
dw HorizDisp3B,VertDisp3B,Tilemap3B,TileProps3B,TileSize3B : db $06	; tilemap setting 02 (locked)

.PastGFX

LDA $14C8,x			;
CMP #$08			;
BNE .Return			;
LDA $9D				;
BNE .Return			;

JSL !SubOffscreenX0	;

JSL $83B664			;
JSR SetSpriteClipping	;
JSL $83B72B			;
BCC .Return			;

LDA $16				;
AND #$08			;
BEQ .Return			;

LDA $1504,x			;
BEQ .SkipLockCheck	;
JSR CheckLock			;
.SkipLockCheck		;

JSR TeleportDoor		;

.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; check whether or not the sprite should appear and interact
;------------------------------------------------

CheckStatus:

LDA $187B,x		;
BEQ .Return		;
PEA.w .End-$01	;
DEC				;
JSL $8086DF		;

dw .Check1		;
dw .Check2		;
dw .Check3		;
dw .Check4		;
dw .Check5		;
dw .Check6		;
dw .Check7		;

.End				;
BEQ .Return		;
PLA				; return not only from this routine,
PLA				; but also from the main one
.Return			;
RTS				;

.Check1			;
LDY #$00			;
LDA $14AD		;
BNE $01			;
INY				;
CPY #$00			;
RTS				;

.Check2			;
LDA $14AD		;
RTS				;

.Check3			;
LDY #$00			;
LDA $14AE		;
BNE $01			;
INY				;
CPY #$00			;
RTS				;

.Check4			;
LDA $14AE		;
RTS				;

.Check5			;
LDA $14AF		;
RTS				;

.Check6			;
LDA $14AF		;
EOR #$01			;
RTS				;

.Check7			;
LDY $13BF		;
LDA $1EA2,y		;
AND #$80		;
EOR #$80			;
RTS				;

;------------------------------------------------
; locked status check routine
;------------------------------------------------

CheckLock:

LDY #$0B				;

.SpriteLoop			;

LDA $14C8,y			;
CMP #$0B			;
BNE .NextSprite		;

LDA $009E,y			;
CMP #$80			;
BNE .NextSprite		;

LDA $1504,x			;
CMP #$02			;
BNE .Unlock			;

JSR CheckPalette		;
BNE .NextSprite		;

.Unlock				;

LDA $1504,x			;
CMP #$03			;
BNE .NoSetFlag		;

LDA $151C,x			; which bit of free RAM to use
TAX					;
LDA $818000,x		;
LDX $15E9			;
ORA !RAM_LockedFlags	;
STA !RAM_LockedFlags	;

.NoSetFlag			;

LDA $1594,x			;
BEQ .NoItemMemory	;
JSR SetItemMemoryBit	;
.NoItemMemory		;

STZ $1504,x			;
JSR EraseKey			;

RTS					;

.NextSprite			;
DEY					;
BPL .SpriteLoop		;
PLA					;
PLA					;
RTS					;

CheckPalette:

PHY					;
LDY $160E,x			;
LDA CheckPalettes,y	;
STA $00				;
PLY					;
LDA $15F6,y			;
AND #$0E			;
CMP $00				;
RTS					;

EraseKey:				;

LDA #$04			;
STA $14C8,y			;
LDA #$0F				;
STA $1540,y			;

PHX					;
TYX					;
LDA $7FAB40,x		;
PLX					;
AND #$80			;
BEQ .Return			;

PHX					;
TYX					;
LDA $E4,x			;
PHA					;
LDA $D8,x			;
PHA					;
LDA $14E0,x			;
PHA					;
LDA $14D4,x			;
PHA					;

LDA $7FAD00,x		;
STA $E4,x			;
LDA $7FAD0C,x		;
STA $D8,x			;
LDA $7FAD18,x		;
STA $14E0,x			;
LDA $7FAD24,x		;
STA $14D4,x			;

JSR SetItemMemoryBit	;

PLA					;
STA $14D4,x			;
PLA					;
STA $14E0,x			;
PLA					;
STA $D8,x			;
PLA					;
STA $E4,x			;
PLX					;

.Return				;
RTS					;

;------------------------------------------------
; teleporting routine
;------------------------------------------------

TeleportDoor:

LDY $95			;
LDA $5B			;
LSR				;
BCC .NotVertical	;
LDY $97			;
.NotVertical		;

LDA $1528,x		;
STA $19B8,y		;
LDA $1534,x		;
PHA				;
AND #$04		;
ASL				;
STA $00			;
PLA				;
AND #$03		;
ORA #$04		;
ORA $00			;
STA $19D8,y		;

LDA #$05		;
STA $71			;
STZ $88			;
STZ $89			;

LDA #$0F			;
STA $1DFC		;

RTS				;

;------------------------------------------------
; sprite clipping routine
;------------------------------------------------

SetSpriteClipping:		; custom sprite clipping routine, based off $03B69F

LDA $160E,x			;
ASL #2				;
TAY					;
STZ $0F				;
LDA ClippingTbl,y		;
BPL $02				;
DEC $0F				;
CLC					;
ADC $E4,x			;
STA $04				; $04 = sprite X position low byte + X displacement value
LDA $14E0,x			;
ADC $0F				;
STA $0A				; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDA ClippingTbl+2,y	;
STA $06				; $06 = sprite clipping width
STZ $0F				;
LDA ClippingTbl+1,y	;
BPL $02				;
DEC $0F				;
CLC					;
ADC $D8,x			;
STA $05				; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x			;
ADC $0F				;
STA $0B				; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA ClippingTbl+3,y	;
STA $07				; $07 = sprite clipping height
RTS					;

;------------------------------------------------
; player/sprite contact check routine
;------------------------------------------------

CheckForContact:	;

PHX				;
LDX #$01			;

ContactLoop:		;

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
BCC EndCLoop		;
DEX				;
BPL ContactLoop	;

EndCLoop:		;
PLX				;
RTS				;

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











