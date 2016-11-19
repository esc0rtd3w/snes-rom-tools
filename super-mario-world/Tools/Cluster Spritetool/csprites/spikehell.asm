;------------;
; Spike Hell ;
;------------;
; Initial XY positions set by generating sprite.

!Speed = $02 ; How many pixels to move per frame.
!YInteractSmOrDu = $20 ; How many pixels to interact with small or ducking Mario, vertically.
!YInteractSmNorDu = $30 ; How many pixels to interact with powerup Mario (not ducking), vertically.

SpeedTable:
db $FE,$02,$01,$01,$01,$FD,$03,$02,$02,$03,$01,$04,$FF,$01,$02,$02,$02,$01,$01,$03 ; Speed table, per sprite. Amount of pixels to move down each frame. 00 = still, 80-FF = rise, 01-7F = sink.

OAMStuff:
db $40,$44,$48,$4C,$D0,$D4,$D8,$DC,$80,$84,$88,$8C,$B0,$B4,$B8,$BC,$C0,$C4,$C8,$CC

Properties:
db $B5,$35,$35,$35,$35,$B5,$35,$35,$35,$35,$35,$35,$B5,$35,$35,$35,$35,$35,$35,$35 ; Properties table, per sprite. YXPPCCCT.

IncrementByOne:
LDA $1E02,y                     ; \ Increment Y position of sprite.
INC A                           ;  |
STA $1E02,y                     ;  |
SEC                             ;  | Check Y position relative to screen border Y position.
SBC $1C                         ;  | If equal to #$F0...
CMP #$F0                        ;  |
BNE ReturnAndSuch               ;  |
LDA #$01                        ;  | Appear.
STA $1E2A,y                     ; /

ReturnAndSuch:
RTS

Main:;The code always starts at this label in all sprites.
LDA $1E2A,y                     ; \ If meant to appear, skip spike hell intro code.
BEQ IncrementByOne              ; /

SkipIntro:
LDA $9D				; \ Don't move if sprites are supposed to be frozen.
BNE Immobile			; /
LDA $1E02,y                     ; \
CLC				;  |
ADC SpeedTable,y                ;  | Movement.
STA $1E02,y                     ; /
LDA $94				; \ Sprite <-> Mario collision routine starts here.
SEC                             ;  | X collision = #$18 pixels. (#$0C left, #$0C right.)
SBC $1E16,y                     ;  |
CLC                             ;  |
ADC #$0C			;  |
CMP #$18			;  |
BCS Immobile			; /
LDA #!YInteractSmOrDu           ; Y collision routine starting here.
LDX $73
BNE StoreToNill
LDX $19
BEQ StoreToNill
LDA #!YInteractSmNorDu

StoreToNill:
STA $00
LDA $96
SEC
SBC $1E02,y
CLC
ADC #$20
CMP $00
BCS Immobile
JSL $00F5B7			; Hurt Mario if sprite is interacting.

Immobile:                       ; OAM routine starts here.
LDX.w OAMStuff,y 		; Get OAM index.
LDA $1E02,y			; \ Copy Y position relative to screen Y to OAM Y.
SEC                             ;  |
SBC $1C				;  |
STA $0201,x			; /
LDA $1E16,y			; \ Copy X position relative to screen X to OAM X.
SEC				;  |
SBC $1A				;  |
STA $0200,x			; /
LDA #$E0			; \ Tile = #$E0.
STA $0202,x                     ; / (Spike.)
LDA Properties,y		; \ Properties per spike, some are rising so this needs a seperate table.
STA $0203,x			; /
PHX
TXA
LSR
LSR
TAX
LDA #$02
STA $0420,x
PLX
LDA $18BF
ORA $1493
BEQ ReturnToTheRTSCommandMyChocolate            ; Change BEQ to BRA if you don't want it to disappear at generator 2, sprite D2.
LDA $0201,x
CMP #$F0                                        ; As soon as the spike is off-screen...
BCC ReturnToTheRTSCommandMyChocolate
LDA #$00					; Kill sprite.
STA $1892,y					;

ReturnToTheRTSCommandMyChocolate:
RTS