.equ MAXPOS, 64

.data
    buf_IN     .quad MAXPOS+1
    buf_UT     .quad MAXPOS+1
    temp       .quad 0
    index_IN   .quad 0
    index_UT   .quad 0

//input
.global inImage, getInt, getText, getChar, getInPos, setInPos

//output
.global outImage, putInt, putText, putChar, getOutPos, getOutPos

//input dec
inImage:
    movq buf_IN, %rdi
    movq %MAXPOS+1, %rsi
    movq stdin, %rdx
    call fgets
    movq $0, index_IN
    ret

getInt:
    ret

getText:
    ret

getChar:
    // comparisons
    cmpq $MAXPOS,index_IN
    jl getChar_Complete
    call inImage
getChar_Complete:
    movzbq (buf_IN,index_IN,1), %rax
    incq index_IN 
    ret

getInPos:
    movq index_IN, %rax
    ret
    
setInPos:
    cmpq $0, %rdi //check if 0
    jl setInPos_Zero
    cmpq MAXPOS,%rdi //check if out of range
    jge setInPos_Large
    movq %rdi, index_IN //set
    ret
setInPos_Zero: //set to 0
    movq $0,%rdi
    ret
setInPos_Large: //set to max
    movq index_IN, %rdi
    ret
//output dec
outImage:
    movq buf_UT, %rdi
    call puts
    movq $0, buf_UT
    movq $0, index_UT
    ret
putInt:
    ret
    
putText:
    
    ret
    
putChar:
    // comparisons  
    cmpq $MAXPOS,index_UT
    jl putChar_Complete
    call outImage
    ret
putChar_Complete:
    movq %rdi, (buf_UT,index_UT,1)
    incq index_UT
    ret
    
getOutPos:
    movq %rax, index_UT
    ret

setOutPos:
    cmpq $0, %rdi //check if 0
    jl setOutPos_Zero: //set to 0
    cmpq MAXPOS,%rdi //check if out of range
    jge setOutPos_Large
    movq %rdi, index_UT //set
    ret
setOutPos_Zero: //set to 0
    movq $0,%rdi
    ret
setOutPos_Large: //set to max
    movq index_UT, %rdi
    ret
