.text
.globl main

main:

    li x20, 3 # x = 3
    li x21, 1 # a = 1
    li x22, 3 # b = 3
    li x23, 5 # c = 5

    li t0, 1  # temp variable for comparison

    beq x20, t0, Case1

    li t0, 2  # temp variable for comparison

    beq x20, t0, Case2

    li t0, 3  # temp variable for comparison

    beq x20, t0, Case3

    li t0, 4  # temp variable for comparison

    beq x20, t0, Case4

    beq x0, x0, Default


Case1:
    add x21, x22, x23  # a = b + c
    beq x0, x0, Exit 

Case2:

    sub x21, x22, x23  # a = b - c
    beq x0, x0, Exit

Case3:
    slli x21, x22, 1  # a = b * 2
    beq x0, x0, Exit

Case4:

    srai x21, x22, 1 # a = b / 2
    beq x0, x0, Exit

Default:

    li x21, 0  # a = 0

Exit:

end:
    j end 
