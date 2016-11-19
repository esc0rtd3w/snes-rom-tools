;===============================================================================
; Levelnum.ips, by BMF
;
; Patch this to your ROM if LevelMusic isn't having any effect.
;===============================================================================
!false = 0
!true = 1

; Check for SA-1
if read1($00FFD5) == $23
!SA1 = !true
sa1rom
else
!SA1 = !false
endif

if !SA1
; SA-1 base addresses
!Base1 = $3000
!Base2 = $6000
else
; Non SA-1 base addresses
!Base1 = $0000
!Base2 = $0000
endif

incsrc config.asm

; Beta version of LevelMusic uses JSL for Levelnum.
; Restore the CLC if necessary.
if read1($05D8B9) == $22
!FixJSL = !true
else
!FixJSL = !false
endif

org $05D8B9
	JSR Levelnummain
if !FixJSL
	CLC
endif

org $05DC46
Levelnummain:
	LDA $0E
	STA !Levelnum
	ASL A
	RTS
