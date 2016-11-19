;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Venus Fire Trap, by mikeyk
;;
;; Description: Pipe dwelling plant that spits fireballs at Mario.
;;
;; Uses first extra bit: YES
;; It will spit two fireballs if the first extra bit is set, one if not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
                    EXTRA_BITS = $7FAB10
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP             dcb $C0,$CE,$C0,$CE
VERT_DISP           dcb $10,$00,$10,$00
PROPERTIES          dcb $08,$8A,$88,$8A     ;xyppccct format

Y_SPEED             dcb $00,$10,$00,$F0     ;rest at bottom, moving up, rest at top, moving down
TIME_IN_POS         dcb $20,$68,$20,$48     ;moving up, rest at top, moving down, rest at bottom

Y_FIRE              dcb $0C,$0C,$06,$06,$F4,$F4,$FA,$FA
X_FIRE              dcb $0C,$F4,$10,$F0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap -  initialization JSL
; align sprite to middle of pipe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    LDA $E4,x
                    CLC
                    ADC #$08
                    STA $E4,x
                    DEC $D8,x
                    LDA $D8,x
                    CMP #$FF
                    BNE NO_DEC_HI_Y
                    DEC $14D4,x
NO_DEC_HI_Y         RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap -  main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "MAIN"
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR VENUS_CODE_START    ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap main routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VENUS_CODE_START    LDA $1594,x             ;A:8E76 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0918 VC:051 00 FL:24235
                    BNE LABEL24             ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0950 VC:051 00 FL:24235
                    LDA $64                 ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0966 VC:051 00 FL:24235
                    PHA                     ;A:8E20 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizcHC:0990 VC:051 00 FL:24235
                    LDA $15D0,x             ;A:8E20 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdizcHC:1012 VC:051 00 FL:24235
                    BNE LABEL23             ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdiZcHC:1044 VC:051 00 FL:24235
                    LDA #$10                ;A:8E00 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdiZcHC:1060 VC:051 00 FL:24235
                    STA $64                 ;A:8E10 X:0007 Y:0000 D:0000 DB:01 S:01F4 P:envMXdizcHC:1076 VC:051 00 FL:24235
LABEL23             JSR SUB_GFX
                    PLA                     ;A:003B X:0007 Y:00EC D:0000 DB:01 S:01F4 P:envMXdizcHC:1152 VC:054 00 FL:24235
                    STA $64                 ;A:0020 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdizcHC:1180 VC:054 00 FL:24235
LABEL24             JSR SUB_OFF_SCREEN_X3   ; off screen routine
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN27            ; /
                    LDA $1594,x             ;A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0538 VC:055 00 FL:24235
                    BNE LABEL25             ;A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0570 VC:055 00 FL:24235
                    JSL $01803A             ; 8FC1 wrapper - A:0000 X:0007 Y:00EC D:0000 DB:01 S:01F5 P:envMXdiZcHC:0586 VC:055 00 FL:24235 calls A40D then A7E4 

LABEL25             JSR SUB_GET_X_DIFF      ; face mario horizontally
                    JSR SUB_GET_Y_DIFF      ; face mario vertically
                                        
                    LDA $C2,x               ;A:0001 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdizcHC:1270 VC:056 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1300 VC:056 00 FL:24235
                    TAY                     ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1316 VC:056 00 FL:24235
                    LDA $1540,x             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1330 VC:056 00 FL:24235
                    BEQ LABEL28             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1362 VC:056 00 FL:24235
                    PHY                     ; \ call routine to spit fire if out of pipe
                    CPY #$02                ;  |
                    BNE NO_FIRE             ;  |
                    JSR SUB_FIRE_THROW      ;  |
NO_FIRE             PLY                     ; /
                    LDA Y_SPEED,y           ; \ set y speed
                    STA $AA,x               ; /
                    JSL $01801A             ; ABD8 wrapper - A:00F0 X:0007 Y:001A D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0824 VC:097 00 FL:24268 stays in pipe w/o, has long
RETURN27            RTS                     ;A:00FF X:0007 Y:00FF D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0488 VC:098 00 FL:24268
LABEL28             LDA $C2,x               ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0016 VC:057 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0046 VC:057 00 FL:24235
                    STA $00                 ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0062 VC:057 00 FL:24235
                    STZ $1594,x             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0598 VC:057 00 FL:24235
                    LDY $00                 ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0630 VC:057 00 FL:24235
                    LDA TIME_IN_POS,y       ;A:0001 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZCHC:0654 VC:057 00 FL:24235
                    STA $1540,x             ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0686 VC:057 00 FL:24235
                    INC $C2,x               ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0718 VC:057 00 FL:24235
LABEL30             RTS                     ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0762 VC:057 00 FL:24235


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX             JSR GET_DRAW_INFO       ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                    LDA $151C,x             ; \
                    ASL A                   ;  | $03 = index to frame start (frame to show * 2 tile per frame)
                    STA $03                 ; /
                    LDA $157C,x             ; \ $02 = sprite direction
                    AND #$01                ;  |
                    STA $02                 ; /
                    PHX                     ; push sprite index

                    LDX #$01                ; loop counter = (number of tiles per frame) - 1
LOOP_START          PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
                    PHA                     ; push index of current tile
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300,y             ; /
                    
                    PLX                     ; \ pull, X = index to vertical displacement and tilemap
                    LDA $01                 ;  | tile y position = sprite y location ($01) + tile displacement
                    CLC                     ;  |
                    ADC VERT_DISP,x         ;  |
                    STA $0301,y             ; /

                    LDA TILEMAP,x           ; \ store tile
                    STA $0302,y             ; / 
                    
                    TXA
                    AND #$01
                    BNE STEM

                    LDA PROPERTIES,x        ; \ get tile properties
                    LDX $02                 ;  | flip tile if necessary
                    BNE NO_FLIP             ;  | 
                    ORA #$40                ;  | 
NO_FLIP             ORA $64                 ;  | 
                    STA $0303,y             ; / store tile properties
                    BRA DONE_DRAW

STEM                LDA PROPERTIES,x        ; \ get tile properties
                    ORA $64                 ;  | 
                    STA $0303,y             ; / store tile properties

DONE_DRAW           TYA                     ; \ get index to sprite property map ($460)...
                    LSR A                   ;  |    ...we use the sprite OAM index...
                    LSR A                   ;  |    ...and divide by 4 because a 16x16 tile is 4 8x8 tiles
                    TAX                     ;  | 
                    LDA #$02                ;  |    else show a full 16 x 16 tile
                    STA $0460,x             ; /
                    
                    PLX                     ; \ pull, X = current tile of the frame we're drawing
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; / 

                    PLX                     ; pull, X = sprite index
                    LDY #$FF                ; \ why FF? (460 &= 2) 8x8 tiles maintained
                    LDA #$01                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3             ; / don't draw if offscreen
                    RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fire spit routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_FIRE_THROW      LDA $15A0,x             ; \ no fire ball if off screen
                    ORA $186C,x             ;  |
                    BNE LABEL6              ; /

                    LDA EXTRA_BITS,x
                    AND #$04
                    BEQ ONE_SHOT
TWO_SHOTS           LDA $1540,x
                    CMP #$10
                    BEQ SPIT
                    CMP #$58
                    BEQ SPIT
                    RTS            
ONE_SHOT            LDA $1540,x
                    CMP #$34
                    BEQ SPIT
                    RTS

SPIT                LDY #$E8                ;A:0218 X:0009 Y:0009 D:0000 DB:03 S:01E8 P:envMXdizcHC:0522 VC:104 00 FL:19452
                    LDA $157C,x             ;A:0218 X:0009 Y:00E8 D:0000 DB:03 S:01E8 P:eNvMXdizcHC:0538 VC:104 00 FL:19452
                    AND #$01
                    BNE LABEL9              ;A:0201 X:0009 Y:00E8 D:0000 DB:03 S:01E8 P:envMXdizcHC:0570 VC:104 00 FL:19452
                    LDY #$18                ;A:0200 X:0009 Y:00E8 D:0000 DB:03 S:01E8 P:envMXdiZcHC:0210 VC:098 00 FL:21239
LABEL9              STY $00                 ;A:0201 X:0009 Y:00E8 D:0000 DB:03 S:01E8 P:envMXdizcHC:0592 VC:104 00 FL:19452
                    LDY #$07                ;A:0201 X:0009 Y:00E8 D:0000 DB:03 S:01E8 P:envMXdizcHC:0616 VC:104 00 FL:19452
LABEL8              LDA $170B,y             ;A:0201 X:0009 Y:0007 D:0000 DB:03 S:01E8 P:envMXdizcHC:0632 VC:104 00 FL:19452
                    BEQ LABEL7              ;A:0200 X:0009 Y:0007 D:0000 DB:03 S:01E8 P:envMXdiZcHC:0664 VC:104 00 FL:19452
                    DEY                     ;A:0204 X:0009 Y:0007 D:0000 DB:03 S:01E8 P:envMXdizcHC:0088 VC:103 00 FL:19638
                    BPL LABEL8              ;A:0204 X:0009 Y:0006 D:0000 DB:03 S:01E8 P:envMXdizcHC:0102 VC:103 00 FL:19638
                    RTS                     

LABEL7              LDA #$02                ; \ projectile is a fireball
                    STA $170B,y             ; /

                    LDA $E4,x               ; \ set x position
                    CLC                     ;  |
                    ADC #$05                ;  |
                    STA $171F,y             ;  |
                    LDA $14E0,x             ;  |
                    ADC #$00                ;  |
                    STA $1733,y             ; /
                    
                    LDA $D8,x               ; \ set y position
                    CLC                     ;  |
                    ADC #$15                ;  |
                    STA $1715,y             ;  |
                    LDA $14D4,x             ;  |
                    ADC #$00                ;  |
                    STA $1729,y             ; /
                    
                    PHX                     ; \ set y speed of fire ball
                    LDA $151C,x             ;  |
                    ASL A                   ;  |
                    ASL A                   ;  |
                    ORA $157C,x             ;  |
                    TAX                     ;  |
                    LDA Y_FIRE,x            ;  |
                    STA $173D,y             ;  |
                    PLX                     ; /     
                    
                    PHX                     ; \  set x speed of fire ball
                    LDA $157C,x             ;  |
                    TAX                     ;  |
                    LDA X_FIRE,x            ;  |
                    STA $1747,y             ; /
                    PLX 

LABEL6              RTS                     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; difference in y position
; sets 151C if mario is above plant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GET_Y_DIFF      LDY #$00                ;A:25A1 X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizCHC:0130 VC:085 00 FL:924

                    LDA $D3                 ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
                    SEC                     ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
                    SBC $D8,x               ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
                    STA $0E                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
                    LDA $D4                 ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
                    SBC $14D4,x             ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
                    BPL LABEL14             ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0294 VC:085 00 FL:924
                    INY                     ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0310 VC:085 00 FL:924
LABEL14             TYA                     ;  | 
                    STA $151C,x 
                    
                    RTS                     ;A:25FF X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizcHC:0324 VC:085 00 FL:924


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; difference in x position
; sets 157C to 00 through 03 depending on the relative position of mario to the plant
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

SUB_GET_X_DIFF      LDY #$00                ;A:8505 X:0009 Y:0005 D:0000 DB:01 S:01ED P:envMXdizcHC:0464 VC:058 00 FL:138
                    LDA $D1                 ;A:8505 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0480 VC:058 00 FL:138
                    SEC                     ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0504 VC:058 00 FL:138
                    SBC $E4,x               ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZCHC:0518 VC:058 00 FL:138
                    STA $0F                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0548 VC:058 00 FL:138
                    LDA $D2                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0572 VC:058 00 FL:138
                    SBC $14E0,x             ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0596 VC:058 00 FL:138
                    BPL TO_RIGHT            ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0628 VC:058 00 FL:138
TO_LEFT             INY                     ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0644 VC:058 00 FL:138
                    LDA $0F
                    CMP #$C0
                    BCS SET_VAL
                    INY
                    INY                 
                    BRA SET_VAL
TO_RIGHT            LDA $0F
                    CMP #$50
                    BCC SET_VAL
                    INY
                    INY 
SET_VAL             TYA
                    STA $157C,x
                    RTS                     ;A:85FF X:0009 Y:0001 D:0000 DB:01 S:01ED P:envMXdizcHC:0658 VC:058 00 FL:138


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routines below can be shared by all sprites.  they are ripped from original
; SMW and poorly documented
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine helper - shared
; sets off screen flags and sets index to OAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03B75C

TABLE1              dcb $0C,$1C
TABLE2              dcb $01,$02

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
                    ADC TABLE1,y            ;  |
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
                    ORA TABLE2,y            ;  |
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
; AC0D - off screen processing code - shared
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

START_SUB           JSR SUB_80CB            ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0328 VC:176 00 FL:205
                    BEQ LABEL35             ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0480 VC:176 00 FL:205
                    LDA $5B                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0496 VC:176 00 FL:205
                    AND #$01                ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0520 VC:176 00 FL:205
                    BNE LABEL36             ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0536 VC:176 00 FL:205
                    LDA $D8,x               ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0552 VC:176 00 FL:205
                    CLC                     ;A:8A60 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0582 VC:176 00 FL:205
                    ADC #$50                ;A:8A60 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0596 VC:176 00 FL:205
                    LDA $14D4,x             ;A:8AB0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNVMXdizcHC:0612 VC:176 00 FL:205
                    ADC #$00                ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:enVMXdizcHC:0644 VC:176 00 FL:205
                    CMP #$02                ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0660 VC:176 00 FL:205
                    BPL LABEL32             ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizcHC:0676 VC:176 00 FL:205
                    LDA $167A,x             ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizcHC:0692 VC:176 00 FL:205
                    AND #$04                ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0724 VC:176 00 FL:205
                    BNE LABEL35             ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0740 VC:176 00 FL:205
                    LDA $13                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0756 VC:176 00 FL:205
                    AND #$01                ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0780 VC:176 00 FL:205
                    ORA $03                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0796 VC:176 00 FL:205
                    STA $01                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0820 VC:176 00 FL:205
                    TAY                     ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0844 VC:176 00 FL:205
                    LDA $1A                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0858 VC:176 00 FL:205
                    CLC                     ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0882 VC:176 00 FL:205
                    ADC TABLE14,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0896 VC:176 00 FL:205
                    ROL $00                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizcHC:0928 VC:176 00 FL:205
                    CMP $E4,x               ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:0966 VC:176 00 FL:205
                    PHP                     ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:0996 VC:176 00 FL:205
                    LDA $1B                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizCHC:1018 VC:176 00 FL:205
                    LSR $00                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdiZCHC:1042 VC:176 00 FL:205
                    ADC TABLE15,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizcHC:1080 VC:176 00 FL:205
                    PLP                     ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F0 P:eNvMXdizcHC:1112 VC:176 00 FL:205
                    SBC $14E0,x             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1140 VC:176 00 FL:205
                    STA $00                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1172 VC:176 00 FL:205
                    LSR $01                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1196 VC:176 00 FL:205
                    BCC LABEL31             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1234 VC:176 00 FL:205
                    EOR #$80                ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1250 VC:176 00 FL:205
                    STA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1266 VC:176 00 FL:205
LABEL31             LDA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1290 VC:176 00 FL:205
                    BPL LABEL35             ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1314 VC:176 00 FL:205
LABEL32             LDA $9E,x               
                    CMP #$1F                
                    BNE NOT_MAGIKOOPA       
                    STA $18C1                   
                    LDA #$FF                    
                    STA $18C0
NOT_MAGIKOOPA       LDA $14C8,x             ;A:FF1A X:0007 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:1044 VC:059 00 FL:2878
                    CMP #$08                ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:1076 VC:059 00 FL:2878
                    BCC LABEL34             ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1092 VC:059 00 FL:2878
                    LDY $161A,x             ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1108 VC:059 00 FL:2878
                    CPY #$FF                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1140 VC:059 00 FL:2878
                    BEQ LABEL34             ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1156 VC:059 00 FL:2878
                    LDA #$00                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1172 VC:059 00 FL:2878
                    STA $1938,y             ;A:FF00 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZcHC:1188 VC:059 00 FL:2878
LABEL34             STZ $14C8,x             ;A:FF00 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZcHC:1220 VC:059 00 FL:2878
LABEL35             RTS                     ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1336 VC:176 00 FL:205
LABEL36             LDA $167A,x             ;A:0101 X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdizCHC:0758 VC:136 00 FL:5307
                    AND #$04                ;A:0100 X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdiZCHC:0790 VC:136 00 FL:5307
                    BNE LABEL35             ;A:0100 X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdiZCHC:0806 VC:136 00 FL:5307
                    LDA $13                 ;A:0100 X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdiZCHC:0822 VC:136 00 FL:5307
                    LSR A                   ;A:0115 X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdizCHC:0846 VC:136 00 FL:5307
                    BCS LABEL35             ;A:010A X:0003 Y:006C D:0000 DB:01 S:01ED P:envMXdizCHC:0860 VC:136 00 FL:5307
                    LDA $E4,x               ;A:000B X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1092 VC:250 00 FL:5379
                    CMP #$00                ;A:0048 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1122 VC:250 00 FL:5379
                    LDA $14E0,x             ;A:0048 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizCHC:1138 VC:250 00 FL:5379
                    SBC #$00                ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1170 VC:250 00 FL:5379
                    CMP #$02                ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1186 VC:250 00 FL:5379
                    BCS LABEL32             ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:1202 VC:250 00 FL:5379
                    LDA $13                 ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:1218 VC:250 00 FL:5379
                    LSR A                   ;A:0016 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1242 VC:250 00 FL:5379
                    AND #$01                ;A:000B X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1256 VC:250 00 FL:5379
                    STA $01                 ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1272 VC:250 00 FL:5379
                    TAY                     ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1296 VC:250 00 FL:5379
                    BEQ LABEL37             ;A:0001 X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:1310 VC:250 00 FL:5379
                    LDA $9E,x               ;A:0001 X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:1326 VC:250 00 FL:5379
                    CMP #$22                ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:1356 VC:250 00 FL:5379
                    BEQ LABEL35             ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0004 VC:251 00 FL:5379
                    CMP #$24                ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0020 VC:251 00 FL:5379
                    BEQ LABEL35             ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0036 VC:251 00 FL:5379
LABEL37             LDA $1C                 ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0052 VC:251 00 FL:5379
                    CLC                     ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0076 VC:251 00 FL:5379
                    ADC TABLE12,y           ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0090 VC:251 00 FL:5379
                    ROL $00                 ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:enVMXdizCHC:0122 VC:251 00 FL:5379
                    CMP $D8,x               ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0160 VC:251 00 FL:5379
                    PHP                     ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0190 VC:251 00 FL:5379
                    LDA.W $001D             ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F2 P:eNVMXdizcHC:0212 VC:251 00 FL:5379
                    LSR $00                 ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdiZcHC:0244 VC:251 00 FL:5379
                    ADC TABLE13,y           ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdizCHC:0282 VC:251 00 FL:5379
                    PLP                     ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:envMXdiZCHC:0314 VC:251 00 FL:5379
                    SBC $14D4,x             ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0342 VC:251 00 FL:5379
                    STA $00                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0374 VC:251 00 FL:5379
                    LDY $01                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0398 VC:251 00 FL:5379
                    BEQ LABEL38             ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0422 VC:251 00 FL:5379
                    EOR #$80                ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0438 VC:251 00 FL:5379
                    STA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0454 VC:251 00 FL:5379
LABEL38             LDA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0478 VC:251 00 FL:5379
                    BPL LABEL35             ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0502 VC:251 00 FL:5379
                    BMI LABEL32             ;A:8AFF X:0002 Y:0000 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0704 VC:184 00 FL:5490


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AD30 - horizontal mario/sprite check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                     ;org $01AD30
                     
SUB_HORZ_POS1        LDY #$00                ;A:8505 X:0009 Y:0005 D:0000 DB:01 S:01ED P:envMXdizcHC:0464 VC:058 00 FL:138
                     LDA $D1                 ;A:8505 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0480 VC:058 00 FL:138
                     SEC                     ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0504 VC:058 00 FL:138
                     SBC $E4,x               ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZCHC:0518 VC:058 00 FL:138
                     STA $0F                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0548 VC:058 00 FL:138
                     LDA $D2                 ;A:8550 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdizcHC:0572 VC:058 00 FL:138
                     SBC $14E0,x             ;A:8500 X:0009 Y:0000 D:0000 DB:01 S:01ED P:envMXdiZcHC:0596 VC:058 00 FL:138
                     BPL TO_RIGHT2           ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0628 VC:058 00 FL:138
                     INY                     ;A:85FF X:0009 Y:0000 D:0000 DB:01 S:01ED P:eNvMXdizcHC:0644 VC:058 00 FL:138
TO_RIGHT2            RTS                     ;A:85FF X:0009 Y:0001 D:0000 DB:01 S:01ED P:envMXdizcHC:0658 VC:058 00 FL:138


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $0180CB 
                    
SUB_80CB            LDA $15A0,x
                    ORA $186C,x
                    RTS


