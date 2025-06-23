.globl main
.globl map

.data
arrays: 
    .word 5, 6, 7, 8, 9
    .word 1, 2, 3, 4, 7
    .word 5, 2, 7, 4, 3
    .word 1, 6, 3, 8, 4
    .word 5, 2, 7, 8, 1

start_msg:  .asciiz "Lists before: \n"
end_msg:    .asciiz "Lists after: \n"

.text

main:
    jal create_default_list
    mv s0, a0           # s0 = head of list

    # print "Lists before:"
    li a0, 4
    la a1, start_msg
    ecall

    # print the list
    mv a0, s0
    jal print_list

    # newline
    jal print_newline

    # call map with mystery function
    mv a0, s0
    la a1, mystery
    jal map

    # print "Lists after:"
    li a0, 4
    la a1, end_msg
    ecall

    # print modified list
    mv a0, s0
    jal print_list

    li a0, 10
    ecall


# map(list_head, func_ptr)
# Recursively applies func_ptr to each element of each array in the linked list
map:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw t0, 12(sp)

    beq a0, x0, map_done

    mv s0, a0           # current node
    mv s1, a1           # function pointer
    li t0, 0            # i = 0

map_loop:
    lw t1, 0(s0)        # t1 = node->arr
    lw t2, 4(s0)        # t2 = node->size

    slli t3, t0, 2      # offset = i*4
    add t4, t1, t3      # address of arr[i]
    lw a0, 0(t4)        # a0 = arr[i]
    jalr s1             # call mystery(a0)
    sw a0, 0(t4)        # arr[i] = result

    addi t0, t0, 1
    bne t0, t2, map_loop

    lw a0, 8(s0)        # move to next node
    mv a1, s1
    jal map

map_done:
    lw t0, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    jr ra


# prints a newline
print_newline:
    li a1, '\n'
    li a0, 11
    ecall
    jr ra


# mystery(x): return x*x + x
mystery:
    mul t1, a0, a0
    add a0, t1, a0
    jr ra


# create_default_list: builds 5-node linked list from arrays in .data
create_default_list:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    li s0, 0           # head = null
    li s1, 0           # counter i
    li s2, 5           # array size
    la s3, arrays      # address of arrays

list_loop:
    li a0, 12          # size of node struct
    jal malloc
    mv s4, a0          # new node address

    li a0, 20          # 5 ints = 20 bytes
    jal malloc
    sw a0, 0(s4)       # node->arr = malloc

    mv a1, s3
    mv a0, a0          # a0 = malloc'd array ptr
    jal fillArray

    sw s2, 4(s4)       # node->size = 5
    sw s0, 8(s4)       # node->next = previous head
    mv s0, s4          # update head

    addi s1, s1, 1
    addi s3, s3, 20    # next group of 5 ints
    li t6, 5
    bne s1, t6, list_loop

    mv a0, s4          # return head

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra


# fillArray(dest_array, source_array)
fillArray:
    lw t0, 0(a1)
    sw t0, 0(a0)
    lw t0, 4(a1)
    sw t0, 4(a0)
    lw t0, 8(a1)
    sw t0, 8(a0)
    lw t0, 12(a1)
    sw t0, 12(a0)
    lw t0, 16(a1)
    sw t0, 16(a0)
    jr ra


# print_list(node)
print_list:
    bne a0, x0, print_node
    jr ra

print_node:
    mv t0, a0          # save current node ptr
    lw t3, 0(t0)       # arr
    li t1, 0           # index = 0

print_loop:
    slli t2, t1, 2
    add t4, t3, t2
    lw a1, 0(t4)
    li a0, 1
    ecall

    li a1, ' '
    li a0, 11
    ecall

    addi t1, t1, 1
    li t6, 5
    bne t1, t6, print_loop

    li a1, '\n'
    li a0, 11
    ecall

    lw a0, 8(t0)
    j print_list


# malloc syscall wrapper
malloc:
    mv a1, a0
    li a0, 9
    ecall
    ret
   