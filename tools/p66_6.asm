# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s0, $zero, 5
	add		$a0, $zero, $s0
	jal 	sum
	add     $s1, $zero, $v0
	j		N1
sum:
	addi	$t0, $sp, -8
	addi	$sp, $t0, 0
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	slti	$t0, $a0, 1
	beq		$t0, $zero, L1
	lw		$ra, 4($sp)
	lw 		$a0, 0($sp)
	add		$v0, $zero, $zero
	addi	$t0, $sp, 8
	addi	$sp, $t0, 0
	jr		$ra
	add		$s1, $zero, $zero
	add		$s0, $zero, $zero
L1:
	addi	$t0, $a0, -1
	addi	$a0, $t0, 0
	jal		sum
	lw		$a0, 0($sp)
	lw		$ra, 4($sp)
	add		$t0, $a0, $v0
	addi	$v0, $t0, 0
	addi	$t0, $sp, 8
	addi	$sp, $t0, 0
	jr		$ra
N1:
