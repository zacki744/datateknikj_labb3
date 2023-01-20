.data
    counter:    .quad 0
    GPIO:		.quad gpio

.text
    .global  interrupt 
    .global  setup

interrupt:
    mov     counter, %rax	    # get counter address
    inc     %rax			    # increment counter
	andq 	$0x0f,%rax		    # mask to 4 bits
    movq     %rax, counter	    # store counter
    shl     $4, %al			    # shift counter to bits 4-7
    mov     GPIO, %rdi		    # get GPIO address
    mov     $1, %r8			    # set bit 8

interrupt_loop:
    cmp     $4, %r8				
    jg      interrupt_loop_done	# if so, done
    shl     $1, %al				# shift counter to next bit
    jc      interrupt_loop_on	# if carry set, turn on bit
    mov     $0xcf, %rdx			# set GPIO clear register
    mov     %r8b, %cl			# set GPIO bit to clear
    dec     %cl					# decrement to get bit number
    shl     $3, %cl				# shift to bit position
    shl     %cl, %rdx			# shift to register position
    not     %rdx				# invert to get set register
	andq 	%rdx,3(%rdi) 		# *(int*)gpio_addr+3 &= ~(0xcf << (8*(GPIO_NR - 1))) (altså led av)
    jmp     interrupt_loop_update	# update GPIO bit

interrupt_loop_on:
    mov     $3, %rdx		    # set GPIO set register
    shl     $4, %rdx		    # shift to register position
    inc     %rdx			    # increment to get set register
    mov     %r8b, %cl		    # set GPIO bit to set
    dec     %cl				    # decrement to get bit number
    shl     $3, %cl			    # shift to bit position
    shl     %cl, %rdx		    # shift to register position
	or  	%rdx,3(%rdi) 	    # (int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1)); (allts˚a LED på)

interrupt_loop_update:
    inc     %r8				    # increment bit number
    jmp     interrupt_loop	    # loop

interrupt_loop_done:
    ret

setup:
    mov     $0x60, %rax 	    # immediate value 0x60 into the RAX. constant representation
    shl     $16, %rax 		    # shifts RAX left by 16 bits, 2^16
    mov     $0xffff, %rcx 	    # immediate value 0xffff into the RCX. constant representation
    and     $0x1000, %rcx 	    # clears all but the most significant bit of RCX
    mov     $0x9e, %rdx 	    # 0x9e = 0b10011110
    not     %rdx 			    # inverts all the bits of RDX
    and     $0xff, %rdx 	    # clears all but the least significant byte of RDX
    or      %rcx, %rax 		    # ORs RCX with RAX
    or      %rdx, %rax 		    # int gpio_addr = ((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF)) (minnesaddressen till de emulerade GPIO pinnarna)
    mov     %rax, GPIO		    # gpio_addr = 0x610061
    mov     $1, %r8 		    # the counter (witch pin is on) GPIO_NR = 1

setup_loop: 
    cmpq    $4, %r8 		    # GPIO_NR < 4
    jg      setup_loop_done     # if so, done
    movw    $2, %dx 		    # set GPIO direction register
    shl     $6, %dx 		    # shift to register position
	movb 	$4,%cl 			    # set GPIO bit to set
    sub     %r8b, %cl 		    # subtracts the last significant byte of R8 from CL
	shl 	$1,%cl 			    # shifts CL left by 1 bit
	shl     %cl, %dx 		    # shifts DX left by CL
    or      %dx, (%rax) 	    # (short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2) (Sätter GPIO pin med nummer GPIO_NR till att vara output)
    mov     $3, %dx 		    # moves the 3 into DX
	shl     $3, %cl 		    # shifts CL left by 3 bits
	subb 	%r8b,%cl 		    # subtracts R8 from CL
	shl    $1, %cl 			    # shift  CL left by 1 bit
    and     $7, %cl 		    # AND betwen CL and 7
    add     $8, %cl 		    # adds the value 8 in the register CL
	shl 	%cl,%dx 		    # shifts DX left CL
	or      %dx, (%rax) 	    # OR between DX and the memory address at RAX
	mov     $1, %dx 		    # moves 1 into DX
	movq 	%r8,%r9 		    # copies R8 into R9
	shr 	$3,%r9 			    # shifts R9 righ by 3 bits
	orw 	%dx,(%rax,%r9)      # (short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8); (sätta en GPIO pin till input) 
	incq 	%r8 			    # increments the value in R8 by 1
	jmp     setup_loop 		    # continues the loop 
setup_loop_done: 			    # break
    ret
