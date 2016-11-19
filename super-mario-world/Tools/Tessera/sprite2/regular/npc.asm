;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; NPC, by imamelia
;;
;; This is a sprite that cannot be harmed by anything, that can be made to walk back
;; and forth, and that can display a message when the player "talks" to it.  Setting the
;; level number for the regular message to #$60 or higher or the VWF message number
;; to #$2AAA or higher will prevent the sprite from displaying a message at all.
;;
;; Extra bytes: 2 or 3
;;
;; Extra byte 1:
;;
;; Bits 0-2: Tilemap and clipping index.
;; Bits 3-7: Walking distance.  If this is 0, then the sprite will be stationary and always face the player.
;;
;; Extra byte 2:
;;
;; Bits 0-6: Level number from which to display a message.
;; Bit 7: Message number to display (1 or 2).
;; -or-
;; Bits 0-7: Low byte of VWF message number.
;;
;; Extra byte 3:
;;
;; Bits 0-5: High byte of VWF message number.
;; Bits 6-7: Unused.
;;
;; Extra property bytes:
;;
;; If bit 0 of the extra property byte 1 is clear, the sprite will use the original
;; message system and two extra bytes.  If bit 0 of the extra property byte 1 is set,
;; the sprite wiill use the VWF message system and three extra bytes.
;;
;; Relevant sprite tables:
;;
;; $151C,x - turn flag
;; $1528,x - initial X position low byte
;; $1534,x - initial X position high byte
;; $1570,x - frame counter
;; $157C,x - direction
;; $1602,x - animation frame and tilemap index
;; $187B,x - walk boundary
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!VWFState = $702000

WalkingSpeed:
db $0A,$F6

HorizDisp1A:
HorizDisp1B:
HorizDisp1C:
HorizDisp1D:
db $00,$00
VertDisp1A:
VertDisp1B:
VertDisp1C:
VertDisp1D:
db $F0,$00
Tilemap1A:
Tilemap1B:
db $44,$64
Tilemap1C:
Tilemap1D:
db $46,$66
TileProps1A:
TileProps1C:
db $4F,$4F
TileProps1B:
TileProps1D:
db $0F,$0F
TileSize1A:
TileSize1B:
TileSize1C:
TileSize1D:
db $02,$02

HorizDisp2A:
HorizDisp2B:
HorizDisp2C:
HorizDisp2D:
VertDisp2A:
VertDisp2B:
VertDisp2C:
VertDisp2D:
Tilemap2A:
Tilemap2B:
Tilemap2C:
Tilemap2D:
TileProps2A:
TileProps2B:
TileProps2C:
TileProps2D:
TileSize2A:
TileSize2B:
TileSize2C:
TileSize2D:

; X displacement, Y displacement, width, height
ClippingTbl:
db $00,$F0,$14,$20		; index 0 (facing right)
db $FC,$F0,$14,$20		; index 0 (facing left)
db $04,$F0,$24,$20		; index 1 (facing right)
db $E8,$F0,$24,$20		; index 1 (facing left)
db $00,$00,$00,$00		; index 2 (facing right)
db $00,$00,$00,$00		; index 2 (facing left)
db $00,$00,$00,$00		; index 3 (facing right)
db $00,$00,$00,$00		; index 3 (facing left)
db $00,$00,$00,$00		; index 4 (facing right)
db $00,$00,$00,$00		; index 4 (facing left)
db $00,$00,$00,$00		; index 5 (facing right)
db $00,$00,$00,$00		; index 5 (facing left)
db $00,$00,$00,$00		; index 6 (facing right)
db $00,$00,$00,$00		; index 6 (facing left)
db $00,$00,$00,$00		; index 7 (facing right)
db $00,$00,$00,$00		; index 7 (facing left)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x	;
PHA				;
AND #$07		;
ASL #2			;
STA $1602,x		;
PLA				;
AND #$F8		;
STA $187B,x		;

JSL !SubHorizPos	;
TYA				;
STA $157C,x		;

LDA $E4,x		;
STA $1528,x		;
LDA $14E0,x		;
STA $1534,x		;

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR NPCMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NPCMain:

PEA.w .PastGFX-$01	; push the real return address
JSL !GenericSprGFX		; shared GFX routine

dw HorizDisp1A,VertDisp1A,Tilemap1A,TileProps1A,TileSize1A : db $01	; tilemap 1, frame 1 (facing right)
dw HorizDisp1B,VertDisp1B,Tilemap1B,TileProps1B,TileSize1B : db $01	; tilemap 1, frame 1 (facing left)
dw HorizDisp1C,VertDisp1C,Tilemap1C,TileProps1C,TileSize1C : db $01	; tilemap 1, frame 2 (facing right)
dw HorizDisp1D,VertDisp1D,Tilemap1D,TileProps1D,TileSize1D : db $01	; tilemap 1, frame 2 (facing left)
dw HorizDisp2A,VertDisp2A,Tilemap2A,TileProps2A,TileSize2A : db $01	; tilemap 2, frame 1 (facing right)
dw HorizDisp2B,VertDisp2B,Tilemap2B,TileProps2B,TileSize2B : db $01	; tilemap 2, frame 1 (facing left)
dw HorizDisp2C,VertDisp2C,Tilemap2C,TileProps2C,TileSize2C : db $01	; tilemap 2, frame 2 (facing right)
dw HorizDisp2D,VertDisp2D,Tilemap2D,TileProps2D,TileSize2D : db $01	; tilemap 2, frame 2 (facing left)
;dw HorizDisp3A,VertDisp3A,Tilemap3A,TileProps3A,TileSize3A : db $01	; tilemap 3, frame 1 (facing right)
;dw HorizDisp3B,VertDisp3B,Tilemap3B,TileProps3B,TileSize3B : db $01	; tilemap 3, frame 1 (facing left)
;dw HorizDisp3C,VertDisp3C,Tilemap3C,TileProps3C,TileSize3C : db $01	; tilemap 3, frame 2 (facing right)
;dw HorizDisp3D,VertDisp3D,Tilemap3D,TileProps3D,TileSize3D : db $01	; tilemap 3, frame 2 (facing left)
;...
;dw HorizDisp8A,VertDisp8A,Tilemap8A,TileProps8A,TileSize8A : db $01	; tilemap 8, frame 1 (facing right)
;dw HorizDisp8B,VertDisp8B,Tilemap8B,TileProps8B,TileSize8B : db $01	; tilemap 8, frame 1 (facing left)
;dw HorizDisp8C,VertDisp8C,Tilemap8C,TileProps8C,TileSize8C : db $01	; tilemap 8, frame 2 (facing right)
;dw HorizDisp8D,VertDisp8D,Tilemap8D,TileProps8D,TileSize8D : db $01	; tilemap 8, frame 2 (facing left)

.PastGFX

LDA $14C8,x			;
CMP #$08			; return if the sprite is not in normal status
BNE ReturnMain		;
LDA $9D				;
BNE ReturnMain		;

JSL !SubOffscreenX0	; offscreen processing code

INC $1570,x			;
LDA $1602,x			;
AND #$FC			;
STA $00				;
LDA $1570,x			;
LSR #2				;
AND #$02			;
ORA $157C,x			;
ORA $00				;
STA $1602,x			;

LDA $187B,x			;
BEQ .SkipSpeed		;

LDY $157C,x			;
LDA WalkingSpeed,y	;
STA $B6,x			;

JSL $81802A			; update the sprite position

LDA $1588,x			;
AND #$03			; if the sprite is touching a wall...
BEQ .NoWallContact		;
JSR SetSpriteTurning	; make it turn around
.NoWallContact		;

JSR StayOnLedges		;

LDA $1588,x			;
AND #$04			; if the sprite is on the ground...
BEQ .NotOnGround		;
STZ $AA,x			; clear the Y speed
STZ $151C,x			; and the turning flag
.NotOnGround			;
JSR CheckBoundary		;
BRA .NoFace			;

.SkipSpeed			;
JSL !SubHorizPos		;
TYA					;
STA $157C,x			;
LDA $1602,x			;
AND #$FD			;
STA $1602,x			;

.NoFace				;

JSL $83B664			;
JSR SetSpriteClipping	;
JSL $83B72B			; check for contact between the player and the sprite
BCC ReturnMain		; return if there is none
INC $13CC
LDA $16				;
AND #$08			;
BEQ ReturnMain		;
JSR DisplayMessage		;

ReturnMain:			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
; routine for checking whether the sprite has reached a boundary or not
;------------------------------------------------

CheckBoundary:

LDA $1528,x			;
STA $0A				;
LDA $1534,x			;
STA $0B				;
LDA $187B,x			;
STA $0C				;
STZ $0D				;
LDA $14E0,x			;
XBA					;
LDA $E4,x			;
REP #$20				;
SEC					;
SBC $0A				;
BPL $04				;
EOR #$FFFF			;
INC					;
CMP $0C				;
SEP #$20				;
BCC .Return			;
JSR SetSpriteTurning	;
.Return				;
RTS					;

;------------------------------------------------
; routine for staying on ledges
;------------------------------------------------

StayOnLedges:

LDA $1588,x			; unless the sprite is touching an object...
ORA $151C,x			; or already turning...
BNE .Return			;
JSR SetSpriteTurning	; make the sprite turn around
LDA #$01			;
STA $151C,x			; set the turning flag
.Return				;
RTS					;

;------------------------------------------------
; turning set routine
;------------------------------------------------

SetSpriteTurning:

LDA #$08			;
STA $15AC,x			;
LDA $157C,x			;
EOR #$01				;
STA $157C,x			;
RTS					;

;------------------------------------------------
; set up the sprite's clipping field
;------------------------------------------------

SetSpriteClipping:		; custom sprite clipping routine, based off $03B69F

LDA $1602,x			;
AND #$FC			;
STA $14B0			;
LDA $1602,x			;
AND #$01			;
ASL					;
ORA $14B0			;
ASL					;
TAY					;
STZ $0F				;
LDA ClippingTbl,y		;
BPL $02				;
DEC $0F				;
CLC					;
ADC $E4,x			;
STA $04				; $04 = sprite X position low byte + X displacement value
LDA $14E0,x			;
ADC $0F				;
STA $0A				; $0A = sprite X position high byte + X displacement high byte (00 or FF)
LDA ClippingTbl+2,y	;
STA $06				; $06 = sprite clipping width
STZ $0F				;
LDA ClippingTbl+1,y	;
BPL $02				;
DEC $0F				;
CLC					;
ADC $D8,x			;
STA $05				; $05 = sprite Y position low byte + Y displacement value
LDA $14D4,x			;
ADC $0F				;
STA $0B				; $0B = sprite Y position high byte + Y displacement high byte (00 or FF)
LDA ClippingTbl+3,y	;
STA $07				; $07 = sprite clipping height
RTS					;

;------------------------------------------------
; message display routine
;------------------------------------------------

DisplayMessage:

LDA $7FAB28,x
AND #$01
BNE .DisplayVWF

LDA $7FAB4C,x
AND #$7F
CMP #$60
BCS .Return
STA $13BF
LDA $7FAB4C,x
ROL
ROL
AND #$01
INC
STA $1426

.Return
SEP #$20
RTS

.DisplayVWF

LDA $7FAB4C,x
XBA
LDA $7FAB58,x
REP #$20
;AND #$3FFF
CMP #$2AAA
BCS .Return
STA !VWFState+1
SEP #$20
LDA !VWFState
BNE .Return
LDA #$01
STA !VWFState

RTS


dl Init,Main











