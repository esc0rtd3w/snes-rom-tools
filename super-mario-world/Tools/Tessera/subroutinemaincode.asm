
Table1:		db $0C,$1C
Table2:		db $01,$02
Table3:		db $40,$B0
Table4:		db $30,$C0,$A0,$C0,$A0,$F0,$60,$90,$30,$C0,$A0,$80,$A0,$40,$60,$B0
Table5:		db $01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$00,$01,$FF
Table6:		db $01,$FF


GetDrawInfoMain:
PHB
PHK
PLB
JSL GetDrawInfoMainSub
PLB
RTL

GetDrawInfoMainSub:

STZ $186C,x
STZ $15A0,x
LDA $E4,x
CMP $1A
LDA $14E0,x
SBC $1B
BEQ OnscreenX
INC $15A0,x
OnscreenX:
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC $1A
CLC
ADC.w #$0040
CMP #$0180
SEP #$20
ROL A
AND #$01
STA $15C4,x
BNE Invalid

LDY #$00
LDA $1662,x
AND #$20
BEQ OnscreenLoop
INY
OnscreenLoop:
LDA $D8,x
CLC
ADC Table1,y
PHP
CMP $1C
ROL $00
PLP
LDA $14D4,x
ADC #$00
LSR $00
SBC $1D
BEQ OnscreenY
LDA $186C,x
ORA Table2,y
STA $186C,x
OnscreenY:
DEY
BPL OnscreenLoop
LDY $15EA,x
LDA $E4,x
SEC
SBC $1A
STA $00
LDA $D8,x
SEC
SBC $1C
STA $01
RTL

Invalid:

REP #$10
PLY
PLA
PLB
PLY
PLA
PLY
PHA
PHY
SEP #$10
RTL

SubOffscreenX0:
LDA #$00
BRA SubOffscreen
SubOffscreenX1:
LDA #$02
BRA SubOffscreen
SubOffscreenX2:
LDA #$04
BRA SubOffscreen
SubOffscreenX3:
LDA #$06
;BRA SubOffscreen
;SubOffscreenX4:
;LDA #$08
;BRA SubOffscreen
;SubOffscreenX5:
;LDA #$0A
;BRA SubOffscreen
;SubOffscreenX6:
;LDA #$0C
;BRA SubOffscreen
;SubOffscreenX7:
;LDA #$0E
SubOffscreen:
PHB
PHK
PLB
JSL SubOffscreenMainRt
PLB
RTL

SubOffscreenMainRt:

STA $03
JSL SubIsOffscreen
BEQ Return2
LDA $5B
AND #$01
BNE VerticalLevel
LDA $D8,x
CLC
ADC #$50
LDA $14D4,x
ADC #$00
CMP #$02
BPL EraseSprite
LDA $167A,x
AND #$04
BNE Return2
LDA $13
AND #$01
ORA $03
STA $01
TAY
LDA $1A
CLC
ADC Table4,y
ROL $00
CMP $E4,x
PHP
LDA $1B
LSR $00
ADC Table5,y
PLP
SBC $14E0,x
STA $00
LSR $01
BCC Label20
EOR #$80
STA $00
Label20:
LDA $00
BPL Return2
EraseSprite:
LDA $14C8,x
CMP #$08
BCC KillSprite
LDY $161A,x
CPY #$FF
BEQ KillSprite
LDA #$00
STA $1938,y
KillSprite:
STZ $14C8,x
Return2:
RTL

VerticalLevel:
LDA $167A,x
AND #$04
BNE Return2
LDA $13
LSR
BCS Return2
AND #$01
STA $01
TAY
LDA $1C
CLC
ADC Table3,y
ROL $00
CMP $D8,x
PHP
LDA $1D
LSR $00
ADC Table6,y
PLP
SBC $14D4,x
STA $00
LDY $01
BEQ Label22
EOR #$80
STA $00
Label22:
LDA $00
BPL Return2
BMI EraseSprite
SubIsOffscreen:
LDA $15A0,x
ORA $186C,x
RTL

SubHorizPosMain:

LDY #$00
LDA $94
SEC
SBC $E4,x
STA $0F
LDA $95
SBC $14E0,x
BPL $01
INY
RTL

SubVertPosMain:

LDY #$00
LDA $96
SEC
SBC $D8,x
STA $0E
LDA $97
SBC $14D4,x
BPL $01
INY
RTL

SubVertPos2Main:

REP #$20
LDA $96
CLC
ADC.w #$0010
STA $0C
SEP #$20

LDY #$00
LDA $0C
SEC
SBC $D8,x
STA $0E
LDA $0D
SBC $14D4,x
BPL $01
INY
RTL

SubSetMap16Main:

PHP
REP #$30
PHY
PHX
TAX
LDA $03
PHA
JSL .Sub8034
PLA
STA $03
PLX
PLY
PLP
RTL

.Return18
PLX
PLB
PLP
RTL

.Sub8034
PHP
SEP #$20
PHB
LDA #$00
PHA
PLB
REP #$30
PHX
LDA $9A
STA $0C
LDA $98
STA $0E
LDA.w #$0000
SEP #$20
LDA $5B
STA $09
LDA $1933
BEQ .NoShift
LSR $09
.NoShift
LDY $0E
LDA $09
AND #$01
BEQ .Horiz
LDA $9B
STA $00
LDA $99
STA $9B
LDA $00  
STA $99
LDY $0C
.Horiz
CPY #$0200
BCS .Return18
LDA $1933
ASL
TAX
LDA $BEA8,x
STA $65
LDA $BEA9,x
STA $66
STZ $67
LDA $1925
ASL
TAY
LDA ($65),y
STA $04
INY
LDA ($65),y
STA $05
STZ $06
LDA $9B
STA $07
ASL
CLC
ADC $07
TAY
LDA ($04),y
STA $6B
STA $6E
INY
LDA ($04),y
STA $6C
STA $6F
LDA #$7E
STA $6D
INC
STA $70
LDA $09
AND #$01
BEQ .NoAnd
LDA $99
LSR
LDA $9B
AND #$01
BRA .Label52
.NoAnd
LDA $9B
LSR
LDA $99
.Label52
ROL
ASL #2
ORA #$20
STA $04
CPX.w #$0000
BEQ .NoAdd
CLC
ADC #$10 
STA $04
.NoAdd
LDA $98
AND #$F0
CLC
ASL
ROL
STA $05
ROL
AND #$03
ORA $04
STA $06
LDA $9A
AND #$F0
LSR #3
STA $04
LDA $05
AND #$C0
ORA $04
STA $07
REP #$20
LDA $09
AND.w #$0001
BNE .Label51
LDA $1A
SEC
SBC.w #$0080
TAX
LDY $1C
LDA $1933
BEQ .Label50
LDX $1E
LDA $20
SEC
SBC.w #$0080
TAY
BRA .Label50
.Label51
LDX $1A
LDA $1C
SEC
SBC.w #$0080
TAY
LDA $1933
BEQ .Label50
LDA $1E
SEC
SBC.w #$0080
TAX  
LDY $20
.Label50
STX $08
STY $0A
LDA $98
AND #$01F0
STA $04
LDA $9A
LSR #4
AND.w #$000F
ORA $04
TAY
PLA
SEP #$20
STA [$6B],y
XBA
STA [$6E],y
XBA
REP #$20
ASL A
TAY
PHK
PEA.w .Map16Return-$01
PEA $804C
JML $00C0FB|$800000
.Map16Return
PLB
PLP
RTL

RandomNumGenMain:

LDA !RAM_RandomSeed
STA $4202
LDA $98
ADC $7B
EOR ($04,s),y
STA $4203
ORA ($01,x)
NOP
REP #$20
LDA $4216
CLC
ADC $13
STA $4204
SEP #$20
LDA $00
STA $4206
LDA ($01,s),y
LDA ($01,s),y
NOP
LDA $4216
STA !RAM_RandomSeed
RTL

HexToDec2Main:

LDY #$00
.Loop
CMP #$0A
BCC .Return
SBC #$0A
INY
BRA .Loop
.Return
RTL

HexToDec3Main:

LDX #$00
LDY #$00
.Loop1
CMP #$64
BCC .Loop2
SBC #$64
INX
BRA .Loop1
.Loop2
CMP #$0A
BCC .Return
SBC #$0A
INY
BRA .Loop2
.Return
RTL

GenericSprGFXMain:

; here, we do NOT change the data bank, since the graphics data is in the same bank as the sprite code
REP #$20		;
PLA			; pull back the program bank value of the next byte after the JSL
INC			;
STA $08		; and save it
PLY			;
PLA			; set up the return address
PHY			;
PHA			;
SEP #$20		;

JSR GFXRtPart2	;
RTL			; if the code reaches here, then the graphics routine won't be run

GFXRtPart2:		;

JSL !GetDrawInfo	;

PLA			; if GetDrawInfo doesn't terminate the code,
PLA			; pull the extra two bytes off the stack

LDA $1602,x	; $1602,x is assumed to contain the sprite's current animation frame
STA $4202		; multiplicand A: current animation frame
LDA #$0B		; multiplicand B: 0B, or 11 in decimal - each table contains 11 bytes
STA $4203		;
REP #$20		;
LDA $08		;
STA $02		;
TYX			; OAM index -> X
LDY $4216		; load the value from the frame table (I could put this in 16-bit, but this allows for 23 frames anyway)
LDA ($02),y		; bytes 1 and 2 -> $06
STA $06		; $06 = pointer to horizontal displacement table
INY			;
INY			;
LDA ($02),y		; bytes 3 and 4 -> $08
STA $08		; $08 = pointer to vertical displacement table
INY			;
INY			;
LDA ($02),y		; bytes 5 and 6 -> $0A
STA $0A		; $0A = pointer to tilemap table
INY			;
INY			;
LDA ($02),y		; bytes 7 and 8 -> $0C
STA $0C		; $0C = pointer to tile properties table
INY			;
INY			;
LDA ($02),y		; bytes 9 and 10 -> $0E
STA $0E		; $0E = pointer to tile size table
INY			;
INY			;
SEP #$20		;
LDA ($02),y		; byte 11 -> $05
STA $05		; $05 = number of tiles to draw
TAY			; starting index into Y

.GFXLoop

LDA $00		; base X position
CLC			;
ADC ($06),y	; plus horizontal displacement
STA $0300,x	; into first OAM slot

LDA $01		; base Y position
CLC			;
ADC ($08),y	; plus vertical displacement
STA $0301,x	; into second OAM slot

LDA ($0A),y		; tile number
STA $0302,x	; into third OAM slot

LDA ($0C),y		; tile properties (YX--CCCT)
ORA $64		; plus sprite priority settings
STA $0303,x	; into fourth OAM slot

PHX			; preserve OAM index
TXA			;
LSR #2		; OAM index / 4
TAX			;
LDA ($0E),y		; tile size
STA $0460,x	; into tile size OAM slot
PLX			;

INX #4		; increment the OAM index by 4
DEY			; decrement the pointer index
BPL .GFXLoop	; if positive, there are more tiles to draw

LDX $15E9		; sprite index back into X
LDA $05		; $05 holds the number of tiles to draw
LDY #$FF		; we already set the tile size, so use FF here
JSL $81B7B3		; finish the write to OAM

RTL			;

FindFreeEMain:

LDY #$07
.Loop
LDA $170B,y
BEQ .FoundSlot
DEY
BPL .Loop
.FoundSlot
RTL

FindFreeCMain:

LDY #$13
.Loop
LDA $1892,y
BEQ .FoundSlot
DEY
BPL .Loop
.FoundSlot
RTL

BitCheck1:

PHX
PHA
LDY #$00
LDX #$07
.Loop
LSR
BCC $01
INY
DEX
BPL .Loop
PLA
PLX
RTL

BitCheck2:

PHA
LDY #$07
STY $00
.Loop
ASL
BCS .End
DEC $00
BPL .Loop
.End
PLA
LDY $00
RTL

BitCheck3:

PHX
PHA
LDY #$00
LDX #$07
.Loop
LSR
BCS $01
INY
DEX
BPL .Loop
PLA
PLX
RTL

BitCheck4:

PHA
LDY #$07
STZ $00
.Loop
LSR
BCS .End
INC $00
DEY
BPL .Loop
STY $00
.End
PLA
LDY $00
RTL



