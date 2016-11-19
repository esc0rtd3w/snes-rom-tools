;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sideways Piranha Plant, by mikeyk
;;
;; Description: A piranha plant that comes out of horizontal pipes.
;;
;; Uses first extra bit: YES
;; It's direction depends on the first extra bit.  If it is set it will travel to the
;; right to come out of the pipe.  Otherwise it will travel left to come out of the pipe.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
                    EXTRA_BITS = $7FAB10                   
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; venus fire trap -  initialization JSL
; align sprite to middle of pipe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    LDA EXTRA_BITS,x
                    AND #$04
                    BNE OUT_RIGHT
                    INC $E4,x
                    INC $E4,x
                    BRA VERTICAL

OUT_RIGHT           DEC $E4,x
                    DEC $E4,x

VERTICAL            ;LDA $D8,x
                    ;CLC
                    ;ADC #$E8
                    ;STA $D8,x
                    ;LDA $14D4,x
                    ;ADC #$FF
                    ;STA $14D4,x
                    RTL


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

X_SPEED             dcb $00,$F0,$00,$10     ;rest at bottom, moving up, rest at top, moving down
TIME_IN_POS         dcb $22,$30,$22,$30     ;moving up, rest at top, moving down, rest at bottom


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

LABEL25             LDA $C2,x               ;A:0001 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdizcHC:1270 VC:056 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1300 VC:056 00 FL:24235
                    TAY                     ;A:0000 X:0007 Y:0007 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1316 VC:056 00 FL:24235
                    LDA $1540,x             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1330 VC:056 00 FL:24235
                    BEQ LABEL28             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:1362 VC:056 00 FL:24235

                    LDA X_SPEED,y           ; \ set x speed
                    STA $B6,x               ; /
                    
                    LDA EXTRA_BITS,x        ; invert x speed if extra bits set
                    AND #$04
                    BEQ NO_FLIP2
                    LDA $B6,x
                    EOR #$FF
                    INC A
                    STA $B6,x
                    
NO_FLIP2            STZ $AA,x
                    
                    
                    ;JSL $01801A             ; ABD8 wrapper - A:00F0 X:0007 Y:001A D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0824 VC:097 00 FL:24268 stays in pipe w/o, has long
                    JSL $01802A
                    LDA $D8,x
                    AND #$F0
                    ORA #$08
                    STA $D8,x
RETURN27            RTS                     ;A:00FF X:0007 Y:00FF D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0488 VC:098 00 FL:24268
LABEL28             LDA $C2,x               ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0016 VC:057 00 FL:24235
                    AND #$03                ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0046 VC:057 00 FL:24235
                    STA $00                 ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0062 VC:057 00 FL:24235
                    BNE LABEL29             ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0086 VC:057 00 FL:24235
                    JSR SUB_HORZ_POS1       ;A:0000 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZcHC:0102 VC:057 00 FL:24235 nothing w/o
                    LDA $0F                 ;A:00FF X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizcHC:0464 VC:057 00 FL:24235
                    CLC                     ;A:00B8 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0488 VC:057 00 FL:24235
                    ADC #$1B                ;A:00B8 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0502 VC:057 00 FL:24235
                    CMP #$37                ;A:00D3 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizcHC:0518 VC:057 00 FL:24235
                    LDA #$01                ;A:00D3 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:eNvMXdizCHC:0534 VC:057 00 FL:24235
                    STA $1594,x             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0550 VC:057 00 FL:24235
                    ;BCC LABEL30             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0582 VC:057 00 FL:24235
LABEL29             STZ $1594,x             ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0598 VC:057 00 FL:24235
                    LDY $00                 ;A:0001 X:0007 Y:0001 D:0000 DB:01 S:01F5 P:envMXdizCHC:0630 VC:057 00 FL:24235
                    LDA TIME_IN_POS,y       ;A:0001 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZCHC:0654 VC:057 00 FL:24235
                    STA $1540,x             ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0686 VC:057 00 FL:24235
                    INC $C2,x               ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0718 VC:057 00 FL:24235
LABEL30             RTS                     ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0762 VC:057 00 FL:24235


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
TILEMAP             dcb $A4,$A0,$A4,$A2,$A4,$A0,$A4,$A2
HORIZ_DISP          dcb $00,$10,$00,$10,$10,$00,$10,$00
PROPERTIES          dcb $4B,$49,$4B,$49,$0B,$09,$0B,$09     ;xyppccct format

SUB_GFX             JSR GET_DRAW_INFO       ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                    LDA $1540,x             ; \
                    LSR A
                    LSR A
                    LSR A
                    AND #$01
                    ASL A
                    STA $03                 ; /
                    LDA $157C,x             ; \ $02 = sprite direction
                    AND #$01                ;  |
                    STA $02                 ; /
                    PHX                     ; push sprite index
                    
                    LDA EXTRA_BITS,x
                    AND #$04
                    BNE NOT_EXTRA
                    LDA $03 
                    CLC
                    ADC #$04
                    STA $03
NOT_EXTRA                    

                    LDX #$01                ; loop counter = (number of tiles per frame) - 1
LOOP_START          PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
                    TAX

                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    CLC                     ;  |
                    ADC HORIZ_DISP,x        ;  |
                    STA $0300,y             ; /
                    
                    LDA $01                 ;  | tile y position = sprite y location ($01) + tile displacement
                    STA $0301,y             ; /

                    LDA TILEMAP,x           ; \ store tile
                    STA $0302,y             ; / 

                    LDA PROPERTIES,x        ; \ get tile properties
                    ORA #$20                 ;  | 
                    STA $0303,y             ; / store tile properties

                    TYA                     ; \ get index to sprite property map ($460)...
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


