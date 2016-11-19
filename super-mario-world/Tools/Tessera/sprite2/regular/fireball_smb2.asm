;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMB2-style Fireball, by imamelia
;;
;; This is a simple fireball sprite with a 3-frame animation.
;;
;; Extra bytes: 0
;;
;; Because it is meant to be spawned, it does not use the extra bytes;
;; however, $C2,x is used for a couple of things.
;; - Bit 0 indicates whether or not the sprite has gravity.  If bit 0 is set, then the
;; sprite has gravity; if not, then it doesn't.
;; - Bit 1 indicates whether or not the sprite's X speed has already been set in the
;; spawning routine.  If bit 1 is set, then the X speed has been set and will not be set
;; again.  If bit 1 is clear, then the sprite's init routine will set its speed automatically.
;; - Bit 2 indicates the size of the sprite.  If bit 2 is clear, then the sprite will be 16x16.
;; If bit 2 is set, then the sprite will be 32x32.  This, of course, changes its tilemap
;; and interaction field as well.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!NumberOfFrames = $03	; the number of different animation frames the sprite has
!AnimationSpeed = $07	; the speed at which it animates (00 [fastest], 01, 03, 07, 0F, 1F, 3F, 7F, or FF [fastest])

Tilemap16:			; tilemap for the 16x16 fireball
db $EA,$EC,$EE		; first frame, second frame, third frame

Tilemap32:			; tilemap for the 32x32 fireball
db $00,$02,$02,$00	; first frame
db $20,$22,$22,$20	; second frame
db $40,$42,$42,$40	; third frame

XDisp:				; X displacement for the tiles of the 32x32 fireball
db $00,$10,$00,$10	;

YDisp:				; Y displacement for the tiles of the 32x32 fireball
db $00,$00,$10,$10	;

TileProps:			; X- and Y-flip for the tiles of the 32x32 fireball
db $00,$00,$C0,$C0	;

!InitXSpeed = $20		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $C2,x			;
AND #$04			;
BEQ .NoChangeSize		;
LDA #$0E				;
STA $1662,x			;
.NoChangeSize		;
LDA $C2,x			;
AND #$02			;
BNE .NoSetSpeed		;
LDA #!InitXSpeed		;
LDY $157C,x			;
BEQ $03				;
EOR #$FF				;
INC					;
STA $B6,x			;
.NoSetSpeed			;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR FireballMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireballMain:

JSR FireballGFX			; draw it

LDA $14C8,x			;
CMP #$08			; if the sprite is not in normal status...
BNE Return00			;
LDA $9D				; or if sprites are locked...
BNE Return00			; return

JSL !SubOffscreenX0	; offscreen handling code
JSR GenericAnimationRt	; make the sprite animate
JSL $81A7DC			;

LDA $C2,x			;
AND #$01			;
BEQ .NoGravity		;

JSL $81802A			;
RTS					;

.NoGravity			;
JSL $81801A			;
JSL $818022			;

Return00:			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireballGFX:

JSL !GetDrawInfo	;

LDA $15F6,x		;
ORA $64			;
STA $03			;

LDA $C2,x		;
AND #$04		;
BNE GFX32		;

LDA $00			;
STA $0300,y		;
LDA $01			;
STA $0301,y		;
LDA $1602,x		;
TAX				;
LDA.w Tilemap16,x	;
STA $0302,y		;
LDA $03			;
STA $0303,y		;

LDX $15E9		;
LDY #$02			;
LDA #$00		;
JSL $81B7B3		;
RTS				;

GFX32:			;

LDA #$03		;
STA $04			;
LDA $1602,x		;
ASL #2			;
ORA #$03		;
STA $05			;

.Loop			;

LDX $04			;
LDA $00			;
CLC				;
ADC.w XDisp,x	;
STA $0300,y		;
LDA $01			;
CLC				;
ADC.w YDisp,x	;
STA $0301,y		;

LDX $05			;
LDA.w Tilemap32,x	;
STA $0302,y		;
LDX $04			;
LDA $03			;
ORA.w TileProps,x	;
STA $0303,y		;

INY #4			;
DEC $05			;
DEC $04			;
BPL .Loop			;

LDX $15E9		;
LDY #$02			;
LDA #$03		;
JSL $81B7B3		;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; miscellaneous subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GenericAnimationRt:

INC $1570,x			; increment this sprite's frame counter
LDA $1570,x			;
AND #!AnimationSpeed	; if necessary...
BNE NoIncFrame		;
INC $1602,x			; change the animation frame
LDA $1602,x			;
CMP #!NumberOfFrames	; if the animation frame has reached maximum...
BCC NoIncFrame		;
STZ $1602,x			; reset it to 00 (because frame 00 also counts)
NoIncFrame:			;
RTS					;


dl Init,Main

