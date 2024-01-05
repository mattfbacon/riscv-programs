.equ BUF_SIZE, 100

.global main
main:
// input:
//   none
// output:
//   r0 is the exit code.
	stmdb sp!, {r4, r5, fp, lr}
	add fp, sp, #8

	ldr r0, =header
	ldr r1, =stderr
	ldr r1, [r1]
	bl fputs

	ldr r4, =string_buf
	mov r0, r4
	mov r1, #(BUF_SIZE - 1)
	bl my_getline

	mov r1, r0
	ldr r0, =chars_fmt
	mov r2, r4
	bl printf

	mov r0, r4
	bl count_vowels
	mov r1, r0
	ldr r0, =vowels_fmt
	mov r2, r4
	bl printf

	mov r0, r4
	bl uppercase_first
	ldr r0, =upper_first_fmt
	mov r1, r4
	bl printf

	mov r0, r4
	bl uppercase_all
	ldr r0, =shouting_fmt
	mov r1, r4
	bl printf

	mov r0, r4
	bl remove_extra_spaces
	ldr r0, =spaces_fmt
	mov r1, r4
	bl printf

	mov r0, #0
	ldmia sp!, {r4, r5, fp, lr}
	bx lr

my_getline:
// input:
//   r0 is the address of the buffer.
//   r1 is the size of the buffer in bytes.
// output:
//   r0 is the number of bytes stored in the buffer.
// notes:
//   this function will not add a null terminator.
	stmdb sp!, {r4, r5, r6, r7, fp, lr}
	add fp, sp, #16

	mov r4, r0
	add r5, r0, r1
	mov r6, r0
	b 2f
1:
	bl getchar
	cmp r0, #'\n'
	beq 3f
	strb r0, [r4], #1
2:
	cmp r4, r5
	bmi 1b
3:
	sub r0, r4, r6
	ldmia sp!, {r4, r5, r6, r7, fp, lr}
	bx lr

count_vowels:
// input:
//   r0 is the address of the string.
// output:
//   r0 is the number of vowels in the string.

	mov r1, r0
	mov r0, #0
	b 2f
1:
	// Clearing bit 5 halves our check cases without introducing false positives.
	bic r2, r2, #(1<<5)
	cmp r2, #'A'
	cmpne r2, #'E'
	cmpne r2, #'I'
	cmpne r2, #'O'
	cmpne r2, #'U'
	addeq r0, r0, #1
2:
	ldrb r2, [r1], #1
	cmp r2, #0
	bne 1b

	bx lr

uppercase_first:
// input:
//   r0 is the address of the string.
// output:
//   none

	ldrb r1, [r0]
	cmp r1, #0
	bxeq lr
1: // .outer_loop
	cmp r1, #'a'
	bmi 2f
	cmp r1, #'z'
	bhi 2f
	bic r1, r1, #(1<<5)
	strb r1, [r0]
2: // .skip_loop
	ldrb r1, [r0, #1]!
	cmp r1, #0
	bxeq lr
	cmp r1, #' '
	bne 2b
3: // .space_loop
	ldrb r1, [r0, #1]!
	cmp r1, #0
	bxeq lr
	cmp r1, #' '
	beq 3b
	b 1b

uppercase_all:
// input:
//   r0 is the address of the string.
// output:
//   none

1: // .loop
	ldrb r1, [r0], #1
	cmp r1, #0
	bxeq lr
	cmp r1, #'a'
	bmi 1b
	cmp r1, #'z'
	bhi 1b
	bic r1, r1, #(1<<5)
	strb r1, [r0, #-1]
	b 1b

remove_extra_spaces:
// input:
//   r0 is the address of the string.
// output:
//   none

	mov r3, #' '
	// r0 = read ptr, r1 = write ptr
	mov r1, r0
1: // .loop
	ldrb r2, [r0], #1
	cmp r2, #0
	beq 4f
	cmp r2, #' '
	bne 3f
2: // .spaces_loop
	ldrb r2, [r0], #1
	cmp r2, #0
	beq 4f
	cmp r2, #' '
	beq 2b
	// By writing the single space here, we ensure that no space will be added if the string ends with just spaces.
	strb r3, [r1], #1
3: // .skip_spaces_loop
	strb r2, [r1], #1
	b 1b
4: // .end
	strb r2, [r1]
	bx lr

.bss
string_buf: .skip BUF_SIZE

.section .rodata
header: .asciz "Matt Fellenz\n\nEnter a string: "
chars_fmt: .asciz "There are %u characters in \"%s\".\n"
vowels_fmt: .asciz "There are %u vowels in \"%s\".\n"
upper_first_fmt: .asciz "Upper case first characters: \"%s\".\n"
shouting_fmt: .asciz "Shouting: \"%s\".\n"
spaces_fmt: .asciz "Extra spaces removed: \"%s\".\n"
