.globl simple_fn naive_pow inc_arr

.data
failure_message: .asciiz "Test failed for some reason.\n"
success_message: .asciiz "Sanity checks passed! Make sure there are no CC violations.\n"
array:
    .word 1 2 3 4 5
exp_inc_array_result:
    .word 2 3 4 5 6

.text
main:
    li s0, 2623
    li s1, 2910
    li s11, 134

    jal simple_fn
    li t0, 1
    bne a0, t0, failure

    li a0, 2
    li a1, 7
    jal naive_pow
    li t0, 128
    bne a0, t0, failure

    la a0, array
    li a1, 5
    jal inc_arr
    jal check_arr

    li t0, 2623
    li t1, 2910
    li t2, 134
    bne s0, t0, failure
    bne s1, t1, failure
    bne s11, t2, failure

    li a0, 4
    la a1, success_message
    ecall

    li a0, 10
    ecall

# Just a simple function. Returns 1.
simple_fn:
    li a0, 1
    ret

# Computes a0 to the power of a1.
naive_pow:
    # BEGIN PROLOGUE
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    # END PROLOGUE

    li s0, 1
naive_pow_loop:
    beq a1, zero, naive_pow_end
    mul s0, s0, a0
    addi a1, a1, -1
    j naive_pow_loop
naive_pow_end:
    mv a0, s0

    # BEGIN EPILOGUE
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    # END EPILOGUE
    ret

# Increments the elements of an array in-place.
inc_arr:
    # BEGIN PROLOGUE
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw t0, 12(sp)
    # END PROLOGUE

    mv s0, a0
    mv s1, a1
    li t0, 0
inc_arr_loop:
    beq t0, s1, inc_arr_end
    slli t1, t0, 2
    add a0, s0, t1

    # Save t0 before calling helper
    addi sp, sp, -4
    sw t0, 0(sp)

    jal helper_fn

    # Restore t0
    lw t0, 0(sp)
    addi sp, sp, 4

    addi t0, t0, 1
    j inc_arr_loop
inc_arr_end:
    # BEGIN EPILOGUE
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw t0, 12(sp)
    addi sp, sp, 16
    # END EPILOGUE
    ret

# Adds 1 to value at address in a0.
helper_fn:
    # BEGIN PROLOGUE
    addi sp, sp, -4
    sw s0, 0(sp)
    # END PROLOGUE

    lw t1, 0(a0)
    addi s0, t1, 1
    sw s0, 0(a0)

    # BEGIN EPILOGUE
    lw s0, 0(sp)
    addi sp, sp, 4
    # END EPILOGUE
    ret



check_arr:
    la t0, exp_inc_array_result
    la t1, array
    addi t2, t1, 20
check_arr_loop:
    beq t1, t2, check_arr_end
    lw t3, 0(t0)
    lw t4, 0(t1)
    bne t3, t4, failure
    addi t0, t0, 4
    addi t1, t1, 4
    j check_arr_loop
check_arr_end:
    ret

failure:
    li a0, 4
    la a1, failure_message
    ecall
    li a0, 10
    ecall
