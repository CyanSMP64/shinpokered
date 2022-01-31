OneHitKOEffect_:
	ld hl, wDamage
	xor a
	ld [hli], a
	ld [hl], a ; set the damage output to zero
	dec a
	ld [wCriticalHitOrOHKO], a
	ld hl, wBattleMonLevel + 1
	ld de, wEnemyMonLevel + 1
	ld a, [H_WHOSETURN]
	and a
	jr z, .compareLevel
	ld hl, wEnemyMonLevel + 1
	ld de, wBattleMonLevel + 1
.compareLevel
; set damage to 65535 and OHKO flag if the user's current level is higher than the target's
	ld a, [de]
	dec de
	ld b, a
	ld a, [hld]
	sub b
	ld a, [de]
	ld b, a
	ld a, [hl]
	sbc b
	jr c, .userLevelIsLower
	ld hl, wDamage
	ld a, $ff
	ld [hli], a
	ld [hl], a
	ld a, $2
	ld [wCriticalHitOrOHKO], a
	ret
.userLevelIsLower
; keep damage at 0 and set move missed flag if target's current level is higher instead
	ld a, $1
	ld [wMoveMissed], a
	ret
