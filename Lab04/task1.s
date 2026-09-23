.text
.globl main

main:
    addi x5, x0, 1  # result = 1
    addi x10, x0, 5 # n = 5

    jal x1, fact

    addi x11, x5, 0   # move result into x11 for ecall
    addi x10, x0, 1  # x10 = 1 ecall code for print int
    ecall

    j exit          # stop

fact:
    loop:

        bge x0, x10, done   # (n <= 0), exit
        mul x5, x5, x10     # result *= n
        addi x10, x10, -1   # n --
        beq x0, x0, loop    # loop 

    done:
        addi x10, x5, 0   # return result
        jalr x0, 0(x1)   # jump back


exit:
    j exit  # infinite loop to end the program 