.section .text

.equ	GPIOFSEL0,	0x20200000
.equ	GPIOFSEL1,	0x20200004
.equ	GPIOSET0,	0x2020001C
.equ	GPIOCLR0,	0x20200028


/* Initialize the SNES Controller GPIO Pins
 *	LAT (GPIO 9) - Output
 *	CLK (GPIO 11) - Output
 *	DAT (GPIO 10) - Input
 */
.globl InitSNES
InitSNES:
	// GPIO 9 (LAT) is on GPIOFSEL0
	ldr		r0, =GPIOFSEL0
	ldr		r1, [r0]
	
	// clear bits 27-29 and set them to 001 (Output)
	bic		r1, #0x38000000
	orr		r1, #0x08000000

	// write back to GPIOFSEL0
	str		r1, [r0]

	// GPIO 10 & 10 are on GPIOFSEL1
	ldr		r0, =GPIOFSEL1
	ldr		r1, [r0]

	// clear bits 0-2 (GPIO 10) and 3-5 (GPIO 11), set 0-2 to 000 (Input) and 3-5 to 001 (Output)
	bic		r1, #0x0000003F
	orr		r1, #0x00000008

	// write back to GPIOFSEL1
	str		r1, [r0]

	// return
	bx		lr


/* Initialize ACT LED (GPIO 16) line to Output
 */
.globl InitLED
InitLED:
	ldr		r0, =GPIOFSEL1
	ldr		r1, [r0]			

	bic		r1, #0x001C0000
	orr		r1, #0x00040000

	str		r1, [r0]

	bx		lr

/* Set the Latch (GPIO 9) line level
 *	r0 - 0 (clear) or != 0 (set)
 */
.globl SetLATLevel
SetLATLevel:
	tst		r0, #1
	ldreq	r0, =GPIOCLR0
	ldrne	r0, =GPIOSET0

	ldr		r1, =0x00000200
	str		r1, [r0]

	bx		lr

/* Set the LED (GPIO 16) line level
 *	r0 - 0 (clear) or != 0 (set)
 */
.globl SetLEDLevel
SetLEDLevel:
	tst		r0, #1
	ldreq	r0, =GPIOCLR0
	ldrne	r0, =GPIOSET0

	ldr		r1, =0x00010000
	str		r1, [r0]

	bx		lr

