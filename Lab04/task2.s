.text
.globl main

main:
    addi t0, x0, 1   # temp  = 1 for if condition
    addi x10, x0, 5  # num = 5
    jal x1, ntri

    addi x11, x10, 0  # x11 = result
    addi x10, x0, 1  # x10 = 1 for print integer
    ecall

exit:
    j exit 

ntri:

    addi sp, sp, -8  # stack allocation for num and return address x1
    sw x10, 0(sp)    # save num
    sw x1, 4(sp)    # save return address

    bge t0, x10, base  # (n <= 1), done

    addi x10, x10, -1  # num - 1
    jal x1, ntri    # ntri(n-1)
    addi t1, x10, 0 # temp = ntri(n-1)
    lw x10, 0(sp)   #  restore x10

    add t2, x10, t1  # temp =  num + ntri(n-1)
    add x10, x0, t2   # return num
    jal x0, done  # skip base case


    base:

        addi x10, x0, 1  # return 1

    done:
        lw x1, 4(sp)  # restore x1
        addi sp, sp, 8  # deallocate stack
        jalr x0, 0(x1)  # jump back
    
