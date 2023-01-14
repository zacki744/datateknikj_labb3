.data
	counter:	.quad 0
	GPIO:		.quad 0x601061
	vector:		
		.word 0000
		.word 0001
		.word 0010
		.word 0011
		.word 0100
		.word 0101
		.word 0110
		.word 0111
		.word 1000
		.word 1001
		.word 1010
		.word 1011
		.word 1100
		.word 1101
		.word 1110
		.word 1111
.text
.global setup, interrupt, interupt_zero

interrupt:
	cmpq $15,%rdx
	jge interupt_zero
	incq %rdx
	movq 4(%rdi),GPIO
	ret

interupt_zero:
	movq $0,%rdx
	str %rdx
	ret

setup:
	leaq counter,%rcx
	leaq (%rcx),%rdx
	leaq vector,%rsi
	leaq (%rsi),%rdi
	movq $0,%rdx
	movq %rdi,GPIO
	str %rdx
	ret


