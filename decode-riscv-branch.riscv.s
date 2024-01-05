.global main
main:
	addi sp, sp, -32
	sd ra, (sp)
	sd s0, 8(sp)
	sd s1, 16(sp)

	la a0, header
	call puts

	la s0, test_code
loop:
	# s1 = raw instruction.
	lwu s1, (s0)

	la a0, row_fmt
	mv a1, s0
	mv a2, s1
	call printf

	# Opcode.
	andi t0, s1, 0b1111111
	# The opcode for branches.
	li t1, 0x63
	bne t0, t1, unknown_instruction

	# t0 = immediate.

	# 11:8 => 4:1
	srli a4, s1, 8 - 1
	andi a4, a4, 0b1111 << 1

	# 30:25 => 10:5
	srli t1, s1, 25 - 5
	andi t1, t1, 0b111111 << 5
	or a4, a4, t1

	# 7 => 11
	srli t1, s1, 7
	andi t1, t1, 0b1
	slli t1, t1, 11
	or a4, a4, t1

	# 31 => 12
	# s1 was loaded unsigned, so bits >= 32 are zero.
	# Use an arithmetic shift (in `w` mode) to sign extend now.
	sraiw t1, s1, 31
	slli t1, t1, 12
	or a4, a4, t1

	# a2 = rs1.
	srli a2, s1, 15
	andi a2, a2, 0b11111

	# a3 = rs2.
	srli a3, s1, 20
	andi a3, a3, 0b11111

	# t3 = condition code.
	srli t3, s1, 12
	andi t3, t3, 0b111

	la a0, instruction_fmt

	# `a1 = &condition_codes[t3 * 3]`.
	slli t4, t3, 1
	add t4, t4, t3
	la a1, condition_codes
	add a1, a1, t4

	call printf

	j skip
unknown_instruction:
	la a0, unknown_fmt
	mv a1, t0
	call printf
skip:

	addi s0, s0, 4
	la t0, test_code_end
	bltu s0, t0, loop

	ld ra, (sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	addi sp, sp, 32

	li a0, 0
	ret

.section .rodata
header: .asciz "Matt Fellenz\n\nThis program will decode RISC-V code.\n\nAddress    M Code   Instruction"
row_fmt: .asciz "0x%08x %08x "
instruction_fmt: .asciz "b%-3.3s x%-2d, x%-2d, <%+d>\n"
unknown_fmt: .asciz "(unknown; opcode = 0x%llx)\n"
condition_codes: .ascii "eq\0", "ne\0", "???", "???", "lt\0", "ge\0", "ltu", "geu"

test_code:
	beqz a0, test2
	bne a0, a1, test_code
.word 0xffffffff
.word 0x00000000
	bltz x3, test2
	mv a1, a2
	bltu s0, sp, test2
	add t0, a0, a1
	bge t0, a0, test2
	bne s1, ra, test_code
.ascii "abcd"
	blt x0, t3, test2
	bnez s1, test_code
	bgeu a3, s1, test_code
test2:
	slli t2, a1, 7
	and a3, t1, t2
	or t2, t3, a0
	ld a0, (sp)
	ret
test_code_end:
