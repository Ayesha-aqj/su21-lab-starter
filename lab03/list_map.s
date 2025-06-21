.globl map

.text
main:
    jal ra, create_default_list
    add s0, a0, x0              # a0 (and now s0) is the head of node list

    # Print the list
    add a0, s0, x0
    jal ra, print_list
    jal ra, print_newline

    # === Calling `map(head, &square)` ===
    add a0, s0, x0              # Load head pointer
    la a1, square               # MARKER 1: load address of square
    jal ra, map                 # Call map

    # Print the squared list
    add a0, s0, x0
    jal ra, print_list
    jal ra, print_newline

    # === Calling `map(head, &decrement)` ===
    add a0, s0, x0              # Load head pointer
    la a1, decrement            # MARKER 2: load address of decrement
    jal ra, map                 # Call map

    # Print decremented list
    add a0, s0, x0
    jal ra, print_list
    jal ra, print_newline

    addi a0, x0, 10
    ecall                       # Exit program

map:
    # MARKER 3: Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    beq a0, x0, done            # If a0 == NULL, return

    add s0, a0, x0              # s0 = node address
    add s1, a1, x0              # s1 = function pointer

    #  MARKER 4: Load value from node
    lw a0, 0(s0)                # a0 = node->value

    #  MARKER 5: Call function via pointer
    jalr ra, s1, 0              # Call (*f)(a0)

    # MARKER 6: Store result into node
    sw a0, 0(s0)                # node->value = result

    #  MARKER 7: Load next pointer
    lw a0, 4(s0)                # a0 = node->next

    #  MARKER 8: Restore function pointer to a1
    add a1, s1, x0              # a1 = f (function pointer)

    #  MARKER 9: Recursive call
    jal ra, map

done:
    #  MARKER 10: Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra                       # return

# === Definition of the "square" function ===
square:
    mul a0, a0, a0
    jr ra

# === Definition of the "decrement" function ===
decrement:
    addi a0, a0, -1
    jr ra

# === Helper functions ===
# You don't need to understand these, but reading them may be useful

create_default_list:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    li s0, 0            # Pointer to the last node we handled
    li s1, 0            # Number of nodes handled
loop:                   # do...
    li a0, 8
    jal ra, malloc      #     Allocate memory for the next node
    sw s1, 0(a0)        #     node->value = i
    sw s0, 4(a0)        #     node->next = last
    add s0, a0, x0      #     last = node
    addi s1, s1, 1      #     i++
    addi t0, x0, 10
    bne s1, t0, loop    # ... while i != 10
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

print_list:
    bne a0, x0, print_me_and_recurse
    jr ra               # Nothing to print
print_me_and_recurse:
    add t0, a0, x0      # t0 gets current node address
    lw a1, 0(t0)        # a1 gets value in current node
    addi a0, x0, 1      # syscall 1 = print int
    ecall
    addi a1, x0, ' '
    addi a0, x0, 11     # syscall 11 = print char
    ecall
    lw a0, 4(t0)        # a0 = node->next
    jal x0, print_list  # recurse

print_newline:
    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall
    jr ra

malloc:
    addi a1, a0, 0
    addi a0, x0, 9
    ecall
    jr ra
