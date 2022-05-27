GrowthEffect_: ; raise user's attack and special by 1 stage
	ld a, [H_WHOSETURN]
	and a
	jr z, .notEnemyTurn
; Enemy's turn
	ld a, ATTACK_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wEnemyMoveNum], a
	ld a, SPECIAL_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	jpab StatModifierUpEffect
.notEnemyTurn
	ld a, ATTACK_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wPlayerMoveNum], a
	ld a, SPECIAL_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	jpab StatModifierUpEffect

BulkUpEffect_: ; raise user's attack and defense by 1 stage
	ld a, [H_WHOSETURN]
	and a
	jr z, .notEnemyTurn
; Enemy's turn
	ld a, ATTACK_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wEnemyMoveNum], a
	ld a, DEFENSE_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	jpab StatModifierUpEffect
.notEnemyTurn
	ld a, ATTACK_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wPlayerMoveNum], a
	ld a, DEFENSE_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	jpab StatModifierUpEffect

QuiverDanceEffect_: ; raise user's special and speed by 1 stage
	ld a, [H_WHOSETURN]
	and a
	jr z, .notEnemyTurn
; Enemy's turn
	ld a, SPECIAL_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wEnemyMoveNum], a
	ld a, SPEED_UP1_EFFECT
	ld [wEnemyMoveEffect], a
	jpab StatModifierUpEffect
.notEnemyTurn
	ld a, SPECIAL_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	callab StatModifierUpEffect
	xor a
	ld [wPlayerMoveNum], a
	ld a, SPEED_UP1_EFFECT
	ld [wPlayerMoveEffect], a
	jpab StatModifierUpEffect
