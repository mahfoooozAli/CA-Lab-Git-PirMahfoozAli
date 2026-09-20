.text
.globl main


main:

    li x10, 10  # g  = 10
    li x11, 5   # h = 5
    li x12, 7   # i = 7
    li x13, 6   # j = 6

    jal x1, leaf_example  # calls the function
    
    addi x11, x10, 0    # copies f result into x11 for ecall
    li x10, 1           # ecall 1 = print integer
    ecall               # prints 2

    j exit


leaf_example:


    addi sp, sp, -12  # stack allocation for three registers 
    sw x18, 8(sp)  #  saves x18
    sw x19, 4(sp)  #  saves x19
    sw x20, 0(sp)  #  saves x20
    
    add x18, x10, x11  # x18 = g + h
    add x19, x12, x13  # x19 = i + j
    sub x20, x18, x19   # f = ( g + h ) - ( i + j )

    addi x10, x20, 0   # return value f goes into x10
    lw x18, 8(sp)      # restore x18
    lw x19, 4(sp)      # restore x19
    lw x20, 0(sp)      # restore x20
    addi sp, sp, 12    # pop the stack
    jalr x0, 0(x1)     # return to the caller 

exit:

    j exit     
