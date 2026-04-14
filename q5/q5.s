.section .data
filename: .asciz "input.txt"
yes:      .asciz "Yes\n"
no:       .asciz "No\n"

.section .bss
buf1: .skip 1
buf2: .skip 1

.section .text
.globl main

main:
    addi sp, sp, -32
    sd   ra, 24(sp)
    sd   s0, 16(sp)
    sd   s1, 8(sp)
    sd   s2, 0(sp)

    # open(filename, O_RDONLY)
    li   a7, 56          # syscall: openat
    li   a0, -100        # AT_FDCWD
    la   a1, filename
    li   a2, 0           # O_RDONLY
    li   a3, 0
    ecall
    mv   s0, a0          # fd

    # lseek(fd, 0, SEEK_END)
    li   a7, 62
    mv   a0, s0
    li   a1, 0
    li   a2, 2
    ecall
    mv   s1, a0          # size

    li   s2, 0           # left = 0
    addi s1, s1, -1      # right = size - 1

loop:
    bge  s2, s1, is_palindrome

    # read left char
    li   a7, 62
    mv   a0, s0
    mv   a1, s2
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, buf1
    li   a2, 1
    ecall

    # read right char
    li   a7, 62
    mv   a0, s0
    mv   a1, s1
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, buf2
    li   a2, 1
    ecall

    # compare
    lb   t1, buf1
    lb   t2, buf2

    bne  t1, t2, not_palindrome

    addi s2, s2, 1
    addi s1, s1, -1
    j    loop

is_palindrome:
    li   a7, 64          # write
    li   a0, 1
    la   a1, yes
    li   a2, 4
    ecall
    j    done

not_palindrome:
    li   a7, 64
    li   a0, 1
    la   a1, no
    li   a2, 3
    ecall

done:
    li   a7, 57          # close
    mv   a0, s0
    ecall

    ld   ra, 24(sp)
    ld   s0, 16(sp)
    ld   s1, 8(sp)
    ld   s2, 0(sp)
    addi sp, sp, 32
    ret
