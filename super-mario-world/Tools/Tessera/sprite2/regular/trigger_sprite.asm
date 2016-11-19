;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Trigger Sprite, by imamelia
;;
;; This sprite will perform a specified action when all the other sprites on the screen
;; (not counting platforms and the like) are gone.
;;
;; Extra bytes: 2
;;
;; Extra byte 1:
;; This determines what the sprite does when it activates.
;;	00 - end the level (activate the normal exit)
;;	01 - end the level (activate the secret exit) *does not work in vertical levels*
;;	02 - end the level (fade to the overworld)
;;	03 - spawn a normal sprite
;;	04 - spawn a custom sprite
;;	05 - spawn a single Map16 tile
;;	06 - spawn 4 Map16 tiles
;;	07 - enable horizontal scroll
;;	08 - switch the On/Off status
;;	09 - activate the blue P-switch
;;	0A - activate the gray P-switch
;;	0B - spawn a special command sprite (for things like creating bridges)
;;	0C-FF - unused (use them for custom subroutines)
;;
;; Extra byte 2:
;; This determines the specifics of a particular behavior.  For the default options:
;;	Option 00: Bits 0-6 determine the music to play, and bit 7 determines whether or not the player should walk after the goal (1 = yes).
;;	Option 01: Bits 0-6 determine the music to play, and bit 7 determines whether or not the player should walk after the goal (1 = yes).
;;	Option 02: Bit 0 determines whether to activate the normal exit or the secret one.
;;	Option 03: Index to normal sprite tables.
;;	Option 04: Index to custom sprite tables.
;;	Option 05: Index to Map16 tile tables.
;;	Option 06: Index to Map16 tile tables (4 bytes per index).
;;	Option 07: Unused.
;;	Option 08: Unused.
;;	Option 09: P-switch timer (the original was B0).
;;	Option 0A: P-switch timer (the original was B0).
;;	Option 0B: Determines what the command sprite does.
;;	Options 0C-FF: Whatever you choose to use it for.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sprite number of the special command sprite
!CmdSprNum = $01B0

; how many frames will pass between the last sprite going away and the trigger sprite activating
!DelayTime = $18

; normal sprite numbers to spawn with option 3
SpawnedNSprNum:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; normal sprite status for option 3
SpawnedNSprStatus:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; normal sprite X speed for option 3
SpawnedNSprXSpd:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; normal sprite Y speed for option 3
SpawnedNSprYSpd:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; custom sprite numbers to spawn with option 4 (low byte)
SpawnedCSprNumLo:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; custom sprite numbers to spawn with option 4 (low byte)
SpawnedCSprNumHi:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; custom sprite status for option 4
SpawnedCSprStatus:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; value of the first extra byte of the custom sprites spawned with option 4
SpawnedEB1:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; value of the second extra byte of the custom sprites spawned with option 4
SpawnedEB2:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; value of the third extra byte of the custom sprites spawned with option 4
SpawnedEB3:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; value of the fourth extra byte of the custom sprites spawned with option 4
SpawnedEB4:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; custom sprite X speed for option 4
SpawnedCSprXSpd:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; custom sprite Y speed for option 4
SpawnedCSprYSpd:
db $00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00	; values 10-17

; Map16 tile numbers to spawn with option 5
Map16Num:
dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	; values 00-07
dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	; values 08-0F
;dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	; values 10-17

; Map16 tile numbers to spawn with option 6
Map16Num2:
dw $0133,$0134,$0135,$0136 : dw $0000,$0000,$0000,$0000	; values 00 and 01
dw $0000,$0000,$0000,$0000 : dw $0000,$0000,$0000,$0000	; values 02 and 03
dw $0000,$0000,$0000,$0000 : dw $0000,$0000,$0000,$0000	; values 04 and 05
dw $0000,$0000,$0000,$0000 : dw $0000,$0000,$0000,$0000	; values 06 and 07
;dw $0000,$0000,$0000,$0000 : dw $0000,$0000,$0000,$0000	; values 08 and 09

BlockXOffsets:
dw $00,$10,$00,$10

BlockYOffsets:
dw $00,$00,$10,$10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR TriggerSpriteMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TriggerSpriteMain:

LDA $14C8,x
CMP #$08
BNE .Return
LDA $9D
BNE .Return

JSL !SubOffscreenX0

LDA $1540,x
BEQ .CheckSprites
DEC
BEQ .RunTriggerCode
RTS

.CheckSprites
JSR CheckSpritesGone
BCC .Return
LDA #!DelayTime
STA $1540,x

.Return
RTS

.RunTriggerCode

LDA $7FAB40,x
REP #$30
AND.w #$00FF
ASL
TAY
LDA TriggerRoutinePointers,y
STA $00
SEP #$30
STZ $14C8,x
JMP ($0000)

TriggerRoutinePointers:

dw S00_EndLevelN
dw S01_EndLevelS
dw S02_EndLevelF
dw S03_SpawnNSpr
dw S04_SpawnCSpr
dw S05_Spawn1Tile
dw S06_Spawn4Tiles
dw S07_EnableHorizScroll
dw S08_SwitchOnOff
dw S09_ActivateBSwitch
dw S0A_ActivateGSwitch
dw S0B_SpawnCommandSpr
;dw S0C_				; use values 0C-FF for your own custom subroutines
;dw S0D_				; you can expand this table if necessary
;dw S0E_
;dw S0F_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutines 00 and 01 - end the level (normal or secret exit)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S00_EndLevelN:
LDA #$00
BRA Shared_00_01
S01_EndLevelS:
LDA #$01
Shared_00_01:
STA $141C
STA $13CE
LDA #$FF
STA $1493
STA $0DDA
LDA $7FAB4C,x
BMI .Walk
DEC $13C6
.Walk
AND #$7F
STA $1DFB
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 02 - end the level by simply fading to the overworld
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S02_EndLevelF:

LDA $7FAB4C,x
AND #$01
INC
STA $0DD5
STA $13CE
INC $1DE9
LDA #$0B
STA $0100
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutines 03 and 04 - spawn a sprite (normal or custom)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S03_SpawnNSpr:

JSL $82A9E4
BMI Return_03_04

JSR Shared_03_04

LDA $7FAB4C,x
PHX
TYX
TAY
LDA SpawnedNSprNum,y
STA $9E,x
LDA SpawnedNSprStatus,y
STA $14C8,x
PHY
JSL $87F7D2
PLY
LDA SpawnedNSprXSpd,y
STA $B6,x
LDA SpawnedNSprYSpd,y
STA $AA,x
PLX

Return_03_04:
RTS


S04_SpawnCSpr:

JSL $82A9E4
BMI Return_03_04

JSR Shared_03_04

LDA $7FAB4C,x
PHX
TYX
TAY
LDA SpawnedCSprNumLo,y 
STA $7FAB9E,x
LDA SpawnedCSprNumHi,y 
ORA #$80
STA $7FAB10,x
LDA SpawnedCSprStatus,y
STA $14C8,x
PHY
JSL $81830B
PLY
LDA SpawnedEB1,y
STA $7FAB40,x
LDA SpawnedEB2,y
STA $7FAB4C,x
LDA SpawnedEB3,y
STA $7FAB58,x
LDA SpawnedEB4,y
STA $7FAB64,x
LDA SpawnedCSprXSpd,y
STA $B6,x
LDA SpawnedCSprYSpd,y
STA $AA,x
PLX
RTS


Shared_03_04:

JSR SubSmoke

LDA $E4,x
STA $00E4,y
LDA $D8,x
STA $00D8,y
LDA $14E0,x
STA $14E0,y
LDA $14D4,x
STA $14D4,y

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 05 - spawn a single Map16 tile
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S05_Spawn1Tile:

JSR SetBlockPosition

LDA #$15
STA $1DFC

LDA $7FAB4C,x
REP #$30
AND.w #$00FF
ASL
TAY
LDA Map16Num,y
STA $03
SEP #$30

JSL !SubSetMap16
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 06 - spawn four Map16 tiles
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S06_Spawn4Tiles:

JSR SetBlockPosition

LDA #$15
STA $1DFC

LDA $7FAB4C,x
REP #$30
AND.w #$00FF
ASL #3
TAY
LDA Map16Num2,y
STA $03

JSL !SubSetMap16

LDA $9A
CLC
ADC.w #$0010
STA $9A

INY #2
LDA Map16Num2,y
STA $03

JSL !SubSetMap16

LDA $98
CLC
ADC.w #$0010
STA $98

INY #4
LDA Map16Num2,y
STA $03

JSL !SubSetMap16

LDA $9A
SEC
SBC.w #$0010
STA $9A

DEY #2
LDA Map16Num2,y
STA $03

JSL !SubSetMap16

SEP #$30
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 07 - enable horizontal scroll
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S07_EnableHorizScroll:

INC $1411
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 08 - switch the On/Off switch status
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S08_SwitchOnOff:

LDA $14AF
EOR #$01
STA $14AF
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutines 09 and 0A - activate the blue and gray P-switches
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S09_ActivateBSwitch:

LDA $7FAB4C,x
STA $14AD
BRA Shared_09_0A

S0A_ActivateGSwitch:

LDA $7FAB4C,x
STA $14AE

Shared_09_0A:
LDA #$0E
STA $1DFB
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutine 0B - spawn a special command sprite
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

S0B_SpawnCommandSpr:

JSL $82A9E4
BMI Return0B

JSR Shared_03_04

LDA $7FAB4C,x
STA $08
PHX
TYX
LDA.b #!CmdSprNum
STA $7FAB9E,x
LDA.b #!CmdSprNum>>8
ORA #$80
STA $7FAB10,x
LDA #$01
STA $14C8,x
JSL $81830B
LDA $08
STA $C2,x
PLX

Return0B:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; default subroutines 0C-FF - unused
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;S0C_

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; supporting subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; check if all sprites on the screen are gone
;------------------------------------------------

CheckSpritesGone:

LDY #$0B
.Loop
CPY $15E9
BEQ .NoCheck
LDA $190F,y
AND #$40
BNE .NoCheck
LDA $14C8,y
BNE .StillAlive
.NoCheck
DEY
BPL .Loop
SEC
RTS
.StillAlive
CLC
RTS

;------------------------------------------------
; create a puff of smoke
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
; set the position for a generated Map16 tile to the sprite position
;------------------------------------------------

SetBlockPosition:

LDA $D8,x
STA $98
LDA $14D4,x
STA $99
LDA $E4,x
STA $9A
LDA $14E0,x
STA $9B
RTS


dl Init,Main
