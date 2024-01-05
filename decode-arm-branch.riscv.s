.global main
main:
	addi sp, sp, -32
	sd ra, (sp)
	sd s0, 8(sp)
	sd s2, 16(sp)

	la a0, header
	call puts

	la s0, test_code_armv7

loop:
	# s2 = raw instruction
	lw s2, (s0)

	la a0, row_fmt
	mv a1, s0
	mv a2, s2
	call printf

	# t2 == 0b101, otherwise this is not a branch.
	srli t3, s2, 25
	andi t3, t3, 0b111
	li t2, 0b101
	bne t2, t3, unknown_instruction

	# a2 = jump offset
	slli a2, s2, (64 - 24)
	srai a2, a2, (64 - 24 - 2)
	addi a2, a2, 8

	# t1 = link?
	srli t1, s2, 24
	andi t1, t1, 0b1

	# t2 = cond
	srli t2, s2, 27
	andi t2, t2, 0b11110

	addi t3, sp, 24
	beqz t1, skip_link
	li t4, 'l'
	sb t4, (t3)
	addi t3, t3, 1
skip_link:
	la t1, condition_codes
	add t1, t1, t2
	lh t1, (t1)
	sh t1, (t3)
	sb x0, 2(t3)

	la a0, instruction_fmt
	addi a1, sp, 24
	# a2 set earlier.
	call printf

	j skip
unknown_instruction:
	la a0, unknown
	call puts
skip:

	addi s0, s0, 4
	la t0, test_code_armv7_end
	bltu s0, t0, loop

	ld ra, (sp)
	ld s0, 8(sp)
	ld s2, 16(sp)
	addi sp, sp, 32

	li a0, 0
	ret

.section .rodata

test_code_armv7:
/*
	beq t2_armv7
	blne test_code_armv7
.word 0xffffffff
.word 0x00000000
	bmi t2_armv7
	mov r1, r2
	blpl t2_armv7
	bcs t2_armv7
	blhi test_code_armv7
	bls t2_armv7
	blgt t2_armv7
	bge t2_armv7
.ascii "abcd"
	blcc t2_armv7
	bvs t2_armv7
	blvc t2_armv7
	ble t2_armv7
	b t2_armv7
	bl test_code_armv7
t2_armv7:
	ands r3, r5, r9, asr #7
	cmp r5, r7
	cmp r6, #25

	cmn r11, r13
	add r0,r7,r2
	orr r11,r12,r10
*/
.4byte 0x0a000011, 0x1bfffffd, 0xffffffff, 0x00000000
.4byte 0x4a00000d, 0xe1a01002, 0x5b00000b, 0x2a00000a
.4byte 0x8bfffff6, 0x9a000008, 0xcb000007, 0xaa000006
.4byte 0x64636261, 0x3b000004, 0x6a000003, 0x7b000002
.4byte 0xda000001, 0xea000000, 0xebffffec, 0xe01533c9
.4byte 0xe1550007, 0xe3560019, 0xe17b000d, 0xe0870002
.4byte 0xe18cb00a
test_code_armv7_end:

header: .asciz "Matt Fellenz\n\nThis program will decode a subset of ARMv7 instructions.\n\nAddress      M Language  Instruction"

row_fmt: .asciz "0x%08x   %08x    "
instruction_fmt: .asciz "b%-7s<%+lld>\n"
unknown: .asciz "UNKNOWN INSTRUCTION"

condition_codes: .ascii "eqnecsccmiplvsvchilsgeltgtle  ??"
