.text
.globl main

main:

    li x10, 0x400     # base address of x[]
    li x11, 0x500     # base address of y[]

    addi t0, x0, 67   # load 'C' (ASCII 67)
    sb t0, 0(x11)     # store 'C' in y[0]
    addi t0, x0, 65   # load 'A' (ASCII 65)
    sb t0, 1(x11)     # store 'A' in y[1]
    addi t0, x0, 84   # load 'T' (ASCII 84) 
    sb t0, 2(x11)     # store 'T' in y[2]
    sb x0, 3(x11)     # store '\0' at y[3]

    jal x1, strcpy

    
end:

    j end # loop 

strcpy:

    addi sp, sp, -4  # stack allocation for 1 register 
    sw x19,0(sp) # saves x19

    addi x19, x0, 0  # i = 0

loop:
    add t0, x19, x11  # t0 = address of char y[i]
    lbu  t1, 0(t0)    # t1 = y[i]

    add t2, x19, x10  # t2 = address of char x[i]
    sb t1, 0(t2)      # x[i] = y[i]

    beq t1, x0, Exit  # if the copied byte was \0, exit loop
    addi x19, x19,  1  # i++
    beq x0, x0, loop   # jump back to the loop 

Exit:
    lw x19, 0(sp)   # restore x19
    addi sp, sp, 4  # pop the stack
    jalr x0, 0(x1)  # return 

   