.text
.globl main

main:
    
    li x10, 0x400   # base address of array a
    
    addi t0, x0, 5
    sw t0, 0(x10)   # a[0] = 5

    addi t0, x0, 3 
    sw t0, 4(x10)   # a[1] = 3

    addi t0, x0, 8  
    sw t0, 8(x10)   # a[2] = 8

    addi t0, x0, 1
    sw t0, 12(x10)  # a[3] = 1

    addi t0, x0, 9 
    sw t0, 16(x10)  # a[4] = 9
    
    addi x11, x0, 5 # len = 5

    jal x1, bubble

exit: 
    j exit 
bubble:
    beq x10, x0, outerloop_done   # if a == Null
    beq x11, x0, outerloop_done   # if len == 0
    addi t0, x0, 0   # i = 0

    outerloop:
        bge t0, x11, outerloop_done   # i >= len, done
        
        slli t2, t0, 2  # t2 = i * 4
        add t2, t2 , x10   # t2 = &arr[i]
        
        add t1, x0, t0  # j = i
       
    innerloop:
        bge t1, x11, outerloop_next   # j >= len, exit inner loop

       

        slli t3, t1, 2   # t3 = j * 4
        add t3, t3, x10   # t3 = &arr[j]

        lw t4, 0(t2)   # t4 = arr[i]
        lw t5, 0(t3)   # t5 = arr[j]
        
       bge t4, t5, no_swap   # arr[i] >= arr[j], skip swap

       sw t5, 0(t2)    # arr[i] = arr[j]
       sw t4, 0(t3)    # arr[j] = temp


    no_swap:
        addi t1, t1, 1 # j++
        beq x0,x0, innerloop
    outerloop_next:
        addi t0, t0, 1  # i++
        beq x0, x0, outerloop

    outerloop_done:
        jalr x0, 0(x1)  # return to caller 