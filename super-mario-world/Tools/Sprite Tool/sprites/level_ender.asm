;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Level end trigger, by mikeyk
;;
;; Description: This sprite will cause the level to end when all the enemies on screen
;; are killed.  This version ignnores sprites that don't turn into a coin when the goal
;; tape is passed.
;;
;; Uses first extra bit: YES
;; When the first extra bit is clear, the sprite will trigger the regular exit.  When it
;; is set, the sprite will trigger the secret exit.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                          
                    
                    EXTRA_BITS = $7FAB10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                      

	EXTRA_PROP_1 = $7FAB28
	EXTRA_PROP_2 = $7FAB34
                    
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
        LDA $13C6
        BNE RETURN

        LDY #$0B
LOOP_START:
        LDA $14C8,y
	CMP #$08
	BCS TestTweakerBits
DONT_CHECK:
	DEY
        BPL LOOP_START

        LDA #$FF                ; \ set time before return to overworld
        STA $1493               ; /
        LDA EXTRA_BITS,x        ; set secret exit if first extra bit is set
        LSR A
        LSR A
        LSR A
        AND #$01
        EOR #$01
        STA $141C

        LDA EXTRA_PROP_1,x
	CMP #$01
        BEQ WALK
        DEC $13C6               ; prevent mario from walking at level end
WALK:
	LDA EXTRA_PROP_2,x
        STA $1DFB       
	
TestTweakerBits:
	LDA $1686,y
	AND #$20
	BNE DONT_CHECK
RETURN:
	RTL                    

