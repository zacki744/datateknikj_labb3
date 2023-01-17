.equ Max_Buf_In,64
.equ Max_Buf_Out,64
.data
    buf_IN:     .space Max_Buf_In+1
    buf_UT:     .space Max_Buf_Out+1
    index_IN:   .quad 0
    index_UT:   .quad 0

.text
//input
.global inImage, getInt, getText, getChar, getInPos, setInPos

//output
.global outImage, putInt, putText, putChar, getOutPos, setOutPos

//input dec
inImage:
    movq $Max_Buf_In+1, %rsi # get buf size
    movq $buf_IN, %rdi # get buf pos
    movq stdin, %rdx # get stdin
    call fgets # read from stdin
    movq $0, index_IN # set index to 0
    ret

getInt:
    pushq $0 # 8(%rsp) sign ( 0 mean positive 1 mean negative )
    pushq $0 # (%rsp) we use it as result
    # we need to skip all spaces

getInt_s1:
    call getChar # get char
    cmpb $' ',%al # check if space
    je getInt_s1 # if space jump to getInt_s1
    cmpb $'-',%al # check if '-'
    jne getInt_loop_cmp # if not jump to getInt_loop_cmp
    cmpb $'+',%al # check if '+' 
    je getInt_loop # if not jump to getInt_loop
    movq $1,8(%rsp) # set sign to 1 ( negative )

getInt_loop:
    call getChar # get char

getInt_loop_cmp:
    cmpb $'0',%al # check if 0
    jl getInt_done # if less jump to getInt_done
    cmpb $'9',%al # check if 9
    jg getInt_done1 # if greater jump to getInt_done1
    sub $'0',%al # convert to value
    movzb %al,%r8 # convert to 64 bit
    movq $10,%rax # set 10 to rax
    mulq (%rsp) # multiply result by 10
    addq %r8,%rax # add value
    movq %rax,(%rsp) # set result
    jmp getInt_loop # jump to getInt_loop

getInt_done:
    cmpb $' ',%al # check if space
    jne getInt_done1 # if not jump to getInt_done1

getInt_s2:
    call getChar # get char
    cmpb $' ',%al # check if space
    je getInt_s2 # if space jump to getInt_s2

getInt_done1:
    decq index_IN # decrease index
    movq (%rsp),%rax # get result
    cmpq $0,8(%rsp) # check if sign is 0
    je getInt_done2 # if not jump to getInt_done2
    negq %rax # this mean negative

getInt_done2:
    addq $16,%rsp # set rsp
    ret

getText:
    pushq %rsi # save rsi
    pushq %rsi # save rsi
    pushq %rdi # save rdi

getText_loop:
    cmpq $0,%rsp # check if 0
    jle getText_end # if not jump to getText_end
    cmpq $Max_Buf_In, index_IN # check if index is less than max buf
    jl getText_update # if not jump to getText_update
    call inImage # call inImage

getText_update:
    movq $buf_IN, %rdi # get buf pos
    movq index_IN, %rdx # get index
    addq %rdx, %rdi # add index to buf pos
    incq index_IN # increase index
    movb (%rdi), %al # get char
    movq (%rsp), %rdx # get buf pos
    movb %al, (%rdx) # set char
    cmpb $0, %al # check if 0
    je getText_end # if 0 jump to getText_end
    decq 8(%rsp) # decrease 8(%rsp)
    incq (%rsp) # increase (%rsp)
    jmp getText_loop # jump to getText_loop

getText_end:
    movq 16(%rsp), %rax # get buf pos
    subq 8(%rsp), %rax # sub 8(%rsp) from buf pos
    addq $24, %rsp # set rsp
    ret


getChar:
    // comparisons
    cmpq $Max_Buf_In, index_IN # check if index is less than max buf
    jl getChar_complete # if not jump to getChar_complete
    call inImage # call inImage

getChar_complete:
    movq $buf_IN, %rdi # get buf pos
    movq index_IN, %rdx # get index
    addq %rdx, %rdi # add index to buf pos
    movb (%rdi), %al # get char
    incq index_IN # increase index
    ret

getInPos:
    movq index_IN, %rax # get index
    ret
    
setInPos:
    cmpq $Max_Buf_In,%rdi # check if index is less than max buf
    jge setInPoslarg # if not jump to setInPoslarg
	cmpq $0,%rdi # check if 0
    jl setInPoszero # if not jump to setInPoszero
    movq %rdi, index_IN  # set index
    ret

setInPoszero:
    movq $0,%rdi # set 0
    ret

setInPoslarg: 
    movq index_IN, %rdi # get index
    ret

outImage:
    movq $buf_UT, %rdi # get buf pos
    call puts # print buf
    movq $0, buf_UT # clear buf
    movq $0, index_UT # set index to 0
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
    movq $10, %rcx # set 10 to rcx for div by 10 later on

putInt_loop_init:
    movq $0, %rdx # clear rdx 
    divq %rcx # div by 10 and get result in rax and remainder in rdx
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
	movq (%rsp),%rax # get address of buf
	cmpb $0,(%rax) # check if end of buf
	je putText_mov # if end of buf jump to putText_mov
	cmpq $Max_Buf_Out,index_UT # check if out of range
	jl putText_loop_update # if not out of range
	call outImage # if out of range call outImage

putText_loop_update:
    movq $buf_UT,%rdi # get buf pos
    movq index_UT,%rdx # get index
    addq %rdx,%rdi # add index to buf pos
    movq (%rsp),%rax # get address of buf
    movb (%rax),%al # get char
    movb %al,(%rdi) # put char in buf
    incq index_UT # inc index
    incq (%rsp) # inc address of buf
    jmp putText_loop # loop

putText_mov:
	movq $buf_UT,%rdi # get buf pos 
	movq index_UT,%rdx # get index 
	addq %rdx,%rdi # add index to buf pos 
	movb $0,(%rdi) # null attach 
	popq %rdi # restore address of buf
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
    cmpq $Max_Buf_Out, %rdi # check if out of range
    jge setOutPoslarg # if out of range set to max
    cmpq $0, %rdi # check if 0
    jl setOutPoszero # if 0 set to 0
    movq %rdi, index_UT # set pos
    ret

setOutPoszero:
    movq $0, index_UT # set pos to 0
    ret

setOutPoslarg:
    movq $Max_Buf_Out-1, index_UT # set pos to max
    ret
