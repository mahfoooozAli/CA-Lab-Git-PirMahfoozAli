.text
.globl main


main:

    li x10, 0x180  # base address of v[]
    li x11, 0      # k = 0

    li t0, 1       
    sw t0, 0(x10)  # v[0] = 1

    li t0, 2
    sw t0, 4(x10)  # v[1] = 2
    jal x1, swap     # calls swap


end:
    j end  # loop
    

swap:

    slli t0, x11, 2  # t0 = k * 4  (byte offset)
    add t0, t0, x10  # t0 =  address of v[k]
    lw t1, 0(t0)   # t1 = v[k]
    lw t2, 4(t0)   # t2 = v[k+1]
    sw t2, 0(t0)   # v[k] = v[k+1]
    sw t1, 4(t0)   # v[k+1] = temp
    jalr x0, 0(x1)  # return to the caller 

