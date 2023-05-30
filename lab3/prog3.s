

.arch armv8-a

        .data
mes1:
        .string  "Enter the lines (end input by Ctrl+D buttons):\n"
        .equ    mes1len, .-mes1
mes2:
        .string  "File exists. Rewrite(Y/N)?\n"
        .equ    mes2len, .-mes2
newstr:
	.skip   1024
buf:
        .skip   10
        .equ    buflen, .-buf

        .text
        .align 2
        .global _start
        .type   _start, %function
_start:
        mov     x21, #0         // file descriptor

        bl      getenv
        cmp     x0, #-7         // bad env variables
        beq     write_error
        mov     x24, x1         // save x1 (output filename)

// Creating or overwriting file
        mov     x1, x24         // restore x1
        mov     x0, #-100
        mov     x2, #0xc1
        mov     x3, #0600
        mov     x8, #56
        svc     #0

        cmp     x0, #-17        // if this file doens't exists go to 3f
        bne     3f

        mov     x0, #1		// rewriting message
        adr     x1, mes2
        mov     x2, mes2len
        mov     x8, #64
        svc     #0

        mov     x0, #0		// enter yes/no
        adr     x1, buf
        mov     x2, #3
        mov     x8, #63
        svc     #0

        cmp     x0, #2
        beq     1f
        mov     x0, #-17
        b       write_error
1:
        adr     x1, buf
        ldrb    w0, [x1]
        cmp     w0, 'Y'
        beq     2f
        cmp     w0, 'y'
        beq     2f
        mov     x0, #-17
        b       write_error
2:                              // rewrite
        mov     x0, #-100
        mov     x1, x24         // filename
        mov     x2, #0x201
        mov     x3, #0600
        mov     x8, #56
        svc     #0
3:
        cmp     x0, #0
        blt     write_error
        mov     x21, x0         // descriptor saved to x21

        mov     x0, #1		// enter text
        adr     x1, mes1
        mov     x2, mes1len
        mov     x8, #64
        svc     #0

//Main cycle
	mov	x6, #0		// count of symbols to move
begin:
        mov     x0, #0		// reading 1 buf
        adr     x1, buf
	add 	x1, x1, x6
        mov     x2, buflen
	sub 	x2, x2, x6
        mov     x8, #63
        svc     #0

	cmp     x0, #0		// if 0 symbols read
        ble     exit1           // last line

        adr     x1, buf		// add '/0' in the end of buf
        add     x0, x0, x6
	strb	wzr, [x1, x0] 	// add zero v konec bufera
	adr 	x3, newstr
        mov 	x4, x3
0:
	ldrb	w0, [x1], #1
	cbz	w0, 5f
	cmp 	w0, ' '  	// propuskaem probel
	beq 	0b
	cmp 	w0, '\t' 	// propuskaem tab
	beq 	0b
	cmp 	w0, '\n' 	// propuskaem perenos stroki
	bne 	1f
	strb	w0, [x3], #1 
	b 	0b
1:
	cmp  	x4, x3
	beq 	2f
2:
	sub 	x2, x1, #1
3:
	ldrb	w0, [x1], #1
	cmp 	w0, '\n' 	// propuskaem perenos
	beq 	7f
	cmp 	w0, '\t' 	// propuskaem tab
	beq 	7f
	cmp 	w0, ' ' 	// propuskaem probel
	beq 	7f
	cbnz	w0, 3b
	adr 	x8, buf
	sub	x6, x1, x2 
	sub 	x6, x6, #1
	sub 	x5, x1 ,#1
6:      
	mov 	x9, x2 		// nachalo
	sub 	x10,x5,x2 	// size slova
	mov 	x11, #0 	// schetchik
        b 	FIRST
20:	
	cbnz  	x6, 12f
	cmp 	x11, x10        // sravnili razmer slova s kolichestvom cifr v nem
	beq	9f              // esli ravno to na metku 9
12:	
	ldrb 	w0, [x2], #1 
	strb 	w0, [x8], #1  	// gruzim v nachalo bufera slovo kotoroe na konce bufera
	cmp 	x5,  x2 	// cicl
	bgt 	12b
	b 	9f
FIRST:
	ldrb	w25, [x9], #1 	// FIRST- proverka simvola chislo ili net
	cmp 	w25, '0'
	beq 	CNT
	cmp  	w25, '1'
  	beq 	CNT
	cmp 	w25, '2'
	beq 	CNT
	cmp 	w25 ,'3'
	beq 	CNT
	cmp     w25 , '4'
	beq 	CNT
	cmp 	w25, '5'
	beq 	CNT
	cmp 	w25, '6'
	beq 	CNT
	cmp 	w25, '7'
	beq 	CNT 
	cmp 	w25, '8'
	beq 	CNT
	cmp 	w25, '9'
	beq 	CNT
	b 	20b
CNT:
	add x11, x11 , #1       // nashli ocherednuyu cifru v slove
	b FIRST	
7:
	sub 	x5, x1, #1
	mov 	w7, w0
8:
	mov 	x6, #0
 	b       FIRST3
21:
	cmp 	x10, x11
	beq	0b    
15: 
	ldrb	w0, [x2], #1
	cmp	w0, '\n'
	beq 	10f
	strb	w0, [x3], #1
11:
	cmp 	x5, x2
	bge	15b
	b	0b
10:
	b  	11b
FIRST3:
	mov 	x9, x2 		// nachalo
	sub 	x10,x5,x2 	// size
 	mov 	x11, #0 	// cnt	
FIRST2:
	sub 	x28, x5, #1 	// PROVERKA SIMVOLA NA CHISLO ILI NET
	ldrb 	w25, [x9],#1
	cmp 	w25, '0'
	beq 	CUR
	cmp 	w25, '1'
	beq 	CUR
	cmp 	w25, '2'
	beq 	CUR
	cmp 	w25, '3'
	beq 	CUR
	cmp 	w25, '4'
	beq 	CUR
	cmp 	w25, '5'
	beq 	CUR
	cmp 	w25, '6'
	beq 	CUR
	cmp 	w25, '7'
	beq 	CUR
	cmp 	w25, '8'
	beq 	CUR
	cmp 	w25, '9'
	beq 	CUR
	b 	21b
CUR:
    	add x11,x11,#1
	b FIRST2
NEWLINE:
	strb	w7, [x3], #1
	b 	9f	
5:
	cmp 	x4, x3
	beq 	9f
	cmp 	w7, '\n'
	beq 	NEWLINE
SAVE:
	strb 	w7, [x3], #1
9:	
	sub 	x2, x3, x4
	mov   	x0, x21
	adr	x1, newstr
	mov 	x8, #64
	svc 	#0

	cmp     x0, #0
        blt     write_error
	b	begin
write_error:
        bl      writeerr
        cmp     x21, #0
        bne     exit1
        mov     x0, #1
        b       exit2
exit1:
        mov     x0, x21
        mov     x8, #57
        svc     #0
        mov     x0, #0
exit2:
        mov     x8, #93
        svc     #0

        .size   _start, .-_start


        .type writeerr, %function
        .data
usage:
        .string "Usage error, set enviroment variables: OUTPUT=output\n"
        .equ    usagelen, .-usage
permission:
        .string "Permission denied\n"
        .equ    permissionlen, .-permission
exist:
        .string "File already exists\n"
        .equ    existlen, .-exist
isdir:
        .string "Is a directory\n"
        .equ    isdirlen, .-isdir
unknown:
        .string "Unknown error\n"
        .equ    unklen, .-unknown
invalidargument:
        .string "Invalid argument\n"
        .equ    invalidargumentlen, .-invalidargument

        .text
        .align 2
writeerr:
        cmp x0, #-7
        bne 0f
        adr x1, usage
        mov x2, usagelen
        b   5f
0:
        cmp x0, #-13
        bne 1f
        adr x1, permission
        mov x2, permissionlen
        b   5f
1:
        cmp x0, #-17
        bne 2f
        adr x1, exist
        mov x2, existlen
        b   5f
2:
        cmp x0, #-21
        bne 3f
        adr x1, isdir
        mov x2, isdirlen
        b   5f
3:
        cmp x0, #-22
        bne 4f
        adr x1, invalidargument
        mov x2, invalidargumentlen
        b   5f
4:
        adr x1, unknown
        mov x2, unklen
5:
        mov x0, #2
        mov x8, #64
        svc #0
        ret
        .size   writeerr, .-writeerr
	

         .type   getenv, %function
         .data
var:
         .asciz     "OUTPUT="

         .text
         .align  2
getenv:
         mov     x0, sp
0:
         ldr     x1, [x0], #8
         cmp     x1, #0
         bne     0b
1:
         ldr     x1, [x0], #8
         adr     x2, var
         cmp     x1, #0
         beq     er
         ldrb    w6, [x1], #1
         ldrb    w4, [x2], #1
         cmp     w6, w4
         bne     1b
2:
         ldrb    w6, [x1], #1
         ldrb    w4, [x2], #1
         cmp     w6, w4
         bne     1b
         cmp     w6, '='
         bne     2b
         mov     x0, x1
         b       9f
er:
         mov     x0, #-7
9:
         ret

         .size   getenv, .-getenv
