;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Exploding Block, by imamelia
;;
;; This is an exploding block that can spawn any normal or custom sprite depending
;; on the extra bytes.
;;
;; Number of extra bytes: 1
;;
;; The extra byte is used to index tables that indicate the sprite number to spawn,
;; whether it is a normal sprite or a custom one, and, if the custom sprite has any
;; extra bytes, what they should be.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tilemap = $40

SprSettings1:
db $10,$06,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; Bits 0-1 - high byte of custom sprite number (extra bits)
; Bits 2-3 - index to sprite status table
; Bit 4 - don't set Y speed when spawning
; Bit 5 - don't set direction when spawning
; Bit 6 - unused
; Bit 7 - normal/custom sprite (0 -> normal, 1 -> custom)
SprSettings2:
db $85,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

ExtraByte1:
db $02,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

ExtraByte2:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

ExtraByte3:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

ExtraByte4:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

SprStatus:
db $08,$01,$09,$0A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
JSR InitExplodingBlock
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitExplodingBlock:

LDA $7FAB40,x		;
TAY					;
LDA SprSettings1,y		;
STA $C2,x			; $C2,x = sprite number/low byte of custom sprite number
LDA SprSettings2,y		;
STA $1504,x			; $1504,x = settings of the spawned sprite
LSR					;
LSR					;
AND #$03			;
TAY					;
LDA SprStatus,y		;
STA $1510,x			; $1510,x = status of the spawned sprite
LDA ExtraByte1,y		;
STA $151C,x			; $151C,x = first extra byte of the spawned sprite (if there is one)
LDA ExtraByte2,y		;
STA $1528,x			; $1528,x = second extra byte of the spawned sprite (if there is one)
LDA ExtraByte3,y		;
STA $1534,x			; $1534,x = second extra byte of the spawned sprite (if there is one)
LDA ExtraByte4,y		;
STA $1594,x			; $1594,x = second extra byte of the spawned sprite (if there is one)
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR ExplodingBlockMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExplodingBlockMain:

JSR ExplodingBlockGFX

LDA $9D			; return if sprites are locked
BNE ReturnMain	;
;BRA $04			;
;JSL $02C0CF		; unused code in the original SMW

LDY #$00			;
INC $1570,x		; frame counter for this sprite
LDA $1570,x		;
AND #$40		; if bit 6 of the frame counter is clear...
BEQ .SetXSpeed	; keep the sprite X speed at 0

LDY #$04			; otherwise,
LDA $1570,x		;
AND #$04		; use bit 2 of the frame counter to determine
BEQ .SetXSpeed	; whether to set the sprite's X speed to 04 or FC
LDY #$FC			;

.SetXSpeed		;
STY $B6,x		;

JSL $818022		; update sprite X position without gravity
JSL $81803A		; interact with the player and with other sprites
JSL !SubHorizPos	; get the horizontal distance between the player and the sprite

LDA $0F			;
CLC				;
ADC #$60		;
CMP #$C0		; if the player is 60 or more pixels away from the sprite on either side...
BCS ReturnMain	;
LDY $15A0,x		; or the sprite is offscreen...
BNE ReturnMain	; then the sprite will not shatter

JSR ShatterSprite	; subroutine for shattering the block and spawning the sprite

ReturnMain:		;
RTS				;

ShatterSprite:		;

LDA $1510,x		;
STA $14C8,x		;

LDY $C2,x		;
LDA $1504,x		;
PHA				;
BMI .SpawnCust	; spawn a custom sprite if bit 7 of second settings byte is set

.SpawnNorm		;
STY $9E,x		; set the sprite number
JSL $87F7D2		; re-initialize the sprite tables
BRA .Shared		;

.SpawnCust		;
AND #$03		;
ORA #$80		;
STA $7FAB10,x	;
TYA				;
STA $7FAB9E,x	;
LDA $151C,x		;
PHA				;
LDA $1528,x		;
PHA				;
LDA $1534,x		;
PHA				;
LDA $1594,x		;
PHA				;
JSL $81830B		;
PLA				;
STA $7FAB64,x	;
PLA				;
STA $7FAB58,x	;
PLA				;
STA $7FAB4C,x	;
PLA				;
STA $7FAB40,x	;

.Shared			;

PLA				;
STA $00			;
AND #$10		;
BNE .NoYSpeed	;

LDA #$D0		;
STA $AA,x		; set the Y speed of the new sprite

.NoYSpeed		;
LDA $00			;
AND #$20		;
BNE .NoSetDir		;

JSL !SubHorizPos	;
TYA				;
STA $157C,x		; make the new sprite face the player

.NoSetDir			;

LDA $E4,x		;
STA $9A			; set up the position for the shattering effect
LDA $14E0,x		;
STA $9B			;
LDA $D8,x		;
STA $98			;
LDA $14D4,x		;
STA $99			; X position low, X position high, Y position low, Y position high

PHB				;
LDA #$82		; change the data bank to 02
PHA				;
PLB				;
LDA #$00		; normal shatter, not rainbow
JSL $828663		; shattering effect subroutine
PLB				;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExplodingBlockGFX:

JSL !GetDrawInfo

LDA $00			;
STA $0300,y		; tile X position
LDA $01			;
STA $0301,y		; tile Y position
LDA #!Tilemap		;
STA $0302,y		; tile number
LDA $15F6,x		; palette and GFX page
ORA $64			; plus priority bits
STA $0303,y		; tile properties

LDY #$02			; 16x16 tile
LDA #$00		; 1 tile drawn
JSL $81B7B3		;

RTS


dl Init,Main








