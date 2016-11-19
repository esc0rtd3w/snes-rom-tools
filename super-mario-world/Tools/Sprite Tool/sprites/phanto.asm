;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; , adapted by mikeyk
;;
;; Description: 
;;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;big boo, boo, boo block
                    ;symbolic names for ram addresses
                    SPRITE_Y_SPEED  = $AA
                    SPRITE_X_SPEED  = $B6
                    SPRITE_STATUS   = $14C8
                    SPRITE_STATE    = $C2  
                    SPRITE_OAM      = $15EA
                    SPRITE_DIR      = $157C
                    
                    ;unassigned                  
                    ;$1540  -    shake timer
                    ;$15AC
                    ;$1570
                    ;$1602
                    ;$167A
                    ;$1662
                    ;$1558
                    
                    TILE = $88

                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT" 
                    LDA #$05
                    STA $151C,x
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
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
TBL_ACCEL_X         dcb $02,$FE
TBL_MAX_SPEED_X     dcb $28,$D8
TBL_ACCEL_Y         dcb $02,$FE
TBL_MAX_SPEED_Y     dcb $18,$E8
T_F8D1              dcb $01,$02,$02,$01

                    
SPRITE_CODE_START   JSR SUB_OFF_SCREEN_X0
                    LDA #$10
LBL_21              STA $18B6
                    LDA SPRITE_STATUS,x
                    CMP #$08
                    BNE LBL_01
                    LDA $9D
                    BEQ LBL_02
LBL_01
                    JMP LBL_17
LBL_02
                    JSR SUB_HORZ_POS
                    LDA SPRITE_STATE,x
                    BEQ LBL_20
                    LDA $0F
                    CLC
                    ADC #$0A
                    CMP #$14
                    BCC LBL_04
LBL_20
                    STZ SPRITE_STATE,x
                    JSR SUB_HAS_KEY
                    CPY #$01
                    BEQ LBL_03              ;todo
                    LDA $1558,x
                    BNE LBL_03
                    INC SPRITE_STATE,x      ;freeze ghost
LBL_03
                    LDA $0F
                    CLC
                    ADC #$0A
                    CMP #$14
                    BCC LBL_04
                    LDA $15AC,x
                    BNE LBL_12
                    TYA
                    CMP SPRITE_DIR,x
                    BEQ LBL_04
                    LDA #$1F
                    STA $15AC,x
                    BRA LBL_12
LBL_04
                    STZ $1602,x
                    LDA SPRITE_STATE,x
                    BEQ LBL_14
                    LDA #$03
                    STA $1602,x
                    LDY $9E,x               
                    LDA #$00
                    INC A
LBL_05
                    AND $13
                    BNE LBL_11
                    INC $1570,x
                    LDA $1570,x
                    BNE LBL_06
                    LDA #$20
                    ;STA $1558,x
LBL_06
                    LDA SPRITE_X_SPEED,x
                    BEQ LBL_08
                    BPL LBL_07
                    INC A
                    INC A
LBL_07
                    DEC A
LBL_08
                    STA SPRITE_X_SPEED,x
                    LDA SPRITE_Y_SPEED,x
                    BEQ LBL_10
                    BPL LBL_09
                    INC A
                    INC A
LBL_09
                    DEC A
LBL_10
                    STA SPRITE_Y_SPEED,x
LBL_11
                    BRA LBL_16
LBL_12
                    CMP #$10
                    BNE LBL_13
                    
LBL_13
                    LSR A
                    LSR A
                    LSR A
                    TAY
                    LDA T_F8D1,y
                    STA $1602,x
LBL_14
                    STZ $1570,x
                    LDA $13
                    AND #$03
                    BNE LBL_16
                    
                    JSR SUB_HORZ_POS
                    LDA SPRITE_X_SPEED,x
                    CMP TBL_MAX_SPEED_X,y
                    BEQ LBL_15
                    CLC
                    ADC TBL_ACCEL_X,y
                    STA SPRITE_X_SPEED,x
LBL_15
                    JSR SUB_VERT_POS     
                    LDA SPRITE_Y_SPEED,x
                    CMP TBL_MAX_SPEED_Y,y
                    BEQ LBL_16
                    CLC
                    ADC TBL_ACCEL_Y,y
                    STA SPRITE_Y_SPEED,x
LBL_16
                    JSL $018022             ;x speed
                    JSL $01801A             ;y speed
LBL_17
                    LDA SPRITE_STATUS,x
                    CMP #$08
                    BNE LBL_19
                    JSL $01A7DC		        ;interact with mario
LBL_19
                    JSR SUB_GFX
                    RTS                             


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_HAS_KEY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                    

SUB_HAS_KEY         PHX
                    LDY #$00
                    LDA $1470
                    BEQ RETURN08
                    
                    
                    LDX #$0A
LOOP_START          LDA $9E,x
                    CMP #$80
                    BNE NEXT_X
                    LDA $14C8,x
                    CMP #$0B
                    BNE NEXT_X
                    BRA HAS_KEY
NEXT_X              DEX
                    BPL LOOP_START
                    BRA RETURN08
                    
HAS_KEY             INY
                    LDA $151C,x
                    BEQ RETURN08
                    STZ $151C,x
                    LDA #$20
                    STA $1558,x

                    
RETURN08            PLX
                    RTS                    
                    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX             JSR GET_DRAW_INFO       ; after: Y = index to sprite OAM ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                   
                    LDA $1558,x
                    BEQ XC
                    LDA #$22
                    CLC
XC                   ADC $00                 ; set x position of the tile
                    STA $0300,y

                    LDA $01                 ; set y position of the tile
                    STA $0301,y

                    LDA #TILE
                    STA $0302,y

                    LDA $15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303,y             ; set properties

                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$00                ; This means we drew one tile
                    JSL $01B7B3
                    RTS
                    
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_HORZ_POS
; This routine determines which side of the sprite Mario is on.  It sets the Y register
; to the direction such that the sprite would face Mario
; It is ripped from $03B817
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_HORZ_POS		LDY #$00				;A:25D0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1020 VC:097 00 FL:31642
					LDA $D1					;A:25D0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1036 VC:097 00 FL:31642
					SEC                     ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1060 VC:097 00 FL:31642
					SBC $E4,x				;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1074 VC:097 00 FL:31642
					STA $0F					;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1104 VC:097 00 FL:31642
					LDA $D2					;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1128 VC:097 00 FL:31642
					SBC $14E0,x				;A:2500 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZcHC:1152 VC:097 00 FL:31642
					BPL SPR_L16             ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1184 VC:097 00 FL:31642
					INY                     ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1200 VC:097 00 FL:31642
SPR_L16				RTS                     ;A:25FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:1214 VC:097 00 FL:31642



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_VERT_POS
; This routine determines if Mario is above or below the sprite.  It sets the Y register
; to the direction such that the sprite would face Mario
; It is ripped from $03B829
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_VERT_POS		LDY #$00               ;A:25A1 X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizCHC:0130 VC:085 00 FL:924
					LDA $D3                ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
					SEC                    ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
					SBC $D8,x              ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
					STA $0F                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
					LDA $D4                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
					SBC $14D4,x            ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
					BPL SPR_L11            ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0294 VC:085 00 FL:924
					INY                    ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0310 VC:085 00 FL:924
SPR_L11				RTS                    ;A:25FF X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizcHC:0324 VC:085 00 FL:924


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

GET_DRAW_INFO       STZ $186C,x             ; reset sprite offscreen flag, vertical
                    STZ $15A0,x             ; reset sprite offscreen flag, horizontal
                    LDA $E4,x               ; \
                    CMP $1A                 ;  | set horizontal offscreen if necessary
                    LDA $14E0,x             ;  |
                    SBC $1B                 ;  |
                    BEQ ON_SCREEN_X         ;  |
                    INC $15A0,x             ; /

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
ON_SCREEN_LOOP      LDA $D8,x               ; \ 
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
                    LDA $186C,x             ;  | (vert offscreen)
                    ORA SPR_T2,y            ;  |
                    STA $186C,x             ;  |
ON_SCREEN_Y         DEY                     ;  |
                    BPL ON_SCREEN_LOOP      ; /

                    LDY $15EA,x             ; get offset to sprite OAM
                    LDA $E4,x               ; \ 
                    SEC                     ;  | 
                    SBC $1A                 ;  | $00 = sprite x position relative to screen boarder
                    STA $00                 ; / 
                    LDA $D8,x               ; \ 
                    SEC                     ;  | 
                    SBC $1C                 ;  | $01 = sprite y position relative to screen boarder
                    STA $01                 ; / 
                    RTS                     ; return

INVALID             PLA                     ; \ return from *main gfx routine* subroutine...
                    PLA                     ;  |    ...(not just this subroutine)
                    RTS                     ; /

               
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
                    LDA $D8,x               ; \
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
                    CMP $D8,x               ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0160 VC:251 00 FL:5379
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

SUB_IS_OFF_SCREEN   LDA $15A0,x             ; \ if sprite is on screen, accumulator = 0 
                    ORA $186C,x             ; |  
                    RTS                     ; / return

                    