.equ Max_Buf_In,64
.equ Max_Buf_Out,64

	.data
buf_IN:	.space Max_Buf_In+1
buf_UT:	.space Max_Buf_Out+1
index_IN:	.quad 0
index_UT:	.quad 0

	.text
	.global inImage,getInt,getText,getChar,getInPos,setInPos
	.global outImage,putInt,putText,putChar,getOutPos,setOutPos

inImage:
	movq $buf_IN,%rdi
	movq $Max_Buf_In+1,%rsi
	movq stdin,%rdx
	call fgets
	movq $0,index_IN
	ret

getInt:
    pushq $0 
    pushq $0

getInt_first:
    call getChar # get char
    cmpb $' ', %al # check if space
    je getInt_first # if space get next char
    cmpb $'+', %al # check if positive
    je getInt_loop # if positive get number
    cmpb $'-', %al # check if negative
    jne getInt_compare # if not negative get number
    movq $1,8(%rsp) # set negative flag

getInt_loop:
    call getChar 

getInt_compare:
    cmpb $'0', %al # check if number
    jl getInt_end # if not number end
    cmpb $'9', %al # check if number
    jg getInt_end1 # if not number end
    sub $'0', %al 
    movzb %al, %r8
    movq $10, %rax
    mulq (%rsp)
    addq %r8, %rax
    movq %rax, (%rsp)
    jmp getInt_loop

getInt_end:
    cmpb $' ', %al
    jne getInt_end1

getInt_pos:
    call getChar
    cmpb $' ', %al
    je getInt_pos

getInt_end1:
    decq index_IN 
    movq (%rsp), %rax 
    movq $0,8(%rsp) 
    je getInt_end2 
    negq %rax # negative

getInt_end2:
    addq $16, %rsp
    ret

getText:
    pushq %rsi
    pushq %rsi   
    pushq %rdi

getText_loop:
    cmpq $0,8(%rsp)
    jle getText_end
    cmpq $Max_Buf_In, index_IN
    jl getText_update
    call inImage

getText_update:
    movq $buf_IN, %rdi
    movq index_IN, %rdx
    addq %rdx, %rdi
    incq index_IN
    movb (%rdi), %al
    movq (%rsp), %rdx
    movb %al, (%rdx)
    cmpb $0, %al
    je getText_end
    decq 8(%rsp)
    incq (%rsp)
    jmp getText_loop

getText_end:
    movq 16(%rsp), %rax
    subq 8(%rsp), %rax
	addq $24,%rsp
    ret


getChar:
    // comparisons
    cmpq $Max_Buf_In, index_IN
    jl getChar_complete
    call inImage

getChar_complete:
    movq $buf_IN, %rdi
    movq index_IN, %rsi
    movq (%rdi,%rsi,1), %rax
    incq index_IN
    ret

getInPos:
    movq index_IN, %rax
    ret
    
setInPos:
	# rdi = n
	cmpq $0,%rdi
	jl setInPoszero
	cmpq $Max_Buf_In,%rdi
	jge setInPoslarg
	movq %rdi,index_IN
	ret 

setInPoszero: //set to 0
    movq $0,%rdi
    ret

setInPoslarg: //set to max
    movq index_IN, %rdi
    ret

//output dec
outImage:
	movq $buf_UT,%rdi
	call puts
	movb $0,buf_UT # append null byte
	movq $0,index_UT
    ret
putInt:
    pushq %rbp # save rbp
    movq %rsp, %rbp # set rbp
    pushq $0 # push 0 to stack
    pushq %rdi # push number to stack
    cmpq $0, %rdi # check if 0
    jge putInt_pos # if positive
    negq -16(%rbp) # negative
    movq $'-', %rdi # set '-'
    call putChar # print char

putInt_pos:
    movq -16(%rbp), %rax # get number
    movq $10, %rcx # set 10 to rcx

putInt_loop_init:
    movq $0, %rdx # clear rdx
    divq %rcx # div by 10
    addq $'0', %rdx # add '0'
    pushq %rdx # push to stack
    incq -8(%rbp) # inc stack size
    cmpq $0, %rax # check if 0
    jne putInt_loop_init # if not 0 loop

putInt_loop:
    popq %rdi # pop from stack
    call putChar # print char
    decq -8(%rbp) # dec stack size
    cmpq $0, -8(%rbp) # check if 0
    jne putInt_loop # if not 0 loop
    leave # restore rbp
    ret

putText:
	# rdi = address of buf
	pushq %rdi # (%rsp) for save addres of buf

putText_loop:
	movq (%rsp),%rax
	cmpb $0,(%rax)
	je putText_done
	cmpq $Max_Buf_Out,index_UT
	jl putText_loop_update
	call outImage

putText_loop_update:
	movq (%rsp),%rax
	movb (%rax),%al
	movq $buf_UT,%rdi
	movq index_UT,%rdx
	addq %rdx,%rdi
	movb %al,(%rdi)
	incq index_UT
	incq (%rsp)
	jmp putText_loop

putText_done:
	movq $buf_UT,%rdi
	movq index_UT,%rdx
	addq %rdx,%rdi
	movb $0,(%rdi) # null byte at end :)
	popq %rdi
	ret


putChar:
    cmpq $Max_Buf_Out, index_UT # check if out of range
    jl putChar_complete # if not complete 
    pushq %rdi # save char
    call outImage # print buf
    popq %rdi # get char

putChar_complete:
    movq $buf_UT, %r8 # get buf pos
    movq index_UT, %rdx # get pos
    incq index_UT # inc pos
    addq %rdx, %r8 # get pos in buf
    movb %dil, (%r8) # put char in buf 
    movq $0,1(%r8) # null attach
    ret
    
getOutPos:
    movq index_UT, %rax 
    ret

setOutPos:
	# rdi = n
	cmpq $0,%rdi
	jl setOutPos_0
	cmpq $Max_Buf_Out,%rdi
	jge setOutPos_MAX
	movq %rdi,index_UT
	ret

setOutPos_0:
	movq $0,index_UT
	ret

setOutPos_MAX:
	movq $Max_Buf_Out-1,index_UT
	ret
