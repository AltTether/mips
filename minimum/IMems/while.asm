.set noreorder

.global _start
_start:
	addi	$s7, $zero, 4
	addi	$s0, $zero, 1
L1:
	slti	$t0, $s0, 10
	beq		$t0, $zero, N1
	sll		$t0, $s0, 2
	add		$t0, $s7, $t0
	sw		$s0, 0($t0)
	addi	$s0, $s0, 1
	j		L1
N1:
	lw		$t0, 0($s7)
	lw		$t0, 4($s7)
	lw		$t0, 8($s7)
	lw		$t0, 12($s7)
	lw		$t0, 16($s7)
	lw		$t0, 20($s7)
	lw		$t0, 24($s7)
	lw		$t0, 28($s7)
	lw		$t0, 32($s7)
	lw		$t0, 36($s7)
	lw		$t0, 40($s7)
	lw		$t0, 44($s7)
