lorom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; new RAM values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ExtraBits		= $7FAB10	;12 bytes	extra bits of sprite
!NewCodeFlag		= $7FAB1C	;01 byte	flag indicating whether the sprite being process uses custom code
!ExtraProp1		= $7FAB28	;12 bytes
!ExtraProp2		= $7FAB34	;12 bytes
!NewSpriteNum		= $7FAB9E	;12 bytes	custom sprite number

!InitSpriteTables	= $87F7D2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CustomBit		= $08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Patches to original code
; This following commented-out code is included in this file for 
; reference only.  This stuff is acually applied to the ROM in the
; C++ function, insert_main_routine function (Most correspond to a 
; setup_call_to_asm.)  Note: Not everything done in the C++ code 
; is spelled out here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;org $008000
;
;; sprite init call subroutine
;					org $018172
;					JSL SubInitHack
;					NOP
;
;; sprite code call subroutine					
;					org $0185C3
;					JSL SubCodeHack
;					NOP
;
;; patch goal tape init to get extra bits in $187B
;					org $01C089
;					LDA EXTRA_BITS,x
;					NOP
;					NOP
;					NOP
;					NOP
;					STA $187B,x
;
;; store extra bits separate from $14D4
;					org $02A963
;					JSL SubLoadHack
;					NOP
;
;; clear init bit when changing sprites
;					org $07F785
;					JSL EraserHack
;					NOP
;
;                   org $02A866
;                   JMP SubGenLoad
;
;                   org $02ABA0
;                   JSL SubShootLoad
;                   NOP
; 
;                   org $02AFFE
;                   JSL SubGenExec
;                   NOP
;              
;                   org $02B395
;                   JMP SubShootExec
;                   NOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A quick note about MAIN.OFF:
; There are 11 routines below that get assembled into main.bin.
; The first line of main.off tells sprite tool where each routine
; starts in the binary file.  The second line of main.off lists 
; the location all reloc offsets -- all relative addresses that
; need to be adjusted at insertion time.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In sprites.cpp, there are 11 calls to setup_call_to_asm.  They
; link up the regular SMW code (in order) to the 11 routines below.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $008000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; store extra bits in a seprate ram location
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc
SubLoadHack:
			PHA
			AND #$0D
			STA !ExtraBits,x
			AND #$01
			STA $14D4,x
			LDA $05
			STA !NewSpriteNum,x
			PLA
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; convert regular sprite to custom sprite and call initialization
; routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SubInitHack:

			LDA #$08
			STA $14C8,x

			LDA !ExtraBits,x
			AND #!CustomBit
			BNE .IsCustom
.R			RTL
.IsCustom
			JSL SetSpriteTables
			LDA !NewCodeFlag
			BEQ .R

			PLA	;pull lower 16-bit address
			PLA

			PEA $85C1
			LDA #$01
			JML [$0000]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; call main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;	dcb "AMY"
print "",pc

SubCodeHack:
			STZ $1491
			LDA !ExtraBits,x
			AND #!CustomBit
			BNE .IsCustom
			LDA $9E,x
			RTL
.IsCustom
			LDA !NewSpriteNum,x
			JSR GetMainPtr

			PLA
			PLA

			PEA $85C1
			LDA $14C8,x
			JML [$0000]

GetMainPtr:
			PHB
			PHK
			PLB
			PHP
			REP #$30
			AND #$00FF
			ASL #$04
			TAY

			LDA TableStart+$0B,y
			STA $00
			LDA TableStart+$0C,y
			STA $01

			PLP
			PLB
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clear init bit when changing sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

EraserHack:
			STZ $15AC,x
			LDA #$01
			STA $15A0,x
			DEC A
			STA !ExtraBits,x
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clear init bit when changing sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

EraserHack2:
			LDA #$FF
			STA $161A,x
			INC A
			STA !ExtraBits,x
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; store extra bits - vertical level
; ROM 0x12B4B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SubLoadHack2:
			PHA
			AND #$0D
			STA !ExtraBits,x
			AND #$01
			STA $14E0,x
			LDA $05
			STA !NewSpriteNum,x
			PLA
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hijack main sprite loader to handle custom gens and shooters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SubGenLoad:
			PHA
			LDA #$00
			STA !NewCodeFlag
			PLA
			CMP #$C0
			BCC .NotGen
			CMP #$E0
			BCS .NotGen

;TestExtraBit:
			DEY
			LDA [$CE],y
			AND #$08
			BEQ .NotCustom

;GetType:
			LDA [$CE],y
			AND #$0C
			ASL #$04
			STA !NewCodeFlag
			INY

			LDA $05
			CMP #$D0
			BCS .IsCustomGen

.IsCustomShooter
			JML $82A8D8

.IsCustomGen
			LDA !NewCodeFlag
			STA $18B9
			LDA $05
			SEC
			SBC #$CF
			ORA $18B9
			JML $82A8B8

.NotCustom
			INY
			LDA $05
.NotGen			CMP #$E7
			BCC .Loc2
			JML $82A86A
.Loc2			JML $82A88C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hijack shooter table setter to insert extra bits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SubShootLoad:
			LDA !NewCodeFlag
			BNE .IsCustom
			LDA $04
			SEC
			SBC #$C8
			RTL
.IsCustom
			STA $1783,x
			LDA $04
			SEC
			SBC #$BF
			ORA $1783,x
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;      	dcb "AMY!"
print "",pc

SubShootExec:
			LDY $1783,x
			BMI .IsCustom
			LDY $17AB,x
			BEQ .Loc2
			JML $82B39A
.Loc2			JML $82B3A4

.IsCustom		LDY $17AB,x
			BEQ .CallSprite
			PHA
			LDA $13
			LSR A
			BCC .NoDecTimer
			DEC $17AB,x
.NoDecTimer		PLA
.CallSprite		AND #$3F
			CLC
			ADC #$BF

			JSR GetMainPtr

			LDA #$82
			PHA
			PEA $B3A6
			JML [$0000]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SubGenExec:
			LDA $18B9
			BMI .IsCustom
			PLA
			PLA
			PLA
			LDA $18B9
			BEQ .Loc2
			JML $82B003
.Loc2			JML $82B02A

.IsCustom		AND #$3F
			CLC
			ADC #$CF

			JSR GetMainPtr

			PLA
			PLA
			PEA $B029
			JML [$0000]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set sprite tables from main table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

SetSpriteTables:
			PHY
			PHB
			PHK
			PLB
			PHP

			LDA !NewSpriteNum,x
			REP #$30
			AND #$00FF
			ASL #$04
			TAY
			SEP #$20

			LDA TableStart,y
			STA !NewCodeFlag
			LDA TableStart+$01,y
			STA $9E,x
			LDA TableStart+$02,y
			STA $1656,x
			LDA TableStart+$03,y
			STA $1662,x
			LDA TableStart+$04,y
			STA $166E,x
			AND #$0F
			STA $15F6,x
			LDA TableStart+$05,y
			STA $167A,x
			LDA TableStart+$06,y
			STA $1686,x
			LDA TableStart+$07,y
			STA $190F,x

			LDA !NewCodeFlag
			BNE .IsCustom
			PLP
			PLB
			PLY
			LDA #$00
			STA !ExtraBits,x
			RTL

.IsCustom
			REP #$20
			LDA TableStart+$08,y
			STA $00
			SEP #$20
			LDA TableStart+$0A,y
			STA $02

			LDA TableStart+$0E,y
			STA !ExtraProp1,x
			LDA TableStart+$0F,y
			STA !ExtraProp2,x

			PLP
			PLB
			PLY
			RTL

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call Main after handling status > 9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	;; jump to this location from HandleSprite	
;	dcb "AMY!"
print "",pc

SubHandleStatus:
			LDA $14C8,x
			CMP #$02
			BCC .CallDefault
.NoEraseOrInit
			CMP #$08
			BNE .NoMainRoutine
			JML $8185C3
.NoMainRoutine
			PHA
			LDA !ExtraBits,x
			AND #!CustomBit
			BNE .HandleCustomSprite
			PLA
.CallDefault		JML $818133		;call regular status handler

.HandleCustomSprite
			LDA !ExtraProp2,x
			BMI .CallMain
			PHA
			LDA $02,s
			JSL $81D43E		;handle sprite based on status
			PLA
			ASL A
			BMI .CallMain
			PLA
			CMP #$09
			BCS .CallMain2
			CMP #$03
			BEQ .CallMain2
			JML $8185C2
.CallMain2		PHA
.CallMain
			LDA !NewSpriteNum,x
			JSR GetMainPtr
			PLA

			LDY #$81
			PHY
			PEA $85C1
			JML [$0000]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keep extra bits around when setting the sprite tables during
; level loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	dcb "AMY!"
print "",pc

InitKeepExtraBits:
			LDA !ExtraBits,x
			PHA
			JSL !InitSpriteTables
			PLA
			STA !ExtraBits,x
			RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test a custom sprite's an ACTUAL bit so that the sprite ALWAYS won't be
; transformed to a silver coin.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "",pc
TestSilverCoinBit:	PHA
			LDA !ExtraBits,x
			AND #!CustomBit
			BNE .Custom
			PLX
			LDA $07F659,x	;SMW sprite's $190F,x table
			RTL

.Custom			PLA
			LDA !NewSpriteNum,x
			PHP
			REP #$30
			AND #$00FF
			ASL #$04
			TAX
			LDA TableStart+$07,x
			PLP
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Custom sprites' table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TableStart: