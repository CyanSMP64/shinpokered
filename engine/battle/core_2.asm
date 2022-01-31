ExplodeEffect_:
	ld hl, wBattleMonHP
	ld de, wPlayerBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .faintUser
	ld hl, wEnemyMonHP
	ld de, wEnemyBattleStatus2
.faintUser
	xor a
	ld [hli], a ; set the mon's HP to 0
	ld [hli], a
	inc hl
	ld [hl], a ; set mon's status to 0
	ld a, [de]
	res SEEDED, a ; clear mon's leech seed status
	ld [de], a
	ret

HyperBeamEffect_:
	ld hl, wPlayerBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .hyperBeamEffect
	ld hl, wEnemyBattleStatus2
.hyperBeamEffect
	set NEEDS_TO_RECHARGE, [hl] ; mon now needs to recharge
	ret

RageEffect_:	;joenote - modified to last 1 turn
	ld hl, wPlayerBattleStatus2
	ld bc, wPlayerNumAttacksLeft
	ld a, [H_WHOSETURN]
	and a
	jr z, .player
	ld hl, wEnemyBattleStatus2
	ld bc, wEnemyNumAttacksLeft
.player
	set USING_RAGE, [hl] ; mon is now in "rage" mode
	ld a, 1
	ld [bc], a ; set Rage counter to 1
	ret
