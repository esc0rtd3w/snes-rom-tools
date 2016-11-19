;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Colored Key, by imamelia
;;
;; This sprite creates a key of the specified color for use with colored locked doors.
;;
;; Extra bytes: 1
;;
;; Extra byte 1:
;;
;; Bits 0-2: Sprite palette.
;; Bits 3-6: Unused.
;; Bit 7: Affect item memory.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA #$09
STA $14C8,x
LDA #$80
STA $9E,x
LDA #$00
STA $7FAB10,x

JSL $87F7D2

LDA $166E,x
AND #$F1
STA $00
LDA $7FAB40,x
AND #$07
ASL
ORA $00
STA $166E,x
AND #$0F
STA $15F6,x

LDA $7FAB40,x
BPL .Return

LDA $E4,x
STA $7FAD00,x
LDA $D8,x
STA $7FAD0C,x
LDA $14E0,x
STA $7FAD18,x
LDA $14D4,x
STA $7FAD24,x

JSR GetItemMemoryBit
BEQ .Return
STZ $14C8,x
.Return

Main:
RTL

;------------------------------------------------
; item memory subroutines (for sprites; adapted from the object version at $0DA8DC)
;------------------------------------------------

GetItemMemoryBit:

PHX					;
PHY					;

JSR ItemMemoryIndexRt	;

LDA ($08),y			; item memory pointer
AND $818000,x		; check a particular bit
STA $0F				;

PLY					;
PLX					;
LDA $0F				;
RTS					;


ItemMemoryIndexRt:

LDA $5B				;
LSR					;
BCS .VertLevelSetup		;

LDA $E4,x			;
STA $0A				;
LDA $D8,x			;
STA $0B				;
LDA $14E0,x			;
STA $0C				;
LDA $14D4,x			;
STA $0D				;
BRA .Continue			;

.VertLevelSetup		;
LDA $D8,x			;
STA $0A				;
LDA $E4,x			;
STA $0B				;
LDA $14D4,x			;
STA $0C				;
LDA $14E0,x			;
STA $0D				;

.Continue				;

LDX $13BE			; item memory setting
LDA #$F8				; base address low byte
CLC					;
ADC $0DA8AE,x		; plus offset
STA $08				;
LDA #$19			; base address high byte
ADC $0DA8B1,x		; plus offset
STA $09				; forms a 16-bit pointer

LDA $0C				; screen number (high byte of X position, or Y in vertical levels)
ASL #2				;
STA $0E				;
LDA $0D				;
BEQ .UpperSubscreen	; if the sprite is on the lower subscreen...
LDA $0E				;
ORA #$02			;
STA $0E				;
.UpperSubscreen		;
LDA $0A				;
AND #$80			; if the sprite is on the left half of the subscreen...
BEQ .LeftHalf			;
LDA $0E				;
ORA #$01			;
STA $0E				;
.LeftHalf				;
LDA $0A				;
LSR #4				;
AND #$07			;
TAX					; get the bit index into the table
LDY $0E				; get the byte index
RTS					;

dl Init,Main
