;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Yoku Block, by imamelia
;;
;; Remember those disappearing blocks that appeared in most of the games in the
;; original Mega Man series? Well, now they're in SMW.  This sprite will be invisible
;; at first, and at a certain frame, it will appear.  It will then stay solid for a while,
;; then disappear again.
;;
;; Number of extra bytes: 2
;;
;; Extra byte 1:
;;
;; Bits 0-2: Tilemap index.  This lets you select one of 8 possible tiles for the sprite to use.
;; Bits 3-7: These indicate the frame number on which the sprite will first appear.
;;
;; Extra byte 2:
;;
;; Bits 0-3: These bits indicate how long the sprite will stay solid once it has appeared.
;;	Multiply this by 16 (0x10) to get the number of frames.
;; Bits 4-7: These bits indicate how long the sprite will stay invisible once it has disappeared.
;;	Multiply this by 16 (0x10) to get the number of frames.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SFX1 = $2B		; This is the sound effect in $1DF9 that will play when the block appears.
!SFX2 = $35		; This is the sound effect in $1DFC that will play when the block appears.

; These two tables determine which tile the sprite will use and what its properties will be.
; They are indexed by the lowest 3 bits of the first extra byte.
Tilemap:
db $40,$00,$00,$00,$00,$00,$00,$00
TileProps:
db $30,$30,$30,$30,$30,$30,$30,$30

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x	; first extra byte
AND #$F8		; upper 5 bits
STA $1570,x		; frame to appear
LDA $7FAB40,x	; first extra byte
AND #$07		; lower 3 bits
STA $1602,x		; tilemap index

LDA $7FAB4C,x	;
AND #$0F		; lower 4 bits
ASL #4			; x10
STA $151C,x		; $151C,x - time to stay solid
LDA $7FAB4C,x	;
AND #$F0		; upper 4 bits
STA $1534,x		; $1534,x - time to stay invisible

LDA #$04		;
STA $C2,x		;

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR YokuBlockMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YokuBlockMain:

LDA $14C8,x			;
CMP #$08			; return if the sprite is not in normal status
BNE .Return			;

JSL !SubOffscreenX0	; offscreen processing code

LDA $1504,x			;
BEQ .NoDec			;
DEC $1504,x			;
.NoDec				;

LDA $C2,x			;
JSL $8086DF			;

dw S00_Invisible		; state 00 - invisible
dw S01_Appearing		; state 01 - appearing
dw S02_Solid			; state 02 - solid
dw S03_Disappearing	; state 03 - disappearing
dw S04_InvisibleInit	; state 04 - invisible at start

.Return				;
RTS					; more organized, at the expense of one useless byte


S00_Invisible:			;

LDA $1504,x			;
BNE .NoAppear		; if the state-change timer is down to 0, then the sprite will appear
INC $C2,x			;
.NoAppear			;
RTS					;

S01_Appearing:		;

LDA #!SFX1			; sound effect to play (1)
BEQ $03				;
STA $1DF9			;
LDA #!SFX2			; sound effect to play (2)
BEQ $03				;
STA $1DFC			;
LDA $151C,x			;
STA $1504,x			; set the time to remain solid
INC $C2,x			; set the sprite state to 01
RTS					;

S02_Solid:			;

LDA $1504,x			;
BNE .NoDisappear		; if the state-change timer is down to 0, then the sprite will disappear
INC $C2,x			;
.NoDisappear			;
JSR SubGFX			; draw the sprite
JSL $81B44F			; make the sprite act like a solid block
RTS					;

S03_Disappearing:		;

LDA $1534,x			;
STA $1504,x			; set the time to remain invisible
STZ $C2,x			; reset the sprite state to 00
RTS					;

S04_InvisibleInit:		;

LDA $13				;
CMP $1570,x			; if the frame counter equals the frame on which the sprite is supposed to appear...
BNE .Return			;
LDA #$01			;
STA $C2,x			;
.Return				;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGFX:

JSL !GetDrawInfo	; set up some variables

PHX				;
LDA $1602,x		;
TAX				;
LDA $00			;
STA $0300,y		; tile X position
LDA $01			;
STA $0301,y		; tile Y position
LDA.w Tilemap,x	;
STA $0302,y		; tile to use
LDA.w TileProps,x	;
STA $0303,y		; tile properties
PLX				;

LDY #$02			; the tile was 16x16
LDA #$00		; there was only one tile
JSL $81B7B3		; "fix" the write to OAM
RTS				;


dl Init,Main

