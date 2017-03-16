; -------------------------------------------
; Definitions
; -------------------------------------------

if read1($00FFD5) == $23
	sa1rom
	!base1 = $3000
	!base2 = $6000
else
	lorom
	!base1 = $0000
	!base2 = $0000
endif

; -------------------------------------------
; Patches
; -------------------------------------------
; Mushroom Item
org $01C510
	db $00, 00, 00, 00 ; Disable mushroom giveing item
org $01C515
	db $00 ; Disable flower giveing mushroom
org $01C51D
	db $00 ; Disable feather giveing mushroom
org $01C524
	db $00, 00, 00, 00 ; Mushroom always trys to make you big
org $01C561
	autoclean	JML Mushroom ; New Mushroom pickup code
; -------------------------------------------
; Status Bar
org $8FC8
	autoclean	JML Healthbar ; Change Mario/Luigi text to health
; -------------------------------------------
; Map Mode Code
org $9E2C
	autoclean	JML Newgame ; When starting a new game from titlescreen
	NOP
	NOP
org $0491DB
	autoclean	JML Startlevel ; Whenever you enter a level
	NOP
org $A0E6
	autoclean	JSL Endlevel ; Whenever you go back to the map
; -------------------------------------------
org $F5D5
	autoclean	JML Hit
org $F614
	autoclean	JML Death
org $F5F8
	NOP ; Disable item box getting used when hurt 
	NOP
	NOP
	NOP
org $F600
	NOP ; Disable power up takeing when hurt (we do this elsewhere)
	NOP
; -------------------------------------------
org $8C89 ; Status bar rearangeing
	db $3E, $2C, $3E, $2C, $3E, $2C, $3E, $2C, $3E, $2C, $3E, $2C, $3E, $2C, $3E, $2C
	db $3E, $2C, $FC, $38, $FC, $38, $FC, $38, $4A, $38, $FC, $38, $FC, $38, $4A, $78
	db $76, $38, $26, $38, $FC, $38, $27, $3C, $27, $3C, $27, $3C, $FC, $38, $2E, $3C
	db $26, $38, $FC, $38, $27, $38, $27, $38, $19, $38, $26, $38, $27, $38, $27, $38
	db $FC, $38, $FC, $38, $64, $28, $26, $38, $FC, $38, $FC, $38, $FC, $38, $4A, $38
	db $FC, $38, $FC, $38, $4A, $78, $2E, $3C, $2E, $3C, $2E, $3C, $2E, $3C, $FC, $38
	db $FC, $38, $FC, $38, $FC, $38, $FC, $38, $FC, $38, $FC, $38
org $8E6F ; Time
	LDA $0F31|!base2
	STA $0F0C|!base2
	LDA $0F32|!base2
	STA $0F0D|!base2
	LDA $0F33|!base2
	STA $0F0E|!base2
;org $8E8C ; Score?
;	STA $0EFC,x
org $8F55 ; Lives
	STX $0F17|!base2
	STA $0F18|!base2
org $8FEF ; Dragon Coins
	STA $0F24|!base2,x
; -------------------------------------------
org $F2E0 ; Midway Point Healing/Powerup
	autoclean	JML Midwayheal
	NOP
	NOP
	NOP
	NOP
; -------------------------------------------
	freecode		; code starts here
; -------------------------------------------
; Other defines

!Health = $0DC4|!base2
!MaxHealth = $0DC5|!base2
!MarioHealth = $0F44|!base2
!LuigiHealth = $0F45|!base2
!MarioHeartsFound = $1F2C|!base2
!LuigiHeartsFound = $1F2D|!base2
!Powerup = $19
!MarioPowerup = $0DB8|!base2
!LuigiPowerup = $0DB8|!base2

; -------------------------------------------
Hit:
	DEC !Health
	LDA !Health
	BEQ KillMario
	CMP #$01
	BEQ Losebig ; Make you small if you are on your last hit
	LDA !Powerup
	CMP #$01
	BMI Endhit
	LDA #$01 ; Get rid of flower or cape if you have them
	STA !Powerup
	BRA Endhit
Losebig:
	STZ !Powerup 
Endhit:
	JML $00F5F3
KillMario:
	JML $00F606
Death:
	STZ !Health
	LDA #$09 
	STA $71
	JML $00F618
; -------------------------------------------
Healthbar:
	LDX #$08
HeathBarFillLoop:
	TXA
	CMP !Health
	BPL Empty
Full:
	LDA #$3F
	BRA Set
Empty:
	CMP !MaxHealth
	BPL Blank
	LDA #$3E
	BRA Set
Blank:
	LDA #$3D
Set:
	STA $0EF9|!base2,x
	DEX
	BPL HeathBarFillLoop	
	JML $008FD8
; -------------------------------------------
Mushroom:
	LDX #$00
	LDA !Health ; Mushrooms heal you...
	CMP !MaxHealth
	BPL Checkitem
	INC !Health
	BRA Checkbig
Checkitem:
	LDA !Powerup
	BEQ Getbig ; And make you big if you are small
	LDA $0DC2|!base2
	BNE Endmush
	INC $0DC2|!base2 ; But only gives a reserve item if you are big with full health.
	BRA Endmush
Checkbig:
	LDA !Powerup
	BNE Endmush ; And make you big if you are small
Getbig:
	LDX #$02 ;Set mario to expand
	STX $71
Endmush:
	TXA
	BNE Endmush2
	JML $01C57A
Endmush2:
	JML $01C565
; -------------------------------------------
Newgame:
	STA $0DBE|!base2
	STZ $0DBF|!base2
	LDX $0DB2|!base2
	STZ !Health
	STZ !MaxHealth
	LDA #$01
	STA !Powerup ; Start big
	STA $0DB8|!base2
	STA $0DB9|!base2
	STZ $0DC1|!base2
  	JML $009E37
; -------------------------------------------
Startlevel:
	PHY
	LDY #$03
	LDA #$01
BitCount:
	BIT !MarioHeartsFound,x
	BEQ NotSet
	INY
NotSet:
	ROL
	BCC BitCount
	STY !MaxHealth
	LDA !MarioHealth,x
	BNE HasHealth
	TYA
	STA !MarioHealth,x
HasHealth:
	STA !Health
	PLY
	LDA #$02
	STA $0DB1|!base2
	JML $0491E0
; -------------------------------------------
Endlevel:
	LDA !MaxHealth ; Skip this on init
	BEQ .Skip
	LDA !Health
	BNE .Alive
.Dead
	LDA #$01
	STA !Powerup
	STA !MarioPowerup,x
	LDA !MaxHealth
	STA !Health
.Alive
	STA !MarioHealth,x
.Skip
	LDA #$03
	STA $44
	RTL
; -------------------------------------------
Midwayheal:
	LDA !Health
	CMP #$01
	BNE .Skip
	INC
	STA !Health
	LDA !Powerup
	BNE .Skip
	INC
	STA !Powerup
.Skip
	JML $00F2E8
	; code ends here	
; -------------------------------------------