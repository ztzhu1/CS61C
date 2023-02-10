.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi, sp, sp, -4
    sw ra, 0(sp)

    ## if n < 1
    li t0, 1
    blt a1, t0, quit
    ## else
    li t1, 0 # i
    mv t0, a0 # &arr[0]
loop_start:
    lw t2, 0(t0)
    bgez t2, loop_continue
    li t2, 0
loop_continue:
    sw t2, 0(t0)

    addi t1, t1, 1 # i = i + 1
    addi t0, t0, 4 # &arr[i]
    bge t1, a1, loop_end # i >= n
    j loop_start

loop_end:
    # Epilogue
    lw ra, 0(sp)
    addi, sp, sp, 4

    jr ra

quit:
    li a0, 36 # exit code
    li a7, 93 # SYS_EXIT
    ecall