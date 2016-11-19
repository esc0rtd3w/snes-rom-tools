;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Left Horizontal Thwomp, by mikeyk
;;
;; Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
                    ; symbolic names for RAM addresses (don't change these)
                    SPRITE_Y_SPEED  = $AA
                    SPRITE_X_SPEED  = $B6
                    SPRITE_STATE    = $C2
                    SPRITE_Y_POS    = $D8
                    SPRITE_Y_POS_HI = $14D4
                    SPRITE_X_POS    = $E4
                    SPRITE_X_POS_HI = $14E0
                    
                    ORIG_X_POS      = $151C
                    EXPRESSION      = $1528
                    FREEZE_TIMER    = $1540
                    SPR_OBJ_STATUS  = $1588
                    H_OFFSCREEN     = $15A0
                    V_OFFSCREEN     = $186C
                    
                    ; definitions of bits (don't change these)
                    OBJ_CHECK       = $03             
                    
                    ; sprite data
                    SPRITE_GRAVITY  = $FC
                    MAX_X_SPEED     = $C2 
                    RETURN_SPEED    = $10
                    TIME_TO_SHAKE   = $18
                    SOUND_EFFECT    = $09 
                    TIME_ON_GROUND  = $40
                    ANGRY_TILE      = $CA  

X_OFFSET            dcb $FC,$04,$FC,$04,$00 
Y_OFFSET            dcb $00,$00,$10,$10,$08 
TILE_MAP            dcb $8E,$8E,$AE,$AE,$C8 
PROPERTIES          dcb $03,$43,$03,$43,$03
                                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    LDA SPRITE_X_POS,x  
                    CLC        
                    ADC #$08   
                    STA SPRITE_X_POS,x  
                    STA ORIG_X_POS,x
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

RETURN              RTS  

SPRITE_CODE_START   JSR SUB_GFX

                    LDA $14C8,x             ; return if sprite status != 8
                    CMP #$08            	 
                    BNE RETURN           
                    
                    LDA $9D			        ; return if sprites locked
                    BNE RETURN    
                    
                    JSR SUB_OFF_SCREEN_X0   ; only process sprite while on screen           
                    
                    JSL $01A7DC             ; interact with mario 
                    
                    LDA SPRITE_STATE,x     
                    CMP #$01
                    BEQ ATTACKING
                    CMP #$02
                    BEQ RETURNING

;-----------------------------------------------------------------------------------------
; state 0
;-----------------------------------------------------------------------------------------

WAITING             LDA V_OFFSCREEN,x       ;fall if offscreen vertically
                    BNE RETURN0
                    
                    LDA H_OFFSCREEN,x       ;return if offscreen horizontally
                    BNE RETURN0
                    
                    STZ EXPRESSION,x
                    JSR SUB_HORZ_POS        ;determine if mario is close and act accordingly
                    TYA        
                    STA $157C,x
                    BEQ RETURN0
                    
                    LDA $0F    
                    SEC
                    SBC #$40
                    PHA
                    CMP #$48 
                    BCC THWOMP_4
                    LDA #$01                
                    STA EXPRESSION,x 
THWOMP_4            PLA
                    CMP #$60 
                    BCC RETURN0

                    LDA #$02                    ;set expression    
                    STA EXPRESSION,x  

                    INC SPRITE_STATE,x          ;chage state to attacking

                    LDA #$FF     
                    STA SPRITE_X_SPEED,x        ;set initial speed
                    
RETURN0             RTS                   

;-----------------------------------------------------------------------------------------
; state 1
;-----------------------------------------------------------------------------------------

ATTACKING           STZ SPRITE_Y_SPEED,x
                    JSL $01802A             ;apply speed
                    
                    LDA SPRITE_X_SPEED,x    ;increase speed if below the max
                    CMP #MAX_X_SPEED
                    BCC DONT_INC_SPEED
                    ADC #SPRITE_GRAVITY
                    STA SPRITE_X_SPEED,x    
DONT_INC_SPEED
                    LDA SPRITE_X_POS,x
                    PHA
                    CLC
                    ADC #$F6
                    STA SPRITE_X_POS,x
                    LDA SPRITE_X_POS_HI,x
                    PHA
                    ADC #$FF
                    STA SPRITE_X_POS_HI,x
                    
                    JSL $019138             ;interact with objects
                    
                    PLA
                    STA SPRITE_X_POS_HI,x
                    PLA
                    STA SPRITE_X_POS,x                    
                    
                    LDA SPR_OBJ_STATUS,x    ;return if not in contact
					AND #OBJ_CHECK
                    BEQ RETURN1
                    
                    JSR SUB_9A04            ; ?? speed related
                    
                    ;LDA #TIME_TO_SHAKE      ;shake ground
                    ;STA $1887    
                    
                    ;LDA #SOUND_EFFECT       ;play sound effect
                    ;STA $1DFC    
                    
                    LDA #TIME_ON_GROUND     ;set time to stay on ground
                    STA FREEZE_TIMER,x  
                    
                    INC SPRITE_STATE,x      ;go to returning state
RETURN1             RTS                     

;-----------------------------------------------------------------------------------------
; state 2
;-----------------------------------------------------------------------------------------

RETURNING           LDA FREEZE_TIMER,x      ;return if it's not time to move the sprite
                    BNE RETURN2
                    
                    STZ EXPRESSION,x        ;reset expression
                    
                    LDA SPRITE_X_POS,x      ;check if the sprite is in original position
                    CMP ORIG_X_POS,x  
                    BNE RISE
                    
                    STZ SPRITE_STATE,x      ;reset state to waiting
                    RTS                     

RISE                LDA #RETURN_SPEED       ;set returning speed and apply it
                    STA SPRITE_X_SPEED,x     
                    STZ SPRITE_Y_SPEED,x
                    JSL $01802A             
RETURN2             RTS                     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX             JSR GET_DRAW_INFO
                    
                    LDA EXPRESSION,x   
                    STA $02       
                    PHX                     
                    LDX #$03                
                    CMP #$00                        
                    BEQ LOOP_START
                    INX                     
LOOP_START          LDA $00    
                    CLC                     
                    ADC X_OFFSET,x
                    STA $0300,y

                    LDA $01    
                    CLC                     
                    ADC Y_OFFSET,x
                    STA $0301,y

                    LDA PROPERTIES,x
                    ORA $64    
                    STA $0303,y

                    LDA TILE_MAP,x
                    CPX #$04                
                    BNE NORMAL_TILE
                    PHX                     
                    LDX $02    
                    CPX #$02                
                    BNE NOT_ANGRY
                    LDA #ANGRY_TILE               
NOT_ANGRY           PLX                     
NORMAL_TILE         STA $0302,y

                    INY                     
                    INY                     
                    INY                     
                    INY                     
                    DEX                     
                    BPL LOOP_START

                    PLX                     
                                   
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$04                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3             ; / don't draw if offscreen
                    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; speed related
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
SUB_9A04            LDA SPR_OBJ_STATUS,x
                    BMI THWOMP_1
                    LDA #$00                
                    LDY $15B8,x
                    BEQ THWOMP_2
THWOMP_1            LDA #$18
THWOMP_2            STA SPRITE_X_SPEED,x  
                    RTS                                   


;###############################################################################################
;###############################################################################################
;###############################################################################################
; ROUTINES FROM THE LIBRARY ARE PASTED BELOW
; You should never have to modify this code
;###############################################################################################
;###############################################################################################
;###############################################################################################


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_HORZ_POS
; This routine determines which side of the sprite Mario is on.  It sets the Y register
; to the direction such that the sprite would face Mario
; It is ripped from $03B817
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_HORZ_POS		LDY #$00				;A:25D0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1020 VC:097 00 FL:31642
					LDA $94					;A:25D0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1036 VC:097 00 FL:31642
					SEC                     ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1060 VC:097 00 FL:31642
					SBC $E4,x				;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1074 VC:097 00 FL:31642
					STA $0F					;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1104 VC:097 00 FL:31642
					LDA $95					;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1128 VC:097 00 FL:31642
					SBC $14E0,x				;A:2500 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZcHC:1152 VC:097 00 FL:31642
					BPL SPR_L16             ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1184 VC:097 00 FL:31642
					INY                     ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1200 VC:097 00 FL:31642
SPR_L16				RTS                     ;A:25FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:1214 VC:097 00 FL:31642


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_OFF_SCREEN
; This subroutine deals with sprites that have moved off screen
; It is adapted from the subroutine at $01AC0D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
SPR_T12             dcb $40,$B0
SPR_T13             dcb $01,$FF
SPR_T14             dcb $30,$C0,$A0,$C0,$A0,$F0,$60,$90		;bank 1 sizes
		            dcb $30,$C0,$A0,$80,$A0,$40,$60,$B0		;bank 3 sizes
SPR_T15             dcb $01,$FF,$01,$FF,$01,$FF,$01,$FF		;bank 1 sizes
					dcb $01,$FF,$01,$FF,$01,$00,$01,$FF		;bank 3 sizes

SUB_OFF_SCREEN_X1   LDA #$02                ; \ entry point of routine determines value of $03
                    BRA STORE_03            ;  | (table entry to use on horizontal levels)
SUB_OFF_SCREEN_X2   LDA #$04                ;  | 
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X3   LDA #$06                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X4   LDA #$08                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X5   LDA #$0A                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X6   LDA #$0C                ;  |
                    BRA STORE_03            ;  |
SUB_OFF_SCREEN_X7   LDA #$0E                ;  |
STORE_03			STA $03					;  |            
					BRA START_SUB			;  |
SUB_OFF_SCREEN_X0   STZ $03					; /

START_SUB           JSR SUB_IS_OFF_SCREEN   ; \ if sprite is not off screen, return
                    BEQ RETURN_35           ; /
                    LDA $5B                 ; \  goto VERTICAL_LEVEL if vertical level
                    AND #$01                ; |
                    BNE VERTICAL_LEVEL      ; /     
                    LDA SPRITE_Y_POS,x               ; \
                    CLC                     ; | 
                    ADC #$50                ; | if the sprite has gone off the bottom of the level...
                    LDA $14D4,x             ; | (if adding 0x50 to the sprite y position would make the high byte >= 2)
                    ADC #$00                ; | 
                    CMP #$02                ; | 
                    BPL ERASE_SPRITE        ; /    ...erase the sprite
                    LDA $167A,x             ; \ if "process offscreen" flag is set, return
                    AND #$04                ; |
                    BNE RETURN_35           ; /
                    LDA $13                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0756 VC:176 00 FL:205
                    AND #$01                ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0780 VC:176 00 FL:205
                    ORA $03                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0796 VC:176 00 FL:205
                    STA $01                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0820 VC:176 00 FL:205
                    TAY                     ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0844 VC:176 00 FL:205
                    LDA $1A                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0858 VC:176 00 FL:205
                    CLC                     ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0882 VC:176 00 FL:205
                    ADC SPR_T14,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0896 VC:176 00 FL:205
                    ROL $00                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizcHC:0928 VC:176 00 FL:205
                    CMP $E4,x               ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:0966 VC:176 00 FL:205
                    PHP                     ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:0996 VC:176 00 FL:205
                    LDA $1B                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizCHC:1018 VC:176 00 FL:205
                    LSR $00                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdiZCHC:1042 VC:176 00 FL:205
                    ADC SPR_T15,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizcHC:1080 VC:176 00 FL:205
                    PLP                     ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F0 P:eNvMXdizcHC:1112 VC:176 00 FL:205
                    SBC $14E0,x             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1140 VC:176 00 FL:205
                    STA $00                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1172 VC:176 00 FL:205
                    LSR $01                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1196 VC:176 00 FL:205
                    BCC SPR_L31             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1234 VC:176 00 FL:205
                    EOR #$80                ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1250 VC:176 00 FL:205
                    STA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1266 VC:176 00 FL:205
SPR_L31             LDA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1290 VC:176 00 FL:205
                    BPL RETURN_35           ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1314 VC:176 00 FL:205
ERASE_SPRITE        LDA $14C8,x             ; \ if sprite status < 8, permanently erase sprite
                    CMP #$08                ; |
                    BCC KILL_SPRITE         ; /    
                    LDY $161A,x             ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1108 VC:059 00 FL:2878
                    CPY #$FF                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1140 VC:059 00 FL:2878
                    BEQ KILL_SPRITE         ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1156 VC:059 00 FL:2878
                    LDA #$00                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1172 VC:059 00 FL:2878
                    STA $1938,y             ;A:FF00 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZcHC:1188 VC:059 00 FL:2878
KILL_SPRITE         STZ $14C8,x             ; erase sprite
RETURN_35           RTS                     ; return

VERTICAL_LEVEL      LDA $167A,x             ; \ if "process offscreen" flag is set, return
                    AND #$04                ; |
                    BNE RETURN_35           ; /
                    LDA $13                 ; \
                    LSR A                   ; | 
                    BCS RETURN_35           ; /
                    LDA $E4,x               ; \ 
                    CMP #$00                ;  | if the sprite has gone off the side of the level...
                    LDA $14E0,x             ;  |
                    SBC #$00                ;  |
                    CMP #$02                ;  |
                    BCS ERASE_SPRITE        ; /  ...erase the sprite
                    LDA $13                 ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:1218 VC:250 00 FL:5379
                    LSR A                   ;A:0016 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1242 VC:250 00 FL:5379
                    AND #$01                ;A:000B X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1256 VC:250 00 FL:5379
                    STA $01                 ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1272 VC:250 00 FL:5379
                    TAY                     ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1296 VC:250 00 FL:5379
                    LDA $1C                 ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0052 VC:251 00 FL:5379
                    CLC                     ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0076 VC:251 00 FL:5379
                    ADC SPR_T12,y           ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0090 VC:251 00 FL:5379
                    ROL $00                 ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:enVMXdizCHC:0122 VC:251 00 FL:5379
                    CMP SPRITE_Y_POS,x      ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0160 VC:251 00 FL:5379
                    PHP                     ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0190 VC:251 00 FL:5379
                    LDA.W $001D             ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F2 P:eNVMXdizcHC:0212 VC:251 00 FL:5379
                    LSR $00                 ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdiZcHC:0244 VC:251 00 FL:5379
                    ADC SPR_T13,y           ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdizCHC:0282 VC:251 00 FL:5379
                    PLP                     ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:envMXdiZCHC:0314 VC:251 00 FL:5379
                    SBC $14D4,x             ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0342 VC:251 00 FL:5379
                    STA $00                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0374 VC:251 00 FL:5379
                    LDY $01                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0398 VC:251 00 FL:5379
                    BEQ SPR_L38             ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0422 VC:251 00 FL:5379
                    EOR #$80                ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0438 VC:251 00 FL:5379
                    STA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0454 VC:251 00 FL:5379
SPR_L38             LDA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0478 VC:251 00 FL:5379
                    BPL RETURN_35           ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0502 VC:251 00 FL:5379
                    BMI ERASE_SPRITE        ;A:8AFF X:0002 Y:0000 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0704 VC:184 00 FL:5490

SUB_IS_OFF_SCREEN   LDA H_OFFSCREEN,x       ; \ if sprite is on screen, accumulator = 0 
                    ORA V_OFFSCREEN,x       ; |  
                    RTS                     ; / return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GET_DRAW_INFO
; This is a helper for the graphics routine.  It sets off screen flags, and sets up
; variables.  It will return with the following:
;
;		Y = index to sprite OAM ($300)
;		$00 = sprite x position relative to screen boarder
;		$01 = sprite y position relative to screen boarder  
;
; It is adapted from the subroutine at $03B760
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPR_T1              dcb $0C,$1C
SPR_T2              dcb $01,$02

GET_DRAW_INFO       STZ V_OFFSCREEN,x       ; reset sprite offscreen flag, vertical
                    STZ H_OFFSCREEN,x       ; reset sprite offscreen flag, horizontal
                    LDA $E4,x               ; \
                    CMP $1A                 ;  | set horizontal offscreen if necessary
                    LDA $14E0,x             ;  |
                    SBC $1B                 ;  |
                    BEQ ON_SCREEN_X         ;  |
                    INC H_OFFSCREEN,x       ; /

ON_SCREEN_X         LDA $14E0,x             ; \
                    XBA                     ;  |
                    LDA $E4,x               ;  |
                    REP #$20                ;  |
                    SEC                     ;  |
                    SBC $1A                 ;  | mark sprite invalid if far enough off screen
                    CLC                     ;  |
                    ADC.W #$0040            ;  |
                    CMP.W #$0180            ;  |
                    SEP #$20                ;  |
                    ROL A                   ;  |
                    AND #$01                ;  |
                    STA $15C4,x             ; / 
                    BNE INVALID             ; 
                    
                    LDY #$00                ; \ set up loop:
                    LDA $1662,x             ;  | 
                    AND #$20                ;  | if not smushed (1662 & 0x20), go through loop twice
                    BEQ ON_SCREEN_LOOP      ;  | else, go through loop once
                    INY                     ; / 
ON_SCREEN_LOOP      LDA SPRITE_Y_POS,x               ; \ 
                    CLC                     ;  | set vertical offscreen if necessary
                    ADC SPR_T1,y            ;  |
                    PHP                     ;  |
                    CMP $1C                 ;  | (vert screen boundry)
                    ROL $00                 ;  |
                    PLP                     ;  |
                    LDA $14D4,x             ;  | 
                    ADC #$00                ;  |
                    LSR $00                 ;  |
                    SBC $1D                 ;  |
                    BEQ ON_SCREEN_Y         ;  |
                    LDA V_OFFSCREEN,x       ;  | (vert offscreen)
                    ORA SPR_T2,y            ;  |
                    STA V_OFFSCREEN,x       ;  |
ON_SCREEN_Y         DEY                     ;  |
                    BPL ON_SCREEN_LOOP      ; /

                    LDY $15EA,x             ; get offset to sprite OAM
                    LDA $E4,x               ; \ 
                    SEC                     ;  | 
                    SBC $1A                 ;  | $00 = sprite x position relative to screen boarder
                    STA $00                 ; / 
                    LDA SPRITE_Y_POS,x               ; \ 
                    SEC                     ;  | 
                    SBC $1C                 ;  | $01 = sprite y position relative to screen boarder
                    STA $01                 ; / 
                    RTS                     ; return

INVALID             PLA                     ; \ return from *main gfx routine* subroutine...
                    PLA                     ;  |    ...(not just this subroutine)
                    RTS                     ; /
                    