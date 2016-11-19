header
lorom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Custom Respawner, by imamelia
;;
;; This patch allows you to make any normal or custom sprite respawn
;; like Lakitu and Magikoopa do.
;;
;; $(7E)18C0: Time until the sprite respawns.  This timer will be frozen if $18BF
;;	(another timer) is a nonzero value.
;; $(7E)18C1: Sprite number to respawn, if spawning a normal sprite.  To spawn
;;	a custom sprite, this must be set to FF.
;; $(7E)18C3: Y position of the respawning sprite, low byte.
;; $(7E)18C4: Y position of the respawning sprite, high byte.
;; $7FAB88: Low byte of the sprite number of the respawning sprite, if it is
;;	a custom one.
;; $7FAB89: High byte of the sprite number of the respawning sprite (extra bits),
;;	if it is a custom one.
;; $7FAB8A: X position of the respawning sprite relative to the screen, low byte.
;;	This affects only custom sprites; the X position is hardcoded for normal sprites.
;; $7FAB8B: X position of the respawning sprite relative to the screen, high byte.
;;	This affects only custom sprites; the X position is hardcoded for normal sprites.
;; $7FAB8C: First extra byte of the respawning sprite, if it is a custom one.
;; $7FAB8D: Second extra byte of the respawning sprite, if it is a custom one.
;; $7FAB8E: Third extra byte of the respawning sprite, if it is a custom one.
;; $7FAB8F: Fourth extra byte of the respawning sprite, if it is a custom one.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Freespace = $16E541

org $028B41
JML RespawnRt
;LDA $18C1
;STA $9E,x
	
org !Freespace

db "STAR"
dw End-Start-$01
dw End-Start-$01^$FFFF

Start:

;------------------------------------------------
; the actual respawning routine
;------------------------------------------------

RespawnRt:			;

PHK					;
PLB					;
LDA $18C1			; spawned sprite index
CMP #$FF			;
BEQ .SpawnCustom		; if $18C1 = #$FF, spawn a custom sprite
STA $9E,x			; else, just use it as the sprite number
JML $028B46			; and run the regular code

.SpawnCustom			;
LDA $7FAB88			;
STA $7FAB9E,x		; set the custom sprite number low byte
LDA $7FAB89			;
STA $7FAB10,x		; set the high byte (extra bits) and custom flag

LDA $7FAB8C			;
STA $7FAB40,x		; extra byte 1
LDA $7FAB8D			;
STA $7FAB4C,x		; extra byte 2
LDA $7FAB8E			;
STA $7FAB58,x		; extra byte 3
LDA $7FAB8F			;
STA $7FAB64,x		; extra byte 4

REP #$20				;
LDA $1A				;
CLC					;
ADC $7FAB8A			; set the sprite's position
SEP #$20				;
STA $E4,x			;
XBA					;
STA $14E0,x			;
LDA $18C3			;
STA $D8,x			;
LDA $18C4			;
STA $14D4,x			;

JSL $81830B			; initialize custom sprite tables
JML $828B65			;

End:

