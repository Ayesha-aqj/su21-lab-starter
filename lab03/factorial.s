.globl factorial

.data
n: .word 7

.text
main:
    la t0, n
    lw a0, 0(t0)           # a0 = n
    jal ra, factorial      # call factorial(n)

    addi a1, a0, 0         # move result to a1 (for print_int syscall)
    addi a0, x0, 1         # syscall 1 = print int
    ecall

    addi a1, x0, '\n'
    addi a0, x0, 11        # syscall 11 = print char
    ecall

    addi a0, x0, 10        # syscall 10 = exit
    ecall

factorial:
    # if (a0 == 1) return 1;
    addi t0, x0, 1
    beq a0, t0, base_case

    # recursive case:
    # save return address and a0 on stack
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)

    # a0 = a0 - 1, recursive call
    addi a0, a0, -1
    jal ra, factorial

    # restore a0 and ra
    lw t1, 0(sp)       # original a0
    lw ra, 4(sp)
    addi sp, sp, 8

    # a0 = t1 * a0 (i.e., n * factorial(n - 1))
    mul a0, t1, a0
    jr ra

base_case:
    li a0, 1
    jr ra
