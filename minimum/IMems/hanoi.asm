# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$a0, $zero, 3
	addi	$a1, $zero, 10
	addi	$a2, $zero, 11
	addi	$a3, $zero, 12
	jal		hanoi
	j		N1
hanoi:
	addi	$sp, $sp, -20
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)
	sw		$a3, 12($sp)
	sw		$ra, 16($sp)
	slti	$t0, $a0, 2
	beq		$t0, $zero, L1
	add		$a2, $a3, $zero
	jal		move
	lw		$a2, 8($sp)
	lw		$ra, 16($sp)
	addi	$sp, $sp, 20
	jr		$ra
L1:
	addi	$a0, $a0, -1
	lw		$a2, 12($sp)
	lw		$a3, 8($sp)
	jal		hanoi
	lw		$a0, 0($sp)
	jal		move
	addi	$a0, $a0, -1
	lw		$a1, 8($sp)
	lw		$a2, 4($sp)
	lw		$a3, 12($sp)
	jal		hanoi
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw		$a3, 12($sp)
	lw		$ra, 16($sp)
	addi	$sp, $sp, 20
	jr		$ra
move:
	addi	$t0, $a0, 0
	addi	$t0, $a1, 0
	addi	$t0, $a2, 0
	jr		$ra
N1:
