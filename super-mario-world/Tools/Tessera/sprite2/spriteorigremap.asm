
; erase $018172-$01830E (sprite init pointer table)
; erase $0185C3-$01875D (sprite main pointer table)
; erase $018789-$018897 (sprites that JSL to their main routines)
; erase $02A84C-$02A9DD (sprite loading routine)
; erase $02AA0B-$02AB77 (cluster sprite generator codes)
; erase $03A118-$03A258 (bank 3 sprite handler)

; shooters and generators
org $02B42C : db $6B		; Torpedo Ted launcher (RTS -> RTL)
org $02B463 : db $6B		; Torpedo Ted launcher (RTS -> RTL)
org $02B4DD : db $6B		; Bullet Bill shooter (RTS -> RTL)
org $02B31E : db $6B		; Eerie generator (RTS -> RTL)
org $02B386 : db $6B		; para-enemy generator (RTS -> RTL)
org $02B287 : db $6B		; dolphin generator (RTS -> RTL)
org $02B2CF : db $6B		; dolphin generator (RTS -> RTL)
org $02B1B7 : db $6B		; flying Cheep-Cheep generator (RTS -> RTL)
org $02B031 : db $6B		; Turn Off Generator 2 (RTS -> RTL)
org $02B206 : db $6B		; Super Koopa generator (RTS -> RTL)
org $02B259 : db $6B		; bubble generator (RTS -> RTL)
org $02B0C8 : db $6B		; Bullet Bill generator, single (RTS -> RTL)
org $02B0F9 : db $6B		; Bullet Bill generator, multidirectional/diagonal (RTS -> RTL)
org $02B07B : db $6B		; fireball generator (RTS -> RTL)
org $02B035 : db $6B		; Turn Off Generators (RTS -> RTL)

; normal sprite init routines	;
org $018583 : db $6B		; RTS -> RTL
org $01E1C7 : db $6B		; RTS -> RTL
org $01B011 : db $6B		; RTS -> RTL
org $01B01C : db $6B		; RTS -> RTL
org $0183DF : db $6B		; RTS -> RTL
org $0185C2 : db $6B		; RTS -> RTL
org $0184E8 : db $6B		; RTS -> RTL
org $0184D5 : db $6B		; RTS -> RTL
org $01BDCE : db $6B		; RTS -> RTL
org $01BDD5 : db $6B		; RTS -> RTL
org $01B968 : db $6B		; RTS -> RTL
org $01AEA2 : db $6B		; RTS -> RTL
org $01F88B : db $6B		; RTS -> RTL
org $01CD4D : db $6B		; RTS -> RTL
org $01CD5D : db $6B		; RTS -> RTL
org $01CD86 : db $6B		; RTS -> RTL
org $01CD91 : db $6B		; RTS -> RTL
org $01834B : db $6B		; RTS -> RTL
org $01843A : db $6B		; RTS -> RTL
org $01841A : db $6B		; RTS -> RTL
org $01E07A : db $6B		; RTS -> RTL
org $0183EE : db $6B		; RTS -> RTL
org $018434 : db $6B		; RTS -> RTL
org $018465 : db $6B		; RTS -> RTL
org $018525 : db $6B		; RTS -> RTL
org $018386 : db $6B		; RTS -> RTL
org $0183B2 : db $6B		; RTS -> RTL
org $018892 : db $6B		; RTS -> RTL
org $01BA94 : db $6B		; RTS -> RTL
org $01B261 : db $6B		; RTS -> RTL
org $01B267 : db $6B		; RTS -> RTL
org $01B25D : db $6B		; RTS -> RTL
org $01B235 : db $6B		; RTS -> RTL
org $01C772 : db $6B		; RTS -> RTL
org $01D716 : db $6B		; RTS -> RTL
org $01D6EC : db $6B		; RTS -> RTL
org $01844D : db $6B		; RTS -> RTL
org $018546 : db $6B		; RTS -> RTL
org $01854A : db $6B		; RTS -> RTL
org $01858D : db $6B		; RTS -> RTL
org $01843D : db $6B		; RTS -> RTL
org $01DDB4 : db $6B		; RTS -> RTL
org $01DE10 : db $6B		; RTS -> RTL
org $01AD67 : db $6B		; RTS -> RTL
org $0183D9 : db $6B		; RTS -> RTL
org $01837C : db $6B		; RTS -> RTL
org $01839F : db $6B		; RTS -> RTL
org $018395 : db $6B		; RTS -> RTL
org $01836A : db $6B		; RTS -> RTL
org $01835A : db $6B		; RTS -> RTL
org $018334 : db $6B		; RTS -> RTL
org $018325 : db $6B		; RTS -> RTL
org $018313 : db $6B		; RTS -> RTL

; some branches

org $01AEAC : db $4C		; Thwomp main routine, RTL -> RTS
org $01AEB0 : db $48		; Thwomp main routine, RTL -> RTS
org $01D75B : db $35		; line-guided sprite main routine, RTL -> RTS

; InitExplodingBlock, InitUrchin, FaceMario, are JSR'd to from other codes
; OffScrEraseSprite - JMP'd to, but cannot be changed to RTL

org $018317
JSR InitExplodingBlockEntry2

org $018564
JSR InitExplodingBlockEntry2

org $01840B
JSR InitUrchinEntry2

org $0183FC
JSR InitUrchinEntry3

org $01834E
JSR FacePlayerEntry2

org $01851C
JSR FacePlayerEntry2

org $01852E
JSR FacePlayerEntry2

org $01895B
JSR FacePlayerEntry2

org $018B6C
JSR FacePlayerEntry2

org $018C38
JSR FacePlayerEntry2

org $018D74
JSR FacePlayerEntry2

org $018F61
JSR FacePlayerEntry2

org $019679
JSR FacePlayerEntry2

org $0198BA
JSR FacePlayerEntry2

org $01B00B
JSR FacePlayerEntry2

org $01B216
JSR FacePlayerEntry2

org $01CD5A
JSR FacePlayerEntry2

org $01E320
JSR FacePlayerEntry2

org $01E3A9
JSR FacePlayerEntry2

org $01E44F
JSR FacePlayerEntry2

org $01E55E
JSR FacePlayerEntry2

org $01E60D
JSR FacePlayerEntry2

org $01FB8B
JSR FacePlayerEntry2

org $01838D
JMP OffScrEraseSpriteEntry2

org $018468
JMP OffScrEraseSpriteEntry2

; other fixes

org $01D6E3
JSR $D7A9
JSR $D7A9

org $018172

InitExplodingBlockEntry2:
LDA $E4,x
LSR #4
AND #$03
TAY
RTS

InitUrchinEntry2:
LDA $E4,x
InitUrchinEntry3:
LDY #$00
AND #$10
STA $151C,x
BNE $01
INY
LDA $83EF,y
STA $B6,x
LDA $83F0,y
STA $AA,x
INC $164A,x
RTS

FacePlayerEntry2:
JSR $AD30
TYA
STA $157C,x
RTS

;LineInitSub2:
;JSL $01D74A
;JSL $01D74A
;JMP $01D6E9

OffScrEraseSpriteEntry2:
JSR $AC80
RTL

ShelllessKoopaMain:
JSR $8904
RTL

Sprites0to13Main:
JSR $8AFC
RTL

GreenParatroopaMain:
JSR $8C4D
RTL

RedVertParatroopaMain:
JSR $8CC3
RTL

RedHorizParatroopaMain:
JSR $8CBE
RTL

BobOmbMain:
JSR $8AE5
RTL

KeyholeMain:
JSR $E1C8
RTL

WingedGoombaMain:
JSR $8D2E
RTL

SpinyEggMain:
JSR $8C18
RTL

CheepCheepMain:
JSR $B033
RTL

GenCheepCheepMain:
JSR $B192
RTL

JumpCheepCheepMain:
JSR $B1B4
RTL

DisplayMessageMain:
JSR $E75B
RTL

PiranhasMain:
JSR $8E76
RTL

BulletBillMain:
JSR $8FE7
RTL

HoppingFlameMain:
JSR $8F0D
RTL

LakituMain:
JSR $8F97
RTL

MagikoopaMain:
JSR $BDD6
RTL

MagikoopaMagicMain:
JSR $BC38
RTL

PowerupsMain:
JSR $C353
RTL

NetKoopaMain:
JSR $B97F
RTL

ThwompMain:
JSR $AEA3
RTL

ThwimpMain:
JSR $AF9F
RTL

BigBooMain:
JSR $F8D5
RTL

KoopaKidMain:
JSR $FAC1
RTL

SumoLightningMain:
JSR $87B6
RTL

YoshiEggMain:
JSR $F764
RTL

SpringboardMain:
JSR $E623
RTL

BonesMain:
JSR $E42B
RTL

PodobooMain:
JSR $E093
RTL

BossFireballMain:
JSR $D44E
RTL

YoshiMain:
JSR $EBCA
RTL

BooMain:
JSR $F8DC
RTL

EerieMain:
JSR $F890
RTL

ParaEnemyMain:
JSR $D4FB
RTL

GoalSphereMain:
JSR $8763
RTL

MontyMoleMain:
JSR $E2CF
RTL

NetDoorMain:
JSR $BACD
RTL

PlatformsMain:
JSR $B26C
RTL

TurnBlockBridgeMain:
JSR $B6A5
RTL

HorizTurnBlockBridgeMain:
JSR $B6DA
RTL

Platforms2Main:
JSR $B563
RTL

LargeOrangePlatMain:
JSR $B536
RTL

BrownChainPlatMain:
JSR $C773
RTL

LineFuzzyPlatsMain:
JSR $D9A7
RTL

LineRopeChainsawMain:
JSR $D719
RTL

LineGrinderMain:
JSR $D73A
RTL

FireFlowerMain:
JSR $C349
RTL

CapeFeatherMain:
JSR $C6ED
RTL

GrowingVineMain:
JSR $C183
RTL

GoalTapeMain:
JSR $C098
RTL

FlyingObjectsMain:
JSR $C1F2
RTL

ChangingItemMain:
JSR $C317
RTL

BonusGameMain:
JSR $DE2A
RTL

FlyingQBlockMain:
JSR $AD6E
RTL

LakituCloudMain:
JSR $E7A4
RTL

FloatingSpikeBallMain:
JSR $B559
RTL

IggyBallMain:
JSR $FA58
RTL

GrinderMain:
JSR $DB5C
RTL

;warnpc $01830B
;print pc

org $02D617
JSR $D587
RTL
JSR $D62A
RTL
NOP #11

org $03A263
RTL
NOP

org $03A118

FootballMain:
JSR $8012
RTL

NinjiMain:
JSR $C34C
RTL

FireworkMain:
JSR $C816
RTL

PrincessPeachMain:
JSR $AC97
RTL

BowlingBallMain:
JSR $B163
RTL

MechakoopaMain:
JSR $B2A9
RTL

BlarggMain:
JSR $9F38
RTL

ReznorMain:
JSR $9890
RTL

FishboneMain:
JSR $96F6
RTL

RexMain:
JSR $9517
RTL

WoodenSpikeMain:
JSR $9423
RTL

FishinBooMain:
JSR $9065
RTL

BooStreamMain:
JSR $8F7A
RTL

CreateEatBlockMain:
JSR $9284
RTL

FallingSpikeMain:
JSR $9214
RTL

StatueFireballMain:
JSR $8EEC
RTL

ReflectingFireballMain:
JSR $8F75
RTL

CarrotTopLiftMain:
JSR $8C2F
RTL

MessageBoxMain:
JSR $8D6F
RTL

TimedLiftMain:
JSR $8DBB
RTL

MovingGrayBlockMain:
JSR $8E79
RTL

BowserStatueMain:
JSR $8A3C
RTL

SlidingKoopaMain:
JSR $8958
RTL

SwooperMain:
JSR $88A3
RTL

MegaMoleMain:
JSR $8770
RTL

GrayLavaPlatformMain:
JSR $86FF
RTL

FlyingGrayBlocksMain:
JSR $85F6
RTL

BlurpMain:
JSR $84CA
RTL

PorcuPufferMain:
JSR $852F
RTL

FallingGrayPlatformMain:
JSR $8454
RTL

BigBooBossMain:
JSR $8087
RTL

SpotlightMain:
JSR $C4DC
RTL

InvisMushMain:
JSR $C30F
RTL

LightSwitchMain:
JSR $C1F5
RTL


;warnpc $03A259
;print pc
















