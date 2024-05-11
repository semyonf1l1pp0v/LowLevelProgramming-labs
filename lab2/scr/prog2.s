	.arch armv8-a
	.data
	.align	1
n:
	.hword	4
m:
	.hword	5
matrix:
	.hword	4, 6, 1, 8, 2
	.hword	1, 2, 3, 4, 5
	.hword	5, 7, 8, 4, 2
	.hword	0, -7, 3, -1, -1
matrixnew:
	.skip	40
maxs:
	.skip	10
mas2:
	.hword	0,1,2,3,4
mas3:
	.hword	0,1,2,3,4

	.text
	.align	2
	.global	_start
	.type	_start, %function 
_start:
	adr x2, n
	mov x0, #0
	ldrsh w0, [x2]			// w0 - chislo strok
	adr x2, m
	mov x1, #0
	ldrsh w1, [x2]			// w1 - chislo stolbcov
	adr x2, matrix			// adres nachala matritsi
	adr x3, maxs			// adres nachala massiva max elementov
	adr x13, mas2			// x13 - massiv nomerov (sort)
	adr x23, mas3			// x23 - massiv nomerov
	mov x4, #0
	lsr x11, x1, #1     		// x11 i x12 - granitsi dereva 
//	lsr x21, x1, #1			// x11 = x21 = 5/2 = 2
	sub x12, x1, #1			// x12 = 5-1 = 4
//	sub x22, x1, #1

L0:
	cmp x4, x1			// schetchik stolbcov
	bge L3				// esli x4 = 5 => obrabotali vse stolbci, idem v heap sort
	mov x5, #0
	lsl x6, x4, #1			// smeschenie 
	ldrsh w7, [x2, x6]		// berem pervii element stolbca
	add x6, x6, x1, lsl #1		// next element stolbca
	add x5, x5, #1
L1:
	cmp x5, x0			// schetchik strok
	bge L2				// esli x5 = 3 => posmotreli vse elementi stolbca
	ldrsh w8, [x2, x6]		// next element stolbca 
	add x6, x6, x1, lsl #1
	add x5, x5, #1			
	cmp w7, w8			// sravnivaem tekuschyi i next element stolbca
	bge L1				// esli tekuschyi bolshe
	mov x7, x8			// esli net to next kladem v x7
	b L1
L2:
	strh w7, [x3, x4, lsl #1]	// sohranili max element stolbca
	add x4, x4, #1
	b L0
L3: 
	cbz x11, L4				// heap sort	x11 = 2->0 - vtoraya stadia
	sub x11, x11, #1
//	sub x21, x21, #1
	b L5
L4:
	cbz x12, M                         	// x3 - adres nachala massiva 	x12 = 4 -> 0 - obrabotali vse elementi - exit
	ldrsh w7, [x3, x11, lsl #1]
	ldrsh w8, [x3, x12, lsl #1]

	ldrsh w17, [x13, x11, lsl #1]
	ldrsh w18, [x13, x12, lsl #1]

	strh w17, [x13, x12, lsl #1]
	strh w18, [x13, x11, lsl #1]
	strh w8, [x3 ,x11, lsl #1]
	strh w7, [x3, x12, lsl #1]

	sub x12, x12, #1
//	sub x22, x22, #1
	cbz x12, M				// x12 = 0 => exit
L5:
	ldrsh w7, [x3, x11, lsl #1]		// proseivaemyi element
	ldrsh w17, [x13, x11, lsl #1]		// ego nomer

	mov x5, x11                         	// index elementa
//	mov x15, x21				// index elementa v massive nomerov
L6:
	mov x4, x5				
//	mov x14, x15

	lsl x5, x5, #1				
//	lsl x15, x15, #1

	add x5, x5, #1				// pervyi potomok
//	add x15, x15, #1

	cmp x5, x12	
	bgt L8					// za predelami massiva (potomkov net)	(x12 = 4, potom 3,2,1,0)

	ldrsh w8, [x3, x5, lsl #1]		// esli ne za predelami - pervyi potomok v w8
	ldrsh w18, [x13, x5, lsl #1]

	beq L7					// vtorogo potomka net
	add x6, x5, #1				// vtoroi potomok              
//	add x16, x15, #1 

	ldrsh w9, [x3, x6, lsl #1]		// vtoroi potomok v w9
	ldrsh w19, [x13, x6, lsl #1]

	cmp w8, w9				// sravnivaem dva potomka
	bge L7
	add x5, x5, #1
//	add x15, x15, #1
	mov x8, x9				// x8 - potomok kotoryi bolshe
	mov w18, w19				// !!!!!!!!!
L7:
	cmp w7, w8				// sravnivaem element s potomkom
	bge L8
	strh w8, [x3, x4, lsl #1]		// w8 > w7 - sohranyaem ego
	strh w18, [x13, x4, lsl #1]
	b L6
		
L8:
	strh w7, [x3, x4, lsl #1]		// w7 > w8 -> sohranyaem ego
	strh w17, [x13, x4, lsl #1]
	b L3

M:
	adr x24, m
	ldrsh w6, [x24]			// w6: m = 5 - chislo stolbcov
	adr x24, n
	ldrsh w7, [x24]			// w7: n = 3 - chislo strok
	adr x8, matrix			// staraya matritsa
	adr x9, matrixnew		// adres nachala novoi matritsi
	mov x0, #-1			// schetchik dlya stolbcov
M1:
	add x0, x0, #1
	cmp x0, x6
	bge exit			// x0 = 5 -> exit
	mov x20, x0
	ldrsh w1, [x23, x20, lsl #1]	// ocherednoi element iz massiva 0,1,2,3,4
	mov x2, #-1			
M2:
	add x2, x2, #1
	mov x22, x2
	ldrsh w5, [x13, x22, lsl #1]	// ocherednoi element iz (2,0,4,1,3)
	cmp x1, x5			// nomera sovpali
	beq M3
	b M2
M3:
	mov x4, #-1			// schetchik strok 
M4:
	add x4, x4, #1
	cmp x4, x7			// x4 = 3 -> idem k next stolbcu
	bge M1				// perestavili vse elementi stolbca
	lsl x24, x4, #1
	mul x15, x6, x24		// x15 = dlina stroki*(0,2,4,6,8)
	add x10, x8, x15		// 
	add x11, x9, x15 		// 
	lsl x25, x0, #1 		
	ldrsh w14, [x25, x10]		// berem element
	lsl x25, x2, #1			// x2 - nomer stolbca v novoi matrice
	strh w14, [x25, x11]		// sohranyaem element
	b M4
exit:
	mov x0, #0
	mov x8, #93
	svc #0
	.size	_start, .-_start
