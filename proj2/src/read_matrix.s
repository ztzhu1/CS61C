.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

    mv s0, a0 # filename
    mv s1, a1
    mv s2, a2

    # fopen
    mv a0, s0
    li a1, 3
    call fopen
    beqz a0, fopen_error
    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0 # fd
    # fread
    # row
    mv a1, s1
    li a2, 4
    call fread
    li t0, -1
    beq a0, t0, fread_error
    lw s1, 0(s1)
    # col
    mv a0, s0
    mv a1, s2
    li a2, 4
    call fread
    li t0, -1
    beq a0, t0, fread_error
    lw s2, 0(s2)
    # matrix size
    mul s3, s1, s2
    slli s3, s3, 2 # s3 *= 4
    # malloc
    addi sp, sp, -8
    sw a1, 0(sp)
    sw a2, 4(sp)
    mv a0, s3
    jal malloc
    lw a1, 0(sp)
    lw a2, 4(sp)
    addi sp, sp, 8

    beqz a0, malloc_error
    li t0, -1
    beq a0, t0, malloc_error
    mv s4, a0 # new array
    # read matrix
    mv a0, s0
    mv a1, s4
    mv a2, s3
    call fread
    li t0, -1
    beq a0, t0, fread_error
    # fclose
    mv a0, s0
    call fclose
    li t0, -1
    beq a0, t0, fclose_error
    # return value
    mv a0, s4

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    jr ra

malloc_error:
    li a0, 26
    call exit

fopen_error:
    li a0, 27
    call exit

fclose_error:
    li a0, 28
    call exit

fread_error:
    li a0, 29
    call exit
