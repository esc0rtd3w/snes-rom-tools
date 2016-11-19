@include
;===============================================================================
; LevelMusic - Super Music Bypass, by ShadowFan-X
;
; Patch settings
;===============================================================================
; Usually, this should always be $010B (or $610B for SA-1), since a lot of
; patches depend on it. However, it is added here for configurability purposes.
;
; This address MUST fit within 16 bits.
!Levelnum = $010B|!Base2

; This is the fade slot to use. This is ignored on when used with AddmusicK.
;
; Most of the time, you don't need to change this. However, with Addmusic 4.05,
; you can use slot $80. In this case, you can change this number to $A0.
;
; This does NOT work with AddmusicM. The only way around this issue with AMM is
; to not use slot $80.
!FadeSlot = $80

; 0: Do not use !FadeFlag to disable music fading.
; 1: When the value at !FadeFlag is non-zero, disable music fade.
; 2: When the value at !FadeFlag is zero, disable music fade.
!FadeConfig = 0

; Set this to free RAM if you are using the above feature.
; The default address is empty RAM that gets set to zero on reset, titlescreen
; load, overworld load and level load.
!FadeFlag = $13D8|!Base2
