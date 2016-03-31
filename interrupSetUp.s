.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    bl		InstallIntTable			// *** MUST COME FIRST, sets the stack pointer
	
	bl		EnableJTAG

	bl		InitLED					// initialize the LED (pin 16 to output)
	bl		InitSNES				// initialize the SNES controller

	mov		r0, #1
	bl		SetLATLevel				// set the Latch line high, so the B button changes the Data line

// don't need?
	// set the Rising Edge detect bit for GPIO line 10 (on the device)
	ldr		r0, =0x2020004C
	ldr		r1, [r0]
	orr		r1, #0x400				// set bit 10
	str		r1, [r0]
***CHANGED
	// enable GPIO IRQ lines on Interrupt Controller
	ldr		r0, =0x2000B210			// Enable IRQs 1
	mov		r1, #0x1				// bit 1 set (IRQs 1 WHICH IS SYSTEM TIMER COMPARE REGISTER 1)
	str		r1, [r0]
***ADDED
	// set the timer
	ldr		r0, =0x20003004			// offset for CLO
	ldr		r1, [r0]				// get the clock time?
	ldr		r2, =0x‭1C9C380‬			// 30 seconds
	add		r1, r2					// time + 30 seconds
	str		r1, [r0]				// put the time back into CLO

	// Enable IRQ
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0

ledLoop$:
	ldr		r1, =SNESDat
	ldr		r0, [r1]
	bl		SetLEDLevel

	b		ledLoop$
    
hang:
	b		hang

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
***CHANGED
	// test if there is an interrupt pending in IRQ Pending 1
	ldr		r0, =0x2000B200
	ldr		r1, [r0]
	tst		r1, #0x100		// bit 8 
	beq		irqEnd
***CHANGED
	// test that at least one GPIO IRQ line caused the interrupt
	ldr		r0, =0x2000B204		// IRQ Pending 1 register
	ldr		r1, [r0]
	tst		r1, #0x1			// check IRQ 1
	beq		irqEnd
***CHANGED
	// test if System Timer C1 caused the interrupt
	ldr		r0, =0x20003000		// System Timer Control and Status
	ldr		r1, [r0]
	tst		r1, #0x20			// bit 1
	beq		irqEnd

	// CHANGE THIS CODE TO DRAW THE VALUE PACK
	// invert the LSB of SNESDat
	ldr		r0, =SNESDat
	ldr		r1, [r0]
	eor		r1, #1
	str		r1, [r0]
***CHANGED
	// clear bit 10 in the event detect register
	ldr		r0, =0x20003000		// System Timer Control and Status
	mov		r1, #0x20			// bit 1
	str		r1, [r0]
	
irqEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4

.section .data

SNESDat:
	.int	1

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

