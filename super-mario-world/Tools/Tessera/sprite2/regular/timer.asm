;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Timer, by imamelia
;;
;; Extra bytes: 2
;;
;; Extra byte 1:
;;	- Bits 0-4: Number of minutes the timer will start out with.
;;	- Bits 5-7: What will happen when the decrementing timer reaches 0
;;		(determined by a pointer table).
;; Extra byte 2:
;;	- Bits 0-6: Number of seconds the timer will start out with.
;;	- BIt 7: Counting direction.  0 -> count down from the set time, 1 -> count
;;		up from 00:00:00 to 99:59:99.
;;
;; Sprite table info:
;;
;; $1510,x: Effect subroutine to activate.
;; $151C,x: Frames shown on the timer.
;; $1528,x: Seconds shown on the timer.
;; $1534,x: Minutes shown on the timer.
;; $157C,x: Counting direction.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc subroutinedefs.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!RAM_TimerSub = $7FA210	; 3 bytes of RAM pointing to a custom subroutine
!TileXPosition = $B0		; the X position of the numbers on the screen
!TileYPosition = $20		; the X position of the numbers on the screen
NumberTiles:				; tile numbers of the numerals 0-9 (the last two are the colon and clock)
db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$17
TileProps:				; tile properties of all 9 tiles in order
db $31,$33,$33,$33,$33,$33,$33,$33,$33
TileXOffsets:				; X offsets of all 9 tiles in order relative to the first tile
db $00,$08,$10,$17,$1F,$27,$2E,$36,$3E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:

LDA $7FAB40,x
AND #$1F
STA $1534,x
LDA $7FAB40,x
AND #$E0
LSR #5
STA $1510,x

LDA $7FAB4C,x
AND #$7F
STA $1528,x
LDA $7FAB4C,x
AND #$80
STA $157C,x

STZ $151C,x

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
JSR TimerMainRt
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimerMainRt:

JSR TimerGFX

LDA $1A
CLC
ADC #$80
STA $E4,x
LDA $1B
ADC #$00
STA $14E0,x
LDA $1C
CLC
ADC #$40
STA $D8,x
LDA $1D
ADC #$00
STA $14D4,x

LDA $14C8,x
CMP #$08
BNE .Return
LDA $9D
BNE .Return

JSR UpdateTimer

.Return
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; draw the timer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimerGFX:

JSL !GetDrawInfo		;

PHY					;
LDA $1534,x			;
JSL !HexToDec2		; convert the minutes into decimal
STY $08				;
STA $09				;
LDA $1528,x			;
JSL !HexToDec2		; convert the seconds into decimal
STY $0B				;
STA $0C				;
LDA $151C,x			;
JSL !HexToDec2		; convert the frames into decimal
STY $0E				;
STA $0F				;
PLY					;

LDA #$0B				;
STA $07				;
LDA #$0A			;
STA $0A				;
STA $0D				;

STZ $05				;
LDX #$00				;

.Loop				;

LDA $07,x			;
BNE .StoreTile			;
CPX #$01				; if the tens digit of the minutes is 0, skip it
BEQ .SkipTile			;
.StoreTile				;
PHX					;
TAX					;
LDA.w NumberTiles,x	;
PLX					;
STA $0302,y			;

LDA.w TileProps,x		;
STA $0303,y			;

LDA #!TileXPosition		;
CLC					;
ADC.w TileXOffsets,x	;
STA $0300,y			;

LDA #!TileYPosition		;
STA $0301,y			;

INC $05				;
INY #4				;
.SkipTile				;
INX					;
CPX #$09				;
BCC .Loop			;

LDY #$00				;
LDA $05				;
JSL $81B7B3			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; update the timer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateTimer:

LDA $157C,x			; check the counting direction
BEQ .CountDown		;

.CountUp				;
LDA $1534,x			; if the minutes have reached 99...
CMP #$63			;
BCC .NoMax			;
LDA #$3B				;
CMP $1528,x			; and the seconds and frames have both reached 59...
BCC .NoMax			;
CMP $151C,x			;
BCC .NoMax			;
RTS					; then the timer stops
.NoMax				;
INC $151C,x			; increment the frames
LDA $151C,x			;
CMP #$3C			; if the frames have reached 60 (in decimal)...
BCC .End				;
STZ $151C,x			; reset them to 00
INC $1528,x			; and increment the seconds
LDA $1528,x			;
CMP #$3C			; if the seconds have reached 60 (in decimal)...
BCC .End				;
STZ $1528,x			; reset them to 00
INC $1534,x			; and increment the minutes
.End					;
RTS					;

.CountDown			;
LDA $1510,x			; if a subroutine has already been activated...
BMI .End				;
LDA $1534,x			; if the minutes, seconds, and frames have all reached 00...
BNE .NoZero			;
LDA $1528,x			;
BNE .NoZero			;
LDA $151C,x			;
BNE .NoZero			;
JMP ActivateSubroutine	; then activate a subroutine
.NoZero				;
DEC $151C,x			; increment the frames
LDA $151C,x			;
CMP #$FF			; if the frames have wrapped around...
BNE .End				;
LDA #$3B				;
STA $151C,x			; reset them to 59
DEC $1528,x			; and increment the seconds
LDA $1528,x			;
CMP #$FF			; if the seconds have wrapped around...
BNE .End				;
LDA #$3B				;
STA $1528,x			; reset them to 59
DEC $1534,x			; and increment the minutes
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; activate a subroutine at 00:00:00
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ActivateSubroutine:

LDA $1510,x			;
PHA					;
ORA #$80			;
STA $1510,x			;
PLA					;
BEQ .Return			; don't do anything if the subroutine number is 0
DEC					;
JSL $8086DF			;

dw Sub01				; subroutine 01 - 
dw Sub02				; subroutine 02 - 
dw Sub03				; subroutine 03 - 
dw Sub04				; subroutine 04 - 
dw Sub05				; subroutine 05 - 
dw Sub06				; subroutine 06 - 
dw CustomRoutine		; subroutine 07 - activate a custom subroutine set by !RAM_TimerSub

.Return				;
RTS					;

Sub01:				;
Sub02:				;
Sub03:				;
Sub04:				;
Sub05:				;
Sub06:				;
RTS					;

CustomRoutine:

LDA !RAM_TimerSub	;
STA $00				;
LDA !RAM_TimerSub+1	;
STA $01				;
LDA !RAM_TimerSub+2	;
STA $02				;
PHK					;
PEA.w .SubRet-1		;
JML [$0000]			;
.SubRet				;
RTS					;

dl Init,Main











