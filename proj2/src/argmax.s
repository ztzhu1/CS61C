.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi, sp, sp, -4
    sw ra, 0(sp)

    ## if n < 1
    li t0, 1
    blt a1, t0, quit
    ## if n == 1
    addi t0, a1, -1
    beqz t0, return_0
    ## else
    li t1, 1 # i
    mv t0, a0 # &arr[0]
    addi t2, t0, 4 # &arr[1]
    lw t0, 0(t0) # arr[0] (temp max)
    li a0, 0

loop_start:
    lw t3, 0(t2) # arr[i]
    bge t0, t3, loop_continue 
    mv a0, t1
    mv t0, t3
loop_continue:
    addi t1, t1, 1 # i = i + 1
    addi t2, t2, 4 # &arr[i]
    bge t1, a1, loop_end # i >= n
    j loop_start
return_0:
    li a0, 0
loop_end:
    # Epilogue
    lw ra, 0(sp)
    addi, sp, sp, 4

    jr ra

quit:
    li a0, 36 # exit code
    li a7, 93 # SYS_EXIT
    ecall