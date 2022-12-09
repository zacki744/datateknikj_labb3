
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
    ret

//output dec
outImage:
    ret
    
putInt:
    ret
    
putText:
    ret
    
putChar:
    ret
    
getOutPos:
    ret

getOutPos:
    ret