.text
.globl main

main:

    li x10, 0x400  # base address of array a

    addi t0, x0, 5
    sw t0, 0(x10)  # arr[0] = 5

    addi t0, x0, 3 
    sw t0, 4(x10)  # arr[1] = 3

    addi t0, x0, 8  
    sw t0, 8(x10)  # arr[2] = 8

    addi t0, x0, 1 
    sw t0, 12(x10) # arr[3] = 1

    addi t0, x0, 9
    sw t0, 16(x10) # arr[4] = 9


    addi x11, x0, 5 # len = 5
    addi x12, x0, 8  # target = 8
    addi x13, x0, 0  # i = 0

    jal x1, linearsearch

    addi x11, x10, 0   # x11 = result 
    addi x10, x0, 1    # x10 = 1 for ecall
    ecall

exit:

    j exit



linearsearch:

    addi sp, sp, -4   # stack allocation for return address
    sw x1, 0(sp)      # save x1

    bge x13, x11, not_found  # i >= len, done

    slli t1, x13, 2     # t1 = i * 4 for offset
    add t1, t1, x10    # t1 = &arr[i]
    lw t2, 0(t1)       # t2 = arr[i]

    beq t2, x12, found  # arr[i] == target, return

    addi x13, x13, 1 # i++
    jal x1, linearsearch    # recursive call

    lw x1, 0(sp)   # restore x1
    addi sp, sp, 4 # deallocate stack
    jalr x0, 0(x1)  # return

found: 
    addi x10, x13, 0   # return i 
    lw x1, 0(sp)      # restore x1
    addi sp, sp, 4    # stack deallocation
    jalr x0, 0(x1)    # return to caller

not_found:
    addi x10, x0, -1  # return -1 
    lw x1, 0(sp)      # restore x1
    addi sp, sp, 4    # stack deallocation
     jalr x0, 0(x1)    

