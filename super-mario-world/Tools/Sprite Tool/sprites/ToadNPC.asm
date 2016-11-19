;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NPC sprite v3.0, by Dispari Scuro
;;
;; This sprite displays a message when Mario touches it and presses UP.
;; It cannot hurt Mario and cannot be killed.
;; Read below to figure out how to use and fully customize this sprite!
;;
;; When placing the sprite in a level, the sprite uses three different variables
;; to determine which message it displays. Although this system is a little
;; complicated, this is to ensure that users use as few config files as possible.
;; With this system, you can have as many as 32 NPCs per level which all display
;; different messages, all with one config file!
;;
;; Firstly, the "Extra Info" is used to determine which message the sprite
;; displays from its level. With the new system, there's no need to specifically
;; display the "you found Yoshi" message, because it can be done directly. The ability
;; to display no message at all has (regrettably) also been removed. If you need an NPC
;; that displays no message, you will have to use the old NPC sprite or edit the code.
;; Extra Info is set when you create a sprite in Lunar Magic. Normally when you insert
;; a custom sprite, you put Extra Info as 02. This sprite has different behavior if you
;; set it as 03 instead.
;;
;; Extra Info:
;; 02 = Message 1
;; 03 = Message 2
;;
;; After you determine which message the sprite will read from, you need to place it
;; in a good X position on the screen. When placing the sprite, the X position will
;; determine part one of which level the sprite actually reads from. There are 16
;; unique X positions possible per screen, which allows up to 16 unique messages.
;; The number starts over on the next screen. So if your sprite is in the first
;; position but on page 4, it's still considered 0 (position 1). Think of it like
;; the original messagebox, which changed its message based on its X position.
;; Only instead of only displaying one of two messages, you display one of 16.
;; In combination with the Extra Info, that's one of 32.
;;
;; The reason for the X position is to determine which color on the palette to read
;; from to use. If you set the X position for a sprite to 0, it will use the first
;; color on the palette as a reference. Therefore, you can set color 0 to color 24
;; to make the sprite read messages from level 24. This DOES mean that you can use
;; ExAnimation to palette animate this color and generate "random" messages! Please
;; note the special handling for levels over 24. For any level number over 24,
;; subtract DC from the level number. For example, level 105 would be 29. Note
;; that to properly use the palette, you have to set the color so that its SNES
;; RGB value is the level you want it to be, times 100. So if you want to read
;; from level 20, the SNES RGB value needs to be 2000. The easiest way to do this
;; is to set an ExAnimation palette animation of 2000 and then check the actual
;; palette to see what to paste. 2000 for instance is 0 red, 0 green, 64 blue.
;;
;; Here are some examples of how these three varibles come together. For the
;; sake of this example, we will assume the sprite is still reading from palette E.
;;
;; Example 1:
;; Extra Info is 2. X position is 6 (on screen 1). Palette E6 is 1200. This means the
;; sprite will display message 1 from level 12. X position is 6 so it reads from E6.
;; E6 says to read from level 12.
;;
;; Example 2:
;; Extra Info is 3. X position is 42 (on screen 3). Palette EB is 3200. This means the
;; sprite will display message 2 from level 10E. X position is 11 (11th spot on screen
;; 3). EB (B = 11) says to read from level 10E (32 + DC = 10E).
;;
;; If you're still confused about how to set the messages, check the included demo file
;; to see just how all the NPCs are set.
;;
;; For additional configuration for sprites which you may want to vary on an individual
;; basis and not just an overall behavior (unlike the sound the sprites make when spoken
;; to, which should remain the same across all sprites), use the following variables
;; found in the config file. With this, you can have a couple different NPCs with
;; varying behavior without having to change the ASM file.
;;
;; Extra Byte Property 1:
;; 00 = Sprite is stationary (if stationary, sprite always faces Mario).
;; 01 = Sprite "wanders" with random movement. Sprite will walk for random amounts
;; of time and stop if configured to do so. It will also turn around at random.
;; Anything else = Sprite moves back and forth, and this is how long before it turns
;; around and starts in the other direction. Note that the NPC's turn timer will be
;; reset if he touches an object or a cliff (if set to stay on ledges). This is to
;; prevent the NPCs from "hugging" the wall.
;;
;; Extra Byte Property 2:
;; 00 = Sprite displays one message when spoken to.
;; Anything else = Sprite displays two messages when spoken to, one after the other.
;; Note that if sprite is set to display level message two, using this feature will cause
;; it to display level message two and then the "you found Yoshi" message.
;;
;; For all other configurables, see below!
;;
;; Thank yous to:
;; andyk250
;; Heisanevilgenius
;; S.N.N.
;; mikeyk
;;
;; Based on the following sprite(s):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shy Guy, by mikeyk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SMB2 Birdo, by mikeyk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Palenemy Lakitu, by Glyph Phoenix and Davros.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Configurables for the sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	MessagePalette = $E0		; Which palette to read from for messages displayed.
								; Change to suit your needs. Please use the palette you
								; want to use, followed by a zero. If you want to use
								; palette D, change this to $D0
								; DEFAULT: $E0
	
	SoundEffect = $22			; Which sound to play. Use in conjunction with SoundBank.
								; Check online to find a list of sound effects. 00 should
								; play no sound at all.
								; DEFAULT: $22
								
	SoundBank = $1DFC			; Which sound bank to read from.
								; Acceptible values: $1DF9, $1DFA, $1DFB, $1DFC
								; DEFAULT: $1DFC
	
	SpriteSpeed dcb $08,$F8		; This is how fast the sprite walks.
								; DEFAULT: $08,$F8
								
	SpriteStop = $41			; How long a sprite stops before it turns around.
								; Set this to 00 if you don't want NPCs to stop
								; before turning around.
								; DEFAULT: $41
								
	DirAtStart = $FF			; How does the sprite start off? The classic NPC would
								; always start off walking to the right no matter what.
								; The new version is configurable. By default it will
								; walk toward Mario at the start. If you don't like this
								; behavior, you can set 00 so it always walks right and
								; 01 so it always walks left. The default walking toward
								; Mario is so the sprite doesn't walk off screen and
								; disappear.
								; DEFAULT: $FF
								
	StayOnLedges = $01			; Does the NPC stay on ledges? 01 for yes, 00 for no.
								; DEFAULT: $01
								
	SpriteFollows = $00			; Does the NPC follow Mario? If yes, sprite will always
								; go where Mario does and stay as close to him as possible
								; if speed allows. When close to Mario, sprite will stop.
								; This will also override the walking distance or sprite's
								; configuration to not move at all. Sprite will also
								; ignore the StayOnLedges setting and always drop off them.
								; 00 turns this feature off and sprite will not follow.
								; If not zero, this is how close the sprite needs to be to
								; Mario before it stops following. If this is set, Extra
								; Byte Property 1 needs to be 00 or the NPC will wig out.
								; DEFAULT: $00
								
	SpriteJumps = $C0			; Does the NPC jump when following you if it runs into a
								; wall? Use this feature to make sprites that can more
								; easily follow Mario. If turned off, sprites can only
								; walk to follow Mario. If turned on, sprites will jump
								; when they collide with a wall and still aren't close
								; to Mario. This ensures the sprite can still follow Mario
								; through levels that have cliffs and ledges. 00 turns
								; this feature off, and any value other than 00 is how
								; high the sprite jumps (and turns the feature on).
								; This feature has no effect unless the sprite follows.
								; Note that jump numbers should be higher than 80.
								; Higher numbers = less height to the jump.
								; DEFAULT: $C0
								
	JumpSound = $00				; The sound to when the sprite jumps (if it jumps at all).
								; Setting this to 01 will make it play Mario's standard
								; jumping sound. Setting it to 00 makes it play nothing.
								; DEFAULT: $00
								
	JumpBank = $1DFA			; Sound bank to use for the jumping noise.
								; Acceptible values: $1DF9, $1DFA, $1DFB, $1DFC
								; DEFAULT: $1DFA
								
	ButtonToPush = $08			; This controls what you must push to open a messagebox.
								; Edit this to suit your button-pushing needs:
								; 01 = Right
								; 02 = Left
								; 04 = Down
								; 08 = Up
								; 10 = Start
								; 20 = Select
								; 00 = R and L
								; 40 = Y and X
								; 80 = B and A
								; DEFAULT: $08
								
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic mikey stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								
	UpdateSpritePos = $01802A  
	MarioSprInteract = $01A7DC
	GetSpriteClippingA = $03B69F
	FinishOAMWrite = $01B7B3
	
    ExtraProperty1 = $7FAB28
	ExtraProperty2 = $7FAB34
	RAM_SpriteDir = $157C
	RAM_SprTurnTimer = $15AC
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dispari's stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ExtraInfo = $7FAB10
	X_Position = $1504
	Message2_Timer = $163E
	RAM_SprStopTimer = $1564
	GetRand = $01ACF9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        dcb "INIT"
        
        LDA #DirAtStart
        CMP #$FF
        BNE SetDir
        
        JSR SUB_GET_DIR
        TYA
        STA $157C,x
        BRA DoneWithDir
        
    SetDir:
        LDA #DirAtStart
        STA $157C,x
        
	DoneWithDir:
		LDA $167A,x
		STA $1528,x
	
		LDA #$01		
		STA $151C,x
		
		LDA $E4,x				; \ Grab X position
		LSR A					; |
		LSR A					; |
		LSR A					; |
		LSR A					; |
		STA X_Position,x		; / Save for later
		
		LDA ExtraProperty1,x	; \
		CMP #$01				; | If sprite is set to random wander mode...
		BNE NormalMove			; |
		JSL GetRand				; |
		STA RAM_SprTurnTimer,x	; | ...issue random walking duration.
		BRA InitReturn			; /
		
	NormalMove:
		LDA ExtraProperty1,x	; \ Load walking duration into RAM address as a timer
		STA RAM_SprTurnTimer,x	; /
		
	InitReturn:
        RTL                 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        dcb "MAIN"                                    
        PHB                  
        PHK                  
        PLB                  
        JSR SpriteMainSub    
        PLB                  
        RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:
	RTS
SpriteMainSub:
	LDA ExtraProperty1,x	; \ 
	BNE NormalCode			; | If NPC is stationary...
	JSR SUB_GET_DIR         ; | ...always face Mario.
    TYA                     ; | 
    STA $157C,x             ; /

NormalCode:
	JSR SubGfx
	
    LDA $9D                 ; \ if sprites locked, return
    BNE Return              ; /

    JSR SubOffScreen		; Handle off screen situation
	INC $1570,x

StartSpeed:
	LDA #SpriteFollows		; \ If sprite isn't set to follow...
	BEQ NotFollow			; / ...jump to normal code.
	
	JSR SUB_GET_DIR         ; \
    TYA                     ; | Always face Mario. 
    STA $157C,x             ; /

	JSR Proximity			; \ If NPC is close to Mario...
	BEQ SetSpeed			; |
	STZ $B6,x				; / ...don't move.
	
NotFollow:
    LDA ExtraProperty1,x	; \ If NPC is stationary...
    BNE HandleTurnaround	; |
    STZ $B6,x				; / ...set speed as 0.
    BRA DoneWithSpeed
    
HandleTurnaround:
    LDA RAM_SprStopTimer,x	; \ If sprite has stopped long enough...
    CMP #$01				; |
    BEQ RestartSpriteMove	; / ...restart its movement
    
    LDA RAM_SprTurnTimer,x	; \ If turn timer is zero...
    BNE SetSpeed			; |
    LDA #SpriteStop			; | ...and sprite doesn't stop...
	BEQ RestartSpriteMove	; / ...just turn around.
    
    LDA RAM_SprStopTimer,x	; \ If sprite isn't already stopped...
    BNE SetSpeed			; /
    LDA #SpriteStop			; \ ...start the stop timer.
    STA RAM_SprStopTimer,x	; /
    BRA SetSpeed
    
RestartSpriteMove:
	STZ RAM_SprStopTimer,x
    JSR SpriteTurning		; Turn the NPC around.
    
    LDA ExtraProperty1,x	; \
	CMP #$01				; | If sprite is set to random wander mode...
	BNE NormalMove2			; |
	JSL GetRand				; |
	STA RAM_SprTurnTimer,x	; | ...issue random walking duration.
	BRA SetSpeed			; /
    
NormalMove2:
    LDA ExtraProperty1,x 	; |
    STA RAM_SprTurnTimer,x	; / ...and reset turn timer.
    
SetSpeed:
    LDY $157C,x             ; Set x speed based on direction
    LDA SpriteSpeed,y     
    STA $B6,x
    
CheckIfStopped:
    LDA RAM_SprStopTimer,x	; \
    CMP #$02				; | Reset speed to zero...
    BCC DoneWithSpeed		; | ...if Stop Timer is going.
    STZ $B6,x				; /

DoneWithSpeed:	
	LDA $1588,x             ; If sprite is in contact with an object...
    AND #$03                  
    BEQ NoObjContact
    
    LDA #SpriteFollows		; \ If sprite isn't set to follow...
    BEQ ChangeDir			; / ...just change direction.
    LDA #SpriteJumps		; \ If sprite isn't set to jump...
    BEQ StopSprite			; / ...just walk aimlessly into the wall.
    
CheckJump:
	LDA $1588,x             ; \ If sprite is in air...
    AND #$04				; |
    BEQ StopSprite			; / ...don't jump again.
    LDA #SpriteJumps		; \ Otherwise, make sprite jump to clear wall (or try)
    STA $AA,x				; /
    LDA #JumpSound			; \ Play a sound.
	STA JumpBank			; /
    
StopSprite:
	LDA $157C,x             ; \
	EOR #$01				; | This grab's the sprite's speed and reverses it
	TAY						; | but doesn't change direction. This makes sure
    LDA SpriteSpeed,y		; | the sprite doesn't pass through walls, and
    STA $B6,x				; | instead just stops being able to move.
    BRA NoObjContact		; /

ChangeDir:
	JSR SpriteTurning		; Change direction
	
	LDY $157C,x             ; Set x speed based on direction
    LDA SpriteSpeed,y     
    STA $B6,x
    
    STZ RAM_SprStopTimer,x	; Halt the stop timer if it's going for some reason.
    
    LDA ExtraProperty1,x	; \
	CMP #$01				; | If sprite is set to random wander mode...
	BNE NormalMove3			; |
	JSL GetRand				; |
	STA RAM_SprTurnTimer,x	; | ...issue random walking duration.
	CMP #$20				; \
	BCS NoObjContact		; |
	LDA #$20				; | Make sure turn time is at least 20.
	STA RAM_SprTurnTimer,x	; /
	BRA NoObjContact
    
NormalMove3:
    LDA ExtraProperty1,x	; \ Load walking duration into RAM address as a timer
	STA RAM_SprTurnTimer,x	; /

NoObjContact:
	LDA #SpriteFollows		; \ Don't bother with ledges if following.
	BNE NoLedges			; /
	
	JSR MaybeStayOnLedges
	
NoLedges:
	JSL UpdateSpritePos     ; Update position based on speed values

	LDA $1588,x             ; if on the ground, reset the turn counter
    AND #$04
    BEQ NotOnGround
	STZ $AA,x
	STZ $151C,x				; Reset turning flag (used if sprite stays on ledges)

NotOnGround:
	LDA $1528,x
	STA $167A,x

	JSL MarioSprInteract	; \ Check for sprite contact
	BCC ReturnZ				; /
	
	LDA Message2_Timer,x	; \ Handle second message if needed
	BNE Message2			; /
	
	LDA $15					; \ Check if Mario is pressing UP...
	AND #ButtonToPush		; | or whatever button you defined
	BEQ ReturnZ				; /
	LDA #SoundEffect		; \ Play a sound.
	STA SoundBank			; /
	
	LDA #MessagePalette		; \
	CLC						; | Figure out which palette to use for level
	ADC X_Position,x		; /
    STA $2121               ;
    LDA $213B               ; \ palette to read data
    LDA $213B               ; /
    STA $08					; Store so we know which level to read from
	
	LDA ExtraInfo,x			; \ Get Extra Info
	AND #$04				; /
	BNE Scratch_1			; \
	LDA #$01				; | Extra Info is kinda wacky
	BRA Scratch_2			; /
	
Scratch_1:
	LDA #$02
	
Scratch_2:
	STA $09					; Scratch RAM is a go
	
	LDA $08					; \ This allows you to read from any level
	STA $13BF				; | you want by tricking the game into thinking
							; | the level's number is something other than
							; / what it actually is.
	
	LDA $09
	STA $1426				; Display message specified
	LDA #$0F				; \ Set double message
	STA Message2_Timer,x	; /
ReturnZ:
	RTS
	
Message2:					; NOTE: Repeat code is fail, but the alternative
							; is spaghetti code.
							
	LDA ExtraProperty2,x	; \ If not set to display two messages...
	BEQ ReturnX				; / ...return.
	
	LDA #MessagePalette		; \
	CLC						; | Figure out which palette to use for level
	ADC X_Position,x		; /
    STA $2121               ;
    LDA $213B               ; \ palette to read data
    LDA $213B               ; /
    STA $08					; Store so we know which level to read from
	
	LDA ExtraInfo,x			; \ Get Extra Info
	AND #$04				; /
	BNE Scratch_3			; \
	LDA #$01				; | Extra Info is kinda wacky
	BRA Scratch_4			; /
	
Scratch_3:
	LDA #$02
	
Scratch_4:
	CLC
	ADC #$01
	STA $09					; Scratch RAM is a go
	
	LDA $08					; \ This allows you to read from any level
	STA $13BF				; | you want by tricking the game into thinking
							; | the level's number is something other than
							; / what it actually is.
	
	LDA $09
	STA $1426				; Display second message
	STZ Message2_Timer,x
	
ReturnX:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Schwa's proximity routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EORTBLI	dcb $FF,$00

Proximity
	LDA $14E0,x			;sprite x high
	XBA
	LDA $E4,x			;sprite x low
	REP #$20			;16bitA
	SEC
	SBC $94				;sub mario x
	SEP #$20			;8bitA
	PHA					;preserve for routine jump
	JSR SUB_GET_DIR		;horizontal distance
	PLA					;restore
	EOR EORTBLI,y		;invert if needed
	CMP #SpriteFollows	;range is defined at beginning of script
	BCS PRange_Out1		;return not within range
	LDA #$01			;Z = 0
	RTS

PRange_Out1:			
	LDA $E4,x			; \ Schwa's code is a little flawed.
	CMP $94				; | If the sprite and Mario share the same X position
	BNE PRange_Out		; | it considers them not in range.
	LDA #$01			; / This fixes that.
	RTS

PRange_Out:
	LDA #$00			;Z = 1
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some mikey routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteTurning:
		LDA $157C,x		; \ If sprite is going right...
		BNE GoLeft		; / ...go left.
		LDA #$01		; \ Otherwise go right.
		STA $157C,x		; /
		RTS
		
GoLeft:
		LDA #$00
		STA $157C,x
        RTS
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ledges
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MaybeStayOnLedges:	
	LDA #StayOnLedges		; Stay on ledges if set   
	BEQ NoFlipDirection
	LDA $1588,x             ; If the sprite is in the air
	ORA $151C,x             ;   and not already turning
	BNE NoFlipDirection
	JSR SpriteTurning 		;   flip direction
    LDA #$01				;   set turning flag
	STA $151C,x
	
	STZ RAM_SprStopTimer,x	; Halt the stop timer if it's going for some reason.
	
	LDA ExtraProperty1,x	; \
	CMP #$01				; | If sprite is set to random wander mode...
	BNE NormalMove4			; |
	JSL GetRand				; |
	STA RAM_SprTurnTimer,x	; / ...issue random walking duration.
	CMP #$20				; \
	BCS NoFlipDirection		; |
	LDA #$20				; | Make sure turn time is at least 20.
	STA RAM_SprTurnTimer,x	; /
	BRA NoFlipDirection
	
NormalMove4:
	LDA ExtraProperty1,x	; \ Load walking duration into RAM address as a timer
	STA RAM_SprTurnTimer,x	; /
	
NoFlipDirection:
	RTS
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B817 - horizontal mario/sprite check - shared
; Y = 1 if mario left of sprite??
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GET_DIR         LDY #$00                ;A:25D0 X:0006 Y:0001 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1020 VC:097 00 FL:31642
                    LDA $94                 ;A:25D0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1036 VC:097 00 FL:31642
                    SEC                     ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1060 VC:097 00 FL:31642
                    SBC $E4,x               ;A:25F0 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizCHC:1074 VC:097 00 FL:31642
                    STA $0F                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1104 VC:097 00 FL:31642
                    LDA $95                 ;A:25F4 X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1128 VC:097 00 FL:31642
                    SBC $14E0,x             ;A:2500 X:0006 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZcHC:1152 VC:097 00 FL:31642
                    BPL LABEL16             ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1184 VC:097 00 FL:31642
                    INY                     ;A:25FF X:0006 Y:0000 D:0000 DB:03 S:01ED P:eNvMXdizcHC:1200 VC:097 00 FL:31642
LABEL16             RTS                     ;A:25FF X:0006 Y:0001 D:0000 DB:03 S:01ED P:envMXdizcHC:1214 VC:097 00 FL:31642
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP             dcb $80,$A0	; Walking 1 (upper, lower) standing actually...
		    dcb $82,$A2	; Walking 2 (upper, lower)
		    dcb $84,$A4	; Walking 3 (upper, lower)

VERT_DISP           dcb $F0,$00
		    dcb $F0,$00
		    dcb $F0,$00

PROPERTIES          dcb $40,$00             ;xyppccct format
  
SubGfx             
		JSR GetDrawInfo         ; after: Y = index to sprite tile map ($300)
                                ;      $00 = sprite x position relative to screen boarder 
                                ;      $01 = sprite y position relative to screen boarder  
        LDA $1602,x             ; \
        ASL A                   ; | $03 = index to frame start (frame to show * 2 tile per frame)
        STA $03                 ; /
        
        ;LDA ExtraProperty1,x	; \ If NPC is stationary, don't animate
        ;BEQ SpriteDir			; /
        ;LDA RAM_SprStopTimer,x	; \ If NPC is stopped, don't animate
        LDA $B6,x				; \ If NPC isn't moving, don't animate
        BEQ	SpriteDir			; /
        LDA $14					; Frame Counter
		LSR A					; Change every 4 frames
		LSR A
		LSR A
		AND #$01				; 2 walking frames
		ASL A					; Sprite is made up of 2 tiles
		INC A
		INC A
		STA $03
        
SpriteDir:
        LDA $157C,x             ; \ $02 = sprite direction
        STA $02                 ; /
        PHX                     ; push sprite index
        LDX #$01                ; loop counter = (number of tiles per frame) - 1
        
LOOP_START
        PHX                     ; push current tile number
        TXA                     ; \ X = index to horizontal displacement
        ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
        
FACING_LEFT
        TAX                     ; \                     
        LDA $00                 ; | tile x position = sprite x location ($00)
		STA $0300,y             ; /
                    
        LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
        CLC                     ; |
        ADC VERT_DISP,x         ; |
        STA $0301,y             ; /
        
        LDA TILEMAP,x           ; \ store tile
        STA $0302,y             ; / 

        LDX $02                 ; \
        LDA PROPERTIES,x        ;  | get tile properties using sprite direction
        LDX $15E9               ;  |
        ORA $15F6,x             ;  | get palette info
        ORA $64                 ;  | put in level properties
        STA $0303,y             ; / store tile properties


		TYA						; Set tile size
        LSR A
        LSR A
        TAX
        LDA #$02
        STA $0460,x
	
        PLX                     ; \ pull, X = current tile of the frame we're drawing
        INY                     ;  | increase index to sprite tile map ($300)...
        INY                     ;  |    ...we wrote 1 16x16 tile...
        INY                     ;  |    ...sprite OAM is 8x8...
        INY                     ;  |    ...so increment 4 times
        DEX                     ;  | go to next tile of frame and loop
        BPL LOOP_START          ; / 

        PLX                     ; pull, X = sprite index
        LDY #$FF                ; \ 02, because we didn't write to 460 yet
        LDA #$02                ;  | A = number of tiles drawn - 1
        JSL $01B7B3             ; / don't draw if offscreen
        RTS                     ; return
                    
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
 	
DATA_03B75C:
	dcb $0C,$1C
DATA_03B75E:
	dcb $01,$02

GetDrawInfo:
	STZ $186C,X             ; Reset sprite offscreen flag, vertical 
        STZ $15A0,X             ; Reset sprite offscreen flag, horizontal 
        LDA $E4,X               ; \ 
        CMP $1A                 ;  | Set horizontal offscreen if necessary 
        LDA $14E0,X             ;  | 
        SBC $1B                 ;  | 
        BEQ ADDR_03B774         ;  | 
        INC $15A0,X             ; / 
ADDR_03B774:
        LDA $14E0,X             ; \ 
        XBA                     ;  | Mark sprite invalid if far enough off screen 
        LDA $E4,X               ;  | 
        REP #$20                ; Accum (16 bit) 
        SEC                     ;  | 
        SBC $1A                 ;  | 
        CLC                     ;  | 
        ADC.W #$0040            ;  | 
        CMP.W #$0180            ;  | 
        SEP #$20                ; Accum (8 bit) 
        ROL                     ;  | 
        AND.B #$01              ;  | 
        STA $15C4,X             ;  | 
        BNE ADDR_03B7CF         ; /  
        LDY.B #$00              ; \ set up loop: 
        LDA $1662,X             ;  |  
        AND.B #$20              ;  | if not smushed (1662 & 0x20), go through loop twice 
        BEQ ADDR_03B79A         ;  | else, go through loop once 
        INY                     ; /                        
ADDR_03B79A:
        LDA $D8,X               ; \                        
        CLC                     ;  | set vertical offscree 
        ADC DATA_03B75C,Y       ;  |                       
        PHP                     ;  |                       
        CMP $1C                 ;  | (vert screen boundry) 
        ROL $00                 ;  |                       
        PLP                     ;  |                       
        LDA $14D4,X             ;  |                       
        ADC.B #$00              ;  |                       
        LSR $00                 ;  |                       
        SBC $1D                 ;  |                       
        BEQ ADDR_03B7BA         ;  |                       
        LDA $186C,X             ;  | (vert offscreen)      
        ORA DATA_03B75E,Y       ;  |                       
        STA $186C,X             ;  |                       
ADDR_03B7BA:
        DEY                     ;  |                       
        BPL ADDR_03B79A         ; /                        
        LDY $15EA,X             ; get offset to sprite OAM                           
        LDA $E4,X               ; \ 
        SEC                     ;  |                                                     
        SBC $1A                 ;  |                                                    
        STA $00                 ; / $00 = sprite x position relative to screen boarder 
        LDA $D8,X               ; \                                                     
        SEC                     ;  |                                                     
        SBC $1C                 ;  |                                                    
        STA $01                 ; / $01 = sprite y position relative to screen boarder 
        RTS                     ; Return 

ADDR_03B7CF:
        PLA                     ; \ Return from *main gfx routine* subroutine... 
        PLA                     ;  |    ...(not just this subroutine) 
        RTS                     ; / 

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUB_OFF_SCREEN
; This subroutine deals with sprites that have moved off screen
; It is adapted from the subroutine at $01AC0D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
DATA_01AC0D:
	dcb $40,$B0
DATA_01AC0F:
	dcb $01,$FF
DATA_01AC11:
        dcb $30,$C0
DATA_01AC19:
        dcb $01,$FF

SubOffScreen:
	JSR IsSprOnScreen       ; \ if sprite is not off screen, return                                       
        BEQ Return01ACA4        ; /                                                                           
        LDA $5B                 ; \  vertical level                                    
        AND #$01                ;  |                                                                           
        BNE VerticalLevel       ; /                                                                           
        LDA $D8,X               ; \                                                                           
        CLC                     ;  |                                                                           
        ADC #$50                ;  | if the sprite has gone off the bottom of the level...                     
        LDA $14D4,X             ;  | (if adding 0x50 to the sprite y position would make the high byte >= 2)   
        ADC #$00                ;  |                                                                           
        CMP #$02                ;  |                                                                           
        BPL OffScrEraseSprite   ; /    ...erase the sprite                                                    
        LDA $167A,X             ; \ if "process offscreen" flag is set, return                                
        AND #$04                ;  |                                                                           
        BNE Return01ACA4        ; /                                                                           
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
ADDR_01AC7C:
        LDA $00                   
        BPL Return01ACA4          
OffScrEraseSprite:
	LDA $14C8,X             ; \ If sprite status < 8, permanently erase sprite 
        CMP #$08                ;  | 
        BCC OffScrKillSprite    ; / 
        LDY $161A,X             
        CPY #$FF                
        BEQ OffScrKillSprite      
        LDA #$00                
        STA $1938,Y             
OffScrKillSprite:
	STZ $14C8,X             ; Erase sprite 
Return01ACA4:
	RTS                       

VerticalLevel:
	LDA $167A,X             ; \ If "process offscreen" flag is set, return                
        AND #$04                ;  |                                                           
        BNE Return01ACA4        ; /                                                           
        LDA $13                 ; \                                                           
        LSR                     ;  |                                                           
        BCS Return01ACA4        ; /                                                           
        LDA $E4,X               ; \                                                           
        CMP #$00                ;  | If the sprite has gone off the side of the level...      
        LDA $14E0,X             ;  |                                                          
        SBC #$00                ;  |                                                          
        CMP #$02                ;  |                                                          
        BCS OffScrEraseSprite   ; /  ...erase the sprite      
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
ADDR_01ACF3:
        LDA $00                   
        BPL Return01ACA4          
        BMI OffScrEraseSprite  

IsSprOnScreen:
	LDA $15A0,X             ; \ A = Current sprite is offscreen 
        ORA $186C,X             ; /  
        RTS                     ; Return 
		
