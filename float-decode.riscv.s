.global main
main:
	addi sp, sp, -32
	sd ra, (sp)
	fsw fs0, 8(sp)

	la a0, header
	call puts

in_loop:
	la s0, stderr
	ld s0, (s0)
	la a0, prompt
	mv a1, s0
	call fputs
	mv a0, s0
	call fflush

	la a0, in_fmt
	add a1, sp, 16
	call scanf
	flw fs0, 16(sp)
	fclass.s t0, fs0
	andi t0, t0, 0b11000
	bnez t0, end_loop

	fmv.x.w a0, fs0
	la a1, out1
	jal print_decoded

	fmul.s ft0, fs0, fs0
	fmv.x.w a0, ft0
	la a1, out2
	jal print_decoded

	fsqrt.s ft0, fs0
	fclass.s t0, ft0
	andi t0, t0, 0b1100000000
	bnez t0, skip_sqrt
	fmv.x.w a0, ft0
	la a1, out3
	jal print_decoded
skip_sqrt:

	j in_loop
end_loop:

	flw fs0, 8(sp)
	ld ra, (sp)
	addi sp, sp, 32
	li a0, 0
	ret

# /// Prints `v` in expanded decoded notation, with the header `msg`.
# fn _(v: f32, msg: *const c_char);
print_decoded:
	addi sp, sp, -32
	sd ra, (sp)
	sd s0, 8(sp)
	sd s1, 16(sp)

	mv s0, a0

	la a0, out_fmt
	srliw t0, s0, 31
	addi a2, t0, '+'
	add a2, a2, t0
	call printf

	li s1, 22
bits_loop:
	srl t1, s0, s1
	andi t1, t1, 1
	addi a0, t1, '0'
	call putchar
	addi s1, s1, -1
	bgez s1, bits_loop

	slli a1, s0, 1
	srliw a1, a1, 24
	addi a1, a1, -127
	la a0, exp_fmt
	call printf

	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, (sp)
	addi sp, sp, 32
	ret

.section .rodata
header: .asciz "Matt Fellenz\n\nThis program with input and decode IEEE-754 Floating Point numbers.\nIt will square the number and decode it. Next, if possible,\nit will take the square root of the number and decode it. This will repeat until\nthe user enters zero."
prompt: .asciz "\nEnter the single precision floating point value (0 to exit): "

in_fmt: .asciz "%f"

out_fmt: .asciz "%-26s%c1."
out1: .asciz "The initial value is:"
out2: .asciz "The value squared is:"
out3: .asciz "The root of the value is:"
exp_fmt: .asciz " E%d\n"
