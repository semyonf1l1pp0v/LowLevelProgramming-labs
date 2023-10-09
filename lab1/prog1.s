	.arch armv8-a
//       res=(a*b*c - c*d*e) / (a/b+c/d)
        .data
        .align  3
res:
        .skip   8
a:
        .long	40
d:
        .long	20
c:
        .short	20
e:
        .short  30
b:
	.short	20

        .text
        .align  2
        .global _start
        .type   _start, %function
_start:
		//res = (abc - cde)/(a/b + c/d)
		//long a,d short b,c,e
        adr     x0, a
        ldr     w1, [x0]
        adr     x0, b
        ldrh    w2, [x0]
        adr     x0, c
        ldrh    w3, [x0]
        adr     x0, d
        ldr     w4, [x0]
        adr     x0, e
        ldrh    w5, [x0]
        mul	w6, w2, w3	// b*c
        umull	x8, w6, w1	// a * (bc)
        mul 	w7, w3, w5	// c*e
        umull 	x7, w7, w4	// d * (ce)
        sub	x8, x8, x7	// abc - cde
        bcs 	_exit1
        cbz	w2, _exit1
        udiv	w9, w1, w2	// a/b
        cbz	w4, _exit1
        udiv	w10, w3, w4	// c/d
        uxtw	x1, w9
        uxtw	x2, w10
        add	x4, x2, x1	// c/d + a/b
        bcs	_exit1
        cbz	x4, _exit1
        udiv	x8, x8, x4	// res
        adr     x0, res
        str     x8, [x0]
_exit:
        mov     x0, #0
        b       END
_exit1:
	mov	x0, #1
	b 	END
END:
        mov     x8, #93
        svc     #0
        .size   _start, .-_start

