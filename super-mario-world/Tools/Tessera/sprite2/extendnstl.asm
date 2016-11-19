header
lorom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Extended No Sprite Tile Limits, by imamelia
;;
;; This is similar to edit1754's famous No Sprite Tile Limits patch, except that
;; this one is for sprites using the other half of OAM.  That is, the patch makes it
;; so that sprite tiles using OAM addresses $02xx (extended sprites, cluster sprites,
;; minor extended sprites, block bounce sprites, smoke images, spinning coins
;; from blocks, and Yoshi's tongue), use dynamic OAM indexes instead of hardcoded
;; ones,  just like normal sprites do when the normal No Sprite Tile Limits patch is
;; used.  This drastically reduces the risk of any sprite graphics glitching up because
;; of an OAM conflict.  (It also means that Sumo Brothers work properly with the original
;; NSTL patch and sprite memory 10; they didn't before.)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Freespace = $16E1EB		; location of the main code
!FindFree = $04A1FC		; location of the jump to the OAM slot-finding routine (in case you want to use it for your own sprites)
!Default = $00			; the slot to overwrite when all are full
!ItemBoxOAM = $EC		; the slot to use for the item box item
!RAM_ExtOAMIndex = $17BB	; the free RAM address to use for the OAM index

!foundExtSlot = FindExtOAMSlot_foundSlot

macro speedup(offset)
		LDA.w $01FD+<offset>	; get Y position of PREVIOUS tile in OAM
		CMP #$F0		; F0 means it's free (Y=F0 means it can't be seen)
		BEQ ?notFound		; \  if last isn't free
		LDA.b #<offset>		;  | (and this is), then
		JMP !foundExtSlot		; /  this is the index
?notFound:
endmacro

macro bulkSpeedup(arg)
		%speedup(<arg>+12)
		%speedup(<arg>+8)
		%speedup(<arg>+4)
		%speedup(<arg>)
endmacro


org !FindFree
JML GetExtOAMIndex


org $01F466		; Yoshi's tongue
JML YoshiTongueOAM	;

org $02904D		; bounce blocks
JML BounceBlockOAM	;
NOP				;

org $02922D		;
LDY !RAM_ExtOAMIndex	;

org $028B6C		; minor extended sprites
JML MinorExtOAM		;
NOP				;

org $028C6E		;
LDY !RAM_ExtOAMIndex	;

org $028CFF		;
LDY !RAM_ExtOAMIndex	;

org $028D8B		;
LDY !RAM_ExtOAMIndex	;

org $028E20		;
LDY !RAM_ExtOAMIndex	;

org $028E94		;
LDY !RAM_ExtOAMIndex	;

org $028EE1		;
LDY !RAM_ExtOAMIndex	;

org $028F4D		;
LDY !RAM_ExtOAMIndex	;

org $028FDD		;
LDY !RAM_ExtOAMIndex	;

org $0299D7		; spinning coins
JML SpinningCoinOAM	;
NOP				;

org $029A3D		;
LDY !RAM_ExtOAMIndex	;

org $0296C3		; smoke images
JML SmokeImageOAM	;

org $02974A		;
LDY !RAM_ExtOAMIndex	;

org $02996C		;
LDY !RAM_ExtOAMIndex	;

org $02ADBD		; score sprites
JML ScoreSpriteOAM	;

org $02AE9B		;
LDY !RAM_ExtOAMIndex	;

org $00907A		; item box item
db !ItemBoxOAM		;

org $029B16		; extended sprites
JML ExtendedSprOAM	;
NOP				;

org $029B51		;
LDY !RAM_ExtOAMIndex	;

org $029C41		;
LDY !RAM_ExtOAMIndex	;

org $029C8B		;
LDY !RAM_ExtOAMIndex	;

org $029D10		;
LDY !RAM_ExtOAMIndex	;

org $029DDF		;
LDY !RAM_ExtOAMIndex	;

org $029E5F		;
LDY !RAM_ExtOAMIndex	;

org $029E9D		;
LDY !RAM_ExtOAMIndex	;

org $029F46		;
LDY !RAM_ExtOAMIndex	;

org $029F76		;
LDY !RAM_ExtOAMIndex	;

org $02A180		;
LDY !RAM_ExtOAMIndex	;

org $02A1A4		;
LDY !RAM_ExtOAMIndex	;

org $02A235		;
LDY !RAM_ExtOAMIndex	;

org $02A287		;
LDY !RAM_ExtOAMIndex	;

org $02A31A		;
LDY !RAM_ExtOAMIndex	;

org $02A362		;
LDY !RAM_ExtOAMIndex	;

org $02F815		; cluster sprites
JML ClusterSpriteOAM	;
NOP				;

org $02FCCD		;
LDA !RAM_ExtOAMIndex	;

org $02FCD9		;
LDY !RAM_ExtOAMIndex	;

org $02FD4A		;
LDY !RAM_ExtOAMIndex	;

org $02FD98		;
LDY !RAM_ExtOAMIndex	;

org $02FA2B		;
LDY !RAM_ExtOAMIndex	;

org $02FE48		;
LDY !RAM_ExtOAMIndex	;

org $02F92C		;
LDA !RAM_ExtOAMIndex	;

org $02F940		;
JML SumoBroFlameGFX	; patch Sumo Brother flame GFX routine

org $02FCD6		;
dw $0420			; use the first set of tiles

org $02FCDF		;
dw $0201			;

org $02FD54		;
dw $0200			;

org $02FD5D		;
dw $0201			;

org $02FD74		;
dw $0202			;

org $02FD86		;
dw $0203			;

org $02FD8F		;
dw $0420			;

org $02FDAF		;
dw $0202			;

org $02FDB4		;
dw $0203			;

org $02FA35		;
dw $0200			;

org $02FA3E		;
dw $0201			;

org $02FA4C		;
dw $0202			;

org $02FA52		;
dw $0203			;

org $02FA5C		;
dw $0420			;

org $02FA60		;
dw $0200			;

org !Freespace

db "STAR"
dw EndCode-StartCode-$01
dw EndCode-StartCode-$01^$FFFF

StartCode:

GetExtOAMIndex:

JSL FindExtOAMSlot		;
STA !RAM_ExtOAMIndex	;
RTL					;

FindExtOAMSlot:

%bulkSpeedup($F0)		;
%bulkSpeedup($E0)		;
%bulkSpeedup($D0)	;
%bulkSpeedup($C0)		;
%bulkSpeedup($B0)		;
%bulkSpeedup($A0)		;
%bulkSpeedup($90)		;
%bulkSpeedup($80)		;
%bulkSpeedup($70)		;
%bulkSpeedup($60)		;
%bulkSpeedup($50)		;
%bulkSpeedup($40)		;
LDA #$3C			;
.foundSlot			;
TAY					;
RTL					;


YoshiTongueOAM:
STA $06
JSL GetExtOAMIndex
LDY !RAM_ExtOAMIndex
JML $01F46A

BounceBlockOAM:
LDA $1699,x
BEQ .Return
PHA
JSL GetExtOAMIndex
PLA
JML $029052
.Return
JML $02904C

MinorExtOAM:
BEQ .Return
STX $1698
PHA
JSL GetExtOAMIndex
PLA
JML $028B71
.Return
JML $028B74

SpinningCoinOAM:
LDA $17D0,x
BEQ .Return
PHA
JSL GetExtOAMIndex
PLA
JML $0299DC
.Return
JML $0299DF

SmokeImageOAM:
BEQ .Return
AND #$7F
PHA
JSL GetExtOAMIndex
PLA
JML $0296C7
.Return
JML $0296D7

ScoreSpriteOAM:
LDA $16E1,x
BEQ .Return
PHA
JSL GetExtOAMIndex
PLA
JML $02ADC2
.Return
JML $02ADC5

ExtendedSprOAM:
LDA $170B,x
BEQ .Return
PHA
JSL GetExtOAMIndex
PLA
JML $029B1B
.Return
JML $029B15

ClusterSpriteOAM:
LDA $1892,x
BEQ .Return
PHA
JSL GetExtOAMIndex
PLA
JML $02F81A
.Return
JML $02F81D

SumoBroFlameGFX:

LDA $1E16,x
SEC
SBC $1A
STA $00
LDA $1E3E,x
SBC $1B
BNE .End
LDA $1E02,x
SEC
SBC $1C
STA $01
LDA $1E2A,x
SBC $1D
BNE .End
JSL GetExtOAMIndex
LDY !RAM_ExtOAMIndex
PHX
LDX #$01
.Loop
PHX
LDA $00
STA $0200,y
TXA
ORA $185E
TAX
LDA $02F8FC,x
BMI .Skip
CLC
ADC $01
STA $0201,y
STA $7FB000
LDA $02F904,x
STA $0202,y
LDA $14
AND #$04
ASL #4
ORA $64
ORA #$05
STA $0203,y 
PHY
TYA
LSR #2
TAY
LDA #$02
STA $0420,y
PLY
.Skip
PLX
INY #4
DEX
BPL .Loop
PLX
.End
JML $02F93B


EndCode:
