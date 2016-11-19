;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Message Box, by Sonikku and imamelia
;;
;; This sprite acts like the message box, or Info Box,  in SMW (sprite B9), but you can
;; customize which message from which level to play, or you can make it display a VWF
;; message from RPG Hacker's patch.  Setting the level number for the regular message
;; to #$60 or higher or the VWF message number to #$2AAA or higher will prevent the
;; sprite from displaying a message at all.
;;
;; Extra bytes: 1 or 2
;;
;; Extra byte 1:
;;
;; Bits 0-6: Level number from which to display a message.
;; Bit 7: Message number to display (1 or 2).
;; -or-
;; Bits 0-7: Low byte of VWF message number.
;;
;; Extra byte 2:
;;
;; Bits 0-5: High byte of VWF message number.
;; Bits 6-7: Unused.
;;
;; Extra property bytes:
;;
;; If bit 0 of the extra property byte 1 is clear, the sprite will use the original
;; message system and one extra byte.  If bit 0 of the extra property byte 1 is set,
;; the sprite wiill use the VWF message system and two extra bytes.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Here's the stuff you are able to edit without too much 
; knowledge of ASM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!VWFState = $702000

!TILE	= $C0

YPOS:
db $00,$04,$07,$08,$08,$07,$04,$00,$00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    Main:             
                    PHB
                    PHK
                    PLB
                    JSR SPRITE_ROUTINE
                    PLB
		    Init:
                    RTL     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE:	JSL $81B44F ; Load invisible solid block routine.
	JSL !SubOffscreenX3
	JSL !GetDrawInfo
	LDA $1558,x	; If timer for sprite..
	CMP #$01	; isn't 1..
	BNE CODE_038D93 ; Set Y position.
	LDA #$22	; Play Sound.
	STA $1DFC	; Store it.
	STZ $1558,x	; Restore timer.
	STZ $C2,x	; Make it so it can be hit again.
	JSR DisplayMessage
CODE_038D93:
	LDA $1558,x	; I just took this code out of all.log.
	LSR		; I didn't bother commenting it..
	TAY		; Since I don't really have the patience to.
	LDA $1C		; This code wasn't really documented..
	PHA		; In all.log to begin with..
	CLC		; So I only know this code sets the Y position..
	ADC YPOS,y	; Of the tile..
	STA $1C		; When Mario hits this sprite..
	LDA $1D		; from the bottom..
	PHA		; ..
	ADC #$00	; ..
	STA $1D		; ..
	JSL $8190B2	; Load generic graphics routine.
	LDY $15EA,x	; Load sprite OAM.
	LDA #!TILE	; Load tile number..
	STA $0302,y	; And store it.
	PLA		; Pull A.
	STA $1D		; Store to Layer 1 Y position (High byte).
	PLA		; Pull A.
	STA $1C		; And store to Layer 1 Y position (Low byte).
	RTS		; Return.
	
DisplayMessage:

LDA $7FAB28,x
LSR
BCS .DisplayVWF

LDA $7FAB40,x
AND #$7F
CMP #$60
BCS .Return
STA $13BF
LDA $7FAB40,x
ROL
ROL
AND #$01
INC
STA $1426

.Return
SEP #$20
RTS

.DisplayVWF

LDA $7FAB40,x
XBA
LDA $7FAB4C,x
REP #$20
AND #$3FFF
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
