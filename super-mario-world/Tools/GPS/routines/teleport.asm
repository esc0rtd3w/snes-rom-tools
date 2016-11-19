;~@sa1

;Usage:
;REP #$20
;LDA <level>
;%teleport()
	
	STA $00
	STZ $88
	
	SEP #$30
	PHX

	LDX $95
	PHA
	LDA $5B
	LSR
	PLA
	BCC +
	LDX $97
	
+	LDA $00
	STA $19B8|!addr,x
	LDA $01
	STA $19D8|!addr,x

	LDA #$06
	STA $71

	PLX
	RTL
	
