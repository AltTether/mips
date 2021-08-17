# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s0, $zero, 10
	add		$a0, $zero, $s0
	jal 	sum
	add     $s1, $zero, $v0
sum:
	addi	$sp, $sp, -8
	sw		$s0, 0($sp)
	sw		$s1, 4($sp)
	slti	$t0, $a0, 1
	bne		$t0, $zero, L1
	lw		$ra, 4($sp)
	lw 		$a0, 0($sp)
	add		$v0, $zero, $zero
	addi	$sp, $sp, 8
	jr		$ra
	add		$s1, $zero, $zero
	add		$s0, $zero, $zero
L1:
	addi	$a0, $a0, -1
	jal		sum
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	add		$v0, $a0, $v0
	addi	$sp, $sp, 8
	jr		$ra
