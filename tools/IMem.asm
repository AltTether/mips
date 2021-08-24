# Tell assembler to not insert instructions to fill branch delay slots.
# This is necessary when branch delay slots are disabled.
.set noreorder

.global _start
_start:
	addi	$s0, $zero, 5
	addi	$s1, $zero, -5
	addi	$s2, $zero, 0
	bltz	$s0, J1
	nop
J1:
	bltz	$s1, J2
	nop
J2:
	bgez	$s0, J3
	nop
J3:
	bgez	$s1, J4
	nop
J4:
	bne		$s0, $s1, J5
	nop
J5:
	bne		$s0, $s0, J6
	nop
J6:
	blez	$s0, J7
	nop
J7:
	blez	$s1, J8
	nop
J8:
	bgtz	$s0, J9
	nop
J9:
	bgtz	$s1, J10
	nop
J10:
