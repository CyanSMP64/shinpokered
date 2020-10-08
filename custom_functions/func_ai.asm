;joenote - custom functions for determining which trainerAI pkmn have already been sent out before
;a=party position of pkmn (like wWhichPokemon). If checking, zero flag gives bit state (1 means sent out already)
CheckAISentOut:
	ld a, [wWhichPokemon]	
	cp $05
	jr z, .party5
	cp $04
	jr z, .party4
	cp $03
	jr z, .party3
	cp $02
	jr z, .party2
	cp $01
	jr z, .party1
	jr .party0
.party5
	ld a, [wFontLoaded]
	bit 6, a
	jr .partyret
.party4
	ld a, [wFontLoaded]
	bit 5, a
	jr .partyret
.party3
	ld a, [wFontLoaded]
	bit 4, a
	jr .partyret
.party2
	ld a, [wFontLoaded]
	bit 3, a
	jr .partyret
.party1
	ld a, [wFontLoaded]
	bit 2, a
	jr .partyret
.party0
	ld a, [wFontLoaded]
	bit 1, a
.partyret
	ret
	
SetAISentOut:
	ld a, [wWhichPokemon]	
	cp $05
	jr z, .party5
	cp $04
	jr z, .party4
	cp $03
	jr z, .party3
	cp $02
	jr z, .party2
	cp $01
	jr z, .party1
	jr .party0
.party5
	ld a, [wFontLoaded]
	set 6, a
	ld [wFontLoaded], a
	jr .partyret
.party4
	ld a, [wFontLoaded]
	set 5, a
	ld [wFontLoaded], a
	jr .partyret
.party3
	ld a, [wFontLoaded]
	set 4, a
	ld [wFontLoaded], a
	jr .partyret
.party2
	ld a, [wFontLoaded]
	set 3, a
	ld [wFontLoaded], a
	jr .partyret
.party1
	ld a, [wFontLoaded]
	set 2, a
	ld [wFontLoaded], a
	jr .partyret
.party0
	ld a, [wFontLoaded]
	set 1, a
	ld [wFontLoaded], a
.partyret
	ret

;joenote - custom functions for determining which trainerAI pkmn have already been switched out before
;a=party position of pkmn (like wEnemyMonPartyPos). If checking, zero flag gives bit state (1 means switched out already)	
CheckAISwitched:
	ld a, [wEnemyMonPartyPos]	
	cp $05
	jr z, .party5
	cp $04
	jr z, .party4
	cp $03
	jr z, .party3
	cp $02
	jr z, .party2
	cp $01
	jr z, .party1
	jr .party0
.party5
	ld a, [wUnusedD366]
	bit 6, a
	jr .partyret
.party4
	ld a, [wUnusedD366]
	bit 5, a
	jr .partyret
.party3
	ld a, [wUnusedD366]
	bit 4, a
	jr .partyret
.party2
	ld a, [wUnusedD366]
	bit 3, a
	jr .partyret
.party1
	ld a, [wUnusedD366]
	bit 2, a
	jr .partyret
.party0
	ld a, [wUnusedD366]
	bit 1, a
.partyret
	ret
	
SetAISwitched:
	ld a, [wEnemyMonPartyPos]	
	cp $05
	jr z, .party5
	cp $04
	jr z, .party4
	cp $03
	jr z, .party3
	cp $02
	jr z, .party2
	cp $01
	jr z, .party1
	jr .party0
.party5
	ld a, [wUnusedD366]
	set 6, a
	ld [wUnusedD366], a
	jr .partyret
.party4
	ld a, [wUnusedD366]
	set 5, a
	ld [wUnusedD366], a
	jr .partyret
.party3
	ld a, [wUnusedD366]
	set 4, a
	ld [wUnusedD366], a
	jr .partyret
.party2
	ld a, [wUnusedD366]
	set 3, a
	ld [wUnusedD366], a
	jr .partyret
.party1
	ld a, [wUnusedD366]
	set 2, a
	ld [wUnusedD366], a
	jr .partyret
.party0
	ld a, [wUnusedD366]
	set 1, a
	ld [wUnusedD366], a
.partyret
	ret
	

;this function handles selecting which mon in an AI trainer should be sent out
AISelectWhichMonSendOut:
	ld b, $FF
	xor a
	ld [wAIPartyMonScores + 6], a
	
.partyloop	;the party loop, using b as a counter, grabs the position of the mon that is not currently out
	inc b
	ld a, [wEnemyMonPartyPos]	;wEnemyMonPartyPos is 0-indexed (1st mon is position 0). This address holds FF at the start of a battle.
	cp b
	jp z, .seeifdone	;next position if pointing to the same mon
	
	;check the HP of the mon
	ld a, b
	ld hl, wEnemyMon1
	push bc
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl	
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c
	jp z, .seeifdone	;go to next pkmn in roster if this one has zero HP
	
	ld a, b
	ld [wWhichPokemon], a	;else save the new mon's position
	
	ld a, [wUnusedC000]
	bit 5, a
	jp z, .sendOutNewMon	;skip all this if AI routine 4 has not run and done all the scoring
	ld a, [wAIPartyMonScores + 6]	;get the best score
	and a
	jr z, .updatebestscore	;skip if no best score assiged yet
	ld c, a		;load best score in c
	;get the position of the mon currently being looked at and point HL to its score
	ld a, [wWhichPokemon]
	ld hl, wAIPartyMonScores
	push bc
	ld bc, $00
	ld c, a
	add hl, bc
	pop bc
	;get the currently inspected mon's score and compare it to the best score
	ld a, [hl]
	cp c
	jr c, .keepcurrentbestscore
	jr z, .keepcurrentbestscore
.updatebestscore
	ld a, [wWhichPokemon]
	ld [wAIPartyMonScores + 7], a	;store the position with the best score so far
	ld hl, wAIPartyMonScores
	push bc
	ld bc, $00
	ld c, a
	add hl, bc
	pop bc
	ld a, [hl]	; get the best score so far
	ld [wAIPartyMonScores + 6], a	;store the best score so far
	jr .seeifdone
.keepcurrentbestscore
	ld a, [wAIPartyMonScores + 7]
	ld [wWhichPokemon], a
.seeifdone
	ld a, [wEnemyPartyCount]
	dec a	;make party counter zero-indexed
	cp b
	jp nz, .partyloop	;loop if the last party member hasn't been reached
	
.sendOutNewMon
	;we're done here, so the mon in the position held by wWhichPokemon will get sent out
	ret

	
	

ScoreAIParty:
	push de
	
	;copy hp, position, and status of the active pokemon to its roster position so it is properly scored
	ld a, [wEnemyMonPartyPos]
	ld hl, wEnemyMon1HP
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, wEnemyMonHP
	ld bc, 4
	call CopyData	 
	
	ld a, [wEnemyPartyCount]	;value of 1 to 6
	ld b, a
	ld hl, wEnemyMon1
	ld de, wAIPartyMonScores
.scoreloop
	ld a, $A0; set sefault score
	ld [de], a
	push bc
	
	
	;check the HP of the mon
	push hl
	inc hl	
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c
	pop hl
	jr nz, .next0	;go to next check if hp > 0
	ld a, $0F
	ld [de], a
	jp .next6
.next0	
	
	;+2 score if faster than current player mon's speed
	ld bc, $28	
	call GetRosterStructData
	ld b, a	;store hi byte of speed in b
	ld a, [wBattleMonSpeed]	;store hi byte of player mon speed in a
	cp b
	jr nz, .next1	;if bytes are not equal, then rely on carry bit to see which is greater
	;else check the lo bytes
	ld bc, $29
	call GetRosterStructData
	ld b, a	;store lo byte of speed in b
	ld a, [wBattleMonSpeed + 1]	;store lo byte of player mon speed in a
	cp b
.next1
	ld b, 2
	call c, .plus	;if carry is set, then player mon has less speed
	
	
	;+2 score if at or above max base hp
	ld a, 1
	call AIRosterScoringCheckIfHPBelowFraction
	ld b, 2
	push af
	call nc, .plus
	pop af
	jr nc, .next2
	;-2 score if less than 3/4 base hp
	ld a, $34
	call AIRosterScoringCheckIfHPBelowFraction
	ld b, 2
	call c, .minus
	;-3 more (total of -5) score if less than 1/2 base hp
	ld a, 2
	call AIRosterScoringCheckIfHPBelowFraction
	ld b, 3
	call c, .minus
	;-5 more (total of -10) score if less than 1/4 base hp
	ld a, 4
	call AIRosterScoringCheckIfHPBelowFraction
	ld b, 5
	call c, .minus
.next2	


	;-5 for a mon with sleep counter > 1
	ld bc, $04	;get status byte
	call GetRosterStructData
	ld c, a	;back up the status byte in c
	and SLP
	cp $02
	ld b, 5
	push af
	call nc, .minus
	pop af
	jr nz, .next3
	;-2 if burned, paralyzed, or poisoned
	ld a, c
	and (1 << BRN) | (1 << PSN) | (1 << PAR)
	ld b, 2
	push af
	call nz, .minus
	pop af
	jr nz, .next3
	;-10 if frozen
	ld a, c
	and (1 << FRZ)
	ld b, 10
	call nz, .minus
.next3


	;adjust score for most recent player move
	ld a, [wActionResultOrTookBattleTurn]
	and a
	jr nz, .next4	;skip if the player switched or used an item
	ld a, [wPlayerMovePower]	;get the power of the player's move
	cp $02	;regular damaging moves have power > 1
	jr c, .next4	;skip out if the move is not a normal damaging move
	;get effectiveness of the most recent player move
	ld a, [wUnusedC000]
	set 3, a 
	ld [wUnusedC000], a
	;preserve the current enemy mon typing
	ld a, [wEnemyMonType]
	ld [wAIPartyMonScores + 6], a
	ld a, [wEnemyMonType + 1]
	ld [wAIPartyMonScores + 7], a
	;override the current enemy mon typing with that from the roster pointer
	ld bc, $05
	call GetRosterStructData
	ld [wEnemyMonType], a
	ld bc, $06
	call GetRosterStructData
	ld [wEnemyMonType + 1], a
	;now get the typing effectiveness
	push hl
	push de
	callab AIGetTypeEffectiveness
	pop de
	pop hl
	;now undo the current mon type override
	ld a, [wAIPartyMonScores + 6]
	ld [wEnemyMonType], a
	ld a, [wAIPartyMonScores + 7]
	ld [wEnemyMonType + 1], a
	;now get the move-to-type effectiveness
	ld a, [wTypeEffectiveness]
	;skip if effectiveness is neutral
	cp $0A
	jr z, .next4
	;+10 to score if move has no effect
	cp $01
	ld b, 10
	push af
	call c, .plus
	pop af
	jr c, .next4
	;+5 to score if move has little effect
	cp $03
	ld b, 5
	push af
	call c, .plus
	pop af
	jr c, .next4
	;+2 to score if move is less effective
	cp $0A
	ld b, 2
	push af
	call c, .plus
	pop af
	jr c, .next4
	;at this point the move must be super effective
	;minus based on the power of the move
	ld a, [wPlayerMovePower]
	srl a
	srl a
	srl a
	ld b, a
	call nc, .minus
.next4

	
	;adjust score based on having any regular damaging moves
	ld a, $00
	ld [wAIPartyMonScores + 6], a	;set a default score tracker: (bits 0 to 6--> 0-5=-5, 0A = 0, 14 or more=+2)(bit 7 set for 60+ power) 
	ld a, [wUnusedC000]
	res 3, a ;get effectiveness of enemy moves
	ld [wUnusedC000], a
	ld bc, $08	;set offest to point to first move of current mon
.enemymoveloop
	ld a, $0C
	cp c	
	jp z, .enemymoveloop_done	;exit loop if incremented beyond 4th move slot
	call GetRosterStructData ;get the move and put it into a
	and a
	jp z, .enemymoveloop_done	;exit loop if reached an empty move slot
	push bc
	push hl
	push de
	ld d, a
	callba ReadMoveForAIscoring	;takes move in d, returns its power in d and type in e
	ld a, d	;get the power of the move
	cp $02	;regular damaging moves have power > 1
	jr c, .next5
	push af	;save the power in a
	ld a, [wEnemyMoveType]
	ld [wAIPartyMonScores + 7], a
	ld a, e	;get the type of the move
	ld [wEnemyMoveType], a
	callba AIGetTypeEffectiveness
	ld a, [wAIPartyMonScores + 7]
	ld [wEnemyMoveType], a
	pop af	;get the power back in a
	ld c, a	;and put it in c
	ld a, [wAIPartyMonScores + 6]	;get the current score tracker
	and $7F	;mask out highest bit
	ld b, a	;and put it in b
	ld a, [wTypeEffectiveness]	;get the found type effectiveness
	cp b
	jr c, .next5	;if the type effectiveness is less than the current score tracker then loop to next move
	ld [wAIPartyMonScores + 6], a	;else update score tracker
	ld a, c
	cp $3C	;set score tracker bit if power of this move 60+
	jr c, .next5
	ld a, [wAIPartyMonScores + 6]
	set 7, a
	ld [wAIPartyMonScores + 6], a
.next5
	pop de
	pop hl
	pop bc
	inc c
	jp .enemymoveloop
.enemymoveloop_done
	ld a, [wAIPartyMonScores + 6]
	and $7F
	;-5 score if no moves are decently effective
	cp $0A
	ld b, 5
	push af
	call c, .minus
	pop af
	;no score adjustment for a neutral move
	jr z, .next6
	;+2 score if there's a supereffective move
	cp $14
	ld b, 2
	call nc, .plus
	;+3 more score (+5 total) if the supereffective move is 60 power or more
	ld a, [wAIPartyMonScores + 6]
	bit 7, a
	ld b, 3
	call nz, .plus
.next6	
	

	pop bc
	dec b
	jr z, .donescoring
	push bc
	ld bc, wEnemyMon2 - wEnemyMon1
	add hl, bc
	pop bc
	inc de
	jp .scoreloop
.donescoring
	pop de
	jp AIAbortMonSendOut
.plus
	ld a, [de]
	add b
	ld [de], a
	ret
.minus
	ld a, [de]
	sub b
	ld [de], a
	ret

	
	

;sets the carry bit if current mon score < highest score of remaining roster	
AIAbortMonSendOut:
	ld a, [wWhichPokemon]
	ld b, a
	push bc
	call AISelectWhichMonSendOut	;this will get the mon with the highest score that is neither KO'd nor the active mon
	pop bc
	ld a, b
	ld [wWhichPokemon], a
	
	ld a, [wAIPartyMonScores + 6]
	ld b, a
	push bc
	
	ld a, [wEnemyMonPartyPos]
	ld c, a
	ld b, $00
	ld hl, wAIPartyMonScores
	add hl, bc
	pop bc
	
	
	ld a, [wEnemyBattleStatus3]
	bit 0, a	;check a for the toxic bit on active mon
	ld a, [hl]
	call nz, .dec5	;-5 score if badly poisoned
	
	ld a, [wPlayerBattleStatus1]
	bit 5, a	;check a for trapping move bit 
	ld a, [hl]
	call nz, .dec5	;-5 score if stuck in a trapping move
	
	ld a, [wEnemyBattleStatus1]
	bit 7, a	;check a for the confusion bit 
	ld a, [hl]
	call nz, .dec2	;-2 score if confused
	
	ld a, [wEnemyBattleStatus2]
	bit 7, a	;check a for the leech seed bit 
	ld a, [hl]
	call nz, .dec2	;-2 score if seeded
	
	ld a, [wEnemyDisabledMove] ; get disabled move (if any)
	swap a
	and $f
	ld a, [hl]
	call nz, .dec2	;-2 score if a move is disabled
	
	push bc
	;use b for storage and a for loading
	ld a, [wEnemyMonAttackMod]	
	ld b, a 
	ld a, [wEnemyMonDefenseMod]
	cp b
	call c, .ldba	;if a < b, then load a into b
	ld a, [wEnemyMonSpeedMod]
	cp b
	call c, .ldba	;if a < b, then load a into b
	ld a, [wEnemyMonSpecialMod]
	cp b
	call c, .ldba	;if a < b, then load a into b
	ld a, [wEnemyMonAccuracyMod]
	cp b
	call c, .ldba	;if a < b, then load a into b
	ld a, [wEnemyMonEvasionMod]
	cp b
	call c, .ldba	;if a < b, then load a into b
	ld a, b	;put b back into a
	pop bc
	cp $07	;is the lowest stat mod the normal value of 7?
	jr nc, .compare		;lowest stat mod is not negative (value below 7)
	push bc
	ld b, a	;put the lowest mod into b
	ld a, $07	; put 7 into a
	sub b	;a = 7 - b, so a becomes 6 (-6 stages) to 1 (-1 stage)
	ld b, a	;put a back into b
	;add the lowest mod to the score
	ld a, [hl]
	sub b
	ld [hl], a
	pop bc
	
.compare
	ld a, [hl]
	cp b	;(current mon score - highest other mon score)
	ret
.dec5
	dec a
	dec a
	dec a
.dec2
	dec a
	dec a
	ld [hl], a
	ret
.ldba
	ld b, a
	ret

	
	
	
; return carry if enemy trainer's current HP is below 1 / a of the maximum
; adapted to work with the roster scoring functions
; preserves hl and de
; the max hp is the base max value since true max hp is calculated upon every sendout and not stored anywhere
AIRosterScoringCheckIfHPBelowFraction:
;first preserve stuff onto the stack
	push de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - handle an 'a' value of 1
	cp 1
	jr nz, .not_one
	ld bc, $22
	call GetRosterStructData
	ld d, a
	ld bc, $01
	call GetRosterStructData
	cp d	;a = HP MSB an d = MAXHP MSB so do a - d and set carry if negative
	jr c, .return
	ld bc, $23
	call GetRosterStructData
	ld d, a
	ld bc, $02
	call GetRosterStructData
	cp d	;a = HP LSB an d = MAXHP LSB so do a - d and set carry if negative
	jp .return
.not_one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cp $34
	jr nz, .not3fourths
	ld bc, $22
	call GetRosterStructData
	ld d, a
	ld bc, $23
	call GetRosterStructData
	ld e, a
	;de now holds the max hp value
	ld a, d
	srl a
	ld d, a
	ld a, e
	rra
	ld e, a
	;de now holds half max hp
	ld a, d
	srl a
	ld d, a
	ld a, e
	rra
	ld e, a
	;de now holds 1/4 max hp
	push hl
	ld hl, $0000
	add hl, de
	add hl, de
	add hl, de
	ld d, h
	ld e, l
	pop hl
	;de now holds 3/4ths max hp
	push de
	ld bc, $01
	call GetRosterStructData
	ld d, a
	ld bc, $02
	call GetRosterStructData
	ld c, a
	ld a, d
	ld b, a
	pop de
	;now bc holds current hp and de holds 3/4ths max hp
	ld a, b
	sub d
	jr nz, .return
	ld a, c
	sub e
	jr .return
.not3fourths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push hl
	ld [H_DIVISOR], a
	ld bc, $22
	add hl, bc
	ld a, [hli]
	ld [H_DIVIDEND], a
	ld a, [hl]
	ld [H_DIVIDEND + 1], a
	ld b, 2
	call Divide
	ld a, [H_QUOTIENT + 3]
	ld c, a
	ld a, [H_QUOTIENT + 2]
	ld b, a
	pop hl
	push hl
	ld de, $02
	add hl, de
	ld a, [hld]
	ld e, a
	ld a, [hl]
	pop hl
	ld d, a
	ld a, d
	sub b
	jr nz, .return
	ld a, e
	sub c
.return	;joenote - consolidating returns with the stack
	pop de
	ret
	
	
	
	
;hl should point at a party struct such as wEnemyMon1
;bc holds an offset
;returns the value of the offsetted in a
GetRosterStructData:
	push hl
	add hl, bc
	ld a, [hl]
	pop hl
	ret



