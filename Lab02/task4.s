.text
.globl main

main:

    li x5, 5  # a = 5
    li x6, 10 # b = 10
    li x7, 0 # i = 0
    li x29, 0 # j = 0
    li x10, 0x200 # address of arr d



loop1:
    
    bge x7, x5, Exit
    li x29, 0 # resetting j
    li x10, 0x200 # resetting base address of arr d 

    loop2:

        bge x29, x6, increment
        add x15, x7, x29  # temp = i + j
        sw x15, 0(x10)   # D[4*j] = i + j 
        addi x10, x10, 16 # incrementing the base address d 
        addi x29, x29, 1  # j++
        beq x0, x0, loop2



   increment:
        addi x7, x7, 1 # i++
        beq x0,x0, loop1

Exit:

end:

    j end
