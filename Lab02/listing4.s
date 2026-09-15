.text
.globl main


main:
    # assuming i in x22, k in x24, base address of save in x25
Loop:
    slli x10, x22, 2      # x10 = i * 4
    add  x10, x10, x25    # x10 = address of save[i]
    lw   x9, 0(x10)       # x9 = save[i]
    bne  x9, x24, Exit    # if save[i] != k, exit
    addi x22, x22, 1      # i = i + 1
    beq  x0, x0, Loop     # jump back to Loop
Exit:


end:
    j end
