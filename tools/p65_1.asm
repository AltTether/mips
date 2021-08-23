# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s0, $zero, 3
	add		$a0, $zero, $s0
	jal 	sum
    add     $s1, $zero, $v0
	j		E1
sum:
	addi	$sp, $sp, -8
	sw		$s0, 0($sp)
	sw		$s1, 4($sp)
	addi	$s1, $zero, 0
	addi	$s0, $zero, 0
L1:
	slt		$t0, $s0, $a0
	beq		$t0, $zero, N1
	add		$s1, $s1, $s0
	addi	$s1, $s1, 1
	addi	$s0, $s0, 1
	j		L1
N1:
	add		$v0, $zero, $s1
	lw		$s1, 4($sp)
	lw		$s0, 0($sp)
	addi	$sp, $sp, 8
	jr		$ra
E1:
