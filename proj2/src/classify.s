.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0, 5
    bne a0, t0, cmd_arg_num_error

    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw ra, 44(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    li s10, -1
    # malloc
    li a0, 16
    call malloc
    beqz a0, malloc_error
    beq a0, s10, malloc_error
    addi s3, a0, 0 # &row0
    addi s4, a0, 4 # &col0
    addi s5, a0, 8 # &row1
    addi s6, a0, 12 # &col1
    # Read pretrained m0
    addi a0, s1, 4 # &filepath of m0
    lw a0, 0(a0) # filepath of m0
    mv a1, s3
    mv a2, s4
    call read_matrix
    lw s3, 0(s3) # row0
    lw s4, 0(s4) # col0
    mv s7, a0 # &m0[0][0]
    # Read pretrained m1
    addi a0, s1, 8 # &filepath of m1
    lw a0, 0(a0) # filepath of m1
    mv a1, s5
    mv a2, s6
    call read_matrix
    lw s5, 0(s5) # row1
    lw s6, 0(s6) # col1
    mv s8, a0 # &m1[0][0]
    # Read input matrix
    # malloc
    li a0, 8
    call malloc
    beqz a0, malloc_error
    beq a0, s10, malloc_error
    addi a1, a0, 0 # &row_in
    addi a2, a0, 4 # &col_in
    addi a0, s1, 12 # &filepath of m_in
    lw a0, 0(a0) # filepath of m_in

    addi sp, sp, -8
    sw a1, 0(sp)
    sw a2, 4(sp)
    call read_matrix
    lw a1, 0(sp)
    lw a2, 4(sp)
    addi sp, sp, 8

    lw t0, 0(a1) # row_in
    lw t1, 0(a2) # col_in
    mv t2, a0 # &m_in[0][0]
    # Compute h = matmul(m0, input)
    # malloc for h (t3 = &h[0][0])
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)

    mul t3, s3, t1
    slli t3, t3, 2
    mv a0, t3
    call malloc
    beqz a0, malloc_error
    beq a0, s10, malloc_error
    sw a0, 12(sp) # now a0 is &h[0][0]

    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)

    mv a6, a0
    mv a0, s7
    mv a1, s3
    mv a2, s4
    mv a3, t2
    mv a4, t0
    mv a5, t1

    call matmul
    lw t1, 4(sp)
    lw t3, 12(sp)
    # Compute h = relu(h)
    mv a0, t3
    mul a1, s3, t1

    call relu
    lw t1, 4(sp)
    lw t3, 12(sp)
    # Compute o = matmul(m1, h)
    # free m0
    mv a0, s7
    call free
    lw t1, 4(sp)
    # malloc for o.
    mul a0, s5, t1
    slli a0, a0, 2
    call malloc
    lw t1, 4(sp)
    lw t3, 12(sp)
    mv s7, a0 # s7 = &o[0][0]
    # matmul
    mv a0, s8
    mv a1, s5 # row1, row_o
    mv a2, s6
    mv a3, t3
    mv a4, s3 # row_h
    mv a5, t1 # col_h, col_o
    mv a6, s7

    call matmul
    lw t1, 4(sp)
    # Write output matrix o
    addi a0, s1, 16
    lw a0, 0(a0)
    mv a1, s7
    mv a2, s5
    mv a3, t1
    call write_matrix
    lw t1, 4(sp)
    # Compute and return argmax(o)
    mv a0, s7
    mul a1, s5, t1
    call argmax
    mv s0, a0

    # If enabled, print argmax(o) and newline
    addi s2, s2, -1
    beqz s2, End
    mv a0, s0
    call print_int
    la a0, new_line
    call print_str
    mv a0, s0

End:
    addi sp, sp, 16
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw ra, 44(sp)
    addi sp, sp, 48

    jr ra

malloc_error:
    li a0, 26
    call exit

cmd_arg_num_error:
    li a0, 31
    call exit

.data
new_line: .string "\n"