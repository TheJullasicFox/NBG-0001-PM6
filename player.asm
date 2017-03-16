HEADER
LOROM

!players	= $00	;00 = 1 player, 01 = 2 player

!BASE = $0000

IF READ1($00FFD5) == $23
	SA1ROM
	!BASE = $6000
ENDIF

ORG $009DFA
	INC $0100|!BASE
	BRA +
	
ORG $009E0B
	+
	LDX.b #!players
	
ORG $05B872
	db $FF
