header
lorom

;---------;
; Defines ;
;---------;

!PalNum = $0F ; Which palette slots to affect (default: $00-$0F).
!XPos = $78 ; X pos smoke tile
!YPos = $40 ; Y pos smoke tile
!Prop = $04 ; YXPPCCCT
!Size = $02 ; 16x16. Change to $00 for 8x8
!SmokeTime = $1B ; Amount of time to smoke (putting it higher than $1B is not recommended.)
!MarioSize = $B0 ; Stop shrinking when Mario has this size. (The higher the number, the smaller.)
!CenterX = $80 ; The horizontal center position around which Layer 1 rotates and scales (default: middle point of Mario)
!CenterY = $48 ; The vertical center position around which Layer 1 rotates and scales (default: middle point of Mario)
!MarioImgPos1 = $8F03 ; see below
!MarioImgStartPos = $0F04 ; Position of Mario's tiles. Relevant bits: yxxxxxxx --yyyyyy.
!MarioImgPos2 = $8F04 ; see above
!MarioImgPos3 = $0F05 ; see above
!RotateSpd = $0010 ; rotation speed
!SclSpd = $01 ; scale speed
; Graphics are to be edited in GFX32, or if you use Seperate Luigi GFX or Mario ExGFX, there. The death frame depends on the death frame inside the level.
; Palettes can be edited with a hex editor -> palett.bin. They're in -bbbbbgg gggrrrrr format (SNES RGB). x0-x1F is Mario's palette, x20-x3F is Luigi's palette.

;--------;
; Hijack ;
;--------;

org $0081D5
autoclean JML Mainheh

org $0093E6
autoclean JML Random

org $009750
autoclean JML Meh

org $009759
autoclean JSL Heh

;--------;
; Custom ;
;--------;

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

Mainheh:
LDA $0100
CMP #$0B
BEQ Hehch
CMP #$17
BNE Rolardy

Hehch:
LDA $143B
CMP #$14
BNE Rolardy
LDA $2E
STA $211B
LDA $2F
STA $211B
LDA $30
STA $211C
LDA $31
STA $211C
LDA $32
STA $211D
LDA $33
STA $211D
LDA $34
STA $211E
LDA $35
STA $211E
LDA #!CenterX
STA $211F
STZ $211F
LDA #!CenterY
STA $2120
STZ $2120
LDA #$07
BRA Ret

Rolardy:
LDA #$09

Ret:
STA $2105
JML $0081DA

Random:
LDA $0100
CMP #$16
BNE Hehok
LDA $143B
CMP #$14
BNE Hehok
LDX.b #PalEnd-PalBeg-$22
LDA $0DB3
BEQ NotSoThen
TXA
CLC
ADC #$20
TAX

NotSoThen:
LDY.b #!PalNum

PalLoop:
STY $2121
LDA.l PalBeg,x
STA $2122
LDA.l PalBeg+1,x
STA $2122
DEX
DEX
DEY
CPY.b #!PalNum-$10
BNE PalLoop
LDX #$11
TXY
BRA DoDat

Special:
REP #$20
TYA
SEC
SBC #$0010
TAY
TXA
SEC
SBC #$0020
TAX
SEP #$20
BRA PalLoop

Hehok:
LDX #$10
LDY #$04

DoDat:
JML $0093EA

Meh:
PHK
PEA.w Ret1-1
PEA $84CE
JML $0085FA

Ret1:
PHK
PEA.w Ret2-1
PEA $84CE
JML $00A82D

Zero:
db $00

Ret2:
STZ $2115
STZ $2116
STZ $2117
LDX #$06

DMALoop1:
LDA.l DMATable1,x
STA $4300,x
DEX
BPL DMALoop1
LDA #$01
STA $420B
LDX #$07

Ohno:
LDA.l Rrr,x
STA $7ECA00,x
DEX
BPL Ohno

REP #$10
LDX #$0000
STX $00
LDA #$00
XBA
TXY
CLC
PHB
LDA #$7E
PHA
PLB

ConvertGraphics:
LDA $6500,x
PHY
LDY $00
AND $CA00,y
BEQ Br1
LDA #$01

Br1:
PLY
STA $C800,y 
INX
LDA $6500,x
PHY
LDY $00
AND $CA00,y
BEQ Br2
LDA #$02

Br2:
PLY
ORA $C800,y
STA $C800,y
REP #$20
TXA
CLC
ADC #$000F
TAX
SEP #$20
LDA $6500,x
PHY
LDY $00
AND $CA00,y
BEQ Br3
LDA #$04

Br3:
PLY
ORA $C800,y
STA $C800,y
INX
LDA $6500,x
PHY
LDY $00
AND $CA00,y
BEQ Br4
LDA #$08

Br4:
PLY
ORA $C800,y
STA $C800,y ; Pixel done.
REP #$20
TXA
SEC
SBC #$0011
TAX
SEP #$20
INY
REP #$20
TYA
AND #$0007
STA $00
SEP #$20
BNE ConvertGraphics
REP #$20
TXA
CLC
ADC #$0002
TAX
TYA
AND #$003F
SEP #$20
BNE ConvertGraphics
REP #$20
TXA
CLC
ADC #$0010
TAX
TYA
AND #$007F
SEP #$20
BNE JumpDiz
REP #$20
TXA
CLC
ADC #$01C0
TAX
TYA
AND #$00FF
SEP #$20
BNE JumpDiz
REP #$20
TXA
SEC
SBC #$03C0
TAX
SEP #$20
CPY #$0200
BCS BreakOut

JumpDiz:
JMP ConvertGraphics

BreakOut:
SEP #$10
PLB
LDA #$80
STA $2115
STZ $2116
STZ $2117
LDX #$06

DMALoop2:
LDA.l DMATable2,x
STA $4300,x
DEX
BPL DMALoop2
LDA #$01
STA $420B
STZ $2117
LDA #$40
STA $2116
LDX #$06

DMALoop3:
LDA.l DMATable3,x
STA $4300,x
DEX
BPL DMALoop3
LDA #$01
STA $420B
REP #$10
STZ $2115
LDX #$0000
LDA #$00
XBA
 
DMANIT:
LDA.l StripeImage,x
BMI Wateenk
STA $2117
INX
LDA.l StripeImage,x
STA $2116
INX
LDA.l StripeImage,x
BPL SevenUPE
AND #$7F
TAY
INX
 
LoopStim:
LDA.l StripeImage,x
STA $2118
DEY
BNE LoopStim
INX
BRA DMANIT
 
Wateenk:
SEP #$10
BRA Urdone

SevenUPE:
TAY
INX

Loopheh:
LDA.l StripeImage,x
STA $2118
INX
DEY
BNE Loopheh
BRA DMANIT

Urdone:
STZ $36
STZ $37
STZ $38
STZ $39
STZ $1A
STZ $1B
STZ $1C
STZ $1D
JML $0093CA

DMATable1:
db $08,$18
dl Zero
dw $4000

DMATable2:
db $08,$19
dl Zero
dw $0040

DMATable3:
db $00,$19
dl $7EC800
dw $0200

Rrr:
db $80,$40,$20,$10,$08,$04,$02,$01

PalBeg:
incbin palett.bin
PalEnd:

StripeImage:
dw !MarioImgPos1 : db $02,$01,$02
dw !MarioImgStartPos : db $02,$03,$04
dw !MarioImgPos2 : db $02,$05,$06
dw !MarioImgPos3 : db $02,$07,$08
db $FF

Ign:
RTL

Heh:
JSL $7F8000
LDA $143B
CMP #$14
BNE Ign
LDA $17C0
CMP #$63
BNE NotSoS
LDA $17C1
BEQ Ign
DEC $17C1
LDA $17C1
LSR A
LSR A
TAX
BRA Unequi

NotSoS:
REP #$20
LDA $36
CLC
ADC #!RotateSpd
STA $36
SEP #$20
LDA $38
CLC
ADC #!SclSpd
STA $38
LDA $39
CLC
ADC #!SclSpd
STA $39
CMP #!MarioSize
BCC DontErase
REP #$30
STZ $00
LDA $7F837B
TAX

Loop:
LDA #!MarioImgPos1
XBA
CLC
ADC $00
XBA
STA $7F837D,x
INX
INX
LDA #$0300
STA $7F837D,x
INX
INX
LDA #$0000
STA $7F837D,x
INX
INX
STA $7F837D,x
INX
INX
LDA $00
CLC
ADC #$0080
STA $00
CMP #$0400
BCC Loop
DEC A
STA $7F837D,x
TXA
STA $7F837B
SEP #$30
LDA #$63
STA $17C0
LDA #!SmokeTime
STA $17C1
LSR A
LSR A
TAX

Unequi:
LDA #!XPos
STA $0250
LDA #!YPos
STA $0251
LDA.l Rrrrr,x
STA $0252
LDA #!Prop
STA $0253
LDA #!Size
STA $0434

DontErase:
PHK
PEA.w Ret3-1
PEA $84CE
JML $008ACD

Rrrrr:
db $66,$66,$64,$62,$60,$62,$60 ; Tiles for smoke table.

Ret3:
RTL