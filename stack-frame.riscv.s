.macro read prompt, offset
	la a0, \prompt
	la a1, stderr
	ld a1, (a1)
	call fputs
	la a0, in_fmt
	addi a1, sp, \offset
	call scanf
	# EOF check
	li t0, -1
	beq a0, t0, quit
.endm

.global main
main:
	addi sp, sp, -16
	sd ra, 8(sp)
	sd fp, (sp)
	mv fp, sp
	addi sp, sp, -64

	la a0, header
	call puts

loop:
	# Loop unrolling :)
	read prompt1, 24

	flw ft0, 24(sp)
	fclass.s t0, ft0
	andi t0, t0, 0b11000
	bnez t0, quit

	read prompt2, 28
	read prompt3, 32
	read prompt4, 36
	read prompt5, 40
	read prompt6, 44
	read prompt7, 48
	read prompt8, 52
	read prompt9, 56
	read prompt10, 60

	la a0, call_fmt

	flw ft0, 24(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a1, ft0

	flw ft0, 28(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a2, ft0

	flw ft0, 32(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a3, ft0

	flw ft0, 36(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a4, ft0

	flw ft0, 40(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a5, ft0

	flw ft0, 44(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a6, ft0

	flw ft0, 48(sp)
	fcvt.d.s ft0, ft0
	fmv.x.d a7, ft0

	flw ft0, 52(sp)
	fcvt.d.s ft0, ft0
	fsd ft0, (sp)

	flw ft0, 56(sp)
	fcvt.d.s ft0, ft0
	fsd ft0, 8(sp)

	flw ft0, 60(sp)
	fcvt.d.s ft0, ft0
	fsd ft0, 16(sp)

	call printf

	flw fa0, 24(sp)
	flw fa1, 28(sp)
	flw fa2, 32(sp)
	flw fa3, 36(sp)
	flw fa4, 40(sp)
	flw fa5, 44(sp)
	flw fa6, 48(sp)
	flw fa7, 52(sp)
	lw t0, 56(sp)
	sw t0, (sp)
	lw t0, 60(sp)
	sw t0, 4(sp)
	jal add9_subtract1

	fcvt.d.s fa0, fa0
	fmv.x.d a1, fa0
	la a0, out_fmt
	call printf

	j loop

quit:
	addi sp, fp, 16
	ld ra, 8(fp)
	ld fp, (fp)
	li a0, 0
	ret

add9_subtract1:
	addi sp, sp, -16
	sd ra, 8(sp)
	sd fp, (sp)
	mv fp, sp

	fadd.s fa0, fa0, fa1
	fadd.s fa0, fa0, fa2
	fadd.s fa0, fa0, fa3
	fadd.s fa0, fa0, fa4
	fadd.s fa0, fa0, fa5
	fadd.s fa0, fa0, fa6
	fadd.s fa0, fa0, fa7
	flw ft0, 16(fp)
	fadd.s fa0, fa0, ft0
	flw ft0, 20(fp)
	fsub.s fa0, fa0, ft0

	addi sp, fp, 16
	ld ra, 8(fp)
	ld fp, (fp)
	ret

.section .rodata
header: .asciz "Matt Fellenz"
prompt1: .asciz "\nEnter the 1st number (0 to exit): "
prompt2: .asciz "Enter the 2nd number: "
prompt3: .asciz "Enter the 3rd number: "
prompt4: .asciz "Enter the 4th number: "
prompt5: .asciz "Enter the 5th number: "
prompt6: .asciz "Enter the 6th number: "
prompt7: .asciz "Enter the 7th number: "
prompt8: .asciz "Enter the 8th number: "
prompt9: .asciz "Enter the 9th number: "
prompt10: .asciz "Enter the 10th number: "
in_fmt: .asciz "%f"
call_fmt: .asciz "Now calling add9_subtract1(%g, %g, %g, %g, %g, %g, %g, %g, %g, %g);\n"
out_fmt: .asciz "The result is %g.\n"
