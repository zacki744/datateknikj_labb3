.equ MAX_INBUFFER_SIZE,64
.equ MAX_OUTBUFFER_SIZE,64

	.data
inPos:  .quad 0
outPos:  .quad 0
inBuf:  .space MAX_INBUFFER_SIZE+1
outBuf: .space MAX_OUTBUFFER_SIZE+1
	.text
	.global inImage,getInt,getText,getChar,getInPos,setInPos
	.global outImage,putInt,putText,putChar,getOutPos,setOutPos

inImage:
	movq $inBuf,%rdi
	movq $MAX_INBUFFER_SIZE+1,%rsi
	movq stdin,%rdx
	call fgets
	movq $0,inPos
	ret

getInt:
    pushq $0 # 8(%rsp) sign ( 0 mean positive 1 mean negative )
	pushq $0 # (%rsp) we use it as result
	# we need to skip all spaces
getInt_s1:
    call getChar
	cmpb $' ',%al
	je getInt_s1
	# first we need to check for sign
	cmpb $'+',%al
	je getInt_loop
	cmpb $'-',%al
	jne getInt_loop_cmp
	movq $1,8(%rsp) # this mean negative :)

getInt_loop:
	call getChar

getInt_loop_cmp:
	cmpb $'0',%al
	jl getInt_done
	cmpb $'9',%al
	jg getInt_done1
	sub $'0',%al # convert to value
	movzb %al,%r8
	movq $10,%rax
	mulq (%rsp)
	addq %r8,%rax
	movq %rax,(%rsp)
	jmp getInt_loop

getInt_done:
	cmpb $' ',%al
	jne getInt_done1

getInt_s2:
	call getChar
	cmpb $' ',%al
	je getInt_s2

getInt_done1:
	decq inPos
	movq (%rsp),%rax
	cmpq $0,8(%rsp)
	je getInt_done2
	negq %rax # this mean negative

getInt_done2:
	addq $16,%rsp
	ret

getText:
	# rdi = address of buf
	# rsi max number of char to read from input
	pushq %rsi # 16(%rsp) used for number of characters transferred
	pushq %rsi # save max number 8(%rsp)
	pushq %rdi # save buf at (%rsp)

getText_loop:
	cmpq $0,8(%rsp)
	jle getText_done
	cmpq $MAX_INBUFFER_SIZE,inPos
	jl getText_loop_update
	call inImage

getText_loop_update:
	movq $inBuf,%rdi
	movq inPos,% 
	addq %rdx,%rdi
	incq inPos
	movb (%rdi),%al
	movq (%rsp),%rdx
	movb %al,(%rdx)
	cmpb $0,%al
	je  getText_done
	decq 8(%rsp)
	incq (%rsp)
	jmp getText_loop

getText_done:
	movq 16(%rsp),%rax # return number of characters transferred
	subq 8(%rsp),%rax
	addq $24,%rsp
	ret

getChar:
	cmpq $MAX_INBUFFER_SIZE,inPos
	jl getChar_done
	call inImage

getChar_done:
	movq $inBuf,%rax
	movq inPos,%rdx
	addq %rdx,%rax
	incq inPos
	movzb (%rax),%rax
	ret

getInPos:
	movq inPos,%rax
	ret

setInPos:
	# rdi = n
	cmpq $0,%rdi
	jl setInPos_0
	cmpq $MAX_INBUFFER_SIZE,%rdi
	jge setInPos_MAX
	movq %rdi,inPos
	ret 

setInPos_0:
	movq $0,inPos
	ret

setInPos_MAX:
	movq $MAX_INBUFFER_SIZE-1,inPos
	ret

outImage:
	movq $outBuf,%rdi
	call puts
	movb $0,outBuf # append null byte
	movq $0,outPos
	ret

putInt:
	pushq %rbp
	movq %rsp,%rbp
	pushq $0 # -8(%rbp) we use it as counter for loops
	pushq %rdi # -16(%rbp) n value
	cmpq $0,%rdi
	jge putInt_loop1_init
	negq -16(%rbp)
	movq $'-',%rdi
	call putChar

putInt_loop1_init:
	movq -16(%rbp),%rax
	movq $10,%rcx

putInt_loop1:
	movq $0,%rdx
	divq %rcx
	addq $'0',%rdx # convert to assci
	pushq %rdx # save to stack
	incq -8(%rbp)
	cmpq $0,%rax
	jne putInt_loop1

putInt_loop2:
	popq %rdi
	call putChar
	decq -8(%rbp)
	jne putInt_loop2
	leave
	ret

putText:
	# rdi = address of buf
	pushq %rdi # (%rsp) for save addres of buf

putText_loop:
	movq (%rsp),%rax
	cmpb $0,(%rax)
	je putText_done
	cmpq $MAX_OUTBUFFER_SIZE,outPos
	jl putText_loop_update
	call outImage

putText_loop_update:
	movq (%rsp),%rax
	movb (%rax),%al
	movq $outBuf,%rdi
	movq outPos,%rdx
	addq %rdx,%rdi
	movb %al,(%rdi)
	incq outPos
	incq (%rsp)
	jmp putText_loop

putText_done:
	movq $outBuf,%rdi
	movq outPos,%rdx
	addq %rdx,%rdi
	movb $0,(%rdi) # null byte at end :)
	popq %rdi
	ret
    
putChar:
	# dil = char c
	cmpq $MAX_OUTBUFFER_SIZE,outPos
	jl putChar_done
	pushq %rdi
	call outImage
	popq %rdi

putChar_done:
	movq $outBuf,%r8
	movq outPos,%rdx
	incq outPos
	addq %rdx,%r8
	movb %dil,(%r8)
	movb $0,1(%r8) # append null to end
	ret

getOutPos:
	movq outPos,%rax
	ret

setOutPos:
	# rdi = n
	cmpq $0,%rdi
	jl setOutPos_0
	cmpq $MAX_OUTBUFFER_SIZE,%rdi
	jge setOutPos_MAX
	movq %rdi,outPos
	ret

setOutPos_0:
	movq $0,outPos
	ret

setOutPos_MAX:
	movq $MAX_OUTBUFFER_SIZE-1,outPos
	ret