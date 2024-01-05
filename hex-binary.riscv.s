.section .rodata
.balign 4
values: .4byte 0x12345678, 0xfedcba98, 0x01010101, 0x6db6db6d, 0xcafefeed, 0x8badf00d, 0xffffffff, 0x00000000
.equ num_values, 8
header: .asciz "Matt Fellenz"
fmt: .asciz "Hex: 0x%08x          Binary: %.32s\n"

.text
.global main
main:
	addi sp, sp, -48
	sd ra, 40(sp)
	sd s0, 32(sp)

	la a0, header
	call puts

	li s0, 0
loop:
	la t0, values
	add t0, t0, s0
	lwu t1, (t0)
	mv a1, t1

	# t2 = number.
	# t0 = write ptr.
	addi t0, sp, 31
loop2:
	# t2 = lowest bit.
	andi t2, t1, 1
	# Cut off the bit we're processing.
	srli t1, t1, 1
	li t3, '0'
	beqz t2, zero
	li t3, '1'
zero:
	sb t3, (t0)
	addi t0, t0, -1
	bgeu t0, sp, loop2

	mv a2, sp
	la a0, fmt
	call printf

	addi s0, s0, 4
	li t0, (num_values * 4)
	bltu s0, t0, loop

	ld ra, 40(sp)
	ld s0, 32(sp)
	addi sp, sp, 48
	li a0, 0
	ret
