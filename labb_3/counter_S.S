.data
	counter:	.quad 0
	GPIO:		.quad 0
.text
.global setup
.global interrupt
.global inImage
.global getText

inImage:
	moveq $buf,$rdi
	moveq $0,$rdi
	ret
getText:


interrupt:
	ret

setup:
	ret
