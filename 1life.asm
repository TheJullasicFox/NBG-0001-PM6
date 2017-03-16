; Always have one life
; Meaning every death will result in game over :<
;
; by JackTheSpades
; no credit necessary

header
lorom

ORG $009E25		; \
	db $00		; / Always start game with one life


ORG $008F49		; \
	LDA #$01	;  | Always write 1 to status bar
	LDX #$FC	;  |
	STZ $0DBE	;  | Enforce 1 live while we're at it
	BRA SkipStuff	; /

ORG $008F55
	SkipStuff:


ORG $04828D		; \ Disable life exchange between players
	db $80,$06	; / Not much point if each has only one

;You can uncomment this if you want additional securety that this patch works... so to say.
;But with this, the game will also write 1 life during the game over scene (where you choose between continue and end)
;Normally it'd write 0 there. If that doesn't bother you, feel free to uncomment this :)

;ORG $05DC0A		; \
;	LDA #$00	;  | Always write 1 on OW
;	NOP		; /
