.section .text
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    sd      s0, 0(sp)

    mv      s0, a0              # save val

    li      a0, 24
    call    malloc

    sw      s0, 0(a0)           # node->val  = val  (int, 4 bytes)
    sd      zero, 8(a0)         # node->left  = NULL (pointer, 8 bytes)
    sd      zero, 16(a0)        # node->right = NULL (pointer, 8 bytes)

    ld      ra, 8(sp)
    ld      s0, 0(sp)
    addi    sp, sp, 16
    ret

insert:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1, 8(sp)
    sd      s2, 0(sp)

    mv      s0, a0              # s0 = root
    mv      s1, a1              # s1 = val

    beqz    s0, insert_null     # root == NULL -> create node

    lw      s2, 0(s0)           # s2 = root->val
    beq     s1, s2, insert_done # val already exists, do nothing
    blt     s1, s2, insert_left

insert_right:
    ld      a0, 16(s0)          # a0 = root->right
    mv      a1, s1
    call    insert
    sd      a0, 16(s0)          # root->right = result
    j       insert_done

insert_left:
    ld      a0, 8(s0)           # a0 = root->left
    mv      a1, s1
    call    insert
    sd      a0, 8(s0)           # root->left = result
    j       insert_done

insert_null:
    mv      a0, s1
    call    make_node           # returns new node in a0
    j       insert_ret

insert_done:
    mv      a0, s0

insert_ret:
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1, 8(sp)
    ld      s2, 0(sp)
    addi    sp, sp, 32
    ret

get:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1, 8(sp)
    sd      s2, 0(sp)

    mv      s0, a0              # s0 = root
    mv      s1, a1              # s1 = val

    beqz    s0, get_null        # root == NULL -> not found

    lw      s2, 0(s0)           # s2 = root->val
    beq     s1, s2, get_found
    blt     s1, s2, get_left

    # go right
    ld      a0, 16(s0)
    mv      a1, s1
    call    get
    j       get_ret

get_left:
    ld      a0, 8(s0)
    mv      a1, s1
    call    get
    j       get_ret

get_found:
    mv      a0, s0
    j       get_ret

get_null:
    li      a0, 0               # return NULL

get_ret:
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    ld      s1, 8(sp)
    ld      s2, 0(sp)
    addi    sp, sp, 32
    ret


getAtMost:
    addi    sp, sp, -24
    sd      ra, 16(sp)
    sd      s0, 8(sp)
    sd      s1, 0(sp)

    mv      s0, a1          # s0 = root
    mv      s1, a0          # s1 = val

    li      t0, -1          # t0 = best = -1

loop:
    beqz    s0, done        # while (root != NULL)

    lw      t1, 0(s0)       # t1 = root->val

    blt     s1, t1, go_left # if val < root->val → go left

    # root->val <= val → candidate
    mv      t0, t1          # best = root->val

    ld      s0, 16(s0)      # root = root->right
    j       loop

go_left:
    ld      s0, 8(s0)       # root = root->left
    j       loop

done:
    mv      a0, t0          # return best

    ld      ra, 16(sp)
    ld      s0, 8(sp)
    ld      s1, 0(sp)
    addi    sp, sp, 24
    ret
