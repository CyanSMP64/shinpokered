;joenote - Custom functions to handle built-in nuzlocke option

;checks to see if party mon at position wUsedItemOnWhichPokemon is dead or not
;if dead --> return with z
;if alive --> return with nz
IsPartyMonDead:
	ld hl, wPartyMon1CatchRate
	ld bc, wPartyMon2 - wPartyMon1
	ld a, [wUsedItemOnWhichPokemon]
	call AddNTimes
	ld a, [hl]
	cp DEAD
	ret


EndOfBattle_NuzlockeHandler:
	ResetEvent EVENT_9AF	;clear the map-flag-handled event for this battle

	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .return	;return if this was a link battle

	call IsNuzlocke
	jr z, .return	;return if not in nuzlocke mode
	
	ld a, [wUnusedD721]
	bit 1, a
	call z, SetDeadPartyMons	;only set dead mons if player has not forfeited, 
.return
	call GetPredefRegisters
	ret


ForfeitConfirmed_NuzlockeHandler:
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .return	;return if this was a link battle

	call IsNuzlocke
	jr z, .return	;return if not in nuzlocke mode
	
	ld a, [wUnusedD721]
	bit 1, a
	call nz, SetDeadPartyMons	;only set dead mons if player actually forfeited,
.return	
	ret


OverwoldDamage_NuzlockeHandler:
	call IsNuzlocke
	call nz, SetDeadPartyMons	;only set dead mons if in nuzlocke mode
	call GetPredefRegisters
	ret


HealParty_NuzlockeHandler:
	call IsNuzlocke
	jr z, .return	;return if not in nuzlocke mode

	call OneHPDeadMons
	call ZeroPPDeadMons	
	call FRZDeadMons
.return
	call GetPredefRegisters
	ret


EncounterLoad_NuzlockeHandler:
	SetEvent EVENT_9AF	;Set an event to signal that the map flag has been handled for this battle
	call IsNuzlocke
	jr z, .return	;return if not in nuzlocke mode
	
	;comming from its position in PlaceEnemyHUDTiles, the enemy should already be a wild non-tower_ghost
	;do need to check for ghost marowak
	CheckEvent EVENT_10E
	jr nz, .return	;return if this is the ghost marowak
	
	call GetTownMapLocationCoords
	call GetNuzlockeEncounterMapFlag
	jr z, .return	;map not found on list of tracked nuzlocke maps
	call SetNuzlockeEncounterEvent
	
.return
	call GetPredefRegisters
	ret


;is nuzlocke mode active
IsNuzlocke:
	ld a, [wUnusedD721]
	bit 6, a
	ret


;Set KO'ed pokemon as dead
SetDeadPartyMons:
	push de
	ld a, [wPartyCount]
	ld d, a
	
	ld hl, wPartyMon1HP
	ld bc, wPartyMon2 - wPartyMon1
	
.loop
	ld a, [hli]
	or [hl]
	dec hl
	jr nz, .next
	
	push hl
	push bc
	ld bc, (wPartyMon1CatchRate - wPartyMon1HP)
	add hl, bc
	pop bc
	ld a, DEAD
	ld [hl], a
	pop hl
	
.next
	add hl, bc
	dec d
	jr nz, .loop
	
	pop de
	ret


;give dead partymons 1 HP
OneHPDeadMons:
	push de
	
	ld a, [wPartyCount]
	ld d, a
	
	ld hl, wPartyMon1CatchRate
	ld bc, wPartyMon2 - wPartyMon1
	
.loop	
	;check the catch rate for the "dead" value
	ld a, [hl]
	cp DEAD
	jr nz, .next
	
	;if dead, give it 1 hp
	push hl
	push bc
	ld bc, $FFFA
	add hl, bc	;same as subtracting 6, and points hl to PartyMonXHP
	pop bc
	xor a
	ld [hli], a
	inc a
	ld [hli], a
	pop hl

.next
	add hl, bc
	dec d
	jr nz, .loop
	
	pop de
	ret


;give dead partymons 0 PP
ZeroPPDeadMons:
	push de
	
	ld a, [wPartyCount]
	ld d, a
	
	ld hl, wPartyMon1CatchRate
	ld bc, wPartyMon2 - wPartyMon1
	
	ld e, %11000000

.loop	
	;check the catch rate for the "dead" value
	ld a, [hl]
	cp DEAD
	jr nz, .next
	
	;if dead, zero the PP for all moves
	push hl
	push bc
	ld bc, (wPartyMon1PP - wPartyMon1CatchRate)	;point to PartyMonXPP
	add hl, bc
	pop bc
	;move 1
	ld a, [hl]
	and e
	ld [hli], a
	;move 2
	ld a, [hl]
	and e
	ld [hli], a
	;move 3
	ld a, [hl]
	and e
	ld [hli], a
	;move 4
	ld a, [hl]
	and e
	ld [hli], a
	pop hl

.next
	add hl, bc
	dec d
	jr nz, .loop
	
	pop de
	ret

	
;give dead partymons the FRZ status
FRZDeadMons:
	push de
	
	ld a, [wPartyCount]
	ld d, a
	
	ld hl, wPartyMon1CatchRate
	ld bc, wPartyMon2 - wPartyMon1
	
.loop	
	;check the catch rate for the "dead" value
	ld a, [hl]
	cp DEAD
	jr nz, .next
	
	;if dead, give it the FRZ status
	push hl
	dec hl
	dec hl
	dec hl
	;points hl to PartyMonXStatus
	xor a
	set FRZ, a
	ld [hl], a
	pop hl

.next
	add hl, bc
	dec d
	jr nz, .loop
	
	pop de
	ret


;Puts the town map coordinates for the current map into D
GetTownMapLocationCoords:
	ld a, [wCurMap]
	ld d, a
	callba LoadTownMapEntryFromD
	swap d
	ret


;set & reset the nuzlocke encounter event bit specified by register DE	
SetNuzlockeEncounterEvent:
	call NuzlockeEncounterEvent_common1
	set 0, a
	call NuzlockeEncounterEvent_common2
	ret
ResetNuzlockeEncounterEvent:
	call NuzlockeEncounterEvent_common1
	res 0, a
	call NuzlockeEncounterEvent_common2
	ret
NuzlockeEncounterEvent_common1:
	push de
	;divide by 8 to get the byte offset needed for wEventFlags
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld b, d
	ld c, e 	;BC = byte offset
	pop de
	
	;point hl to the correct event flag byte
	ld hl, wEventFlags
	add hl, bc

	;convert BC to the nearest event flag multiple of 8 (rounded down)
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	
	;get the bit that needs to be set at the offset by doing DE = DE - BC
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	;D = 0 & E = bit offset at byte offset
	
	;rotate to the correct bit
	ld a, [hl]
	push de
	inc e
.loop1
	dec e
	jr z, .next1
	rrca
	jr .loop1
.next1
	pop de
	ret	
NuzlockeEncounterEvent_common2:
;rotate back and store value
	inc e
.loop2
	dec e
	jr z, .next2
	rlca
	jr .loop2
.next2
	ld [hl], a
	ret


;Given D holds town map location coordinates,
;Returns the nuzlocke encounter event bit in DE
;Returns with z if current map is not tracked by the list
GetNuzlockeEncounterMapFlag:
	ld hl, NuzlockeMapList
	push hl
	push bc
	ld a, d
	ld b, a
.loop
	ld a, [hli]
	cp b
	jr z, .next
	inc a	;is a = FF then incremented to 00?
	jr z, .next
	jr .loop
.next
	dec hl
	ld d, h
	ld e, l
	pop bc
	pop hl
	and a	;A = 0 of end of list was reached
	ret z	;return if so
	
	;do DE = DE - HL
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	;D = 0 & E = list offset
	
	ld hl, EVENT_980	;load byte offset of first nuzlocke map flag
	add hl, de
	ld d, h
	ld e, l
	;DE now points to the corresponding map flag
	;make sure to return the nz state
	ld a, 1
	and a
	ret
NuzlockeMapList:
	db $75	; CeladonCityName
	db $91	; CeruleanCaveName
	db $A2	; CeruleanCityName
	db $2F	; CinnabarIslandName
	db $34	; DiglettsCaveName
	db $8D	; FuchsiaCityName
	db $62	; MountMoonName
	db $2B	; PalletTownName
	db $02	; PokemonLeagueName
	db $2F	; PokemonMansionName
	db $F5	; PokemonTowerName
	db $F4	; PowerPlantName
	db $E3	; RockTunnelName
	db $E4	; Route10Name
	db $C9	; Route11Name
	db $E7	; Route12Name
	db $DB	; Route13Name
	db $BC	; Route14Name
	db $9D	; Route15Name
	db $45	; Route16Name
	db $48	; Route17Name
	db $6D	; Route18Name
	db $6F	; Route19Name
	db $2A	; Route1Name
	db $4F	; Route20Name
	db $2D	; Route21Name
	db $07	; Route22Name
	db $06	; Route23Name
	db $A1	; Route24Name
	db $B0	; Route25Name
	db $26	; Route2Name
	db $43	; Route3Name
	db $52	; Route4Name
	db $A3	; Route5Name
	db $A8	; Route6Name
	db $85	; Route7Name
	db $B5	; Route8Name
	db $D2	; Route9Name
	db $8C	; SafariZoneName
	db $5F	; SeafoamIslandsName
	db $A9	; VermilionCityName
	db $04	; VictoryRoadName
	db $28	; ViridianCityName
	db $24	; ViridianForestName
	db $FF	; list terminator
