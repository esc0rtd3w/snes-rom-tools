;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Key / Keyhole generator, by mikeyk
;;
;; Description: This sprite will turn into either a key or a keyhole when all the enemies
;; on screen are killed.
;;
;; Uses first extra bit: YES
;; When the first extra bit is clear, the sprite will turn into a key.  When the first
;; extra bit is set, it will turn into a keyhole.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            
                    EXTRA_BITS = $7FAB10
                    NEW_SPRITE_NUM = $7FAB9E            
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "INIT"
                    RTL                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    dcb "MAIN"  
                    LDA $1493
                    BNE RETURN
                    
                    STX $00
                    LDA NEW_SPRITE_NUM,x
                    STA $01

                    LDY #$0B    
LOOP_START          CPY $00
                    BEQ DONT_CHECK
                    LDA $190F,y
                    AND #$40
                    BNE DONT_CHECK                  
                    LDA $14C8,y
                    BNE RETURN
DONT_CHECK          DEY
                    BPL LOOP_START                  

                    LDA EXTRA_BITS,x
                    AND #$04
                    BNE HOLE
                    JSR KEY_GEN
                    BRA RETURN
HOLE                JSR KEYHOLE_GEN

RETURN              RTL                    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; key gen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KEY_GEN             LDA #$09                ; \ set sprite status for new sprite
                    STA $14C8,x             ; /
                    LDA #$80                ; \ set sprite number for new sprite
                    STA $9E,x               ; /

                    JSL $07F7D2             ; reset sprite tables

                    JSR SUB_SMOKE
                    
                    LDA #$10                ; \ sound effect
                    STA $1DF9               ; /

RETURN67            RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; keyhole gen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KEYHOLE_GEN         LDA #$08                ; \ set sprite status for new sprite
                    STA $14C8,x             ; /
                    LDA #$0E                ; \ set sprite number for new sprite
                    STA $9E,x               ; /

                    JSL $07F7D2             ; reset sprite tables

                    JSR SUB_SMOKE

                    LDA #$10                ; \ sound effect
                    STA $1DF9               ; /

RETURN69            RTS                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display smoke effect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_SMOKE           LDY #$03                ; \ find a free slot to display effect
FINDFREE            LDA $17C0,y             ;  |
                    BEQ FOUNDONE            ;  |
                    DEY                     ;  |
                    BPL FINDFREE            ;  |
                    RTS                     ; / return if no slots open

FOUNDONE            LDA #$01                ; \ set effect graphic to smoke graphic
                    STA $17C0,y             ; /
                    LDA #$1B                ; \ set time to show smoke
                    STA $17CC,y             ; /
                    LDA $D8,x               ; \ smoke y position = generator y position
                    STA $17C4,y             ; /
                    LDA $E4,x               ; \ load generator x position and store it for later
                    STA $17C8,y             ; /
                    RTS
                    