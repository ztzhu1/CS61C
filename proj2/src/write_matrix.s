.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp) 
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

    mv s1, a1 # &arr[0][0]
    mv s2, a2 # row
    mv s3, a3 # col
    li s4, -1
    # fopen
    li a1, 4
    call fopen
    beqz a0, fopen_error
    beq a0, s4, fopen_error
    mv s0, a0 # fd
    # fwrite
    # write dim
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    mv a1, sp
    li a2, 2
    li a3, 4
    call fwrite
    addi sp, sp, 8
    blt a0, a3, fwrite_error
    # write matrix
    mv a0, s0
    mv a1, s1
    mul t0, s2, s3
    mv a2, t0
    li a3, 4
    call fwrite
    blt a0, a3, fwrite_error
    # fclose
    mv a0, s0
    call fclose
    beq a0, s4, fclose_error

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp) 
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    jr ra

fopen_error:
    li a0, 27
    call exit

fwrite_error:
    li a0, 30
    call exit

fclose_error:
    li a0, 28
    call exit
