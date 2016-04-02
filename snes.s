.globl selectMenu
// r0 = 0 select from Menu
// r0 = 1, select from pause Menu
selectMenu:

	push	{r4-r9,lr}	// push register values on stack
	mov	r9, r0		// save value of r0
	bl	Read_SNES	// read from SNES, r0 contains buttons stored
	ldr	r4, =0xFFFFFFFF
	eor	r0, r4
	mov	r3, r0

	mov	r0, #0		// default return value if no buttons pressed
	mov	r1, #1		// r1 = 1

	lsl	r2, r1, #12	// try up arrow
	ands	r2, r3		// if up arrow
	movne	r0, #11		// return up
	bne	endSelect
	
	mov	r1, #1		// r1 = 1
	lsl	r2, r1, #11	// try down arrow
	ands	r2, r3		// if down arrow
	movne	r0, #10		// return down
	bne	endSelect

	mov	r1, #1		// r1 = 1
	lsl	r2, r1, #8	// try A
	ands	r2, r3		// if A
	movne	r0, #7		// return A
	bne	endSelect

	cmp	r9, #0
	beq	endSelect
	
	lsl	r2, r1, #13	// try start button
	ands	r2, r3		// if start button
	movne	r0, #12		// return start


endSelect:
	// r0 is our return value
	pop	{r4-r9,lr}
	mov	pc,lr

.globl	getDirection

getDirection:
	
	push	{r4-r9,lr}	// push register values on stack
	bl	Read_SNES	// read from SNES, r0 contains buttons stored
	ldr	r4, =0xFFFFFFFF
	eor	r0, r4
	mov	r3, r0

	mov	r0, #0		// default return value if no buttons pressed

	mov	r1, #1		// r1 = 1

	lsl	r2, r1, #13	// try start button
	ands	r2, r3		// if start button
	movne	r0, #12		// return start
	bne	endDirec

	lsl	r2, r1, #12	// try up arrow
	ands	r2, r3		// if up arrow
	movne	r0, #11		// return up
	bne	endDirec
	
	mov	r1, #1		// r1 = 1
	lsl	r2, r1, #11	// try down arrow
	ands	r2, r3		// if down arrow
	movne	r0, #10		// return down
	bne	endDirec

	mov	r1, #1		// r1 = 1
	lsl	r2, r1, #10	// try left
	ands	r2, r3		// if left
	movne	r0, #9		// return left
	bne	endDirec
	
	mov	r1, #1		// r1 = 1
	lsl	r2, r1, #9	// try right
	ands	r2, r3		// if right
	movne	r0, #8		// return right
endDirec:
	// r0 is our return value
	pop	{r4-r9,lr}
	mov	pc,lr
	


.globl init_GPIO
init_GPIO:
	//set	pin11 to output
	ldr	r0, =0x20200004 	// address for GPFSEL1
	ldr	r1, [r0]		// copy GPFSEL1 into r1
	mov	r2, #7		 	// (b0111)
	lsl	r2, #3 			// index of 1 bit for pin 11
	// r2 = 0 111 000
	bic	r1, r2 		// clear pin11 bits
	mov	r3 , #1 	// output function code
	lsl	r3, #3 		// r3 = 0 001 000
	orr	r1, r3 		// set pin11 function in r1
	str	r1, [r0] 	// write back to GPFSEL1

	//set	pin 10 to input
	ldr	r0, =0x20200004 	// address for GPFSEL1
	ldr	r1, [r0]		// copy GPFSEL1 into r1
	mov	r2, #7 			// (b0111)
					// r2 = 0 000 111
	bic	r1, r2 			// clear pin10 bits

	str	r1, [r0] 		// write back to GPFSEL1

	//set	pin 9 to output
	ldr	r0, =0x20200000 // address for GPFSEL0
	ldr	r1, [r0]	// copy GPFSEL0 into r1
	mov	r2, #7 		// (b0111)
	lsl	r2, #27		// index of 1 bit for pin 9
				
	bic	r1, r2 		// clear pin9 bits
	mov	r3 , #1 	// output function code
	lsl	r3, #27 	// left shift r3 by pin# * 3
	orr	r1, r3 		// set pin11 function in r1
	str	r1, [r0] 	// write back to GPFSEL0
	
	bx	lr		// return to calling code

//subroutine for writing to latch
.globl Write_Latch
Write_Latch:
	//r1= value to write to latch
	mov	r0, #9		// Pin#9
	ldr	r2, =0x20200000 // Base Gpio
	mov	r3, #1		// r3 = 1
	lsl	r3, r0		// shift r3 by pin#
	teq	r1, #0		// if r1 == 0
	streq	r3, [r2, #40]	//clear latch
	strne	r3, [r2, #28]	//set latch

	bx	lr		// return to calling code

//subroutine for writing to clock
.globl Write_Clock
Write_Clock:
	mov	r0, #11		// Pin #11
	ldr	r2, =0x20200000 //Base Gpio
	mov	r3, #1		// r3 = 1
	lsl	r3, r0		// shift r3 by pin#
	teq	r1, #0		// if r1 == 0
	streq	r3, [r2, #40]	//clear clock
	strne	r3, [r2, #28]	//set clock
	
	bx 	lr
//subroutine for reading from data
.globl Read_Data
Read_Data:
	mov	r0, #10		// Pin #10
	ldr	r2, =0x20200000 //Base Gpio
	ldr	r1, [r2, #52] //GPLEV0
	mov	r3, #1		// r3 = 1
	lsl	r3, r0		// shift r3 by pin#
	and	r1, r3		// and r1 with r3
	teq	r1, #0		// if r1 = 0
	moveq	r0, #0		//return 0
	movne	r0, #1		//else, return 1

	bx	lr		// return to calling code




//subroutine for waiting
.globl Wait
Wait:
	//r3 is time to wait
	ldr	r0, =0x20003004	//CLO
	ldr	r1, [r0]	//read CLO
	add	r1, r3		//add r3 to r1
waitLoop:
	ldr	r2, [r0]	// read CLO in r2
	cmp	r1, r2		//stop when CLO = r1
	bhi	waitLoop	// loop back
	
	bx	lr		// return to calling code

//subroutine to read from SNES
.globl Read_SNES
Read_SNES:
	push	{r5, r6, r7, r8, lr}
	mov	r5, #0		// set r5=buttons to 0
	
	mov	r1, #1
	bl	Write_Clock	// set clock to #1

	mov	r1, #1
	bl	Write_Latch	// set latch to #1
	
	mov	r3, #12
	bl	Wait		// wait 12us
	
	mov	r1, #0
	bl	Write_Latch	// set latch to #0

	mov	r6, #0		//set r6=i=0
	mov	r7, #16		//set r7=max=16
pulseLoop:
	
	mov	r3, #6
	bl	Wait		// wait 6us
	
	mov	r1, #0
	bl	Write_Clock	// set clock to #0

	mov	r3, #6
	bl	Wait		// wait 6us
	
	bl	Read_Data	// read GPIO line data in r0
	sub	r8, r7, r6	// sub max by current i to get location of bit for buttons
	lsl	r0, r8		// left shift r0 by r8
	orr	r5, r0		// update buttons register

	mov	r1, #1
	bl 	Write_Clock	// set clock to #1
	
	add	r6, #1		//increment i
	cmp	r6, r7		//check if i is max
	blt	pulseLoop	// if not loop back
	
	mov	r0, r5		//puts r5 into r0 to be returned
	pop	{r5, r6, r7, r8, lr}	// pop off register values from stack

	bx	lr		// return to calliing code
	


.section .data  





