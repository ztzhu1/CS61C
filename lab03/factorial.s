.globl factorial

.data
n: .word 8

.text
main:
    la t0, n # &n
    lw a0, 0(t0) # a0 -> n
    jal ra, factorial
    # now a0 = fact(n)

    addi a1, a0, 0 # a1 = a0
    addi a0, x0, 1 # a0 = 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    addi t0, x0, 1 # result
    ## if n <= 1
    ble a0, t0, RET
    ## else
    addi, sp, sp, -8
    sw a0, 0(sp)
    sw ra, 4(sp)
    
    addi a0, a0, -1
    jal factorial

    addi t0, a0, 0 # t0 = fact(n-1)
    lw a0, 0(sp)
    mul t0, t0, a0
    lw ra, 4(sp)
    addi, sp, sp, 8

RET:
    addi a0, t0, 0
    jr ra