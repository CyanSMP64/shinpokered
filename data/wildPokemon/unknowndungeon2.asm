DungeonMons2:
	db $0F
	db 51,DODRIO
	db 51,VENOMOTH
	db 51,KADABRA
	db 52,RHYDON
IF DEF(_BLUE_JP)
	db 52, RATICATE
ELSE
	db 52,MAROWAK
ENDC
	db 52,ELECTRODE
	db 56,CHANSEY
	db 54,WIGGLYTUFF
	db 55,DITTO
	db 60,DITTO
	db $00