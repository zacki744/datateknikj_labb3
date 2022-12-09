
.data
    buf_IN     .quad 0
    buf_UT     .quad 0
    temp       .quad 0
    index_IN   .quad 0
    index_UT   .quad 0

//input
.global inImage, getInt, getText, getChar, getInPos, setInPos

//output
.global outImage, putInt, putText, putChar, getOutPos, getOutPos

//input dec
inImage:
    leaq stdin, %rcx 
    movzbq (%rcx,index_IN,1), buf_IN
    xorq %rdi,%rdi
    ret

getInt:
    ret

getText:
    ret

getChar:
    // comparisons
    cmpq index_IN, $0
    je inImage
    // out of range
    movzbq (buf_IN,index_IN,1), temp
    cmpq temp, $0
    je inImage
    xorq temp,temp
    //add
    movzbq (buf_IN,index_IN,1), %rax
    incq index_IN 
    ret

getInPos:
    movq %rax, index_IN
    ret
    
setInPos:
    cmpq %rdi,$0 //check if 0
    jg setInPoszero
    cmpq %rdi,index_IN //check if out of range
    jl setInPoszero
    movq %rdi, index_IN //set
    ret
setInPoszero: //set to 0
    movq $0,%rdi
    ret
setInPoslarg: //set to max
    movq index_IN, %rdi
    ret
//output dec
outImage:
    leaq stdout, %rcx 
    movzbq (%rcx,index_UT,1), buf_UT
    xorq BUF_UT, buf_UT
    ret
    
putInt:
    ret
    
putText:
    ret
    
putChar:
    ret
    
getOutPos:
    movq %rax, index_UT
    ret

setOutPos:
    cmpq %rdi,$0 //check if 0
    jg setOutPoszero
    cmpq %rdi,index_UT //check if out of range
    jl setOutPoszero
    movq %rdi, index_UT //set
    ret
setOutPoszero: //set to 0
    movq $0,%rdi
    ret
setOutPoslarg: //set to max
    movq index_UT, %rdi
    ret