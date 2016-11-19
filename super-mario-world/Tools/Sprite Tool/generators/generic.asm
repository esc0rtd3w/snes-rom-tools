;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite Generator, by mikeyk
;;
;; Description: This will generate a normal sprite or a custom sprite depending on the
;; first extra bit.  Specify the actual sprite that is generated below
;;
;; NOTE: Trying to generate a sprite that doesn't exist will crash your game
;;
;; Uses first extra bit: YES
;; if the first extra bit is set a custom sprite will be generated
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    SPRITE_TO_GEN = $38         ;only used if first extra bit is clear
                    CUST_SPRITE_TO_GEN = $20    ;only used if first extra bit is set

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

TBL_B2D0            dcb $F0,$FF
TBL_B2D2            dcb $FF,$00
TBL_B2D4            dcb $10,$F0

SPRITE_CODE_START   LDA $14    
                    AND #$3F
                    ORA $9D   
                    BNE RETURN
                    JSL $02A9DE
                    BMI RETURN
                    TYX        
                    
                    LDA #$01                ; store sprite status
                    STA $14C8,x
                    
                    LDA $18B9               ; check if first extra bit is set
                    AND #$40
                    BNE CUST
                    
NORMAL              LDA #SPRITE_TO_GEN      ; store sprite number
                    STA $9E,x
                    JSL $07F7D2             ; reset sprite properties
                    BRA SHARED                    
                    
CUST                LDA #CUST_SPRITE_TO_GEN ; store custom sprite number
                    STA NEW_SPRITE_NUM,x  
                    JSL $07F7D2             ; reset sprite properties
                    JSL $0187A7             ; get table values for custom sprite
                    LDA #$08                ; mark as initialized
                    STA EXTRA_BITS,x



SHARED              JSL $01ACF9
                    AND #$7F   
                    ADC #$40   
                    ADC $1C    
                    STA $D8,x  
                    LDA $1D    
                    ADC #$00   
                    STA $14D4,x
                    LDA $148E  
                    AND #$01   
                    TAY        
                    LDA TBL_B2D0,y
                    CLC        
                    ADC $1A    
                    STA $E4,x  
                    LDA $1B    
                    ADC TBL_B2D2,y
                    STA $14E0,x
                    LDA TBL_B2D4,y
                    STA $B6,x  
RETURN              RTS        
