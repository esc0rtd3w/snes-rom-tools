;note: level number can be anything from 000-1FF of course.

level101:
		LDA #$00
		STA $4330
		LDA #$02
		STA $4340

		LDA #$32
		STA $4331
		STA $4341

		REP #$20
		LDA.w #.Table2
		STA $4332
		LDA.w #.Table1
		STA $4342

		SEP #$20

		LDA.b #.Table2>>16
		STA $4334
		LDA.b #.Table1>>16
		STA $4344

		LDA #$18
		TSB $0D9F

		RTS

.Table1


.Table2





levelinit101:
		JSR level101
		;*other code*
		RTS