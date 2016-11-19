org $018127		;HandleSprite
;JML $908372
LDA $14C8,x
BEQ $25

org $018151		;EraseSprite
;JSL $90821A
;NOP
LDA #$FF
STA $161A,x

org $018172		;CallSpriteInit
;JSL $9081AF
;NOP
LDA #$08
STA $14C8,x

org $0182B3		;hammer bro repoint
;dw $85C2			;this can stay, it doesn't change anything.

org $0185C3		;CallSpriteMain
;JSL $9081D1
;NOP
STZ $1491
LDA $9E,x

org $0187A7		;jump here to initialize a custom sprite
;JML $9082F8		;this can stay, too, it doesn't change anything either

org $01C089		;patch goal tape to get extra bits from $7FAB10
;LDA $7FAB10,x
;NOP #4
;STA $187B,x
LDA $14D4,x
STA $187B,x
AND #$01
STA $14D4,x

org $01D43E		;Takes advantage of bank 1 'freespace'
;JSR $8133
;RTL				;this can stay, the code itself is unreachable

org $02A866		;hijack sprite loading routine, specificly, the sprite number check if it's greater than E7
;JML $908239
CMP #$E7
BCC $22

org $02A94B		;vertical level extra bits
;JSL $908225
;NOP
AND #$0D
STA $14E0,x

org $02A963		;horizontal level extra bits
;JSL $90819B
;NOP
AND #$0D
STA $14D4,x

org $02A9A6		;seemingly arbitrary part of LoadNormalSprite
;JSL $9083CE
;NOP
TAX
LDA $07F659,x

org $02A9C9		;JSL InitSpriteTables
;JSL $9083BF
JSL $07F7D2

org $02ABA0		;arbitrary shooter hijack
;JSL $908289
;NOP
LDA $04
SEC
SBC #$C8

org $02AFFE		;CallGenerator
;JSL $9082D3
;NOP
LDA $18B9
BEQ $27

org $02B395		;shooter code hijack
;JML $9082A1
;NOP
LDY $17AB,x
BEQ $0A

org $07F785		;zerospritetables
;JSL $90820C
;NOP
LDA #$01
STA $15A0,x