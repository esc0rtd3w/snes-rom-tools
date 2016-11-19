header
lorom
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Shared Subroutines 1.0, by imamelia
;
; This patch inserts a lot of common subroutines into your ROM so that you can
; use them without having to copy-paste them.  Some examples are GetDrawInfo,
; SubOffscreen, and the Map16 tile-generating subroutine.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

incsrc subroutinedefs.asm

!Freespace = $16DB1B

org !FreespaceU
; This is the starting address for the subroutines.  All "JSL [insert subroutine here]" commands should
; be JSLing to this bank.

JML GetDrawInfoMain		; GetDrawInfo: sets up some variables for a sprite GFX routine
JML SubHorizPosMain		; SubHor(i)zPos: checks which horizontal side of a sprite the player is on; stores the horizontal distance between them to $0F
JML SubVertPosMain		; SubVertPos: checks which vertical side of a sprite the player is on; stores the vertical distance between them to $0E
JML SubVertPos2Main		; SubVertPos2: like SubVertPos except that it uses the player's bottom tile instead of his/her top tile
JML SubOffscreenX0		; SubOffscreenX0: checks if a sprite is offscreen, sets offscreen flag if necessary
JML SubOffscreenX1		; SubOffscreenX1: like SubOffscreenX0, but with different boundaries
JML SubOffscreenX2		; SubOffscreenX2: like SubOffscreenX0, but with different boundaries
JML SubOffscreenX3		; SubOffscreenX3: like SubOffscreenX0, but with different boundaries
JML SubSetMap16Main		; Sub(l)SetMap16: changes one Map16 tile to another
JML RandomNumGenMain	; multiply-with-carry ranged random number generator
JML HexToDec2Main		; hexadecimal-to-decimal conversion subroutine (0 <= A <= 99)
JML HexToDec3Main		; hexadecimal-to-decimal conversion subroutine (0 <= A <= 255)
JML BitCheck1				; check how many bits of A are set
JML BitCheck2				; find the highest set bit of A
JML BitCheck3				; check how many bits of A are clear
JML BitCheck4				; find the lowest set bit of A
JML FindFreeEMain			; find free extended sprite slot routine
JML FindFreeCMain			; find free cluster sprite slot routine
JML GenericSprGFXMain		; generic sprite GFX routine

org !Freespace
; This is the place where the main code of each subroutine goes.

reset bytes

db "STAR"
dw EndMainCode-StartMainCode-$01
dw EndMainCode-StartMainCode-$01^$FFFF

StartMainCode:

incsrc subroutinemaincode.asm

EndMainCode:

;print "Freespace used: ",bytes," bytes."
