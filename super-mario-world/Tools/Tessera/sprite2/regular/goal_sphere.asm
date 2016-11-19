;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Goal Point Question Sphere, by imamelia
;;
;; This is a round sprite with a "?" on it that appeared in SMW and SMB3.  It ends
;; the level when touched. 
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;; - Bit 0: 0 -> normal exit, 1 -> secret exit (does not work in vertical levels).
;; - Bit 1: 0 -> don't walk after touching the sprite, 1 -> walk.
;; - Bit 2: 0 -> play "boss defeated" music, 1 -> play normal goal music.
;; - Bit 3: 0 -> no speed or gravity, 1 -> have gravity.
;; - Bits 4-6: Sprite palette.
;; - Bit 7: Unused.
;;
;; *NOTE: The secret exit works only if the sprite is set to make the player walk
;; after touching it.  It's an annoying quirk of SMW's exit handling.  It is possible
;; to circumvent this by using the hex edit at $00C9FE and storing 01/02 to $0DD5
;; instead of 00/01 to $141C.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tilemap = $88
!TileXFlip = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		; extra byte 1
AND #$70			; bits 4-6
LSR #3				;
STA $00				;
LDA $15F6,x			;
AND #$F1			;
ORA $00				; set the sprite palette
STA $15F6,x			;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR GoalSphereMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GoalSphereMain:

JSR GoalSphereGFX	; draw the sprite

LDA $9D			; if sprites are locked...
BNE .Return		; return

LDA $7FAB40,x	;
AND #$08		;
BEQ .NoGravity	;
JSL $81802A		;
.NoGravity		;

LDA $13			; frame counter
AND #$1F		; once every 0x20 frames...
JSR ShowSparkle	; display sparkles

JSL $81A7DC		; interact with the player
BCC .Return		; return if there is no contact

STZ $14C8,x		; erase the sprite
LDA #$FF			;
STA $1493		; set the level end timer
STA $0DDA		; mark the music as "abnormal"
LDA $7FAB40,x	;
PHA				;
PHA				;
AND #$01		;
STA $141C		; store normal/secret exit info
PLA				;
AND #$02		;
BNE .Walk		;
DEC $13C6		;
.Walk			;
PLA				;
LSR #3			;
LDA #$0B			;
ADC #$00		;
STA $1DFB		; set the level end music
LDA #$01		;
STA $13CE		;

.Return			;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sparkle routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowSparkle:

ORA $186C,x		; don't show the sparkles if the sprite is offscreen vertically
BNE .Return		;

JSL $81ACF9		; get a random number

AND #$0F		;
CLC				;
LDY #$00			;
ADC #$FC		;
BPL $01			;
DEY				;
CLC				;
ADC $E4,x		;
STA $02			;
TYA				;
ADC $14E0,x		;
PHA				;
LDA $02			;
CMP $1A			;
PLA				;
SBC $1B			; if the sparkle would be offscreen...
BNE .Return		; end the sparkle routine

LDA $148E		;
AND #$0F		;
CLC				;
ADC #$FE		;
ADC $D8,x		;
STA $00			;
LDA $14D4,x		;
ADC #$00		;
STA $01			; set the Y position of the sparkle

JSL $8285BA		; create sparkles

.Return			;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GoalSphereGFX:

JSL !GetDrawInfo	;

LDA $00			;
STA $0300,y		; tile X position
LDA $01			;
STA $0301,y		; tile Y position
LDA #!Tilemap		;
STA $0302,y		; tile number
LDA $15F6,x		; palette and GFX page
ORA $64			; plus priority bits
;ORA #!TileXFlip	; X-flip the tile
STA $0303,y		; tile properties

LDY #$02			; 16x16 tile
LDA #$00		; 1 tile drawn
JSL $81B7B3		;

RTS


dl Init,Main





