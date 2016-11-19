
!RightArrowGFX		= $303C
!DownArrowGFX		= $303D

!CurrentLine		= $C802
!Xposition		= $C804
!FontColor		= $C806
!TermChars		= $C808		; the number of characters left until finishing rendering a term
!TermWidth		= $C80A
!LineDrawn		= $C80C		; the number of line drawn which will be incremented until this reaches 5
!Timer			= $C80E		; general purpose
!LeftPad		= $C810
!NewLeftPad		= $C812
!LineBroken		= $C814		; to erase an old line
!SelectMsg		= $C816		; for branch
!SkipPos		= $C818		; where the pointer jumps to when the player pressed the Start button
!Skipped		= $C81A

!Inner			= $C820
!ForcedScroll		= $C822
!ValidWidth		= $C824
!RightPad		= $C828

			print "INIT ",pc

			LDA $7FAB10,x
			AND #$04
			BNE $FE


			LDA #$80
			STA $2100
			STZ $0D9D
			STZ $0D9E
			PHX
			LDX #$04
-			LDA HDMATable1,x
			STA $4330,x
			LDA HDMATable2,x
			STA $4340,x
			LDA HDMATable3,x
			STA $4350,x
			DEX
			BPL -
			LDX #$4F
			LDA #$80
-			STA $7EC900,x
			DEX
			BPL -
			LDA #$7E
			STA $4337
			STA $4347
			PLX
			LDA #$88
			STA $420C
			STA $0D9F
			RTL

HDMATable1:		db $40,$00 : dl .src
.src			db $5F
			dw $C900
			db $8C
			dw $C910
			db $90
			dw $C920
			db $54
			dw $C930
			db $90
			dw $C940
			db $00

HDMATable2:		db $43,$11 : dl .src
.src			db $5F
			dw $CA00
			db $0C
			dw $CA10
			db $01
			dw $CA20
			db $00

HDMATable3:		db $00,$09 : dl .src
.src			db $5F
			db $59
			db $0C
			db $5C
			db $01
			db $59
			db $00

			print "MAIN ",pc
			LDA #$38
			STA $0D9F
			LDA $0100
			CMP #$14
			BEQ +
			RTL

+			PHX
			PHB
			SEI
			STZ $4200
			STZ $420C

			STZ $1BE4	;disable updating BG1
			STZ $1CE6	;disable updating BG1

			PHD
			LDA #$21
			XBA
			LDA #$00
			TCD

			LDA #$80
			STA $00
			STA $15

			LDA #$02
			STA $0C
			REP #$30
			LDA #$0014
			STA $2C
			LDA #$2000
			STA $16
-			STZ $18
			DEC A
			BNE -
			LDA #$5800
			STA $16
			LDX #$0400
			LDA #$0000
-			STA $18
			INC A
			AND #$01FF
			DEX
			BNE -
			LDX #$0040
			LDA #$0600
-			STA $18
			INC A
			DEX
			BNE -
			PLD
			SEP #$30

			PEA $7E7E
			PLB
			PLB
			LDX #$4F
-			STZ $C900,x
			DEX
			BPL -
			LDX #$0F
			TXA
			LDY #$00
			STA $C930
-			STA $C920,x
			STA $C940,y
			INY
			DEX
			DEC A
			BPL -

			JSL $7F8000			; Clear all OAM position

			LDA $D002			; | Copy the source data address
			STA $D7
			REP #$30
			LDA $D000
			STA $D5

			LDX #$03FE
-			STZ $AD00,x
			DEX #2
			BPL -
			STZ !CurrentLine		; current line
			STZ !FontColor			; fonr color
			STZ !TermChars			; the number of character left until rendering a term
			LDA #$0008			; | left padding
			STA !LeftPad			; |
			STA !NewLeftPad			;/
			STA !RightPad			; | right
			;STA !NewRightPad		;/
			STA !Xposition			; current X
			STZ !LineDrawn
			STZ !Timer
			STZ !LineBroken
			STZ !Inner
			STZ !ForcedScroll
			STZ !SelectMsg			; for branch
			LDA #$FFFF
			STA !SkipPos
			STZ !Skipped
			LDA #$0100
			STA $CA00
			STA $CA10
			LDA #$0080
			STA $CA02
			LDA #$FFFF-$5F
			STA $CA12
			STZ $CA20
			LDA #$FF80
			STA $CA22
			LDX #$001E
-			STZ $0400,x
			DEX #2
			BPL -
			SEP #$20

			LDA #$81
			STA $004200
-			LDA $10				; | once, just wait for v-blank without doing anything
			BEQ -				; |
			STZ $10				;/
			LDY #$0000
.Loop
			LDA !Skipped
			BEQ +
			LDA #$00
			REP #$20
			BRA .ForcedEnd
+			LDA !ForcedScroll
			BEQ +
			INC $CA22
			LDA $CA22
			AND #$0F
			BNE +
			STZ !ForcedScroll
+			LDA !TermChars
			BNE .NoNewTerm

			LDA [$D5],y
			REP #$20
			BPL .IsChar
.ForcedEnd		PEA.w .ReturnedCommand-1
			AND #$007F
			ASL A
			TAX
			LDA CommandAddress,x
			PHA
			RTS
.ReturnedCommand	SEP #$20
			BRA .Finalize

.IsChar			STZ !TermWidth
			DEC !TermWidth
			PHY
-			AND #$00FF
			TAX
			LDA FontWidth,x
			AND #$00FF
			SEC
			ADC !TermWidth
			STA !TermWidth
			INC !TermChars
			INY
			LDA [$D5],y
			BIT #$0080
			BEQ -
			PLY
			LDA #$0100
			SEC
			SBC !LeftPad
			SBC !RightPad
			STA !ValidWidth
			BMI $FE
			LDA !TermWidth
			CMP !ValidWidth
			BCS $FE
			CLC
			ADC !Xposition
			SEC
			SBC !LeftPad
			CMP !ValidWidth
			SEP #$20
			BCC .Finalize
			REP #$20
			INC !Inner
			JSR BreakLine			; if there is no longer much space to render a term, break a line
			STZ !Inner
			BCS $03
			STZ !TermChars
			SEP #$20
			BRA .Finalize

.NoNewTerm		STZ $04
			LDA #$AD
			STA $05
			LDA [$D5],y
			JSR DrawChar

.Finalize		LDA.w !SkipPos+1
			BMI .WaitVblank
			XBA
			LDA $16
			AND #$10
			BEQ .WaitVblank
			LDA !SkipPos
			TAY
			INC !Skipped
.WaitVblank		LDA $10
			BEQ $FC
			STZ $10
			INC $13

			LDA #$00
			STZ $00420C
			LDA #$80
			STA $002100
			STA $002115
			LDX #$420B
			REP #$20
			LDA !CurrentLine
			LSR !LineBroken
			BCC +
			SBC #$0E00
+			AND #$0E00
			ORA #$2000
			STA $002116
			LDA #$1801
			STA $F5,x
			LDA #$AD00
			STA $F7,x
			LDA #$7EAD
			STA $F8,x
			LDA #$0400
			STA $FA,x
			SEP #$20
			LDA #$01
			STA $00,x
			LDA $0D9F
			STA $01,x
			JMP .Loop

CommandAddress:		dw FinishVWF-1		; 80
			dw PutSpace-1		; 81
			dw BreakLine-1		; 82
			dw WaitButton-1		; 83
			dw WaitTime-1		; 84
			dw FontColor1-1		; 85
			dw FontColor2-1		; 86
			dw FontColor3-1		; 87
			dw PadLeft-1		; 88
			dw PadRight-1		; 89
			dw PadBoth-1		; 8A
			dw ChangeMusic-1	; 8B
			dw EraseSentence-1	; 8C
			dw ChangeTopic-1	; 8D
			dw ShowOAM-1		; 8E
			dw HideOAM-1		; 8F
			dw BranchLabel-1	; 90
			dw JumpLabel-1		; 91
			dw SkipLabel-1		; 92
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FinishVWF:		SEP #$20
			LDX #$004F
-			LDA $C900,x
			BEQ +
			DEC $C900,x
+			DEX
			BPL -
			LDA $C930
			REP #$20
			BNE PutSpace_R
			INY
			LDA [$D5],y
			PLX
			SEP #$30
			PLB
			PLX
			STA $F0
			CMP #$20
			BCS +
			TAY
			LDA $19B8,y
			STA $19B8
			LDA $19D8,y
			STA $19D8
			LDA #$05
			STA $71
			RTL
+			CMP #$20
			BNE +
			;Side Exit
			JML $85B160
+			SBC #$20
			STA $13CE
			STA $0DD5
			INC $1DE9
			LDA #$0B
			STA $0100
			RTL
+
			RTL

PutSpace:		LDA !Xposition
			CLC
			ADC #$0004
			STA !Xposition
			INY
.R			RTS

BreakLine:		LDA !ForcedScroll
			BEQ +
			CLC
			RTS
+			LDA !LineDrawn
			CMP #$0004
			BCC +
			INC !ForcedScroll
			BRA ++
+			INC !LineDrawn
++			LDA !CurrentLine
			CLC
			ADC #$0200
			STA !CurrentLine
			LDA !NewLeftPad
			STA !LeftPad
			STA !Xposition
			LDX #$03FE
-			STZ $AD00,x
			DEX #2
			BPL -
			INC !LineBroken
			LDA !Inner
			BNE .R
			INY
			SEC
.R			RTS

WaitButton:		LDA.b $15-1
			BPL .R
			LDA.b $17-1
			BPL .INY
			LDA.b $18-1
			BPL .R
.INY			INY
.Erase			LDA #$00F0
			STA $0201
			RTS

.R			LDA $13
			AND #$0010
			BNE .Erase
			LDA !ForcedScroll
			BNE .Erase
			LDA !Xposition
			STA $0200
			LDA !LineDrawn
			ASL #4
			ADC #$0086
			STA $0201
			LDA #!RightArrowGFX
			STA $0202
			RTS

WaitTime:		INY
			LDA [$D5],y
			AND #$00FF
			CMP !Timer
			BEQ .INY
			INC !Timer
			DEY
			RTS
.INY			STZ !Timer
			INY
			RTS

FontColor1:		STZ !FontColor
			INY
			RTS
FontColor2:		LDA #$0010
			STA !FontColor
			INY
			RTS
FontColor3:		LDA #$0020
			STA !FontColor
			INY
			RTS

PadLeft:		INY
			LDA [$D5],y
			AND #$00FF
			STA !NewLeftPad
			INY
			RTS
PadRight:		INY
			LDA [$D5],y
			AND #$00FF
			STA !RightPad
			INY
			RTS
PadBoth:		INY
			LDA [$D5],y
			AND #$00FF
			STA !NewLeftPad
			BRA PadRight

ChangeMusic:		INY
			SEP #$20
			LDA [$D5],y
			STA $1DFB
			BMI +
			CMP #$21
			BCC +
			DEC A
			AND #$03
			STA $00
			LDA $C100
			AND #$FC
			ORA $00
			STA $C100
+			REP #$20
			INY
			RTS

EraseSentence:		LDA !ForcedScroll
			BNE .R

			LDX #$03FE
-			STZ $AD00,x
			DEX #2
			BPL -
			SEP #$20
.loop			LDA $10
			BEQ .loop
			STZ $10

			LDA #$00
			STA $00420C
			LDA #$80
			STA $002100
			STA $002115
			LDX #$420B
			REP #$21
			LDA !CurrentLine
			ADC #$0200
			STA !CurrentLine
			AND #$0E00
			ORA #$2000
			STA $002116
			LDA #$1801
			STA $F5,x
			LDA #$AD00
			STA $F7,x
			LDA #$7EAD
			STA $F8,x
			LDA #$0400
			STA $FA,x
			SEP #$20
			LDA #$01
			STA $00,x
			LDA $0D9F
			STA $01,x
			INC !Timer
			LDA !Timer
			CMP #$08
			BNE .loop
			INY
			REP #$20
			STZ !CurrentLine
			LDA !NewLeftPad
			STA !LeftPad
			STA !Xposition
			STZ !LineDrawn
			STZ !Timer
			LDA #$FF80
			STA $CA22
.R			RTS


TopicFadeOut:		LDA !ForcedScroll
			BNE .R
			PHY
			PHP
			SEP #$30
--			LDA $C915
			BEQ +++

			LDX !Timer
			LDA #$0B
			SEC
			SBC !Timer
			TAY
-			LDA $C910,x
			BEQ +
			DEC $C910,x
			PHX
			TYX
			DEC $C910,x
			PLX
+			INY
			DEX
			BPL -
			LDA !Timer
			CMP #$05
			BCS +
			INC !Timer
+			LDA $10
			BEQ $FC
			STZ $10
			BRA --
+++			PLP
			STZ !Timer
			PLY
.R			RTS

TopicFadeIn:		LDA !ForcedScroll
			BNE .R
			PHY
			PHP
			SEP #$30
			LDA #$04
			STA !Timer
--			LDA $C910
			CMP #$0F
			BEQ +++

			LDX #$05
			LDY #$06
-			LDA $C910,x
			CMP #$0F
			BEQ +
			INC $C910,x
			PHX
			TYX
			INC $C910,x
			PLX
+			INY
			DEX
			CPX !Timer
			BNE -
			LDA !Timer
			BMI +
			DEC !Timer
+			LDA $10
			BEQ $FC
			STZ $10
			BRA --
+++			PLP
			STZ !Timer
			PLY
.R			RTS

ChangeTopic:		JSR TopicFadeOut

			SEP #$A0
			LDA #$00
			STA $004200
			REP #$20

			LDA !Xposition
			PHA
			STZ !Xposition

			LDA #$B100
			STA $04
			LDX #$03FE
-			STZ $B100,x
			DEX #2
			BPL -
			SEP #$20
			INY
.Loop			LDA [$D5],y
			BPL .IsChar
			CMP #$8D
			BEQ .END
			REP #$20
			PEA.w .ReturnedCommand-1
			AND #$007F
			ASL A
			TAX
			LDA CommandAddress,x
			PHA
			RTS
.ReturnedCommand	SEP #$20
			BRA .Loop
.IsChar			JSR DrawChar
			BRA .Loop

.END			LDA #$81
			STA $004200
-			LDA $10
			BEQ -
			STZ $10

			LDA #$00
			STA $00420C
			LDA #$80
			STA $002100
			STA $002115
			LDX #$420B
			REP #$20
			LDA #$3000
			STA $002116
			LDA #$1801
			STA $F5,x
			LDA #$B100
			STA $F7,x
			LDA #$7EB1
			STA $F8,x
			LDA #$0400
			STA $FA,x
			SEP #$20
			LDA #$01
			STA $00,x
			LDA $0D9F
			STA $01,x

			REP #$20
			LDA !Xposition
			LSR A
			CLC
			ADC #$FF80
			STA $CA10
			PLA
			STA !Xposition
			STZ !TermChars
			INY
			JSR TopicFadeIn
			RTS

TopFadeOut:		LDA !ForcedScroll
			BNE .R
			PHY
			PHP
			SEP #$30
-			LDA $C900
			BEQ +
			DEC $C900
			LDA $10
			BEQ $FC
			STZ $10
			BRA -
+			PLP
			PLY
.R			RTS

TopFadeIn:		LDA !ForcedScroll
			BNE .R
			PHY
			PHP
			SEP #$30
-			LDA $C900
			CMP #$0F
			BEQ +
			INC $C900
			LDA $10
			BEQ $FC
			STZ $10
			BRA -
+			PLP
			PLY
.R			RTS

ShowOAM:		JSR HideOAM
			LDA #$0001
			STA $0E
			LDX #$0004

			LDA [$D5],y
			AND #$00FF
			STA $0C
			INY
-			LDA [$D5],y
			STA $0200,x
			INY #2
			LDA [$D5],y
			AND #$2000
			ASL #2
			STA $08
			LDA [$D5],y
			STA $0202,x
			INX #4
			INY #2
			PHX
			LDA $0E
			LSR #2
			ORA #$0400
			STA $00
			LDA $0E
			AND #$0003
			ASL A
			TAX
			LDA ($00)
			AND .Mask,x
			ASL $08
			BCC +
			ORA .OR,x
+			STA ($00)
			PLX
			INC $0E
			DEC $0C
			BNE -
			JSR TopFadeIn
			RTS
.Mask			dw $FFFC,$FFF3,$FFCF,$FF3F
.OR			dw $0002,$0008,$0020,$0080

HideOAM:		JSR TopFadeOut
			SEP #$20
			LDA #$F0
			JSL $7F8005
			REP #$20
			INY
.R			RTS

BranchLabel:		LDA !ForcedScroll
			BNE HideOAM_R

			LDA [$D5],y
			STA $06
			XBA
			AND #$007F
			STA $02
			ASL #4
			STA $04

			LDA !LeftPad
			SEC
			SBC #$000A
			BCS $03
			LDA #$0000
			STA $0200
			LDA !SelectMsg
			ASL #4
			STA $00
			LDA !LineDrawn
			ASL #4
			ADC #$008F
			ADC $00
			SEC
			SBC $04
			STA $0201
			LDA #!DownArrowGFX
			STA $0202

			LDA $16
			AND #$000C
			BEQ ++
			CMP #$000C
			BEQ ++
			BIT #$0004
			BEQ +
			INC !SelectMsg
			LDA !SelectMsg
			CMP $02
			BCC ++
			STZ !SelectMsg
			BRA ++
+			DEC !SelectMsg
			BPL ++
			LDA $02
			DEC A
			STA !SelectMsg
++			LDA.b $16-1
			ORA.b $18-1
			BPL .R
			LDA #$00F0
			STA $0201
			INY
			INY
			TYA
			ASL !SelectMsg
			ADC !SelectMsg
			TAY
			LDA [$D5],y
			TAY
			STZ !SelectMsg
			LDA $06
			BMI .R
			INC !Inner
			JSR BreakLine
			STZ !Inner
.R			RTS

JumpLabel:		INY
			LDA [$D5],y
			TAY
			RTS

SkipLabel:		INY
			LDA [$D5],y
			STA !SkipPos
			INY #2
			RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DrawChar:		PHY
			STA $00
			PHK
			PLA
			STA $0C
			STA $0F
			REP #$20
			LDA $00
			AND #$00FF
			TAX
			LDA FontWidth,x
			AND #$00FF
			STA $08				; the character's width
			TXA
			ASL #2
			STA $00
			ASL A
			ADC $00
			ADC.w #Letters			; the character bitmap info. address. left part.
			STA $0A
			ADC #$0400
			STA $0D				; the character bitmap info. address. right part.

			LDY #$0000
.YLoop
			STZ $00
			LDA [$0A],y
			STA $01
			LDA [$0D],y
			AND #$00FF
			ORA $00				; A = LLLLLLLL RRRRRRRR

			LDX #$0000
.XLoop			ASL A
			BCC .NoPixel
			PHA
			PHX
			TXA
			CLC
			ADC !Xposition
			PHA
			AND #$FFF8
			ASL A
			CPY #$0008
			BCC $03
			ORA #$0200
			STA $00
			TYA
			AND #$0007
			ASL A
			ADC $04
			ADC $00
			STA $00
			PLA
			AND #$0007
			ASL A
			ORA !FontColor
			TAX
			LDA ($00)
			ORA BitTable,x
			STA ($00)
			PLX
			PLA
.NoPixel		INX
			CPX $08
			BNE .XLoop
			INY
			CPY #$000C
			BCC .YLoop
			LDA !Xposition
			ADC $08				; carry flag is already set here, so 1 pixel for spacing is automatically added :P
			STA !Xposition
			DEC !TermChars
			CMP #$0100
			BCS $FE
			SEP #$20
			PLY
			INY
			RTS


BitTable:		dw $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
			dw $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
			dw $8080,$4040,$2020,$1010,$0808,$0404,$0202,$0101
Letters:		incbin sprites/vwf.bin
FontWidth:		incbin sprites/width.bin
