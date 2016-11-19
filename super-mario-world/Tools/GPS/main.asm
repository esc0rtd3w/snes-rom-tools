!version = #$01

incsrc defines.asm		; global defines

if read1($06F690) == $8B
	autoclean read3(read3($06F690+8)+21)
endif

macro offset(id, addr)
	ORG <addr>
	PHB
	PHX
	REP #$30
	LDA.w <id>*3
	autoclean JSL block_execute
	PLX
	PLB
	JMP $F602
endmacro
%offset(#$00, $06F690) : %offset(#$01, $06F6A0) : %offset(#$02, $06F6B0) : %offset(#$07, $06F6C0) 
%offset(#$08, $06F6D0) : %offset(#$09, $06F6E0) : %offset(#$03, $06F720) : %offset(#$04, $06F730) 
%offset(#$05, $06F780) : %offset(#$06, $06F7C0)

ORG read3($06F624)
	incbin __acts_likes.bin

freecode
block_execute:
	STA $05
	LDX $03
	LDA.l block_bank_byte,x
	AND #$00FF
	BEQ .return
	XBA
	STA $01
	PHA
	TXA
	ASL
	TAX
	LDA.l block_pointers,x 	;Ignore old blocks for now -- if they are a problem
	ADC $05			;Just hack support into them right here
	STA $00
	SEP #$30
	PLX			;destroy extra bank byte
	PLB			;bank byte of block
	LDX $15E9|!addr
	JML [$0000|!dp]
.return
	SEP #$30
	RTL

block_bank_byte:		;bank byte of each block 00 means "not inserted"
	incbin __banks.bin	;16KB -- can be made into a incsrc for manual use
block_bank_byte_end:
	db "GPS_VeRsIoN"
	db !version
	dl block_bank_byte
	dl block_pointers
	dw block_bank_byte_end-block_bank_byte
	dw block_pointers_end-block_pointers
	
freedata cleaned
block_pointers:			;two byte pointer per block -- little endian as expected.
	incbin __pointers.bin	;32KB -- can also be made to be incsrced
block_pointers_end:
