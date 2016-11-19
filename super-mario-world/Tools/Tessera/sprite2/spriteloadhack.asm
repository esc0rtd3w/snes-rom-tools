
header
lorom

!Freespace = $168618

!LastSpecial = $49			; last Special World level, the one that changes the sprite palettes and graphics

org $02A82A				; main sprite loading code rewrite
JML SpriteLoadHack			;

org $018127				;
JML SpriteStatusHack		;
PHB						; $01812B
PHK						;
PLB						;
JSR $8133				; In case you want to call the default status routines within custom sprite code for any reason,
PLB						; you can use this.  Just JSL to $01812B with your acts-like setting in $9E,x and the status in A.
RTL						;

org $02B3AB				; shooter codes
JML ShooterMainHack		;
NOP #7					;

org $02B003				;
JML GeneratorMainHack		;

org $01830B				;
JML LoadCustomSprite		;

org $07F79A				;
JSL ByteLoadHack			;

; TO DO:
; - hack scroll sprite codes, rearrange pointers
; - and probably some other stuff I forgot...

org $01C089				; goal tape init routine
LDA $7FAB40,x			;
STA $187B,x				; instead of the extra bits, the first extra byte goes in the normal/secret exit info
LDA $14D4,x				;
STA $1534,x				;
RTL						;

org $01C0EA				; part of the goal tape main routine
NOP #2					; no need to bit-shift $187B,x anymore

org $0185C3				;
PHB						;
JML CallSpriteMain			;

org $0EF30C				;
dl SpriteDataSize : db $42	; enable extra bytes and insert the extra byte data table

incsrc sprite2/spriteorigremap.asm

org !Freespace
reset bytes
db "STAR"
dw End-Start-$01
dw End-Start-$01^$FFFF

Start:

BitTable:
db $01,$02,$04,$08,$10,$20,$40,$80

ByteLoadHack:			;
LDA #$00			;
STA $7FAB10,x		;
LDA $9E,x			;
STA $7FAB9E,x		;
JML $87F7A0			;

LoadCustomSprite:
JSL $87F722			; zero out sprite tables
PHB					;
PHK					;
PLB					;
PHY					;
LDA $7FAB9E,x		;
STA $14B3			;
LDA $7FAB10,x		;
AND #$03			;
STA $14B4			; $14B3 = custom sprite number (16-bit)
PHX					;
REP #$10				;
LDY $14B3			;
LDA Sprite1656Vals,y	;
STA $1656,x			;
LDA Sprite1662Vals,y	;
STA $1662,x			;
LDA Sprite166EVals,y	;
STA $166E,x			;
AND #$0F			;
STA $15F6,x			;
LDA Sprite167AVals,y	;
STA $167A,x			;
LDA Sprite1686Vals,y	;
STA $1686,x			;
LDA Sprite190FVals,y	;
STA $190F,x			;
LDA ExtraProp1,y		;
STA $7FAB28,x		;
LDA ExtraProp2,y		;
STA $7FAB34,x		;
SEP #$10				;
PLX					;
PLY					;
PLB					;
RTL					;

SpriteStatusHack:

PHB
PHK
PLB
LDA $14C8,x			;
BEQ .EraseSprite		; if the sprite status is 00, just erase the sprite
CMP #$08			;
BEQ SpriteMainRt		; if the sprite status is 08, call the main routine
CMP #$01			;
BEQ CallSpriteInit		; if the sprite status is 01, call the init routine
LDA $7FAB10,x		;
BPL .NotCustom		;
LDA $7FAB34,x		; check the extra flags
AND #$07			; the first 3 bits indicate which statuses custom code will be run in
ASL					;
TAY					;
PHX					;
LDA $14C8,x			;
ASL					;
TAX					;
REP #$20				;
LDA SpriteStatuses,y	;
AND.w Reverse16Bits,x	;
PLX					;
CMP.w #$0000			;
BNE SpriteMainRt		;
SEP #$20				;
.NotCustom			;
PLB					;
LDA $14C8,x			;
JML $818133			;
.EraseSprite			;
PLB					;
JML $818151			;

SpriteMainRt:			;
SEP #$20				;
JMP CallSpriteMain		;

CallSpriteInit:			;

LDA #$08			;
STA $14C8,x			; restore hijacked code

PHB					;
PHK					;
PLB					;
LDA $7FAB10,x		;
AND #$03			;
STA $14B4			;
LDA $7FAB9E,x		; sprite number into the low byte
STA $14B3			; sprite number/extra bits
REP #$30				;
LDA $14B3			;
ASL					;
ADC $14B3			; x3
TAY					;
LDA SpriteInitPtrs,y		;
STA $14B3			;
SEP #$20				;
LDA SpriteInitPtrs+2,y	;
STA $14B5			;
PHA					;
PLB					;
SEP #$10				;
PHP					;
PHK					;
PEA.w .Return-$01		;
JML [$14B3]			;
.Return				;
PLP					;
PLB					;
PLB					;
JML $818156			;

CallSpriteMain:		;

STZ $1491			; restore hijacked code

PHB					;
PHK					;
PLB					;
LDA $7FAB10,x		;
AND #$03			;
STA $14B4			;
LDA $7FAB9E,x		; sprite number into the low byte
STA $14B3			; sprite number/extra bits
REP #$30				;
LDA $14B3			;
ASL					;
ADC $14B3			; x3
TAY					;
LDA SpriteMainPtrs,y	;
STA $14B3			;
SEP #$20				;
LDA SpriteMainPtrs+2,y	;
STA $14B5			;
PHA					;
PLB					;
SEP #$10				;
LDA $14C8,x			; preserve the sprite status in A
PHP					;
PHK					;
PEA.w .Return-$01		;
JML [$14B3]			;
.Return				;
PLP					;
PLB					;
PLB					;
JML $818156			;

ShooterMainHack:		;

PHB					;
PHK					;
PLB					;
LDA $1783,x			; $1783,x = shooter number
REP #$30				;
AND.w #$00FF			;
STA $14B3			;
ASL					;
ADC $14B3			;
TAY					;
LDA ShooterPtrs,y		;
STA $14B3			;
SEP #$20				;
LDA ShooterPtrs+2,y	;
STA $14B5			;
PHA					;
PLB					;
SEP #$10				;
PHP					;
PHK					;
PEA.w .Return-$01		;
JML [$14B3]			;
.Return				;
PLP					;
PLB					;
JML $82B3AA			;

GeneratorMainHack:	;

LDY $9D				; restore hijacked code
BNE .EndGenerator		; return if sprites are locked
PHB					;
PHK					;
PLB					;
REP #$30				; $18B9 = generator number (already in A)
AND.w #$00FF			;
STA $14B3			;
ASL					;
ADC $14B3			;
TAY					;
LDA GeneratorPtrs,y	;
STA $14B3			;
SEP #$20				;
LDA GeneratorPtrs+2,y	;
STA $14B5			;
PHA					;
PLB					;
SEP #$10				;
PHP					;
PHK					;
PEA.w .Return-$01		;
JML [$14B3]			;
.Return				;
PLP					;
PLB					;
.EndGenerator			;
JML $82AFFD			;


EndSprLoad:			;
PLB					;
SEP #$30				;
JML $82A84B			; jump back to an RTS in bank 02

SpriteLoadHack:

PHB					;
PHK					;
PLB					;

; $00-$01 = sprite's position relative to the screen boundary (Y or X depending on the level direction)
; $02-$03 = sprite's load index ($1938,x)
; $04-$05 = sprite's index to level data ([$CE],y)
; $06 = first byte of sprite data (yyyyeeSY, or xxxxeeSX in vertical levels)
; $07 = second byte of sprite data (xxxxssss, or yyyyssss in vertical levels)
; $08 = third byte of sprite data (nnnnnnnn)
; $09 = sprite extra bits/number high byte (------ee)
; $0A = fourth byte of sprite data (even if the sprite uses only three)
; $0B-$0F = scratch
;	$0B: screen number and low byte of sprite table index
;	$0C: high byte of sprite table index (always 00)
;	$0D: pointer to extra byte count table (low byte), acts-like setting
;	$0E: pointer to extra byte count table (high byte), sprite slot starting value
;	$0F: pointer to extra byte count table (bank byte)
; $14B0-$14B8 = scratch

REP #$10				; 16-bit XY
STZ $02				;
STZ $03				;
LDA #$01			;
STA $04				;
STZ $05				;

.MainLoopStart		;

LDY $04				;
LDX $02				;
CPX.w #$0080			; if there are more than 128 sprites in the level...
BCS EndSprLoad		; don't load the rest, since the loading table is only 128 bytes long

LDA [$CE],y			; first byte: yyyyeeSY
CMP #$FF			; if the first byte of sprite data is FF, then this is the end of it
BEQ EndSprLoad		;
STA $06				; $06 = first byte of sprite data (prevents having to load [$CE],y again)
ASL #3				;
AND #$10			;
STA $0B				; get the high bit of the screen
INY					;
LDA [$CE],y			; second byte: xxxxssss
STA $07				; $07 = second byte of sprite data
AND #$0F			;
ORA $0B				; if the screen the sprite is on (Sssss) is less than the adjusted screen boundary (or greater, in fact),
CMP $01				; then skip this sprite
PHP					;
INY					;
LDA [$CE],y			; third byte: nnnnnnnn
STA $08				; $08 = third byte of sprite data
LDA $06				;
LSR #2				;
AND #$03			;
STA $09				; $09 = extra bits or high byte of the sprite number
INY					;
LDA [$CE],y			;
STA $0A				; $0A = first extra byte (will be useful later)
PHY					;
INY					;
LDA [$CE],y			;
STA $14B6			; $14B6 = second extra byte
INY					;
LDA [$CE],y			;
STA $14B7			; $14B7 = third extra byte
INY					;
LDA [$CE],y			;
STA $14B8			; $14B8 = fourth extra byte
PLY					;
PLP					;
BEQ .Continue			; skip the sprite if it is not on the current screen
BRA .FinishSpriteLoad	;

.LoadNextSprite		;

JSR .GetExtraByteCount	;
LDA $14B1			;
SEC					;
SBC #$03				;
STA $14B0			;
LDX $0B				; sprite table index
LDY $04				; sprite data index
INY #3				; first extra byte
.ExtraByteLoop			;
LDA $0A				;
STA $7FAB40,x		; first extra byte
LDA $14B6			;
STA $7FAB4C,x		; second extra byte
LDA $14B7			;
STA $7FAB58,x		; third extra byte
LDA $14B8			;
STA $7FAB64,x		; fourth extra byte
BRA .FinishSpriteLoad2	;
.FinishSpriteLoad		;
JSR .GetExtraByteCount	;
.FinishSpriteLoad2		;
REP #$30				;
LDA $04				;
CLC					;
ADC $14B1			; increment the sprite data index by 3 always
STA $04				;
INC $02				; increment the sprite loading index
SEP #$20				; A -> 8-bit
JMP .MainLoopStart		;

.GetExtraByteCount		;
REP #$30				;
LDA $08				; $08-$09 = sprite number concatenated with extra bits
TAY					; sprite number/extra bits into X to index the extra byte table
LDA $0EF30C			;
STA $0D				; set the pointer to the extra byte count table
SEP #$20				;
LDA $0EF30E			;
STA $0F				;
LDA [$0D],y			; number of extra bytes
STA $14B1			;
STZ $14B2			;
RTS					;

.Continue				;

LDA $07				;
AND #$F0			;
CMP $00				;
BNE .FinishSpriteLoad	;

LDA $1938,x			; if the sprite has already been loaded/permanently deleted...
BNE .FinishSpriteLoad	; skip it
INC $1938,x			; mark this sprite as loaded

LDA $09				; if the high byte of the sprite number is not 00...
BNE .LoadNormalSprite	; then the sprite is assumed to be a normal one
LDA $08				; check the sprite number
CMP #$C9			; if the sprite number is less than C9...
BCC .LoadNormalSprite	; then the sprite is assumed to be a normal one
BEQ .LoadShooter		; if the sprite number is C9, then the sprite is a shooter (original or custom)
CMP #$CD			; if the sprite number is CD, then the sprite is a scroll sprite (original or custom)
BEQ .LoadScrollSprite	;
BCS .LoadNormalSprite	; if the sprite number is greater than CD, then the sprite is assumed to be a normal one
CMP #$CA			; if the sprite number is CA...
BEQ .LoadGenerator		; then the sprite is a generator
CMP #$CB			; if the sprite number is CB...
BEQ .LoadRunOnceSpr	; then the sprite is a run-once sprite

.LoadClusterGen		; the only sprite number left is CC, so this must be a cluster sprite generator
JMP .ClusterGenCodes	;

.LoadRunOnceSpr		;
JMP .RunOnceSprCodes	;

.LoadShooter			;
JMP .ShooterInit		;

.LoadScrollSprite		;
JMP .ScrollSpriteCodes	;

.LoadNormalSprite		;
JMP .NormalSpriteCodes	;

.LoadGenerator		;
LDA $0A				; the extra byte
STA $18B9			; goes into the generator number
STZ $1938,x			; generators are always reloaded
LDA #$00			;
STA $7FAB00			; initialize some miscellaneous RAM for use in generators
STA $7FAB01			; (there was none in SMW)
STA $7FAB02			;
STA $7FAB03			;
LDA $14B6			; set the extra bytes
STA $7FAB04			;
LDA $14B7			;
STA $7FAB05			;
LDA $14B8			;
STA $7FAB06			;
LDA $5B				; set the generator's XY position
LSR					; (this code was not in SMW; I added it)
BCS .VertLvlGenPos		;

LDA $07				; xxxxssss
LSR #4				;
STA $7FABFF			; ----xxxx
LDA $06				; yyyyeeSY
AND #$F0			;
ORA $7FABFF			;
STA $7FABFF			; yyyyxxxx
LDA $06				;
ASL #5				; get the high bit of the Y position
AND #$20			;
ORA $0B				; --YSssss
STA $7FABFE			;
JMP .FinishSpriteLoad	;

.VertLvlGenPos		;
LDA $06				; xxxxeeSX
LSR #4				;
STA $7FABFF			; ----xxxx
LDA $07				; yyyyssss
AND #$F0			;
ORA $7FABFF			;
STA $7FABFF			; yyyyxxxx
LDA $06				;
ASL #5				; get the high bit of the X position
AND #$20			;
ORA $0B				; --XSssss
STA $7FABFE			;
JMP .FinishSpriteLoad	;

.ScrollSpriteCodes		;

LDA $143E			; if there is already a scroll sprite active...
ORA $143F			;
BNE .NoScrollSpr		;
LDY $04				;
INY #4				;
LDA $14B6			; second extra byte
STA $1440			; into $1440
LDA $14B7			;
STA $7FAB0A			; third extra byte
LDA $14B8			;
STA $7FAB0B			; fourth extra byte
PHX					;
PHY					;
PHP					;
SEP #$10				; 8-bit XY
LDA $0A				; the first extra byte
STA $143E			; goes into the scroll sprite number
JSL $85BCD6			; main scroll sprite codes
PLP					;
PLY					;
PLX					;
.NoScrollSpr			;
JMP .FinishSpriteLoad	;

.NormalSpriteCodes		;

LDY $08				;
LDA ActsLike,y		; check the acts-like setting for the sprite
STA $0D				; here, $0D is the acts-like setting
STZ $0F				; $0F = custom flag
REP #$20				;
LDA $08				;
LSR #3				; sprite number / 3 provides the byte index into the table
TAY					; Y = byte index
LDA $08				; (X and Y will be overwritten anyway)
AND.w #$0007		; sprite number % 7 provides the bit index into the table
TAX					; X = bit index
SEP #$20				; A back to 8-bit mode
LDA CustomFlags,y		;
AND.w BitTable,x		;
BEQ .NoCustomFlag		; if this sprite is a custom one...
LDA #$80			; then the custom sprite flag, bit 7 of $7FAB10,x,
STA $0F				; will be set
.NoCustomFlag		;

PHB					; preserve the data bank
LDA #$02			;
PHA					;
PLB					; set the data bank to 02, where all the sprite slot tables are

SEP #$10				; 8-bit XY
LDY $1692			;
LDX $A773,y			; $02A773 = sprite slot maximum value table 1
LDA $A7AC,y			; $02A7AC = sprite slot starting value table
STA $0E				;
LDA $0D				; if this is the first reserved sprite...
CMP $A7D2,y			; $02A7D2 = first list of reserved sprites
BNE .NotReserved1		;
LDX $A786,y			; $02A786 = highest sprite index?
LDA $A7BF,y			; $02A7BF = lowest sprite index?
STA $0E				;
.NotReserved1			;
LDA $0D				; if this is the second reserved sprite...
CMP $A7E4,y			; $02A7E4 = second list of reserved sprites
BNE .NotReserved2		;
CMP #$64			; if the sprite is the line-guided rope...
BNE .NotLineRope		;
LDA $00				;
AND #$10			; then only use the special index if it is a long rope
BEQ .NotReserved2		;
.NotLineRope			;
LDX $A799,y			; $02A799 = sprite slot maximum value table 2
LDA #$FF				;
STA $0E				;

.NotReserved2			;
PLB					; pull back the previous data bank
.SprStatusChkLoop		;
LDA $14C8,x			;
BEQ .SpriteExists		;
DEX					;
CPX $0E				;
BNE .SprStatusChkLoop	;
LDA $0D				;
CMP #$7B			; if the sprite is the goal tape (sprite 7B)...
BNE .NotGoalTape		;

LDX $0B				;
.GoalTapeLoop			;
LDA $167A,x			;
AND #$02			;
BEQ .SpriteExists		;
DEX					;
CPX $0E				;
BNE .GoalTapeLoop		;

.NotGoalTape			;
SEP #$10				;
LDX $02				;
STZ $1938,x			;
JMP EndSprLoad		;

.SpriteExists			;
STX $0B				; $0B = index to sprite tables
STZ $0C				; $0C = always 00, since $0B is sometimes loaded in 16-bit mode
LDA $5B				;
LSR					;
BCS .ExtraBitsInVertLvl	;

LDA $06				; $06 = yyyyeeSY
AND #$F0			;
STA $D8,x			; set the sprite's starting Y position (low byte)
LDA $06				;
AND #$01			;
STA $14D4,x			; set the sprite's starting Y position (high byte)
LDA $00				;
STA $E4,x			; set the sprite's starting X position (low byte)
LDA $01				;
STA $14E0,x			; set the sprite's starting X position (high byte)
BRA .Continue2		;

.ExtraBitsInVertLvl		;
LDA $06				; $06 = xxxxeeSX
AND #$F0			;
STA $E4,x			; set the sprite's starting X position (low byte)
LDA $06				;
AND #$01			;
STA $14E0,x			; set the sprite's starting X position (high byte)
LDA $00				;
STA $D8,x			; set the sprite's starting Y position (low byte)
LDA $01				;
STA $14D4,x			; set the sprite's starting Y position (high byte)

.Continue2			;
LDA $09				;
ORA $0F				;
STA $7FAB10,x		; set the sprite's extra bits

LDA #$01			;
STA $14C8,x			; sprite status = init
LDA $0D				; $0D here = sprite number/acts-like setting
PHY					;
LDY $1EA2+!LastSpecial	;
BPL .NoChangeKoopa	; if the Special World has been passed, change the Koopas' colors
CMP #$04			;
BNE .NotGreenKoopa	;
LDA #$07			;
.NotGreenKoopa		;
CMP #$05			;
BNE .NoChangeKoopa	;
LDA #$06			;
.NoChangeKoopa		;
STA $9E,x			;
LDA $08				;
STA $7FAB9E,x		;
PLY					;

LDA $02				;
STA $161A,x			;
LDA $14AE			; if the silver P-switch timer is set, change sprites into coins
BEQ .NoSilverCoin		;
LDA $9E,x			;
TAX					;
LDA Sprite190FVals,x	; sprite $190F,x values
LDX $0B				;
AND #$40			; if the sprite does not change into a silver coin...
BNE .NoSilverCoin		; skip the change

LDA #$21			; sprite 21 = moving coin
STA $9E,x			;
LDA #$08			; sprite status = normal
STA $14C8,x			;
JSL $87F7D2			; initialize sprite tables
LDA #$02			;
STA $15F6,x			; set the sprite palette to palette 9 (the AND/ORA is kind of pointless, actually)
BRA .Continue3		;

.NoSilverCoin			;
LDA $7FAB10,x		;
BPL .NoInitCustom		; if the sprite is a custom one...
JSL LoadCustomSprite	; load custom table values
BRA .Continue3		;
.NoInitCustom			;
JSL $87F7D2			; initialize sprite tables
.Continue3			;
LDA #$01			;
STA $15A0,x			; mark the sprite as offscreen
LDA #$04			;
STA $1FE2,x			; cape contact timer?
REP #$10				;
JMP .LoadNextSprite	; move on to the next sprite

.ClusterGenCodes		;

LDA #$01			;
STA $18B8			; activate cluster sprites
LDA $14B6			; set the extra bytes
STA $7FAB07			;
LDA $14B7			;
STA $7FAB08			;
LDA $14B8			;
STA $7FAB09			;
LDA $0A				; $0A = first extra byte
REP #$30				;
AND.w #$00FF			;
STA $14B3			;
ASL					;
ADC $14B3			; x3
TAY					;
LDA ClusterGenPtrs,y	;
STA $14B3			;
SEP #$20				;
LDA ClusterGenPtrs+2,y	;
STA $14B5			;
SEP #$10				;
PHB					;
PHA					; set the data bank to the bank byte of the pointer
PLB					;
PHP					;
PHK					;
PEA.w .EndCluster-$01	;
JML [$14B3]			; thank goodness this uses a 16-bit address; I ran out of scratch RAM
.EndCluster			;
PLP					;
PLB					;
JMP .FinishSpriteLoad	;

.RunOnceSprCodes

LDA $14B6				; set the extra bytes
STA $7FAB07				;
LDA $14B7				;
STA $7FAB08				;
LDA $14B8				;
STA $7FAB09				;
LDA $0A					; $0A = first extra byte
REP #$30					;
AND.w #$00FF				;
STA $14B3				;
ASL						;
ADC $14B3				; x3
TAY						;
LDA RunOnceSprPtrs,y		;
STA $14B3				;
SEP #$20					;
LDA RunOnceSprPtrs+2,y	;
STA $14B5				;
SEP #$10					;
PHB						;
PHA						; set the data bank to the bank byte of the pointer
PLB						;
PHP						;
PHK						;
PEA.w .EndRunOnce-$01		;
JML [$14B3]				;
.EndRunOnce				;
PLP						;
PLB						;
JMP .FinishSpriteLoad		;

.ShooterInit				;
SEP #$10					;
LDX #$07					;
.FindShooterSlot			;
LDA $1783,x				;
BEQ .FreeShooterSlot		;
DEX						;
BPL .FindShooterSlot		;
DEC $18FF				;
BPL .StillFreeS				;
LDA #$07				;
STA $18FF				; reset the shooter slot counter if necessary
.StillFreeS					;
LDX $18FF				;
LDY $17B3,x				;
LDA #$00				; if we had to overwrite another shooter,
STA $1938,y				; make sure that the overwritten one reloads

.FreeShooterSlot			;
LDA $0A					; $0A = first extra byte (shooter number)
STA $1783,x				;
LDA $14B6				;
STA $7FAC00,x			; $14B6 = second extra byte
LDA $14B7				;
STA $7FAC08,x			; $14B7 = third extra byte
LDA $14B8				;
STA $7FAC10,x			; $14B8 = fourth extra byte
LDA $5B					;
LSR						;
BCS .ShooterInitVertLevel	;

LDA $06					; $06 = yyyyeeSY
AND #$F0				;
STA $178B,x				; set the initial Y position low byte of the shooter
LDA $06					;
AND #$01				;
STA $1793,x				; set the initial Y position high byte of the shooter
LDA $00					;
STA $179B,x				; set the initial X position low byte of the shooter
LDA $01					;
STA $17A3,x				; set the initial X position high byte of the shooter
BRA .ContinueShooterInit	;

.ShooterInitVertLevel		;
LDA $06					; $06 = yyyyeeSY
AND #$F0				;
STA $179B,x				; set the initial X position low byte of the shooter
LDA $06					;
AND #$01				;
STA $17A3,x				; set the initial X position high byte of the shooter
LDA $00					;
STA $178B,x				; set the initial Y position low byte of the shooter
LDA $01					;
STA $1793,x				; set the initial Y position high byte of the shooter

.ContinueShooterInit		;
LDA $02					;
STA $17B3,x				; this shooter's index to the sprite data
LDA #$10				;
STA $17AB,x				; time until it shoots
LDA #$00				;
STA $7FAC18,x			; initialize my miscellaneous shooter tables
STA $7FAC20,x			; (there weren't any misc. shooter tables in the original SMW,
STA $7FAC28,x			; so I added some)
STA $7FAC30,x			;
STA $7FAC38,x			;
REP #$10					;
JMP .FinishSpriteLoad		;

ClusterGen00:				; original sprite E3, clockwise Boo ring

LDA #$01				;
BRA ContinueBooRing		;

ClusterGen01:				; original sprite E2, counterclockwise Boo ring

LDA #$FF					;
ContinueBooRing:			;
LDY $18BA				;
CPY #$02					;
BCS .EndBooRing			;
STA $0F					;
LDA #$09				;
STA $0E					;
LDX #$13					; 0x14 cluster sprite indices to loop through
.FindFree					;
LDA $1892,x				;
BNE .CheckNext			;
LDA #$04				; cluster sprite number = 04
STA $1892,x				;
LDA $18BA				;
STA $0F86,x				;
LDA $0E					;
STA $0F72,x				;
LDA $0F					;
STA $0F4A,x				;
STZ $0F					;
BEQ .Skip					;
LDY $18BA				;
LDA $06					; yyyyeeSY
AND #$F0				;
STA $0FB6,y				; Y position low byte of the center of the Boo ring
LDA $06					;
AND #$01				;
STA $0FB8,y				; Y position high byte of the center of the Boo ring
LDA $00					;
STA $0FB2,y				; X position low byte of the center of the Boo ring
LDA $01					;
STA $0FB4,y				; X position high byte of the center of the Boo ring
LDA #$00				;
STA $0FBA,y				;
LDA $02					;
STA $0FBC,y				;

.Skip					;
DEC $0E					;
BMI .EndBooRing2			;
.CheckNext				;
DEX						;
BPL .FindFree				;
.EndBooRing2				;
INC $18BA				;
.EndBooRing				;
RTL						;

ClusterGen02:				; original sprite E1, Boo ceiling

LDX #$13					;
.BooCeilingLoop			;
STZ $1E66,x				; no X speed
STZ $0F86,x				;
LDA #$03				; cluster sprite number = 03
STA $1892,x				;
JSL $81ACF9				; random X and Y position
CLC						;
ADC $1A					;
STA $1E16,x				; X position low byte
STA $0F4A,x				;
LDA $1B					;
ADC #$00				;
STA $1E3E,x				; X position high byte
LDA $148E				;
AND #$3F				;
ADC #$08				;
CLC						;
ADC $1C					;
STA $1E02,x				; Y position low byte
LDA $1D					;
ADC #$00				;
STA $1E2A,x				; Y position high byte
DEX						;
BPL .BooCeilingLoop		;
INC $18BA				;
RTL						;

ClusterGen03:		; original sprite E4, death bat ceiling

LDX #$0E			;
.DeathBatLoop		;
STZ $1E66,x		;
STZ $0F86,x		;
LDA #$08			; cluster sprite number = 08
STA $1892,x		;
JSL $81ACF9		;
CLC				;
ADC $1A			;
STA $1E16,x		; X position low byte
STA $0F4A,x		;
LDA $1B			;
ADC #$00			;
STA $1E3E,x		; X position high byte
LDA $06			; yyyyeeSY
AND #$F0			;
STA $1E02,x		; Y position low byte
LDA $06			;
AND #$01			;
STA $1E2A,x		; Y position high byte
DEX				;
BPL .DeathBatLoop		;
RTL				;

ClusterGen04:		; original sprite E5, reappearing Boos

STZ $190A			; reset the reappearing timer
LDX #$13			;
.ReappearingBooLoop	;
LDA #$07			; cluster sprite number = 07
STA $1892,x		;
LDA ReappearBooPos1,x	;
PHA				;
AND #$F0			;
STA $1E66,x		; X position on frame 1
PLA				;
ASL #4			;
STA $1E52,x		; Y position on frame 1
LDA ReappearBooPos2,x	;
PHA				;
AND #$F0			;
STA $1E8E,x		; X position on frame 2
PLA				;
ASL #4			;
STA $1E7A,x		; Y position on frame 2
DEX				;
BPL .ReappearingBooLoop;
RTL				;

ClusterGen05:			; original sprite E6, background candle flames

LDA #$07				;
STA $14CB				; what the mushrooms?
LDX #$03				;
.BackgroundFlameLoop		;
LDA #$05				; cluster sprite number = 05
STA $1892,x			;
LDA BackgroundFlameXPos,x	;
STA $1E16,x			;
LDA #$F0				; fixed Y position
STA $1E02,x			;
TXA					;
ASL #2				;
STA $0F4A,x			;
DEX					;
BPL .BackgroundFlameLoop	;
RTL					;

ReappearBooPos1:
db $31,$71,$A1,$43,$93,$C3,$14,$65
db $E5,$36,$A7,$39,$99,$F9,$1A,$7A
db $DA,$4C,$AD,$ED

ReappearBooPos2:
db $01,$51,$91,$D1,$22,$62,$A2,$73
db $E3,$C7,$88,$29,$5A,$AA,$EB,$2C
db $8C,$CC,$FC,$5D

BackgroundFlameXPos:
db $50,$90,$D0,$10

RunOnceSpr00:
RunOnceSpr01:
RunOnceSpr02:
RunOnceSpr03:

LDA $0A				;
CLC					;
ADC #$04			; sprites 4-7 - Koopas
BRA KoopaShellMain	;

RunOnceSpr04:

LDA #$09			; sprite 9 - green bouncing Paratroopa
KoopaShellMain:		;
LDY $1EA2+!LastSpecial	;
BPL .StoreKoopa		;
CMP #$06			;
BCS .StoreKoopa		;
CMP #$05			;
BEQ .ChangeRedKoopa	;
LDA #$07			;
BRA .StoreKoopa		;
.ChangeRedKoopa		;
LDA #$06			;
.StoreKoopa			;
STA $14B0			;

LDA $06				;
AND #$F0			;
STA $14B1			; Y position low byte
LDA $06				;
AND #$01			;
STA $14B2			; Y position high byte

JSL $82A9E4			;
BMI .Return			;
TYX					;

LDA $14B0			; sprite number
STA $9E,x			;

JSL $87F7D2			;

LDA #$09			; status 09 - stunned
STA $14C8,x			;
LDA $02				; loading table index (high byte is always 00)
STA $161A,x			;
LDA $00				; X position low byte
STA $E4,x			;
LDA $01				; X position high byte
STA $14E0,x			;
LDA $14B1			; Y position low byte
STA $D8,x			;
LDA $14B2			; Y position high byte
STA $14D4,x			;

.Return				;
RTL					;

RunOnceSpr05:

LDA $06					;
AND #$F0				;
STA $14B1				; Y position low byte
LDA $06					;
AND #$01				;
STA $14B2				; Y position high byte

LDA #$04				; 5 Eeries in the group
STA $04					;

.Loop
JSL $82A9E4				;
BMI .Return				;
TYX						;

LDA #$39				; sprite number
STA $9E,x				;

JSL $87F7D2				;

LDA #$08				; status 08 - normal
STA $14C8,x				;

LDY $04					; index within the group
LDA $00					; X position low byte
CLC						;
ADC EerieGroupXDispLo,y	;
STA $E4,x				;
LDA $01					; X position high byte
ADC EerieGroupXDispHi,y	;
STA $14E0,x				;
LDA $14B1				; Y position low byte
STA $D8,x				;
LDA $14B2				; Y position high byte
STA $14D4,x				;

LDA EerieGroupYSpeed,y		; Y speed
STA $AA,x				;
LDA EerieGroupState,y		;
STA $C2,x				;

CPY #$04				;
BNE .NoSetIndex			;
LDA $02				; loading table index (high byte is always 00)
STA $161A,x			;
.NoSetIndex				;

JSR SubHorizPos			;
LDA EerieGroupXSpeed,y		;
STA $B6,x				; X speed depending on which side the player is on

DEC $04				;
BPL .Loop				;

.Return				;
RTL					;

EerieGroupXDispLo:
db $E0,$F0,$00,$10,$20

EerieGroupXDispHi:
db $FF,$FF,$00,$00,$00

EerieGroupYSpeed:
db $17,$E9,$17,$E9,$17

EerieGroupState:
db $00,$01,$00,$01,$00

EerieGroupXSpeed:
db $10,$F0

RunOnceSpr06:

LDA $06					;
AND #$F0				;
STA $14B1				; Y position low byte
LDA $06					;
AND #$01				;
STA $14B2				; Y position high byte

LDA #$02				; 3 platforms in the group
STA $04					;

.Loop
JSL $82A9E4				;
BMI .Return				;
TYX						;

LDA #$A3				; sprite number
STA $9E,x				;

JSL $87F7D2				;

LDA #$01				; status 01 - init
STA $14C8,x				;

LDA $00					; X position low byte
STA $E4,x				;
LDA $01					; X position high byte
STA $14E0,x				;
LDA $14B1				; Y position low byte
STA $D8,x				;
LDA $14B2				; Y position high byte
STA $14D4,x				;

LDY $04					; index within the group
LDA PlatformTrioAngleLo,y	;
STA $1602,x				;
LDA PlatformTrioAngleHi,y	;
STA $151C,x				;

CPY #$02					;
BNE .NoSetIndex			;
LDA $02					; loading table index (high byte is always 00)
TYA
STA $161A,x				;
.NoSetIndex				;

DEC $04					;
BPL .Loop					;

.Return					;
RTL						;

PlatformTrioAngleLo:
db $00,$AA,$54

PlatformTrioAngleHi:
db $00,$00,$01

SubHorizPos:

LDY #$00			;
LDA $94			;
SEC				;
SBC $E4,x		;
STA $0F			;
LDA $95			;
SBC $14E0,x		;
BPL $01			;
INY				;
RTS				;

incsrc sprite2/spritedatatables.asm

;incsrc spritecode.asm

;print "Freespace used: ",bytes," bytes."
;print "Next address: $",pc

End:





