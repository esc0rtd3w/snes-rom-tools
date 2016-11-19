;===============================================================================
; Scrolling HDMA Gradient Code. Original code was written by imamelia.
;
; I added a few comments on lines you can modify to change what HDMA channels
; you use as well as modifying the register to write and the transfer mode.
;
; To use scrolling HDMA gradients, use the following as an example.
; In LevelASM INIT:
;     ...
;     LDA #$xx ; See ScrollGradientTables.asm for the number to put here
;     JSR/JSL SyncColorGradientInitRt
;     ...
;
; In LevelASM:
;     ...
;     JSR/JSL SyncColorGradientMainRt
;     ...
;
; Add HDMA tables to ScrollGradientTables.asm
;===============================================================================
; Incsrc this file from wherever is most convenient for you.
; Don't insert the code multiple times; it will bloat your ROM.
;
; I use LevelASMTool.
; I incsrc this file at the bottom of Level 0's LevelASM file.
; Then I can JSL to the proper routines from any level's LevelASM.
;
; Note that if you use my method, you'll need to change the RTS at the bottom of
; this file to RTL.
;
; Another thing to note is that you NEED to apply HDMA Bug Fixes or else you'll
; get a flickering background on Snes9x and bsnes when you hit the goal tape.
incsrc ScrollGradientTables.asm

SyncColorGradientInitRt:
	REP #$30
	AND #$00FF
	ASL
	TAX
	LDA.l SyncGradientPtrs,x
	STA $02
	INC
	STA $04
	INC
	STA $06
	INC
	STA $08
	LDA #$B260
	STA $0A
	LDA #$B830
	STA $0D
	SEP #$20
	LDA #$7F
	STA $0C
	STA $0F
.Loop1
	LDA ($02)
	BEQ .End
	STA $00
.Loop2
	LDA #$01
	STA [$0A]
	STA [$0D]
	LDY #$0001
	LDA ($04)
	STA [$0A],y
	LDA ($08)
	STA [$0D],y
	INY
	LDA ($06)
	STA [$0A],y
	REP #$20
	INC $0A
	INC $0A
	INC $0A
	INC $0D
	INC $0D
	SEP #$20
	DEC $00
	BPL .Loop2
	REP #$20
	LDA $02
	CLC
	ADC #$0004
	STA $02
	INC
	STA $04
	INC
	STA $06
	INC
	STA $08
	SEP #$20
	BRA .Loop1
.End
	SEP #$30
	BRA SyncColorGradientMainRt

SpecifySyncColorGradientInitRt:
	PHB      ; Save current data bank number
	PHX      ; / Transfer the value of X
	PLB      ; \ to the data bank register.
	REP #$30 ; 16-bit A, X, and Y
	STA $02
	INC
	STA $04
	INC
	STA $06
	INC
	STA $08
	LDA #$B260
	STA $0A
	LDA #$B830
	STA $0D
	SEP #$20 ; 8-bit A
	LDA #$7F
	STA $0C
	STA $0F
.Loop1
	LDA ($02)
	BEQ .End
	STA $00
.Loop2
	LDA #$01
	STA [$0A]
	STA [$0D]
	LDY #$0001
	LDA ($04)
	STA [$0A],y
	LDA ($08)
	STA [$0D],y
	INY
	LDA ($06)
	STA [$0A],y
	REP #$20
	INC $0A
	INC $0A
	INC $0A
	INC $0D
	INC $0D
	SEP #$20
	DEC $00
	BPL .Loop2
	REP #$20
	LDA $02
	CLC
	ADC #$0004
	STA $02
	INC
	STA $04
	INC
	STA $06
	INC
	STA $08
	SEP #$20
	BRA .Loop1
.End
	PLB        ; Restore previous data bank number
	SEP #$30

SyncColorGradientMainRt:
	REP #$20
	LDA #$3202 ; / Write to $2132 with Transfer Mode 2
	STA $4330  ; \ Using HDMA Channel 3

	LDA #$3200 ; / Write to $2132 with Transfer Mode 0
	STA $4340  ; \ Using HDMA Channel 4

	LDA $20    ; / Load the Y-position of BG2
	LDX $1414  ; | / Check how much the gradient should be shifted upward
	CPX #$01   ; | | /
	BEQ .Const ; | | \ #$01: Constant
	CPX #$02   ; | | /
	BEQ .Var   ; | | \ #$02: Variable
	CPX #$03   ; | | /
	BEQ .Slow  ; | | \ #$03: Slow
	           ; | |
.None              ; | | / No scrolling (consider using fixed HDMA)
	SEC        ; | | |
	SBC #$00C0 ; | | | shift 192 pixels downward
	BRA .Const ; | | \ Continue
	           ; | |
.Slow              ; | | / Slow scrolling (consider using fixed HDMA)
	SEC        ; | | |
	SBC #$00A8 ; | | | shift 168 pixels downward
	BRA .Const ; | | \
	           ; | |
.Var               ; | | / Variable scrolling
	SEC        ; | | |
	SBC #$0060 ; | | \ shift 96 pixels downward
	           ; | |
.Const             ; | \ < Constant scrolling (BG2:Camera = 1:1)
	           ; |
	           ; | / If you want to slow down the scroll rate, put an LSR
	           ; | | or two here. Or you can put an ASL and make the gradient
	           ; | \ scroll faster (looks wierd)
	           ; |
	STA $00    ; \ and store it to scratch RAM.
	ASL        ; /
	CLC        ; | I guess this transforms the Y-pos of BG2
	ADC $00    ; | into the address at which the HDMA
	CLC        ; | gradient should start, maybe?
	ADC #$B260 ; \
	STA $4332  ; HDMA Channel 3 table starting address.

	LDA $00    ; /
	ASL        ; | Y-pos of BG2 to
	CLC        ; | HDMA table offset
	ADC #$B830 ; \
	STA $4342  ; HDMA Channel 4 table starting address.

	LDY #$7F   ; / HDMA channels 3 and 4
	STY $4334  ; | are using decompressed tables
	STY $4344  ; \ in bank $7F.
	SEP #$20

	LDA #$18   ; / Enable HDMA on
	TSB $0D9F  ; \ channels 3 and 4.

	; Change this to RTL if you JSL to these routines.
	; Leave it as RTS if you JSR to these routines.
	RTS
