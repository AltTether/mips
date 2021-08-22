# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s7, $zero, 256
	addi	$t0, $zero, 1
	sw		$t0, 0($s7)
	addi	$t0, $zero, 2
	sw		$t0, 4($s7)
	addi	$t0, $zero, 3
	sw		$t0, 8($s7)
	addi	$t0, $zero, 4
	sw		$t0, 12($s7)
	addi	$t0, $zero, 5
	sw		$t0, 16($s7)
	addi	$t0, $zero, 6
	sw		$t0, 20($s7)
	addi	$t0, $zero, 8
	add		$t0, $s7, $t0
	lw 		$s1, 0($t0)
	lw		$s2, 20($s7)
