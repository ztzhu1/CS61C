.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    ble a2, x0, exception_zero_len
    ble a3, x0, exception_zero_stride
    ble a4, x0, exception_zero_stride
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, 0 # t0 -> i
    li t1, 0 # t1 -> sum

loop_start:
    mul t2, t0, a3
    slli t2, t2, 2 # t2 = t2 * 4
    add t2, a0, t2 # &arr0[i * stride]
    lw t2, 0(t2) # arr0[i * stride]

    mul t3, t0, a4
    slli t3, t3, 2 # t3 = t3 * 4
    add t3, a1, t3 # &arr1[i * stride]
    lw t3, 0(t3) # arr1[i * stride]

    mul t2, t2, t3
    add t1, t1, t2

    addi t0, t0, 1
    bge t0, a2, loop_end
    j loop_start

loop_end:
    # Epilogue
    mv a0, t1

    lw ra, 0(sp)
    addi sp, sp, 4

    jr ra

exception_zero_len:
    li a0, 36
    j exit

exception_zero_stride:
    li a0, 37
    j exit