;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ice Power, by mikeyk
;;
;; Description: This is a generator that allows Big Mario to shoot Ice Blasts
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        CUST_SPRITE_TO_GEN = $21    ;only used if first extra bit is set
	
	RAM_IsDucking 	= $73 
	RAM_OnYoshi	= $187A

	RAM_MarioXPos	= $94 
	RAM_MarioXPosHi	= $95 
	RAM_MarioYPos	= $96 
	RAM_MarioYPosHi	= $97

	RAM_SpriteYHi	= $14D4
	RAM_SpriteXHi	= $14E0
	RAM_SpriteYLo	= $D8
	RAM_SpriteXLo	= $E4

	RAM_MarioDir 	= $76 
	RAM_SpriteDir	= $157C 
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    dcb "INIT"              ;generators don't have an init routine
                    dcb "MAIN"                                    
                    PHB                     
                    PHK                     
                    PLB                     
                    JSR SPRITE_CODE_START   
                    PLB                     
                    RTL      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    EXTRA_BITS = $7FAB10
                    NEW_SPRITE_NUM = $7FAB9E

SPRITE_CODE_START
	LDA $7F8820		
	CMP #$0D
	BCC NoAdjust
	LDA #$00		; Initialize RAM the first time
	STA $7F8820
NoAdjust:	
	BEQ CanShoot
	DEC
	STA $7F8820
	BRA Return
CanShoot:	
	LDA $19			; Only shoot if Big Mario
	CMP #$01
	BNE Return
	LDA RAM_IsDucking
	ORA RAM_OnYoshi
	BNE Return
	BIT $16
	BVC Return
	
	JSL $02A9E4
        BMI Return
	
	LDA #$0C
	STA $7F8820

	PHX
        TYX
	
	LDA #CUST_SPRITE_TO_GEN ; Store custom sprite number
        STA NEW_SPRITE_NUM,x
        JSL $07F7D2             ; Reset sprite properties
        JSL $0187A7             ; Get table values for custom sprite
        LDA #$88                ; Mark as initialized
        STA EXTRA_BITS,x

	LDA #$08                ; store sprite status
        STA $14C8,x

	LDA RAM_MarioXPos
	STA RAM_SpriteXLo,x
	LDA RAM_MarioXPosHi
	STA RAM_SpriteXHi,x

	LDA RAM_MarioYPos
	CLC
	ADC #$08
	STA RAM_SpriteYLo,x
	LDA RAM_MarioYPosHi
	ADC #$00
	STA RAM_SpriteYHi,x
	
	LDA RAM_MarioDir
	EOR #$01
	STA RAM_SpriteDir,x
	
	PLX
	
Return:
	
	RTS




