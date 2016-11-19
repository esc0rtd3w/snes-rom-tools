                    ;org $008000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    JSL $01ACF9
                    PHY
                    JSR SUB_HORZ_POS
                    TYA
                    STA $157C,x
                    PLY
                    RTL
                    
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
                    dcb "MAIN"                        
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_SPRITE_CODE   ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_800E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $01800E

SUB_800E            LDA $1588,x       
                    AND #$04          
                    RTS               


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_8014
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $018014

SUB_8014            LDA $1588,x            
                    AND #$08               
                    RTS                    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_80CB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $0180CB 
                    
SUB_80CB            LDA $15A0,x
                    ORA $186C,x
                    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 857C - done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $01857C

SUB_857C            JSR SUB_HORZ_POS   
                    TYA                 
                    STA $157C,x
                    RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8898
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $018898

SUB_8898            TXA                 
                    EOR $13    
                    AND #$03   
                    BNE LABEL22
                    LDY #$09   
LABEL20             LDA $14C8,y
                    CMP #$0A   
                    BEQ LABEL23
LABEL21             DEY        
                    BPL LABEL20
LABEL22             RTS        
LABEL23             LDA $00E4,y
                    SEC        
                    SBC #$1A   
                    STA $00    
                    LDA $14E0,y
                    SBC #$00   
                    STA $08    
                    LDA #$44   
                    STA $02    
                    LDA $00D8,y
                    STA $01    
                    LDA $14D4,y
                    STA $09    
                    LDA #$10   
                    STA $03    
                    JSL $03B69F
                    JSL $03B72B
                    BCC LABEL21 
                    JSR SUB_800E
                    BEQ LABEL21
                    LDA $157C,y
                    CMP $157C,x
                    BEQ LABEL24
                    LDA #$C0 
                    STA $AA,x
                    STZ $163E,x
LABEL24             RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data for sprites 0-13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $0188EC
                    
X_SPEEDS            dcb $08,$F8,$0C,$F4
SPRITE_PROPERTIES   dcb $00,$02,$03,$0D,$40,$42,$43,$45,$50,$50,$50,$5C,$DD,$05,$00,$20
                    dcb $20,$00,$00,$00




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8931
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $018931
                    
SUB_8931            LDA $9E,x  
                    CMP #$02   
                    BNE LABEL25
                    JSL $01A7DC
                    BRA LABEL27
LABEL25             ASL $167A,x
                    SEC        
                    ROR $167A,x
                    JSL $01A7DC
                    BCC LABEL26 
                    JSR SUB_B12A
LABEL26             ASL $167A,x
                    LSR $167A,x
LABEL27             RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main code for goomba et al
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $018AFC

START_SPRITE_CODE   LDA $9D    
                    BEQ LABEL01
                    JSL $01A7DC
                    JSL $018032
                    JSR SUB_8BC3
                    RTS        
LABEL01             JSR SUB_800E
                    BEQ LABEL04
                    LDY $9E,x  
                    LDA SPRITE_PROPERTIES,y
                    LSR A      
                    LDY $157C,x
                    BCC LABEL02
                    INY  
                    INY  
LABEL02             LDA X_SPEEDS,y              
                    EOR $15B8,x
                    ASL A      
                    LDA X_SPEEDS,y          
                    BCC LABEL03
                    CLC        
                    ADC $15B8,x
LABEL03             STA $B6,x  
LABEL04             LDY $157C,x
                    TYA        
                    INC A      
                    AND $1588,x
                    AND #$03   
                    BEQ LABEL05
                    STZ $B6,x
LABEL05             JSR SUB_8014
                    BEQ LABEL06 
                    STZ $AA,x
LABEL06             JSR SUB_OFF_SCREEN_X3
                    JSL $01802A
                    JSR SUB_8E5F
                    JSR SUB_800E
                    BEQ LABEL09 
                    JSR SUB_9A04
                    STZ $151C,x
                    LDY $9E,x  
                    LDA SPRITE_PROPERTIES,y
                    PHA         
                    AND #$04    
                    BEQ LABEL07 
                    LDA $1570,x
                    AND #$7F 
                    BNE LABEL07
                    LDA $157C,x
                    PHA
                    JSR SUB_857C
                    PLA
                    CMP $157C,x
                    BEQ LABEL07
                    LDA #$08   
                    STA $15AC,x
LABEL07             PLA        
                    AND #$08   
                    BEQ LABEL08
                    JSR SUB_8898
LABEL08             BRA LABEL12
LABEL09             LDY $9E,x  
                    LDA SPRITE_PROPERTIES,y 
                    BPL LABEL10
                    JSR SUB_8E5F
                    BRA LABEL11
LABEL10             STZ $1570,x
LABEL11             LDA SPRITE_PROPERTIES,y 
                    AND #$02   
                    BEQ LABEL12
                    LDA $151C,x
                    ORA $1558,x
                    ORA $1528,x
                    ORA $1534,x
                    BNE LABEL12
                    JSR SUB_9098
                    LDA #$01    
                    STA $151C,x
LABEL12             LDA $1528,x
                    BEQ LABEL13
                    JSR SUB_8931
                    BRA LABEL14
LABEL13             JSL $01A7DC
LABEL14             JSL $018032
                    JSR SUB_9089
SUB_8BC3            LDA $157C,x
                    PHA        
                    LDY $15AC,x
                    BEQ LABEL16
                    LDA #$02   
                    STA $1602,x
                    LDA #$00   
                    CPY #$05   
                    BCC LABEL15
                    INC A      
LABEL15             EOR $157C,x
                    STA $157C,x
LABEL16             LDY $9E,x  
                    LDA SPRITE_PROPERTIES,y
                    AND #$40   
                    BNE LABEL17
                    JSL $0190B2
                    BRA LABEL18
LABEL17             LDA $1602,x
                    LSR A      
                    LDA $D8,x  
                    PHA        
                    SBC #$0F   
                    STA $D8,x  
                    LDA $14D4,x
                    PHA        
                    SBC #$00   
                    STA $14D4,x
                    JSL $019D5F ;gfx
                    PLA        
                    STA $14D4,x
                    PLA        
                    STA $D8,x  
                    LDA $9E,x  
                    CMP #$08   
                    BCC LABEL18
                    JSR SUB_9E28
LABEL18             PLA        
                    STA $157C,x
                    RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_8E5F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $018E5F
                    
SUB_8E5F            INC $1570,x            
                    LDA $1570,x            
                    LSR A                  
                    LSR A                  
                    LSR A                  
                    AND #$01               
                    STA $1602,x            
                    RTS                    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_9089
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $019089

SUB_9089            LDA $157C,x
                    INC A      
                    AND $1588,x
                    AND #$03   
                    BEQ LABEL40
                    JSR SUB_9098
LABEL40             RTS                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_9098
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $019098

SUB_9098            LDA $15AC,x
                    BNE LABEL41
                    LDA #$08   
                    STA $15AC,x
                    LDA $B6,x  
                    EOR #$FF   
                    INC A      
                    STA $B6,x  
                    LDA $157C,x
                    EOR #$01   
                    STA $157C,x
LABEL41             RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9A04
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $019A04
                    
SUB_9A04            LDA $1588,x
                    BMI LABEL42
                    LDA #$00   
                    LDY $15B8,x
                    BEQ LABEL43
LABEL42             LDA #$18
LABEL43             STA $AA,x  
                    RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9E28
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    ;org $019E10
                    
TABLE_9E10          dcb $FF,$F7,$09,$09
TABLE_9E14          dcb $FF,$FF,$00,$00
TABLE_9E18          dcb $FC,$F4,$FC,$F4
TABLE_9E1C          dcb $5D,$C6,$5D,$C6
TABLE_9E20          dcb $46,$46,$06,$06
TABLE_9E24          dcb $00,$02,$00,$02

SUB_9E28            LDY #$00      
                    JSR SUB_800E  
                    BNE LABEL44   
                    LDA $1602,x
                    AND #$01   
                    TAY        
LABEL44             STY $02    
                    LDA $186C,x
                    BNE LABEL46
                    LDA $E4,x  
                    STA $00    
                    LDA $14E0,x
                    STA $04    
                    LDA $D8,x  
                    STA $01    
                    LDY $15EA,x
                    PHX        
                    LDA $157C,x
                    ASL A      
                    ADC $02    
                    TAX        
                    LDA $00    
                    CLC        
                    ADC TABLE_9E10,x
                    STA $00    
                    LDA $04    
                    ADC TABLE_9E14,x
                    PHA        
                    LDA $00    
                    SEC        
                    SBC $1A    
                    STA $0300,y
                    PLA        
                    SBC $1B    
                    BNE LABEL45
                    LDA $01    
                    SEC        
                    SBC $1C    
                    CLC        
                    ADC TABLE_9E18,x
                    STA $0301,y
                    LDA TABLE_9E1C,x
                    STA $0302,y
                    LDA $64    
                    ORA TABLE_9E20,x
                    STA $0303,y
                    TYA        
                    LSR A      
                    LSR A      
                    TAY        
                    LDA TABLE_9E24,x
                    STA $0460,y
LABEL45             PLX        
LABEL46             RTS        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AC31 - off screen processing code - shared
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
                    ;org $01AC0D
                    
TABLE12             dcb $40,$B0
TABLE13             dcb $01,$FF
TABLE14             dcb $30,$C0,$A0,$C0,$A0,$F0,$60,$90
TABLE15             dcb $01,$FF,$01,$FF,$01,$FF,$01,$FF

SUB_OFF_SCREEN_X0   LDA #$06                ; \ entry point of routine determines value of $03
                    STA $03                 ;  |
                    BRA STORE_03            ;  | 
SUB_OFF_SCREEN_X1   LDA #$04                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X2   LDA #$02                ;  |
STORE_03            STA $03                 ;  |
                    BRA START_SUB           ;  |
SUB_OFF_SCREEN_X3   STZ $03                 ; /

START_SUB           JSR SUB_80CB           
                    BEQ LABEL35            
                    LDA $5B                
                    AND #$01               
                    BNE LABEL36            
                    LDA $D8,x              
                    CLC                    
                    ADC #$50               
                    LDA $14D4,x            
                    ADC #$00               
                    CMP #$02               
                    BPL LABEL32            
                    LDA $167A,x            
                    AND #$04               
                    BNE LABEL35            
                    LDA $13                
                    AND #$01               
                    ORA $03                
                    STA $01                
                    TAY                    
                    LDA $1A                
                    CLC                    
                    ADC TABLE14,y          
                    ROL $00                
                    CMP $E4,x              
                    PHP                    
                    LDA $1B                
                    LSR $00                
                    ADC TABLE15,y          
                    PLP                    
                    SBC $14E0,x            
                    STA $00                
                    LSR $01                
                    BCC LABEL31            
                    EOR #$80               
                    STA $00                
LABEL31             LDA $00                
                    BPL LABEL35            
LABEL32             LDA $9E,x              
                    CMP #$1F               
                    BNE NOT_MAGIKOOPA      
                    STA $18C1              
                    LDA #$FF               
                    STA $18C0
NOT_MAGIKOOPA       LDA $14C8,x            
                    CMP #$08               
                    BCC LABEL34            
                    LDY $161A,x            
                    CPY #$FF               
                    BEQ LABEL34            
                    LDA #$00               
                    STA $1938,y            
LABEL34             STZ $14C8,x            
LABEL35             RTS                    
LABEL36             LDA $167A,x            
                    AND #$04               
                    BNE LABEL35            
                    LDA $13                
                    LSR A                  
                    BCS LABEL35            
                    LDA $E4,x              
                    CMP #$00               
                    LDA $14E0,x            
                    SBC #$00               
                    CMP #$02               
                    BCS LABEL32            
                    LDA $13                
                    LSR A                  
                    AND #$01               
                    STA $01                
                    TAY                    
                    BEQ LABEL37            
                    LDA $9E,x              
                    CMP #$22               
                    BEQ LABEL35            
                    CMP #$24               
                    BEQ LABEL35            
LABEL37             LDA $1C                
                    CLC                    
                    ADC TABLE12,y          
                    ROL $00                
                    CMP $D8,x              
                    PHP                    
                    LDA.W $001D            
                    LSR $00                
                    ADC TABLE13,y          
                    PLP                    
                    SBC $14D4,x            
                    STA $00                
                    LDY $01                
                    BEQ LABEL38            
                    EOR #$80               
                    STA $00                
LABEL38             LDA $00                
                    BPL LABEL35            
                    BMI LABEL32            


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AD30 - horizontal mario/sprite check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $01AD30
                     
SUB_HORZ_POS       LDY #$00       
                    LDA $D1        
                    SEC            
                    SBC $E4,x      
                    STA $0F        
                    LDA $D2        
                    SBC $14E0,x    
                    BPL TO_RIGHT   
                    INY            
TO_RIGHT            RTS            


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; B12A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $01B023

TABLE_B023          dcb $F0,$10

                    ;org $01B12A

SUB_B12A            LDA #$10  
                    STA $149A 
                    LDA #$03  
                    STA $1DF9 
                    JSR SUB_HORZ_POS
                    LDA TABLE_B023,y
                    STA $B6,x  
                    LDA #$E0   
                    STA $AA,x  
                    LDA #$02   
                    STA $14C8,x
                    STY $76    
                    LDA #$01   
                    JSL $02ACE5
                    RTS                  


