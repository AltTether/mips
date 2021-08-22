# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s0, $zero, 1
	addi	$s1, $zero, 1
	addi	$s2, $zero, 0
	beq		$s0, $s1, L1
	add		$s2, $zero, $s0
	j		N1
L1:
	add		$s2, $zero, $s1
N1:
