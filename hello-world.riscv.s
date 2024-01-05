# Defaults to the text section, so no need for `.text`.
.global main
main:
	# Save registers.
	addi sp, sp, -16
	sd s0, 8(sp)
	sd ra, 0(sp)

	# Print each entry in `msg_table` until `*msg_table == NULL`.
	la s0, msg_table
	j .entry
.loop:
	jal puts
	addi s0, s0, 8
.entry:
	ld a0, (s0)
	# `x0` is hardwired to zero.
	bnez a0, .loop

	# Restore registers.
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 16

	# Return the day I was born on.
	li a0, 13
	ret

# `.data` is sloppy!
.section .rodata

.balign 8
# With `NULL` sentinel.
msg_table: .quad msg0, msg1, msg2, 0

msg0: .asciz "Matt Fellenz"
msg1: .asciz "lorem ipsum"
msg2: .asciz "hello, world!"
