
.section .text
.globl	interruptSetUp
interruptSetUp:
	
    	

	// clear bit 1 in the event detect register
	ldr		r0, =0x20003000			// System Timer Control and Status
	mov		r1, #0x2			// bit 1
	str		r1, [r0]

//***CHANGED
	// enable GPIO IRQ lines on Interrupt Controller
	ldr		r0, =0x2000B210			// Enable IRQs 1
	mov		r1, #0x2			// bit 1 set (IRQs 1 WHICH IS SYSTEM TIMER COMPARE REGISTER 1)
	str		r1, [r0]
//***ADDED
beforeTimer:	// set the timer
	ldr		r0, =0x20003004			// offset for CLO
	ldr		r1, [r0]				// get the clock time?
	ldr		r2, =30000000			// 30 seconds
	add		r1, r2					// time + 30 seconds
	ldr		r0, =0x20003010			// offset for C1
	str		r1, [r0]				// put the time into C1
breaksetTimer:
	// Enable IRQ
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0

    	mov		pc, lr
hang:
	b		hang


.globl InstallIntTable
InstallIntTable:

	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	bx		lr	

irq:
	push	{r0-r12, lr}


checkInt:
	// test if System Timer C1 caused the interrupt in CS
	ldr		r0, =0x20003000		// System Timer Control and Status
	ldr		r1, [r0]
	tst		r1, #0x2			// bit 1
	beq		irqEnd

	// CHANGE THIS CODE TO DRAW THE VALUE PACK
	// PRINT RIGHT AWAY IF NO PAUSE
	// else if there is pause, keep looping until 
/*
	ldr	r2, =endGame
	ldr	r0, [r2]
	cmp	r0, #5		// if not pause, draw value pack now
	bne	drawNow

// wait until no longer on pause
whilePause:
	ldr	r0, [r2]	// keep checking endGame for pause
	cmp	r0, #5
	beq	whilePause	// wait until no longer on pause

	ldr	r0, =0x20003004	//CLO
	ldr	r1, [r0]	//read CLO
	ldr	r2, =TimeElapsed
	ldr	r2, [r2]	// r2 is time elapsed since the beginning
	ldr	r3, =1000000	// total time to wait
	sub	r2, r3, r2	// total - elapsed time
	add	r1, r2		// get the remaining time
intWait:
	ldr	r2, [r0]	//read CLO
	cmp	r1, r2
	blt	intWait		// wait until remaining time is over


*/
drawNow:
	mov	r0, #1		// drawing a value pack
	bl	getRand
	bl	drawValuePack
//***CHANGED
	// clear bit 1 in the event detect register
	ldr		r0, =0x20003000		// System Timer Control and Status
	mov		r1, #0x2			// bit 1
	str		r1, [r0]
	
irqEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4

.section .data

IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word irq
fiq_handler:		.word hang

