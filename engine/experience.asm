; calculates the level a mon should be based on its current exp
CalcLevelFromExperience:
	ld a, [wLoadedMonSpecies]
	ld [wd0b5], a
	call GetMonHeader
	ld d, $0 ; joenote - level 0 & 1 now supported with underflow protection
	;ld d, $1 ; init level to 1
.loop
	inc d ; increment level
	call CalcExperience
	push hl
	ld hl, wLoadedMonExp + 2 ; current exp
; compare exp needed for level d with current exp
	ld a, [hExperience + 2]
	ld c, a
	ld a, [hld]
	sub c
	ld a, [hExperience + 1]
	ld c, a
	ld a, [hld]
	sbc c
	ld a, [hExperience]
	ld c, a
	ld a, [hl]
	sbc c
	pop hl
	jr nc, .loop ; if exp needed for level d is not greater than exp, try the next level
	dec d ; since the exp was too high on the last loop iteration, go back to the previous value and return
	ret

; calculates the amount of experience needed for level d
;joenote - re-organized and added underflow protection
CalcExperience:
	ld a, [wMonHGrowthRate]
	add a
	add a
	ld c, a
	ld b, 0
	ld hl, GrowthRateTable
	add hl, bc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the second term
	inc hl	;pointing to second term
	
	call CalcDSquared
	ld a, [hl]
	and $7f
	ld [H_MULTIPLIER], a
	call Multiply
	
	ld a, [H_PRODUCT + 0]
	push af
	ld a, [H_PRODUCT + 1]
	push af
	ld a, [H_PRODUCT + 2]
	push af
	ld a, [H_PRODUCT + 3]
	push af
	
	ld a, [hld]	;load then point to first term
	push af
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the first term
	call CalcDSquared
	ld a, d
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, [hl]
	and $f0
	swap a
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, [hli]	;load then point to second term
	and $f
	ld [H_DIVISOR], a
	ld b, $4
	call Divide
	
	ld a, [H_QUOTIENT + 0]
	push af
	ld a, [H_QUOTIENT + 1]
	push af
	ld a, [H_QUOTIENT + 2]
	push af
	ld a, [H_QUOTIENT + 3]
	push af
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the third term
	inc hl	;point to third term
	xor a
	ld [H_MULTIPLICAND], a
	ld [H_MULTIPLICAND + 1], a
	ld a, d
	ld [H_MULTIPLICAND + 2], a
	ld a, [hli]	;load then point to fourth term
	ld [H_MULTIPLIER], a
	call Multiply
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The difference of the linear term and the constant term consists of 3 bytes
; starting at H_PRODUCT + 1. Below, hExperience (an alias of that address) will
; be used instead for the further work of adding or subtracting the squared
; term and adding the cubed term.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add first term to third term
	pop bc
	ld a, [hExperience + 2]
	add b
	ld [hExperience + 2], a
	pop bc
	ld a, [hExperience + 1]
	adc b
	ld [hExperience + 1], a
	pop bc
	ld a, [hExperience]
	adc b
	ld [hExperience], a
	pop bc
	ld a, [hExperience - 1]
	adc b
	ld [hExperience - 1], a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sum with the second term
	pop af
	and $80
	jr nz, .subtractSquaredTerm ; check sign
	pop bc
	ld a, [hExperience + 2]
	add b
	ld [hExperience + 2], a
	pop bc
	ld a, [hExperience + 1]
	adc b
	ld [hExperience + 1], a
	pop bc
	ld a, [hExperience]
	adc b
	ld [hExperience], a
	pop bc
	ld a, [hExperience - 1]
	adc b
	ld [hExperience - 1], a
	jr .subFourthTerm
.subtractSquaredTerm
	pop bc
	ld a, [hExperience + 2]
	sub b
	ld [hExperience + 2], a
	pop bc
	ld a, [hExperience + 1]
	sbc b
	ld [hExperience + 1], a
	pop bc
	ld a, [hExperience]
	sbc b
	ld [hExperience], a
	pop bc
	ld a, [hExperience - 1]
	sbc b
	ld [hExperience - 1], a
	jr c, .underflow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subtract the fourth term
.subFourthTerm
	ld b, [hl]
	ld a, [hExperience + 2]
	sub b
	ld [hExperience + 2], a
	ld b, $0
	ld a, [hExperience + 1]
	sbc b
	ld [hExperience + 1], a
	ld a, [hExperience]
	sbc b
	ld [hExperience], a
	ld a, [hExperience - 1]
	sbc b
	ld [hExperience - 1], a
	jr c, .underflow 
;check for overflow into 4th byte
	and a
	ret z	;return if 4th byte is zero
	dec d	;else decrement max level and start over
	jp CalcExperience
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.underflow
	xor a
	ld [hExperience], a
	ld [hExperience + 1], a
	ld a, d
	ld [hExperience + 2], a
	ret

; calculates d*d
CalcDSquared:
	xor a
	ld [H_MULTIPLICAND], a
	ld [H_MULTIPLICAND + 1], a
	ld a, d
	ld [H_MULTIPLICAND + 2], a
	ld [H_MULTIPLIER], a
	jp Multiply

; each entry has the following scheme:
; %AAAABBBB %SCCCCCCC %DDDDDDDD %EEEEEEEE
; resulting in
;  (a*n^3)/b + sign*c*n^2 + d*n - e
; where sign = -1 <=> S=1
GrowthRateTable:
	db $11,$00,$00,$00 ; medium fast      n^3
	db $34,$0A,$00,$1E ; (unused?)    3/4 n^3 + 10 n^2         - 30
	db $34,$14,$00,$46 ; (unused?)    3/4 n^3 + 20 n^2         - 70
	db $65,$8F,$64,$8C ; medium slow: 6/5 n^3 - 15 n^2 + 100 n - 140
	db $45,$00,$00,$00 ; fast:        4/5 n^3
	db $54,$00,$00,$00 ; slow:        5/4 n^3
