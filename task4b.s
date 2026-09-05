.text
.globl main


main:

    li x5, 0x100 # a = character 
    li x6, 0x200 # b = short
    li x7, 0x300 # c =  word/int


    lb x10, 0(x5)
    lh x11, 0(x6)
    add x12, x10 , x11 # temp = a[0] + b[0]
    sw x12, 0(x7)   # c[0] = a[0] + b [0]

    lb x10, 1(x5)
    lh x11, 2(x6)
    add x12, x10 , x11 # temp = a[1] + b[1]
    sw x12, 4(x7)  # c[1] = a[1] + b [1]

    lb x10, 2(x5)
    lh x11, 4(x6)
    add x12, x10 , x11 # temp = a[2] + b[2]
    sw x12, 8(x7)   # c[2] = a[2] + b [2]

    lb x10, 3(x5)
    lh x11, 6(x6)
    add x12, x10 , x11  # temp = a[3] + b[3]
    sw x12, 12(x7) # c[3] = a[3] + b [3]


end:

    j end 
    
