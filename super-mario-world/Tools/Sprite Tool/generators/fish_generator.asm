;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flying fish style generator
;;
;; Description: Generates any normal or custom sprite.  The creation pattern matches
;; that of the flying fish generator from SMW.
;;
;; Uses first extra bit: YES
;; if the first extra bit is set a custom sprite will be generated
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; RAM locations
	RAM_ExtraBits 		= $7FAB10
        RAM_NewSpriteNumber	= $7FAB9E
	
	;; JSL locations
	FindFreeSlotLowPri	= $02A9DE
	InitSpriteTables	= $07F7D2
	InitCustomSpriteTables  = $0187A7
	GetRand			= $01ACF9

	;; Variables
	Frequency = $1F
	SpriteToGenerate = $17         ; Only used if first extra bit is clear
        CustomSpriteToGenerate = $20   ; Only used if first extra bit is set

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
        dcb "INIT"              ; Generators don't have an INIT routine
        dcb "MAIN"                                    
        PHB                     
        PHK                     
        PLB                     
        JSR GenerateSprite
        PLB                     
        RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02B153:        dcb $10,$18,$20,$28
DATA_02B157:        dcb $18,$1A,$1C,$1E

GenerateSprite:
	LDA $14                   
        AND #Frequency
        BNE Return02B1B7          
        JSL FindFreeSlotLowPri  
        BMI Return02B1B7          
        TYX                       

        LDA $18B9			; Check if first extra bit is set
        AND #$40
        BNE CustomSprite

NormalSprite:	
	LDA #SpriteToGenerate
        STA $9E,X              
        JSL InitSpriteTables
	BRA Shared

CustomSprite:
	LDA #CustomSpriteToGenerate 	; Store custom sprite number
        STA RAM_NewSpriteNumber,x  
        JSL InitSpriteTables           	; Reset sprite tables
        JSL InitCustomSpriteTables     	; Get table values for custom sprite
	LDA #$08                	; Mark as custom sprite
        STA RAM_ExtraBits,x		; (Must be done last, since InitSpriteTables clears this address)

Shared:
	LDA #$08			; Sprite status = Normal 
        STA $14C8,X 			
        LDA $1C                   
        CLC                       
        ADC #$C0                
        STA $D8,X                 
        LDA $1D                   
        ADC #$00                
        STA $14D4,X             
        JSL GetRand             
        CMP #$00                
        PHP                       
        PHP                       
        AND #$03                
        TAY                       
        LDA DATA_02B153,Y       
        PLP                       
        BPL ADDR_02B196           
        EOR #$FF                
ADDR_02B196:
        CLC                       
        ADC $1A                   
        STA $E4,X                 
        LDA $1B                   
        ADC #$00                
        STA $14E0,X             
        LDA $148E               
        AND #$03                
        TAY                       
        LDA DATA_02B157,Y       
        PLP                       
        BPL ADDR_02B1B1           
        EOR #$FF                
        INC A                     
ADDR_02B1B1:
        STA $B6,X                 
        LDA #$B8                
        STA $AA,X                 
Return02B1B7:
	RTS                       ; Return 
