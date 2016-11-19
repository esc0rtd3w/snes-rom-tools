;~@sa1

;Usage:
;REP #$10
;LDX #!block_number
;%change_map16()
;SEP #$10


;todo optimize
	PHP
	SEP #$20
	PHB
	PHY
	LDA #$00|!bank8
	PHA
	PLB
	REP #$30
	PHX
	LDA $9A
	STA $0C
	LDA $98
	STA $0E
	LDA #$0000
	SEP #$20
	LDA $5B
	STA $09
	LDA $1933|!addr
	BEQ SkipShift
	LSR $09
SkipShift:
	LDY $0E
	LDA $09
	AND #$01
	BEQ LeaveXY
	LDA $9B
	STA $00
	LDA $99
	STA $9B
	LDA $00
	STA $99
	LDY $0C
LeaveXY:
	CPY #$0200
	BCC NoEnd
	PLX
	PLY
	PLB
	PLP
	RTL
	
NoEnd:
	LDA $1933|!addr
	ASL A
	TAX
	LDA $BEA8,x
	STA $65
	LDA $BEA9,x
	STA $66
	STZ $67
	LDA $1925|!addr
	ASL A
	TAY
	LDA [$65],y
	STA $04
	INY
	LDA [$65],y
	STA $05
	STZ $06
	LDA $9B
	STA $07
	ASL A
	CLC
	ADC $07
	TAY
	LDA [$04],y
	STA $6B
	STA $6E
	INY
	LDA [$04],y
	STA $6C
	STA $6F
	if !sa1
		LDA #$40
	else
		LDA #$7E
	endif
	STA $6D
	INC A
	STA $70
	LDA $09
	AND #$01
	BEQ SwitchXY
	LDA $99		
	LSR A
	LDA $9B
	AND #$01
	BRA CurrentXY
SwitchXY:
	LDA $9B
	LSR A
	LDA $99
CurrentXY:
	ROL A
	ASL A
	ASL A
	ORA #$20
	STA $04
	CPX #$0000
	BEQ NoAdd
	CLC
	ADC #$10
	STA $04
NoAdd:
	LDA $98
	AND #$F0
	CLC
	ASL A
	ROL A
	STA $05
	ROL A
	AND #$03
	ORA $04
	STA $06
	LDA $9A
	AND #$F0
	REP 3 : LSR A
	STA $04
	LDA $05
	AND #$C0
	ORA $04
	STA $07
	REP #$20
	LDA $09
	AND #$0001
	BNE LayerSwitch
	LDA $1A
	SEC
	SBC #$0080
	TAX
	LDY $1C
	LDA $1933|!addr
	BEQ CurrentLayer
	LDX $1E
	LDA $20
	SEC
	SBC #$0080
	TAY
	BRA CurrentLayer
LayerSwitch: 
	LDX $1A
	LDA $1C
	SEC
	SBC #$0080
	TAY
	LDA $1933|!addr
	BEQ CurrentLayer
	LDA $1E
	SEC
	SBC #$0080
	TAX
	LDY $20
CurrentLayer:
	STX $08
	STY $0A
	LDA $98
	AND #$01F0
	STA $04
	LDA $9A
	REP 4 : LSR A
	AND #$000F
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
	PER $0006
	PEA $804C
	JML $00C0FB|!bank
	PLY
	PLB
	PLP
	RTL
