.global main
main:
	addi sp, sp, -32
	sd s2, 24(sp)
	sd s1, 16(sp)
	sd s0, 8(sp)
	sd ra, 0(sp)

	la a0, header
	jal puts

	la s0, fmt
	li s1, 0
	li s2, 100
.loop:
	mv a0, s0
	mv a1, s1
	mul a2, s1, s1
	jal printf

	addi s1, s1, 1
	bne s1, s2, .loop

	ld s2, 24(sp)
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 16

	li a0, 0
	ret

.section .rodata

header: .asciz "Matt Fellenz\n\nNumber  Squared"
fmt: .asciz "%-7u %u\n"
