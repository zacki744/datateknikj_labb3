.data
    temp    .asciz "tester wabalo"
.global main
main:
    pushq   $0
    movq    $temp,%rdi
    call    putText
    call    outImage
    call	inImage
