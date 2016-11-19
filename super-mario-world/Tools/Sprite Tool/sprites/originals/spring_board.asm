;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spring Board, ripped by mikeyk
;;
;; Description: SMW Spring Board, ripped and modified for use with Sprite Tool
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	SprGfxRt2x2 = $018042
	UpdateSpritePos = $01802A
	GetMarioClipping = $03B664 
	GetSpriteClippingA = $03B69F 
	CheckForContact = $03B72B 

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

DATA_01E611:
	dcb $00,$01,$02,$02,$02,$01,$01,$00
        dcb $00
DATA_01E61A:
        dcb $1E,$1B,$18,$18,$18,$1A,$1C,$1D
        dcb $1E
	
SpriteMainSub:	
	LDA $9D			; \ If sprites locked, 
        BEQ NotLocked		;  |
        JMP ADDR_01E6F0		; / jump to end of routine to draw sprite
NotLocked:	
	JSR SubOffscreen	; Erase when offscreen
        JSL UpdateSpritePos	; Move sprite
	LDA $1588,x
	AND #$04
        BEQ NotOnGround
        JSR ADDR_0197D5		; Runs if on ground
NotOnGround:	
	LDA $1588,X
        AND #$03
        BEQ NotTouchingSide
        JSR SetSpriteTurning	; Runs if touching object side
        LDA $B6,X
        ASL
        PHP
        ROR $B6,X
        PLP
        ROR $B6,X
NotTouchingSide:	
	LDA $1588,X          
        AND #$08
        BEQ NotTouchingCeiling
        STZ $AA,X	      	; If touching celing, sprite Y Speed = 0
NotTouchingCeiling:	
        LDA $1540,X		; Load time to boost Mario
        BEQ ADDR_01E6B0	
        LSR
        TAY
        LDA $187A
        CMP #$01
        LDA DATA_01E61A,Y	; Load amount to boost Mario
        BCC NotOnYoshi
        CLC
        ADC #$12		; Add #$12 if on Yoshi
NotOnYoshi:	
        STA $00
        LDA DATA_01E611,Y 	; Set animation frame
        STA $1602,X
        LDA $D8,X		; \ Mario's Y position = Sprite Y position
        SEC			;  |
        SBC $00			;  |
        STA $96			;  |
        LDA $14D4,X		;  |
        SBC #$00		;  |
        STA $97			; /
        STZ $72
        STZ $7B			; Mario X speed = 0
        LDA #$02
        STA $1471
        LDA $1540,X
        CMP #$07
        BCS ADDR_01E6AE
        STZ $1471
        LDY #$B0
        LDA $17
        BPL ADDR_01E69A
        LDA #$01
        STA $140D
        BRA ADDR_01E69E           

ADDR_01E69A:
        LDA $15
        BPL ADDR_01E6A7           
ADDR_01E69E:
        LDA #$0B
        STA $72
        LDY #$80
        STY $1406               
ADDR_01E6A7:
        STY $7D			; Set Mario's Y speed
        LDA #$08                ; \ Play sound effect
        STA $1DFC               ; / 
ADDR_01E6AE:
        BRA ADDR_01E6F0           

ADDR_01E6B0:
	JSL $01A7DC             ; Handle Mario/sprite contact
        BCC ADDR_01E6F0
        STZ $154C,X
        LDA $D8,X
        SEC
        SBC $96
        CLC
        ADC #$04
        CMP #$1C
        BCC ADDR_01E6CE
        BPL ADDR_01E6E7
        LDA $7D
        BPL ADDR_01E6F0
        STZ $7D
        BRA ADDR_01E6F0           

ADDR_01E6CE:
	BIT $15
        BVC ADDR_01E6E2
        LDA $1470               ; \ Branch if carrying an enemy...
        ORA $187A               ;  | ...or if on Yoshi
        BNE ADDR_01E6E2         ; /
        LDA #$0B                ; \ Sprite status = carried
        STA $14C8,X             ; /
        STZ $1602,X             
ADDR_01E6E2:
	JSR ADDR_01AB31
        BRA ADDR_01E6F0           

ADDR_01E6E7:
        LDA $7D
        BMI ADDR_01E6F0
        LDA #$11
        STA $1540,X             
ADDR_01E6F0:
        LDY $1602,X		; \ Set Y displacement for gfx routine
        LDA DATA_01E6FD,Y	;  |
        TAY			; /
        LDA #$02
        JSL SprGfxRt2x2		; This is actually not the correct routine to call, since it zeroes out Y which we set above
Return01E6FC:
	RTS			; Return 

DATA_01E6FD:
	dcb $00,$02,$00
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
DATA_01AB2D:
        dcb $01,$00,$FF,$FF

ADDR_01AB31:
	STZ $7B
        JSR SubHorizPos
        TYA
        ASL
        TAY
        REP #$20                  ; Accum (16 bit)
        LDA $94
        CLC
        ADC DATA_01AB2D,Y
        STA $94
        SEP #$20                  ; Accum (8 bit) 
Return01AB45:
	RTS                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetSpriteTurning:
	LDA $15AC,X             ; \ Return if turning timer is set
        BNE Return0190B1        ; /
        LDA #$08                ; \ Set turning timer
        STA $15AC,X             ; / 
FlipSpriteDir:
	LDA $B6,X		; \ Invert speed
        EOR #$FF                ;  |
        INC A			;  |
        STA $B6,X		; /
        LDA $157C,X             ; \ Flip sprite direction
        EOR #$01                ;  |
        STA $157C,X             ; / 
Return0190B1:
	RTS                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubHorizPos:
        LDY #$00
        LDA $D1
        SEC
        SBC $E4,X
        STA $0F
        LDA $D2
        SBC $14E0,X
        BPL Return01AD41
        INY                       
Return01AD41:
	RTS                       ; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_0197AF:
        dcb $00,$00,$00,$F8,$F8,$F8,$F8,$F8
        dcb $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
        dcb $E8,$E8,$E8,$00,$00,$00,$00,$FE
        dcb $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
        dcb $DC,$D8,$D4,$D0,$CC,$C8

ADDR_0197D5:
        LDA $B6,X
        PHP
        BPL ADDR_0197DD
        EOR #$FF		  ; \ Set A to -A
        INC A                     ; /  
ADDR_0197DD:
        LSR
        PLP
        BPL ADDR_0197E4
        EOR #$FF		  ; \ Set A to -A
        INC A                     ; /  
ADDR_0197E4:
        STA $B6,X
        LDA $AA,X
        PHA
        JSR SetSomeYSpeed
        PLA
        LSR
        LSR
        TAY
        LDA $9E,X                 ; \ If Goomba, Y += #$13
        CMP #$0F		  ;  |
        BNE ADDR_0197FB           ;  |
        TYA                       ;  |
        CLC                       ;  |
        ADC #$13		  ;  |
        TAY                       ; / 
ADDR_0197FB:
        LDA DATA_0197AF,Y
        LDY $1588,X
        BMI Return019805
        STA $AA,X                 
Return019805:
	RTS       

SetSomeYSpeed:
	LDA $1588,X
        BMI ADDR_019A10
        LDA #$00                ; \ Sprite Y speed = #$00 or #$18
        LDY $15B8,X             ;  | Depending on 15B8,x ???
        BEQ ADDR_019A12		;  | 
ADDR_019A10:
        LDA #$18                ;  | 
ADDR_019A12:
        STA $AA,X		; / 
Return019A14:
	RTS			; Return 
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_OFF_SCREEN
; This subroutine deals with sprites that have moved off screen
; It is adapted from the subroutine at $01AC0D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
DATA_01AC0D:        dcb $40,$B0
DATA_01AC0F:        dcb $01,$FF
DATA_01AC11:        dcb $30,$C0
DATA_01AC19:        dcb $01,$FF

SubOffScreen:	    STZ $03                   
                    JSR IsSprOnScreen         ; \ if sprite is not off screen, return                                       
                    BEQ Return01ACA4          ; /                                                                           
                    LDA $5B                   ; \  vertical level                                    
                    AND #$01                  ; |                                                                           
                    BNE VerticalLevel         ; /                                                                           
                    LDA $D8,X                 ; \                                                                           
                    CLC                       ; |                                                                           
                    ADC #$50                  ; | if the sprite has gone off the bottom of the level...                     
                    LDA $14D4,X               ; | (if adding 0x50 to the sprite y position would make the high byte >= 2)   
                    ADC #$00                  ; |                                                                           
                    CMP #$02                  ; |                                                                           
                    BPL OffScrEraseSprite     ; /    ...erase the sprite                                                    
                    LDA $167A,X               ; \ if "process offscreen" flag is set, return                                
                    AND #$04                  ; |                                                                           
                    BNE Return01ACA4          ; /                                                                           
                    LDA $13                   
                    AND #$01                
                    STA $01                   
                    TAY                       
                    LDA $1A                   
                    CLC                       
                    ADC DATA_01AC11,Y       
                    ROL $00                   
                    CMP $E4,X                 
                    PHP                       
                    LDA $1B                   
                    LSR $00                   
                    ADC DATA_01AC19,Y       
                    PLP                       
                    SBC $14E0,X             
                    STA $00                   
                    LSR $01                   
                    BCC ADDR_01AC7C           
                    EOR #$80                
                    STA $00                   
ADDR_01AC7C:        LDA $00                   
                    BPL Return01ACA4          
OffScrEraseSprite:  LDA $14C8,X               ; \ If sprite status < 8, permanently erase sprite 
                    CMP #$08                  ;  | 
                    BCC OffScrKillSprite      ; / 
                    LDY $161A,X             
                    CPY #$FF                
                    BEQ OffScrKillSprite      
                    LDA #$00                
                    STA $1938,Y             
OffScrKillSprite:   STZ $14C8,X               ; Erase sprite 
Return01ACA4:       RTS                       

VerticalLevel:      LDA $167A,X               ; \ If "process offscreen" flag is set, return                
                    AND #$04                  ; |                                                           
                    BNE Return01ACA4          ; /                                                           
                    LDA $13                   ; \                                                           
                    LSR                       ; |                                                           
                    BCS Return01ACA4          ; /                                                           
                    LDA $E4,X                 ; \                                                           
                    CMP #$00                  ;  | If the sprite has gone off the side of the level...      
                    LDA $14E0,X               ;  |                                                          
                    SBC #$00                  ;  |                                                          
                    CMP #$02                  ;  |                                                          
                    BCS OffScrEraseSprite     ; /  ...erase the sprite      
                    LDA $13                   
                    LSR                       
                    AND #$01                
                    STA $01                   
                    TAY                       
		    LDA $1C                   
                    CLC                       
                    ADC DATA_01AC0D,Y       
                    ROL $00                   
                    CMP $D8,X                 
                    PHP                       
                    LDA $001D               
                    LSR $00                   
                    ADC DATA_01AC0F,Y       
                    PLP                       
                    SBC $14D4,X             
                    STA $00                   
                    LDY $01                   
                    BEQ ADDR_01ACF3           
                    EOR #$80                
                    STA $00                   
ADDR_01ACF3:        LDA $00                   
                    BPL Return01ACA4          
                    BMI OffScrEraseSprite  

IsSprOnScreen:      LDA $15A0,X               ; \ A = Current sprite is offscreen 
                    ORA $186C,X               ; /  
                    RTS                       ; Return 
	