;Input: A = Bounce sprite number,  X = $9C value, Y = bounce sprite direction
;Ouput: Y = Slot used

		STA	$04
		STY	$06
		STX	$07
		LDA	#$0F
		TRB	$9A
		TRB	$98
		LDY	#$03
.find_free		
		LDA	$1699|!addr,y
		BEQ	.slot_found
		DEY	
		BPL	.find_free
		DEC	$18CD|!addr
		BPL	.alt_slot
		LDA	#$03
		STA	$18CD|!addr
.alt_slot		
		LDY	$18CD|!addr
		LDA	$1699|!addr,y
		CMP	#$07
		BNE	.no_turn_block_reset
		LDA	$04
		PHA	
		LDA	$06
		PHA	
		LDA	$07
		PHA	
		LDA	$98
		PHA	
		LDA	$99
		PHA	
		LDA	$9A
		PHA	
		LDA	$9B
		PHA	
		LDA	$16A5|!addr,y
		STA	$9A
		LDA	$16AD|!addr,y
		STA	$9B
		LDA	$16A1|!addr,y
		CLC	
		ADC	#$0C
		AND	#$F0
		STA	$98
		LDA	$16A9|!addr,y
		ADC	#$00
		STA	$99
		LDA	$16C1|!addr,y
		STA	$9C
		JSL	$00BEB0|!bank
		PLA	
		STA	$9B
		PLA	
		STA	$9A
		PLA	
		STA	$99
		PLA	
		STA	$98
		PLA	
		STA	$07
		PLA	
		STA	$06
		PLA	
		STA	$04
.no_turn_block_reset	
		LDY	$18CD|!addr
.slot_found		
		LDA	$04
		STA	$1699|!addr,y
		LDA	#$00
		STA	$169D|!addr,y
		LDA	$9A
		STA	$16A5|!addr,y
		LDA	$9B
		STA	$16AD|!addr,y
		LDA	$98
		STA	$16A1|!addr,y
		LDA	$99
		STA	$16A9|!addr,y
		LDA	$1933|!addr
		LSR	
		ROR	
		STA	$08
		LDX	$06
		LDA.l	$02873A|!bank,x
		STA	$16B1|!addr,y
		LDA.l	$02873E|!bank,x
		STA	$16B5|!addr,y
		TXA	
		ORA	$08
		STA	$16C9|!addr,y
		LDA	$07
		STA	$16C1|!addr,y
		LDA	#$08
		STA	$16C5|!addr,y
		LDA	#$00
		STA	$1901|!addr,y
		PHK	
		PEA.w	.sprite_interact-1
		PEA.w	$B889-1
		JML	$0286ED|!bank
.sprite_interact	
		RTL	