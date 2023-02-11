.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    blez a1, dim_error
    blez a2, dim_error
    blez a4, dim_error
    blez a5, dim_error
    bne a2, a4, dim_error
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, 0 # t0 -> i
outer_loop_start:
    bge t0, a1, outer_loop_end
    li t1, 0 # t1 -> j
    inner_loop_start:
        bge t1, a5, inner_loop_end
        li t2, 0 # t2 -> sum
        li t3, 0 # t3 -> k
        For:
            bge t3, a2, End

            mul t4, t0, a2
            add t4, t4, t3 # i * col + k
            slli t4, t4, 2 # t4 *= 4
            add t4, a0, t4 # &m0[i][k]
            lw t4, 0(t4) # m0[i][k]

            mul t5, t3, a5
            add t5, t5, t1 # k * col + j
            slli t5, t5, 2 # t5 *= 4
            add t5, a3, t5 # &m1[k][j]
            lw t5, 0(t5) # m1[k][j]

            mul t4, t4, t5
            add t2, t2, t4

            addi t3, t3, 1
            j For
        End:
        mul t3, t0, a5 # now t3 is another variable
        add t3, t3, t1 # i * col + j
        slli t3, t3, 2 # t3 *= 4
        add t3, a6, t3 # &d[i][j]
        sw t2, 0(t3) # d[i][j] = sum

        addi t1, t1, 1
        j inner_loop_start
    inner_loop_end:
    addi t0, t0, 1
    j outer_loop_start
outer_loop_end:
    # Epilogue
    sw ra, 0(sp)
    addi sp, sp, 4

    jr ra

dim_error:
    li a0, 38
    j exit
