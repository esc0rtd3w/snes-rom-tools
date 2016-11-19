;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Invisible Sprite, by imamelia
;;
;; This sprite will spawn another sprite (flying up into the air) when
;; the player touches it.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-7: Index to property tables.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm		; shared subroutine definitions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SpawnSFX = $021DFC

; Bits 0-1: High byte of the sprite number, if custom.
; Bits 2-6: Unused.
; Bit 7: Normal/custom sprite.  0 -> normal, 1 -> custom.
SpawnProperties:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite number (low byte of the sprite number if custom)
SpawnNumber:
db $75,$79,$21,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; spawned sprite status
SpawnStatus:
db $08,$08,$08,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; first extra byte of the spawned sprite
ExtraByte1:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; second extra byte of the spawned sprite
ExtraByte2:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; third extra byte of the spawned sprite
ExtraByte3:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

; fourth extra byte of the spawned sprite
ExtraByte4:
db $00,$00,$00,$00,$00,$00,$00,$00	; values 00-07
db $00,$00,$00,$00,$00,$00,$00,$00	; values 08-0F
;db $00,$00,$00,$00,$00,$00,$00,$00	; values 10-17

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x		;
TAY					;
LDA SpawnProperties,y	;
STA $1510,x			;
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR InvisibleSpriteMain
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:				;
RTS					;

InvisibleSpriteMain:

JSL !GetDrawInfo		; I'm not sure why exactly this is here...offscreen stuff maybe?
JSL $81A7DC			; check contact with the player
BCC Return			; if there is none, return

JSL $82A9E4			;
BMI Return			;

LDA $1510,x			;
STA $08				;
LDA $7FAB40,x		;
STA $09				;
PHY					;
TAX					;
LDA.w SpawnStatus,x	;
STA $14C8,y			;

LDA $08				; check the property byte
BMI .SpawnCustom		; if bit 7 is set, spawn a custom sprite

LDA.w SpawnNumber,x	;
STA $009E,y			; second extra byte into sprite number
PHX					;
TYX					;
JSL $87F7D2			; normal sprite initialization routine
PLX					;
BRA .Shared			;

.SpawnCustom			;

LDA.w SpawnNumber,x	;
PHX					;
TYX					;
STA $7FAB9E,x		;
LDA $08				;
AND #$83			; lowest two bits of second extra byte into custom sprite number
STA $7FAB10,x		; (also with bit 7 set)
PHY					;
JSL $81830B			; custom sprite initialization routine
LDY $09				;
LDA ExtraByte1,y		;
STA $7FAB40,x		;
LDA ExtraByte2,y		;
STA $7FAB4C,x		;
LDA ExtraByte3,y		;
STA $7FAB58,x		;
LDA ExtraByte4,y		;
STA $7FAB64,x		;
PLY					;
PLX					;

.Shared				;

PLY					;

LDA #$20			;
STA $154C,y			; interaction disable timer

LDX $15E9			;
LDA $D8,x			;
SEC					;
SBC #$0F				; shift the sprite up 15 pixels
STA $00D8,y			;
LDA $14D4,x			;
SBC #$00				;
STA $14D4,y			;

LDA $E4,x			;
STA $00E4,y			;
LDA $14E0,x			;
STA $14E0,y			;

LDA #$00			;
LDX $7B				;
BPL $01				; set the sprite direction depending on the player's X speed
INC					;
STA $157C,y			;

LDA #$C0			;
STA $00AA,y			; set the sprite's Y speed

LDA.b #!SpawnSFX>>16	;
STA.w !SpawnSFX		;

LDX $15E9			;
STZ $14C8,x			;

RTS					;


dl Init,Main

