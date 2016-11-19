	RAM_PowerTimer = $7F3221

	dcb "INIT"
	dcb "MAIN"
	LDA $14			; Only run every fourth frame
	AND #$03
	BNE Return
	LDA $19
	CMP #$02
	BCS HasPower
	LDA #$00
	STA RAM_PowerTimer
Return:	
	RTL

HasPower:
	LDA RAM_PowerTimer
	BEQ SetTimer		; Set timer if it hasn't been set
	CMP #$01
	BNE DecrementCounter
	LDA #$01		; Set Big Mario status if timer is about to run out
	STA $19
	STZ $1407 		; Set not soaring
DecrementCounter:
	LDA RAM_PowerTimer	; Decrement the timer
	DEC
	STA RAM_PowerTimer
	RTL

SetTimer:
	LDA #$FF
	STA RAM_PowerTimer
	RTL