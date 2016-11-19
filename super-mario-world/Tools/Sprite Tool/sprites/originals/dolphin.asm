;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dolphin, ripped by mikeyk
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	UpdateXPosNoGrvty	= $018022
	UpdateYPosNoGrvty	= $01801A
	InvisBlkMainRt	= $01B44F
	SprGfxRt1x2		= $019D5F
	FinishOAMWrite	= $01B7B3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dcb "INIT"
	RTL

	dcb "MAIN"
	CMP #$08
	BNE SkipMain
        PHB              
        PHK              
        PLB              
	JSR SpriteMainSub
        PLB
SkipMain:	
        RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02BB88:                      dcb $FF,$01,$FF,$01,$00,$00
DATA_02BB8E:                      dcb $E8,$18,$F8,$08,$00,$00
	
SpriteMainSub:	
DolphinMain:        JSR ADDR_02BC14 ; Draw sprite
                    LDA $9D                   
                    BNE Return02BBFF          
                    JSR SubOffscreen1Bnk2   
	;;         JSR UpdateYPosNoGrvtyBnk2
	;;         JSR UpdateXPosNoGrvtyBnk2
		    JSL UpdateYPosNoGrvty
	            JSL UpdateXPosNoGrvty
                    STA $1528,X             
                    LDA $14                   
                    AND #$00                
                    BNE ADDR_02BBB7           
                    LDA $AA,X                 
                    BMI ADDR_02BBB5           
                    CMP #$3F                
                    BCS ADDR_02BBB7           
ADDR_02BBB5:        INC $AA,X                 
ADDR_02BBB7:        TXA                       
                    EOR $13                   
                    LSR                       
                    BCC ADDR_02BBC1           
                    JSL $019138         
ADDR_02BBC1:        LDA $AA,X                 
                    BMI ADDR_02BBFB           
                    LDA $164A,X             
                    BEQ ADDR_02BBFB           
                    LDA $AA,X                 
                    BEQ ADDR_02BBD7           
                    SEC                       
                    SBC #$08                
                    STA $AA,X                 
                    BPL ADDR_02BBD7           
                    STZ $AA,X                 ; Sprite Y Speed = 0 
ADDR_02BBD7:        LDA $151C,X             
                    BNE ADDR_02BBF7           
                    LDA $C2,X                 
                    LSR                       
                    PHP                       
                    LDA $9E,X                 
                    SEC                       
                    SBC #$41                
                    PLP                       
                    ROL                       
                    TAY                       
                    LDA $B6,X                 
                    CLC                       
                    ADC DATA_02BB88,Y       
                    STA $B6,X                 
                    CMP DATA_02BB8E,Y       
                    BNE ADDR_02BBFB           
                    INC $C2,X                 
ADDR_02BBF7:        LDA #$C0                
                    STA $AA,X                 
ADDR_02BBFB:        JSL InvisBlkMainRt      
Return02BBFF:       RTS                       ; Return 

ADDR_02BC00:        LDA $14                   
                    AND #$04                
                    LSR                       
                    LSR                       
                    STA $157C,X             
                    JSL SprGfxRt1x2         
Return02BC0D:       RTS                       ; Return 


DolphinTiles1:      dcb $E2,$88

DolphinTiles2:      dcb $E7,$A8

DolphinTiles3:      dcb $E8,$A9

ADDR_02BC14:        LDA $9E,X                 
                    CMP #$43                
                    BNE ADDR_02BC1D           
                    JMP ADDR_02BC00         

ADDR_02BC1D:        JSR GetDrawInfo2        
                    LDA $B6,X                 
                    STA $02                   
                    LDA $00                   
                    ASL $02                   
                    PHP                       
                    BCC ADDR_02BC3C           
                    STA $0300,Y             
                    CLC                       
                    ADC #$10                
                    STA $0304,Y             
                    CLC                       
                    ADC #$08                
                    STA $0308,Y             
                    BRA ADDR_02BC4E           

ADDR_02BC3C:        CLC                       
                    ADC #$18                
                    STA $0300,Y             
                    SEC                       
                    SBC #$10                
                    STA $0304,Y             
                    SEC                       
                    SBC #$08                
                    STA $0308,Y             
ADDR_02BC4E:        LDA $01                   
                    STA $0301,Y             
                    STA $0305,Y             
                    STA $0309,Y             
                    PHX                       
                    LDA $14                   
                    AND #$08                
                    LSR                       
                    LSR                       
                    LSR                       
                    TAX                       
                    LDA DolphinTiles1,X     
                    STA $0302,Y             
                    LDA DolphinTiles2,X     
                    STA $0306,Y             
                    LDA DolphinTiles3,X     
                    STA $030A,Y             
                    PLX                       
                    LDA $15F6,X             
                    ORA $64                   
                    PLP                       
                    BCS ADDR_02BC7F           
                    ORA #$40                
ADDR_02BC7F:        STA $0303,Y             
                    STA $0307,Y             
                    STA $030B,Y             
                    LDA #$02                
                    LDY #$02                
	            JSL FinishOAMWrite      
Return02B7AB:       RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DATA_02D003:        dcb $40,$B0

DATA_02D005:        dcb $01,$FF

DATA_02D007:        dcb $30,$C0,$A0,$C0,$A0,$70,$60,$B0
DATA_02D00F:        dcb $01,$FF,$01,$FF,$01,$FF,$01,$FF

SubOffscreen3Bnk2:  LDA #$06                ; \ Entry point of routine determines value of $03 
                    BRA ADDR_02D021           ;  | 

SubOffscreen2Bnk2:  LDA #$04                ;  | 
                    BRA ADDR_02D021           ;  | 

SubOffscreen1Bnk2:  LDA #$02                ;  | 
ADDR_02D021:        STA $03                   ;  | 
                    BRA ADDR_02D027           ;  | 

SubOffscreen0Bnk2:  STZ $03                   ; / 
ADDR_02D027:        JSR IsSprOffScreenBnk2  ; \ if sprite is not off screen, return 
                    BEQ Return02D090          ; / 
                    LDA $5B                   ; \  vertical level 
                    AND #$01                ;  | 
                    BNE VerticalLevelBnk2     ; / 
                    LDA $03                   
                    CMP #$04                
                    BEQ ADDR_02D04D           
                    LDA $D8,X                 ; \ 
                    CLC                       ;  | 
                    ADC #$50                ;  | if the sprite has gone off the bottom of the level... 
                    LDA $14D4,X             ;  | (if adding 0x50 to the sprite y position would make the high byte >= 2) 
                    ADC #$00                ;  | 
                    CMP #$02                ;  | 
                    BPL OffScrEraseSprBnk2    ; /    ...erase the sprite 
                    LDA $167A,X             ; \ if "process offscreen" flag is set, return 
                    AND #$04                ;  | 
                    BNE Return02D090          ; / 
ADDR_02D04D:        LDA $13                   
                    AND #$01                
                    ORA $03                   
                    STA $01                   
                    TAY                       
                    LDA $1A                   
                    CLC                       
                    ADC DATA_02D007,Y       
                    ROL $00                   
                    CMP $E4,X                 
                    PHP                       
                    LDA $1B                   
                    LSR $00                   
                    ADC DATA_02D00F,Y       
                    PLP                       
                    SBC $14E0,X             
                    STA $00                   
                    LSR $01                   
                    BCC ADDR_02D076           
                    EOR #$80                
                    STA $00                   
ADDR_02D076:        LDA $00                   
                    BPL Return02D090          
OffScrEraseSprBnk2: LDA $14C8,X             ; \ If sprite status < 8, permanently erase sprite 
                    CMP #$08                ;  | 
                    BCC OffScrKillSprBnk2     ; / 
                    LDY $161A,X             ; \ Branch if should permanently erase sprite 
                    CPY #$FF                ;  | 
                    BEQ OffScrKillSprBnk2     ; / 
                    LDA #$00                ; \ Allow sprite to be reloaded by level loading routine 
                    STA $1938,Y             ; / 
OffScrKillSprBnk2:  STZ $14C8,X             ; Erase sprite 
Return02D090:       RTS                       ; Return 

VerticalLevelBnk2:  LDA $167A,X             ; \ If "process offscreen" flag is set, return 
                    AND #$04                ;  | 
                    BNE Return02D090          ; / 
                    LDA $13                   ; \ Return every other frame 
                    LSR                       ;  | 
                    BCS Return02D090          ; / 
                    AND #$01                
                    STA $01                   
                    TAY                       
                    LDA $1C                   
                    CLC                       
                    ADC DATA_02D003,Y       
                    ROL $00                   
                    CMP $D8,X                 
                    PHP                       
                    LDA $001D               
                    LSR $00                   
                    ADC DATA_02D005,Y       
                    PLP                       
                    SBC $14D4,X             
                    STA $00                   
                    LDY $01                   
                    BEQ ADDR_02D0C3           
                    EOR #$80                
                    STA $00                   
ADDR_02D0C3:        LDA $00                   
                    BPL Return02D090          
                    BMI OffScrEraseSprBnk2    
IsSprOffScreenBnk2: LDA $15A0,X             
                    ORA $186C,X             
Return02D0CF:       RTS                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02D374:        dcb $0C,$1C

DATA_02D376:        dcb $01,$02

GetDrawInfo2:       STZ $186C,X             
                    STZ $15A0,X             
                    LDA $E4,X                 
                    CMP $1A                   
                    LDA $14E0,X             
                    SBC $1B                   
                    BEQ ADDR_02D38C           
                    INC $15A0,X             
ADDR_02D38C:        LDA $14E0,X             
                    XBA                       
                    LDA $E4,X                 
                    REP #$20                  ; Accum (16 bit) 
                    SEC                       
                    SBC $1A                   
                    CLC                       
                    ADC.W #$0040              
                    CMP.W #$0180              
                    SEP #$20                  ; Accum (8 bit) 
                    ROL                       
                    AND #$01                
                    STA $15C4,X             
                    BNE ADDR_02D3E7           
                    LDY #$00                
                    LDA $1662,X             
                    AND #$20                
                    BEQ ADDR_02D3B2           
                    INY                       
ADDR_02D3B2:        LDA $D8,X                 
                    CLC                       
                    ADC DATA_02D374,Y       
                    PHP                       
                    CMP $1C                   
                    ROL $00                   
                    PLP                       
                    LDA $14D4,X             
                    ADC #$00                
                    LSR $00                   
                    SBC $1D                   
                    BEQ ADDR_02D3D2           
                    LDA $186C,X             
                    ORA DATA_02D376,Y       
                    STA $186C,X             
ADDR_02D3D2:        DEY                       
                    BPL ADDR_02D3B2           
                    LDY $15EA,X             ; Y = Index into sprite OAM 
                    LDA $E4,X                 
                    SEC                       
                    SBC $1A                   
                    STA $00                   
                    LDA $D8,X                 
                    SEC                       
                    SBC $1C                   
                    STA $01                   
Return02D3E6:       RTS                       ; Return 

ADDR_02D3E7:        PLA                       
                    PLA                       
Return02D3E9:       RTS                       ; Return 
	