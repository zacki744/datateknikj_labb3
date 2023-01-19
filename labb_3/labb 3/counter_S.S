.data
    counter:    .quad 0
    GPIO:		.quad gpio

.text
    .global  interrupt 
    .global  setup
interrupt:
    mov     counter, %rax	# get counter address
    inc     %rax			# increment counter
	andq 	$0x0f,%rax		# mask to 4 bits
    movq     %rax, counter	# store counter
    shl     $4, %al			# shift counter to bits 4-7
    mov     GPIO, %rdi		# get GPIO address
    mov     $1, %r8			# set bit 8

interrupt_loop:
    cmp     $4, %r8				# check if bit 8 is set
    jg      interrupt_loop_done	# if so, done
    shl     $1, %al				# shift counter to next bit
    jc      interrupt_loop_on	# if carry set, turn on bit

    mov     $0xcf, %rdx		# set GPIO clear register
    mov     %r8b, %cl		# set GPIO bit to clear
    dec     %cl				# decrement to get bit number
    shl     $3, %cl			# shift to bit position
    shl     %cl, %rdx		# shift to register position
    not     %rdx			# invert to get set register
	andq 	%rdx,3(%rdi) 	# clear bit
    jmp     interrupt_loop_update	# update counter

interrupt_loop_on:
    mov     $3, %rdx		# set GPIO set register
    shl     $4, %rdx		# shift to register position
    inc     %rdx			# increment to get set register
    mov     %r8b, %cl		# set GPIO bit to set
    dec     %cl				# decrement to get bit number
    shl     $3, %cl			# shift to bit position
    shl     %cl, %rdx		# shift to register position
	or  	%rdx,3(%rdi) 	# set bit

interrupt_loop_update:
    inc     %r8				# increment bit number
    jmp     interrupt_loop	# loop

interrupt_loop_done:
    ret

setup:
    mov     $0x60, %rax 	# 0x60 = 0b01100000
    shl     $16, %rax 		# 0x600000 = 0b011000000000000000000000
    mov     $0xffff, %rcx 	# 0xffff = 0b1111111111111111
    and     $0x1000, %rcx 	# 0x1000 = 0b0001000000000000
    mov     $0x9e, %rdx 	# 0x9e = 0b10011110
    not     %rdx 			# 0x61 = 0b01100001
    and     $0xff, %rdx 	# 0x61 = 0b01100001
    or      %rcx, %rax 		# 0x610000 = 0b011000010000000000000000
    or      %rdx, %rax 		# 0x610061 = 0b011000010000000000011001
    mov     %rax, GPIO		# gpio_addr = 0x610061
    mov     $1, %r8 		# GPIO_NR

setup_loop:
    cmpq    $4, %r8 		# GPIO_NR
    jg      setup_loop_done # break
    movw    $2, %dx 		# GPIO_OUT
    shl     $6, %dx 		# GPIO_OUT << 6
	movb 	$4,%cl 			# GPIO_ALT0
    sub     %r8b, %cl 		# GPIO_ALT0 - GPIO_NR
	shl 	$1,%cl 			# (GPIO_ALT0 - GPIO_NR) << 1
	shl     %cl, %dx 		# (GPIO_OUT << 6) | ((GPIO_ALT0 - GPIO_NR) << 1)
    or      %dx, (%rax) 	# gpio_addr |= (GPIO_OUT << 6) | ((GPIO_ALT0 - GPIO_NR) << 1)
    mov     $3, %dx 		# GPIO_PUD
	shl     $3, %cl 		# (GPIO_ALT0 - GPIO_NR) << 3
	subb 	%r8b,%cl 		# (GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR
	shl    $1, %cl 			# ((GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR) << 1
    and     $7, %cl 		# ((GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR) << 1 & 7
    add     $8, %cl 		# ((GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR) << 1 & 7 + 8
	shl 	%cl,%dx 		# GPIO_PUD << ((GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR) << 1 & 7 + 8
	or      %dx, (%rax) 	# *(int*)gpio_addr |= GPIO_PUD << ((GPIO_ALT0 - GPIO_NR) << 3 - GPIO_NR) << 1 & 7 + 8
	mov     $1, %dx 		# GPIO_PUDCLK
	movq 	%r8,%r9 		# GPIO_NR
	shr 	$3,%r9 			# GPIO_NR >> 3
	orw 	%dx,(%rax,%r9)  # *(int*)gpio_addr |= GPIO_PUDCLK << (GPIO_NR >> 3)
	incq 	%r8 			# GPIO_NR++
	jmp     setup_loop 		# continue
setup_loop_done: 			# break
    ret

