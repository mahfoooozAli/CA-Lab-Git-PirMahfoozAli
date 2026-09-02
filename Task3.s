.text
.globl main

main:

    li x5, 5  # int a = 5
    li x6, 0  # int b = 0 + 0
    

    addi x5, x6, 32  # a = b + 32

    add x7, x5, x6  # int d = (a + b) 
    addi x7, x7, -5  # int d = (a + b) - 5

    sub x8, x5, x7  # int e = (a - d)
    sub x9, x6, x5  # temp = (b - a)
    add x8, x8, x9  # int e = (a - d) + (b - a)
    add x8, x8, x7  # int e = (((a - d) + (b - a)) + d)

    add x10, x5, x6  # temp = a + b
    add x11, x7, x8  # temp = d + e
    add x8, x10, x11 # e = a + b + d + e

end:
    j end
