;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB1 Firebar, by imamelia
;;
;; This is a Firebar that looks and acts like the one in SMB1.
;;
;; Extra bytes: 2
;;
;; Extra byte 1:
;;
;; Bits 0-3: Number of fireballs in the sprite.  (0 -> 1 fireball, 1 -> 2 fireballs, etc.)
;; Bits 4-5: Rotation speed.  (0 -> 1 unit, 1 -> 2 units, etc.)
;; Bit 6: Rotation direction.  (0 -> clockwise, 1 -> counterclockwise.)
;; Bit 7: High bit of starting angle.
;;
;; Extra byte 2:
;;
;; Bits 0-7: Low byte of starting angle.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!RAM_Offsets = $7F9CE0	; RAM for the offsets of each individual fireball
; This should be RAM in some unused area.  You'll need 2 bytes for each fireball.
; For example, for the 6-tile Firebar, this should be at least 12 (0xC) bytes long.
; For the 12-tile Firebar, this should be at least 24 (0x18) bytes long.

Tilemap:
db $AF,$BF,$AF,$BF

Flip:
db $00,$00,$C0,$C0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR FirebarInit
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FirebarInit:

LDA $7FAB40,x
LSR #4
AND #$03
INC
STA $7FAD00,x
LDA $7FAB40,x
AND #$40
BNE NoInvertSpeed
LDA $7FAD00,x
EOR #$FF
INC
STA $7FAD00,x
NoInvertSpeed:
LDA $7FAB4C,x
STA $7FAD54,x
LDA $7FAB40,x
ROL
ROL
AND #$01
STA $7FAD60,x

LDA $D8,x
CLC
ADC #$04
STA $D8,x
STA $7FAD24,x
LDA $14D4,x
ADC #$00
STA $7FAD3C,x
LDA $E4,x
CLC
ADC #$04
STA $7FAD30,x
LDA $14E0,x
ADC #$00
STA $7FAD48,x

LDA $7FAB40,x
AND #$0F
STA $187B,x

JSR MainEllipseCode

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR FirebarMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FirebarMain:

JSR MainEllipseCode
JSR FirebarGFX

LDA $14C8,x
CMP #$08
BNE Return00
LDA $9D
BNE Return00

JSL !SubOffscreenX0

Return00:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FirebarGFX:

JSL !GetDrawInfo

LDA $14
LSR #2
AND #$03
TAX
LDA Flip,x
STX $04
LDX $15E9
ORA $15F6,x
ORA $64
STA $02
LDX $04
LDA Tilemap,x
STA $03

LDX $15E9
LDA $7FAD30,x
SEC
SBC $1A
STA $00
LDA $7FAD24,x
SEC
SBC $1C
STA $01
LDA $187B,x
ASL
TAX

GFXLoop:

LDA $00
CLC
ADC !RAM_Offsets,x
STA $0300,y

LDA $01
CLC
ADC !RAM_Offsets+1,x
STA $0301,y

LDA $03
STA $0302,y

LDA $02
STA $0303,y

INY #4
DEX #2
BPL GFXLoop

LDX $15E9
LDY #$00
LDA $187B,x
JSL $81B7B3

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; elliptical/circular motion subroutine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainEllipseCode:

JSR EllipseUpdateAngle	;
;JSL !EllipseUpdateAngle	;
JSR EllipseSetUpAngle	;
;JSL !EllipseSetUpAngle	;
JSR EllipseGetCoords	;
;JSL !EllipseGetCoords	;
JSR MultiplyAllCoords	;
;JSL !MultiplyAllCoords	;
JSR Interact		;

RTS

EllipseUpdateAngle:

LDA $9D
BNE Label92

LDY #$00
LDA $7FAD00,x
;CMP #$00
BPL Label91
DEY
Label91:
CLC
ADC $7FAD54,x
STA $7FAD54,x
TYA
ADC $7FAD60,x
AND #$01
STA $7FAD60,x

Label92:
RTS

EllipseSetUpAngle:

LDA $7FAD54,x
STA $00
LDA $7FAD60,x
STA $01
RTS

EllipseGetCoords:

REP #$30
LDA $00
CLC
ADC.w #$0080
AND #$01FF
STA $02
LDA $00
AND.w #$00FF
ASL A
TAX
LDA $07F7DB,x
STA $04
LDA $02
AND.w #$00FF
ASL A
TAX
LDA $07F7DB,x
STA $06
SEP #$30
RTS

MultiplyAllCoords:

LDX $15E9
LDA $04
STA $4202
LDA $187B,x
ASL
TAX
STZ $0B
LDA $01
STA $0C

XCLoop:

LDA $0C
STA $01
LDA $0B
LDY $05
BNE Label93
STA $4203
NOP #4
ASL $4216
LDA $4217
ADC #$00
Label93:
LSR $01
BCC Label94
EOR #$FF
INC A
Label94:
STA !RAM_Offsets,x

LDA $0B
CLC
ADC #$08
STA $0B
DEX #2
BPL XCLoop

LDX $15E9
LDA $06
STA $4202
LDA $187B,x
ASL
TAX
STZ $0B
LDA $03
STA $0C

YCLoop:

LDA $0C
STA $03
LDA $0B
LDY $07
BNE Label95
STA $4203
NOP #4
ASL $4216
LDA $4217
ADC #$00
Label95:
LSR $03
BCC Label96
EOR #$FF
INC A
Label96:
STA !RAM_Offsets+1,x

LDA $0B
CLC
ADC #$08
STA $0B
DEX #2
BPL YCLoop

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; interaction subroutine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Interact:

LDX $15E9		;
LDA $7FAD24,x	; Y-coordinate of the circle's center, low byte
STA $14B0		;
LDA $7FAD30,x	; X-coordinate of the circle's center, low byte
STA $14B2		;
LDA $7FAD3C,x	; Y-coordinate of the circle's center, high byte
STA $14B1		;
LDA $7FAD48,x	; X-coordinate of the circle's center, high byte
STA $14B3		;

TXA				;
EOR $13			;
AND #$01		;
ORA $15A0,x		;
BEQ ProcessInteract	;
NoContact:		;
RTS				;

ProcessInteract:		;

LDA $71				;
BNE NoContact		;
LDA #$00			;
BIT $0D9B			;
BVS SkipCheckP		;
LDA $13F9			;
EOR $1632,x			;
SkipCheckP:			;
BNE NoContact2		;

;JSL $83B664			; get player clipping routine
JSR GetPlayerClipping	;
LDA #$06			;
STA $0C				; sprite clipping width
STZ $0D				;
STA $0E				; sprite clipping height
STZ $0F				;
LDA $187B,x			;
ASL					;
TAX					;
ClippingLoop:			;
JSR GetSpriteClipping	; use custom sprite clipping values here
;JSL $83B72B			;
JSR CheckForContact	;
BCC EndClippingLoop	;
LDA $1490			; unless the player is invincible...
ORA $1497			;
BNE EndClippingLoop	;
JSL $80F5B7			; hurt him/her
EndClippingLoop:		;
DEX #2				;
BPL ClippingLoop		;
NoContact2:			;
LDX $15E9			;
RTS					;

GetSpriteClipping:		; custom sprite clipping routine, based off $03B69F

LDY #$00				;
LDA !RAM_Offsets,x	; X displacement for a particular fireball
BPL $01				;
DEY					;
CLC					;
ADC #$01			;
CLC					;
ADC $14B2			;
STA $08				; $08 = sprite X position low byte + X displacement value
TYA					;
ADC $14B3			;
STA $09				; $09 = sprite X position high byte + X displacement high byte (00 or FF)

LDY #$00				;
LDA !RAM_Offsets+1,x	; Y displacement for a particular fireball
BPL $01				;
DEY					;
CLC					;
ADC #$01			;
CLC					;
ADC $14B0			;
STA $0A				; $0A = sprite Y position low byte + Y displacement value
TYA					;
ADC $14B1			;
STA $0B				; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
RTS					;

GetPlayerClipping:		; modified player clipping routine, equivalent to and based off $03B664

PHX					;
REP #$20				;
LDA $94				;
CLC					;
ADC #$0002			;
STA $00				; $00-$01 = player X position plus X displacement
LDA #$000C			;
STA $04				; $04-$05 = player clipping width
SEP #$20				;
LDX #$00				;
LDA $73				;
BNE .Inc1				;
LDA $19				;
BNE .Next1			;
.Inc1				;
INX					;
.Next1				;
LDA $187A			;
BEQ .Next2			;
INX #2				;
.Next2				;
LDA $83B660,x		;
STA $06				; $06-$07 = player clipping height
STZ $07				;
LDA $83B65C,x		;
REP #$20				;
AND #$00FF			;
CLC					;
ADC $96				;
STA $02				; $02-$03 = player Y position plus Y displacement
SEP #$20				;
PLX					;
RTS					;

CheckForContact:		; custom contact check routine, equivalent to $03B72B

REP #$20				;

.CheckX				;
LDA $00				; if the sprite's clipping field is to the right of the player's,
CMP $08				; subtract the former from the latter;
BCC .CheckXSub2		; if the player's clipping field is to the right of the sprite's,
.CheckXSub1			; subtract the latter from the former
SEC					;
SBC $08				;
CMP $0C				;
BCS .ReturnNoContact	;
BRA .CheckY			;
.CheckXSub2			;
LDA $08				;
SEC					;
SBC $00				;
CMP $04				;
BCS .ReturnNoContact	;

.CheckY				;
LDA $02				; if the sprite's clipping field is below the player's,
CMP $0A				; subtract the former from the latter;
BCC .CheckYSub2		; if the player's clipping field is above the sprite's,
.CheckYSub1			; subtract the latter from the former
SEC					;
SBC $0A				;
CMP $0E				;
BCS .ReturnNoContact	;
.ReturnContact		;
SEC					;
SEP #$20				;
RTS					;
.CheckYSub2			;
LDA $0A				;
SEC					;
SBC $02				;
CMP $06				;
BCC .ReturnContact		;
.ReturnNoContact		;
CLC					;
SEP #$20				;
RTS					;


dl Init,Main

