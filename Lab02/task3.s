.text
.global main

main:

    li x22, 0 # i = 0
    li x23, 0 # sum = 0
    li t0, 0  # temp for loop counter

    li x24, 0x200 # arr with base address of 0x200


loop1:
    bge x22, t0, Exit
    slli t1, x22, 2 # shift left so that we can access the index elements of arr
    add t1, t1, x24 # adds the address to our shift left val
    sw x22, 0(t1)
    addi x22, x22, 1 # increment i
    beq x0, x0, loop1

Exit1:
    li x22, 0  # reset i counter
    li t0, 0  # reset temp for loop counter
    li t1, 0  # reset base address counter


loop2:
    bge x22, t0, Exit2
    slli t1, x22, 2 # shift left so that we can access the index elements of arr
    add t1, t1, x24 # adds the address to our shift left val
    lw x5, 0(t1)  # loading the arr[i] val
    add x23, x23, x5  # sum = sum + arr[i]
    addi x22, x22, 1
    beq x0, x0, loop2

Exit2:

end:

    j end 