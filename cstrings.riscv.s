.equ BUF_SIZE, 100

.global main
main:
# input:
#   none
# output:
#   a0 is the exit code.
	addi sp, sp, -16
	sd fp, (sp)
	sd ra, 8(sp)
	mv fp, sp
	addi sp, sp, -16
	sd s1, -8(fp)

	la a0, header
	ld a1, stderr
	call fputs

	la s1, string_buf

	mv a0, s1
	li a1, BUF_SIZE - 1
	jal my_getline

	mv a1, a0
	mv a2, s1
	la a0, chars_fmt
	call printf

	mv a0, s1
	jal count_vowels
	mv a1, a0
	mv a2, s1
	la a0, vowels_fmt
	call printf

	mv a0, s1
	jal uppercase_first
	la a0, upper_first_fmt
	mv a1, s1
	call printf

	mv a0, s1
	jal uppercase_all
	la a0, shouting_fmt
	mv a1, s1
	call printf

	mv a0, s1
	jal remove_extra_spaces
	la a0, spaces_fmt
	mv a1, s1
	call printf

	addi sp, fp, 16
	ld s1, -8(fp)
	ld ra, 8(fp)
	ld fp, (fp)

	li a0, 0
	ret

my_getline:
# input:
#   a0 is the address of the buffer.
#   a1 is the size of the buffer in bytes.
# output:
#   a0 is the number of bytes read.

	addi sp, sp, -16
	sd fp, (sp)
	sd ra, 8(sp)
	mv fp, sp
	addi sp, sp, -32
	sd s1, -8(fp)
	sd s2, -16(fp)
	sd s3, -24(fp)

	mv s1, a0
	add s2, a0, a1
	mv s3, a0
	j 2f

1:
	sb a0, (s1)
	addi s1, s1, 1
2:
	bgeu s1, s2, 3f
	call getchar
	li t0, '\n'
	bne a0, t0, 1b
3:
	sub a0, s1, s3

	addi sp, fp, 16
	ld s1, -8(fp)
	ld s2, -16(fp)
	ld s3, -24(fp)
	ld ra, 8(fp)
	ld fp, (fp)
	ret

count_vowels:
# input:
#   a0 is the address of the string.
# output:
#   a0 is the number of vowels in the string.

	li a1, 0
	li t0, 'A'
	li t1, 'E'
	li t2, 'I'
	li t3, 'O'
	li t4, 'U'
	li t5, ~(1 << 5)
1:
	lbu t6, (a0)
	beqz t6, 3f
	and t6, t6, t5
	beq t6, t0, 2f
	beq t6, t1, 2f
	beq t6, t2, 2f
	beq t6, t3, 2f
	beq t6, t4, 2f
	addi a1, a1, -1
2:
	addi a1, a1, 1
	addi a0, a0, 1
	j 1b
3:
	mv a0, a1
	ret

uppercase_first:
# input:
#   a0 is the address of the string.
# output:
#   none

	li t0, 'a'
	li t1, 'z'
	li t3, ' '
	j 3f
1:
	bltu t2, t0, 2f
	bgtu t2, t1, 2f
	andi t2, t2, ~(1 << 5)
	sb t2, (a0)
2:
	addi a0, a0, 1
	lbu t2, (a0)
	beqz t2, 4f
	bne t2, t3, 2b
	addi a0, a0, 1
3:
	lbu t2, (a0)
	bnez t2, 1b
4:

	ret

uppercase_all:
# input:
#   a0 is the address of the string.
# output:
#   none

	li t0, 'a'
	li t1, 'z'
	j 3f
1:
	bltu t2, t0, 2f
	bgtu t2, t1, 2f
	andi t2, t2, ~(1 << 5)
	sb t2, (a0)
2:
	addi a0, a0, 1
3:
	lbu t2, (a0)
	bnez t2, 1b

	ret

remove_extra_spaces:
# input:
#   a0 is the address of the string.
# output:
#   none

	# a0 = read ptr, a1 = write ptr
	mv a1, a0
	li t0, ' '

.loop:
	lbu t1, (a0)
	beqz t1, .end
	beq t1, t0, .spaces_loop
	sb t1, (a1)
	addi a0, a0, 1
	addi a1, a1, 1
	j .loop
.spaces_loop:
	addi a0, a0, 1
	lbu t1, (a0)
	beqz t1, .end
	beq t1, t0, .spaces_loop
	sb t0, (a1)
	addi a1, a1, 1
	j .loop
.end:

	sb zero, (a1)
	ret

.bss
# Zeroed by the loader.
string_buf: .skip BUF_SIZE

.section .rodata
header: .asciz "Matt Fellenz\n\nEnter a string: "
chars_fmt: .asciz "There are %llu characters in \"%s\".\n"
vowels_fmt: .asciz "There are %llu vowels in \"%s\".\n"
upper_first_fmt: .asciz "Upper case first characters: \"%s\".\n"
shouting_fmt: .asciz "Shouting: \"%s\".\n"
spaces_fmt: .asciz "Extra spaces removed: \"%s\".\n"
