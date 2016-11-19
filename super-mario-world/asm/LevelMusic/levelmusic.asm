;===============================================================================
; LevelMusic - Super Music Bypass, by ShadowFan-X
;
; This is the file you patch to your ROM.
;
; If you are not an ASM programmer, then move along, nothing to see here.
;===============================================================================
!false = 0
!true = 1

; Check for SA-1
if read1($00FFD5) == $23
!SA1 = !true
sa1rom
else
!SA1 = !false
endif

if !SA1
; SA-1 base addresses
!Base1 = $3000
!Base2 = $6000
else
; Non SA-1 base addresses
!Base1 = $0000
!Base2 = $0000
endif

; Configuration stuff
incsrc config.asm

if read4($0E8000) == $4B4D4140 ; '@AMK'
!FadeSlot = $FF	; AddmusicK invariably uses $FF as music fade-out
endif

; Validate the setting for !FadeConfig.
assert !FadeConfig >= 0 && !FadeConfig <= 2

; Main hijack
org $00971A
	autoclean JML AssignLevelMusic
	nop

; Music fade hijack
org $00D276
	autoclean JSL LevelMusicFade
	nop

freecode
prot LevelMusicTable

; Identifier byte to make this patch easily detectable.
; A pointer to the music table will always immediately follow.
db "!@LvMusMAIN" : dl LevelMusicTable

; Set the level music
AssignLevelMusic:
	REP #$10	; 16-bit X
	LDX !Levelnum
	LDA.l LevelMusicTable, x
	SEP #$10	; 8-bit X
	BEQ +		; Play default music when set to $00
	CMP #$FF
	BNE ++
	LDA #$00
++	STA $0DDA|!Base2
	JML $009738
+	LDA $0109|!Base2
	BEQ +
	JML $00971F
+	JML $009728

; Check if the music for the current level is
; different from the music for the next level.
LevelMusicFade:
if !FadeConfig == 1
	LDA !FadeConfig
	BNE .Return
else
if !FadeConfig == 2
	LDA !FadeConfig
	BEQ .Return
endif
endif
	LDA $5B
	LSR
	BCC +
	LDY $97
	BRA .Continue
+	LDY $95
	.Continue
	LDA $19B8|!Base2, y
	STA $00
	LDA $19D8|!Base2, y
	TAX
	AND #$01
	STA $01
	TXA
	REP #$10	; 16-bit X and Y
; See if this is a secondary entrance!
	AND #$02
	BEQ +
	LDX $00
	LDA $05F800, x
	STA $00
	STZ $01
	LDA $05FE00, x
	AND #$08
	BEQ +
	INC $01
; NOW the destination level number is loaded.
+	LDX $00
	LDA.l LevelMusicTable, x
	LDX !Levelnum
	CMP.l LevelMusicTable, x
	SEP #$10	; 8-bit X and Y
	BEQ .Return
	LDA #!FadeSlot
	STA $1DFB|!Base2
	.Return
	LDA #$0F
	STA $0100|!Base2
	RTL

; Put music tables in a different data chunk
; Note: You can also use a 512-byte .bin file as the LevelMusic table.
freedata
db "!@LvMusTBL"
LevelMusicTable:
	incsrc musictables.asm
