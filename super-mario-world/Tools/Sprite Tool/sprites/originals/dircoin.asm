;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Directional Coin, adapted by mikeyk
;;
;; Description: 
;;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
                    PLUE_POW_TIMER = $14AD                                              

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    RTL
      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "MAIN"                                    
                    PHB                     
                    PHK                     
                    PLB                     
                    JSR SPRITE_CODE_START   
                    PLB                     
                    RTL                     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TBL_E1F9            dcb $00,$00,$F0,$10
TBL_E1FD            dcb $F0,$10,$00,$00
TBL_E201            dcb $00,$03,$02,$00,$01,$03,$02,$00,$00,$03,$02,$00,$00,$00,$00,$00
TBL_E211            dcb $01,$00,$03,$02

SPRITE_CODE_START   LDA $64    
                    PHA        
                    LDA $1540,x            ;check if coming out of block
                    CMP #$30   
                    BCC NO_SET_PRIORITY
                    LDA #$10   
                    STA $64    
NO_SET_PRIORITY
                    LDA $1C    
                    PHA        
                    CLC        
                    ADC #$01   
                    STA $1C    
                    LDA $1D    
                    PHA        
                    ADC #$00   
                    STA $1D    
                    LDA PLUE_POW_TIMER
                    BNE BLUE_POW_SET
                    JSL $01C641
                    BRA NO_BLUE_POW

BLUE_POW_SET        JSL $0190B2
                    LDY $15EA,x
                    LDA #$2E   
                    STA $0302,y
                    LDA $0303,y
                    AND #$3F   
                    STA $0303,y

NO_BLUE_POW
                    PLA    
                    STA $1D
                    PLA    
                    STA $1C
                    PLA    
                    STA $64

                    LDA $9D    
                    BNE NO_GEN_TILE
                    LDA $13
                    AND #$03
                    BNE LABEL02
                    DEC $190C
                    BNE LABEL02
SUB_E271            STZ $190C  
                    STZ $14C8,x
                    LDA $14AD  
                    ORA $14AE  
                    BNE RETURN01
                    LDA $0DDA
                    BMI RETURN01
                    STA $1DFB  
RETURN01            RTS        

LABEL02             LDY $C2,x  
                    LDA TBL_E1F9,y
                    STA $B6,x  
                    LDA TBL_E1FD,y
                    STA $AA,x  
                    JSR SUB_D294  
                    JSR SUB_D288  
                    LDA $15    
                    AND #$0F   
                    BEQ LABEL03
                    TAY
                    LDA TBL_E201,y
                    TAY
                    LDA TBL_E211,y
                    CMP $C2,x  
                    BEQ LABEL03
                    TYA
                    STA $151C,x
LABEL03
                    LDA $D8,x  
                    AND #$0F   
                    STA $00    
                    LDA $E4,x  
                    AND #$0F   
                    ORA $00    
                    BNE NO_GEN_TILE

                    LDA $151C,x
                    STA $C2,x  
                    LDA $E4,x  
                    STA $9A    
                    LDA $14E0,x
                    STA $9B    
                    LDA $D8,x  
                    STA $98    
                    LDA $14D4,x
                    STA $99    
                    LDA #$06   
                    STA $9C    
                    JSL $00BEB0            ;generate tile
RETURN08            RTS

NO_GEN_TILE         JSL $019138
                    LDA $B6,x  
                    BNE LABEL04
                    LDA $18D7  
                    BNE LABEL05
                    LDA $185F  
                    CMP #$25         
                    BNE LABEL05
                    RTS              
LABEL04
                    LDA $1862  
                    BNE LABEL05
                    LDA $1860  
                    CMP #$25            
                    BEQ RETURN06
LABEL05
                    JSR SUB_E271
RETURN06            RTS                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; D288
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_D288            TXA      
                    CLC      
                    ADC #$0C 
                    TAX      
                    JSR SUB_D294
                    LDX $15E9
                    RTS      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; D294
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_D294            LDA $AA,x  
                    ASL A      
                    ASL A      
                    ASL A      
                    ASL A      
                    CLC        
                    ADC $14EC,x
                    STA $14EC,x
                    PHP        
                    PHP        
                    LDY #$00   
                    LDA $AA,x  
                    LSR A      
                    LSR A      
                    LSR A      
                    LSR A      
                    CMP #$08   
                    BCC LABEL07
                    ORA #$F0   
                    DEY        
LABEL07
                    PLP        
                    PHA        
                    ADC $D8,x  
                    STA $D8,x  
                    TYA        
                    ADC $14D4,x
                    STA $14D4,x
                    PLA        
                    PLP        
                    ADC #$00   
                    STA $1491  
                    RTS        
