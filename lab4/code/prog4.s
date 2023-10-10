	.arch armv8-a
	.data
mes1:
	.string "Enter x: "
mes2:
	.string "%lf"
mes3:
	.string "Math library atan(%.17g)=%.17g\n"
mes4:
	.string "Enter accuracy: "
mes5:
	.string "My implementation atan(%.17g)=%.17g\n"
invalid_Arg:
	.string "Absolute value of argument x must be less or equal 1, otherwise series diverges\n"
invalid_Acc:
	.string "Accuracy must be bigger than 0 and less than 1\n"
mode:
	.string "w"
series:
	.string "Series term #%d = %.17g\n"
usage:
	.string "Usage: %s file\n"	// error invalid parameters
	.text
	.align 2

	.global main
	.type	main, %function
	.equ	x, 16			// form constants for stack
	.equ	y, 24
	.equ	accuracy, 32		// progname, filename, filestruct - adresa (1,2 - adres stroki, 3 - adres strukturi)
	.equ	progname, 40		// argv0 (dlya vivoda soobchenia o nepravilnov ispolzovanii programmy)
	.equ	filename, 48		// dlya obraschenia k failu i ego korrektnogo otkrytia (pervyi parametr)
	.equ	filestruct, 56		// ukazatel na strukturu filestruct (file*, ego vozvrashyaet fopen)
	.equ	a, 64			// dlya sohraneniya registrov v algoritme arctg
	.equ	b, 72
	.equ	c, 80	
	.equ	d, 88
	.equ	e, 96
main:
	stp	x29, x30, [sp, #-104]!	
	mov	x29, sp				// formiruem novyi kadr steka (frame pointer) 
	cmp	w0, #2				// (imya programmi + imya faila - 2 parametra dolzno bit peredano)
	bne	fileerror			// esli ne 2 to oshibka, esli 2 to go dalshe

						// formiruem parametri dlya otkritia faila
	ldr	x0, [x1]
	str	x0, [x29, progname] 		// sohranyaem v stek imya nashei programmi 
	ldr	x0, [x1, #8]			// so smescheniem 8 next parametr - imya faila. argv - massiv, argv0 - imya programmi, argv1 - imya faila 
	str	x0, [x29, filename] 

	adr	x1, mode			// rezhim otkrytia - "w" (write - zapis)
	bl	fopen
	cbnz	x0, 1f				// fopen vernet ukazatel na strukturu faila. vse horosho - go na metku 1 
	ldr	x0, [x29, filename]		// v x0 peredali imya faila  
	bl	perror				// vizvali perror (file_name: error) (ex. 123.txt: no such file or directory)
	b	error				

1:
	str	x0, [x29, filestruct]		// sohranyaem ukazatel na potok svyazannii s failom
	adr	x0, mes1
	bl	printf
	adr	x0, mes2
	add	x1, x29, x
	bl	scanf
	ldr	d0, [x29, x]
	bl	atan
	str 	d0, [x29,y]
	adr	x0, mes3
	ldr	d0, [x29, x]
	ldr 	d1, [x29, y]
	bl	printf

	ldr	d0, [x29, x]		// if argument x > 1 - exit with error 
	fabs	d1, d0
	fmov	d2, #1.0	
	fcmp	d1, d2
	bgt	inv_Arg

	adr	x0, mes4
	bl	printf
	adr	x0, mes2
	add	x1, x29, accuracy
	bl	scanf
	ldr	d0, [x29, x]
	ldr	d1, [x29, accuracy]
	fmov	d2, #1.0
	fmov	d3, xzr
	fcmp	d1, d2
	bge	inv_Acc
	fcmp	d1, d3
	ble	inv_Acc

myatan:
   	fmov    d13, d1                 // peredali accuracy
   	fmov    d9, #1.0		
   	fmov    d10, #2.0		
   	fmov    d3, d0
   	fmov    d11, d9                 // schetchik (n = 1,2,3,...)
   	fmov    d12, d0			// sum
   	fmul    d14, d0, d0		// x^2
   	mov	x20, #1                 // file schetchik
	
	str	d3, [x29, a]
	str	d4, [x29, b]
	str	d5, [x29, c]
	str	d6, [x29, d]

	ldr	x0, [x29, filestruct]	// save 1-st series term
	adr	x1, series
	mov	x2, x20
	fmov	d0, d3
	bl	fprintf

	ldr	d3, [x29, a]
	ldr	d4, [x29, b]
	ldr	d5, [x29, c]
	ldr	d6, [x29, d]

	mov	x21, #1
0:
	add	x20, x20, #1
   	fmov    d8, d12                 // vnesli summu pred shaga
   	fmul    d15, d11, d10           // 2n
   	fadd    d15, d15, d9            // 2n+1
   	fnmul   d4, d14, d3             // -(x^2)*x = -x^3 (+- x^(2n+1))
   	fdiv    d3, d4, d15             // +- x^(2n+1) / 2n+1
   	fadd    d12, d12, d3            // x-x^3/3+ ... = new sum
   	fmul    d3, d3, d15             // izbavilis' ot znamenatelya (shtobi dalshe vozvodit' v stepen')
   	fadd    d11, d11, d9            // n++
	cmp	x21, #1
	bne	plus
minus:
	fneg	d16, d12
	mov	x21, #0
	b	obr
plus:
	fmov	d16, d12
	mov	x21, #1		
obr:
	str	d3, [x29, a]		// save in stack
	str	d4, [x29, b]
	str	d5, [x29, c]
	str	d6, [x29, d]
	str	d16, [x29, e]
	
 	ldr	x0, [x29, filestruct]	// write series term and its number to file
	adr     x1, series
 	mov     x2, x20
   	fmov    d0, d16
   	bl      fprintf			

	ldr	d3, [x29, a]		// load from stack
	ldr	d4, [x29, a]
	ldr	d5, [x29, b]
	ldr	d6, [x29, c]
	ldr	d16, [x29, e]

//	add	x20, x20, #1		// schetchik++
//	fneg	d16, d16
   	fsub    d5, d12, d8             // new sum - old sum
   	fabs    d6, d5                  // abs(new sum - old sum)
   	fcmp    d6, d13                 // cmp with accuracy
   	bge     0b
   	fmov    d0, d12

   	str 	d0, [x29, y]		// save sum
   	adr	x0, mes5
   	ldr	d0, [x29, x]
   	ldr 	d1, [x29, y]
   	bl  	printf
   	b	exit
error:
	mov	w0, #1
   	ldp	x29, x30, [sp], #104
	ret
exit:
	mov	w0, #0
   	ldp	x29, x30, [sp], #104
	ret
inv_Arg:
	adr	x0, invalid_Arg		// invalid argument messasge
	bl	printf
	b	error
inv_Acc:
	adr	x0, invalid_Acc		// invalid accuracy messsage 
	bl	printf
	b	error
fileerror:				// file error (must be 2 parameters)
	ldr	x2, [x1]		// adres x1 - imya programmi 
	adr	x0, stderr		// standartnyi potok oshibok, snachala v x0 adres
	ldr	x0, [x0]		// potom v x0 znachenie po etomu adresu
	adr	x1, usage		// formatnaya stroka. vse 3 parametra - ukazateli
	bl	fprintf
	b	error
	.size main, .-main

