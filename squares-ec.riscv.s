.global main
main:
	addi sp, sp, -32
	sd ra, (sp)
	sd s0, 8(sp)
	sd s1, 16(sp)

	la a0, header
	call puts

	call clock
	mv s1, a0

	li s0, 0
loop:
	fcvt.d.w ft0, s0
	fsqrt.d ft0, ft0
	fmv.x.d a3, ft0

	la a0, fmt
	mv a1, s0
	mul a2, s0, s0
	call printf

	addi s0, s0, 1
	li t0, 100
	bltu s0, t0, loop

	call clock
	sub a1, a0, s1
	mv a2, s1
	mv a3, a0
	la a0, time_fmt
	call printf

	ld ra, (sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	addi sp, sp, 32

	li a0, 0
	ret

.section .rodata
header: .asciz "Matt Fellenz

This program will produce a table of the numbers
from 0 to 99 with their squares and square roots.
The total execution will be measured.
For Reference, on May 6, 1947, the EDSAC produced
a squares table (without the roots) in the blistering
time of 2 minutes and 35 seconds!

Number  Squared  Square Root"
fmt: .asciz "%-7d %-8d %.9hf\n"
time_fmt: .asciz "\nThe execution time was %lld microseconds (start=%lld, end=%lld)\n"
