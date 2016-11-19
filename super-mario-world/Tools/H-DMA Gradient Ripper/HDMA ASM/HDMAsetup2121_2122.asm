;note: level number can be anything from 000-1FF of course.

level101:
	PHP
	REP #$20
	LDY #$03
	STY $4350
	LDY #$21
	STY $4351
	LDA.w #.Table
	STA $4352
	LDY.b #.Table>>16
	STY $4354
	SEP #$20
	LDA #$20
	TSB $0D9F
	PLP
	RTS


.Table
	;*table*

levelinit101:
		JSR level101
		;*other code*
		RTS