.text
.globl main


main:
    # assuming f,g,h,i,j in x19-x23
    bne x22, x23, Else     # if (i != j) goto Else
    add x19, x20, x21      # f = g + h
    beq x0, x0, Exit        # unconditional jump


Else:
    sub x19, x20, x21      # f = g - h


Exit:


end:
    j end
