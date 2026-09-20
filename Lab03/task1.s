.text
.globl main

main:

    addi x10,x0,12   # a = 12 (x10)
    addi x11,x0,12   # b = 12 (x11)
    jal x1,sum       # calls sum ( x1 =  return address ) 
    addi x11,x10,0   # copy result into x11 for ecall
    li x10,1         # ecall 1 = print integer 
    ecall            # prints 24
    j exit           # jumps to exit

sum:
    add x10,x11,x10  # x10 = a + b ( return value goes into x10 )
    jalr x0,0(x1)    # return to caller

exit:

    j exit     