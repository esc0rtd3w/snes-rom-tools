;===============================================================================
; Scrolling HDMA Gradient Tables
; This file is where you put compressed scrolling HDMA tables.
;===============================================================================

; To use your own table, just add a Direct Word directive/whatever:
;     dw [Label]
;
; Before JSR/JSLing to SyncColorGradientInitRt, you need to load the index of
; the table you want to use into the accumulator. For example, if you want to
; use the first entry, you would put something similar to this in your LevelASM
; Init code:
;     LDA #$00
;     JSR SyncColorGradientInitRt
;
; Do NOT use an entry that doesn't exist. It will crash the game.
SyncGradientPtrs:
dw ExampleTable

ExampleTable:
db $08,$22,$40,$80
db $08,$24,$40,$80
db $08,$26,$40,$80
db $08,$28,$40,$80
db $08,$2A,$40,$80
db $08,$2C,$40,$80
db $08,$2E,$40,$80
db $08,$30,$40,$82
db $08,$32,$40,$84
db $08,$34,$40,$86
db $08,$36,$40,$88
db $08,$38,$40,$8A
db $08,$3A,$40,$8C
db $08,$3C,$40,$8E
db $08,$3E,$40,$90
db $08,$3C,$40,$92
db $08,$3A,$40,$94
db $08,$38,$40,$96
db $08,$36,$40,$98
db $08,$34,$40,$9A
db $08,$32,$40,$9C
db $08,$30,$40,$9E
db $08,$2E,$40,$9C
db $08,$2C,$40,$9A
db $08,$2A,$40,$98
db $08,$28,$40,$96
db $08,$26,$40,$94
db $08,$24,$40,$92
db $08,$22,$40,$90
db $08,$20,$40,$8E
db $08,$20,$40,$8C
db $08,$20,$40,$8A
db $08,$20,$40,$88
db $08,$20,$40,$86
db $08,$20,$40,$84
db $08,$20,$40,$82
db $00
