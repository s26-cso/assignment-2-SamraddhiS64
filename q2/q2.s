.section .text
.globl main

main:
    addi    sp, sp, -96
    sd      ra, 88(sp)
    sd      s0, 80(sp)
    sd      s1, 72(sp)
    sd      s2, 64(sp)
    sd      s3, 56(sp)
    sd      s4, 48(sp)
    sd      s5, 40(sp)
    sd      s6, 32(sp)

    mv      s0, a0          # argc
    mv      s1, a1          # argv

    li      t0, 1
    ble     s0, t0, quick_exit

    addi    s0, s0, -1      # n

    # malloc arr
    slli    a0, s0, 2
    call    malloc
    mv      s2, a0

    # malloc result
    slli    a0, s0, 2
    call    malloc
    mv      s3, a0

    # parse input
    li      s5, 0
parse_loop:
    beq     s5, s0, parse_done

    addi    t0, s5, 1
    slli    t0, t0, 3
    add     t0, s1, t0
    ld      a0, 0(t0)       # argv[i+1]

    call    atoi

    slli    t1, s5, 2
    add     t1, s2, t1
    sw      a0, 0(t1)

    addi    s5, s5, 1
    j       parse_loop

parse_done:

    # stack malloc
    slli    a0, s0, 2
    call    malloc
    mv      s4, a0

    li      s6, 0           # stack size

    addi    s5, s0, -1

algo_loop:
    blt     s5, zero, print

    slli    t0, s5, 2
    add     t0, s2, t0
    lw      t1, 0(t0)

while:
    beq     s6, zero, empty

    addi    t2, s6, -1
    slli    t2, t2, 2
    add     t2, s4, t2
    lw      t3, 0(t2)

    slli    t4, t3, 2
    add     t4, s2, t4
    lw      t5, 0(t4)

    bgt     t5, t1, greater
    addi    s6, s6, -1
    j       while

empty:
    li      t6, -1
    j       store

greater:
    mv      t6, t3

store:
    slli    t0, s5, 2
    add     t0, s3, t0
    sw      t6, 0(t0)

    slli    t0, s6, 2
    add     t0, s4, t0
    sw      s5, 0(t0)
    addi    s6, s6, 1

    addi    s5, s5, -1
    j       algo_loop

print:
    li      s5, 0

print_loop:
    beq     s5, s0, done

    slli    t0, s5, 2
    add     t0, s3, t0
    lw      a1, 0(t0)

    beq     s5, zero, first_elem
    la      a0, fmt_rest
    j       do_print

first_elem:
    la      a0, fmt_first

do_print:
    call    printf

    addi    s5, s5, 1
    j       print_loop

done:
    la      a0, nl
    call    printf

    li      a0, 0
    j       exit

quick_exit:
    la      a0, nl
    call    printf
    li      a0, 0

exit:
    ld      ra, 88(sp)
    ld      s0, 80(sp)
    ld      s1, 72(sp)
    ld      s2, 64(sp)
    ld      s3, 56(sp)
    ld      s4, 48(sp)
    ld      s5, 40(sp)
    ld      s6, 32(sp)
    addi    sp, sp, 96
    ret

.section .rodata
fmt_first: .asciz "%d"
fmt_rest:  .asciz " %d"
nl:  .asciz "\n"
