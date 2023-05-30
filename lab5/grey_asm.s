    .arch armv8-a
    .data

    .text
    .align 2
    .global grey_asm
    .type grey_asm, %function
    				//x0 - img, x1 - new_img, x2 - img_size, x3 - channel
grey_asm:
    				//x5 i
    mov x5, #0
1:
    				//w6 r w7 g w8 b
    ldrb    w6, [x0, x5]
    add x5, x5, #1
    ldrb    w7, [x0, x5]
    add x5, x5, #1
    ldrb    w8, [x0, x5]
    sub x5, x5, #2

    				//w9 max
    cmp w6, w7
    ble 2f
    cmp w6, w8
    ble 2f
    mov w9, w6
    b   4f
2:
    cmp w7, w8
    ble 3f
    mov w9, w7
    b   4f
3:
    mov w9, w8
4:
				//Saving
    strb w9, [x1, x5]
    add x5, x5, #1
    strb w9, [x1, x5]
    add x5, x5, #1
    strb w9, [x1, x5]
    sub x5, x5, #2
5:
				//Cycle condition
    add x5, x5, x3
    cmp x5, x2
    ble 1b
    mov x0, x1
    ret
    .size grey_asm, .-grey_asm

