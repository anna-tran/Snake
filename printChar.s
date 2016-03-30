
.section .text

// subroutine to write to screen
/*
r0 = score
r1 = lives
*/
.globl printSL
printSL:
	push {r4-r9, lr}
// start at 320

	px	.req r1
	py	.req r2
	count	.req r8
	mov	r4, r0		// save score
	mov	r5, r1		// save lives

	ldr	r6, =scoreTxt
	ldr	r7, =lifeTxt

	
	ldr	px, =320	// init x coor
	mov	r3, px
	mov	count, #7	// init counter
loopScore:
	ldrb	r0, [r6], #1	// load one char
	mov	py, #70		// init y coor
	bl	DrawChar	// write char
	add	px, r3, #8
	mov	r3, px
	subs	count, #1	// dec counter
	bge	loopScore

// add 48 to score digits and lives to get ascii
// cap of at 99 for score
	mov	r0, r4
	bl	itoa
	cmp	r4, #1
	movge	count, #1
	cmp	r4, #10
	movge	count, #2

	ldr	r6, =intHold
	
	ldr	px, =376	// init x coor
getScore:
	ldrb	r0, [r6], #1	// load one char
	mov	py, #70		// init y coor
	bl	DrawChar	// write char
	add	px, r3, #8
	mov	r3, px
	subs	count, #1	// dec counter
	bge	getScore


	ldr	px, =512	// init x coor
	mov	r3, px
	mov	count, #7	// init counter
loopLives:
	ldrb	r0, [r7], #1	// load one char
	mov	py, #70		// init y coor
	bl	DrawChar	// write char
	add	px, r3, #8
	mov	r3, px
	subs	count, #1	// dec counter
	bgt	loopLives

// add 48 to score digits and lives to get ascii
// cap of at 99 for score
	mov	r0, r5
	bl	itoa

	ldr	r6, =intHold	// load address for intHold
	
	ldr	px, =568	// init x coor
getLives:
	ldrb	r0, [r6]	// load one char
	mov	py, #70		// init y coor
	bl	DrawChar	// write char


	.unreq	px
	.unreq	py
	.unreq	count

	pop {r4-r9, lr}
	mov	pc,lr


// subroutine to convert integer to ascii
// r0 is value
itoa:	
	push {r4-r9, lr}		//r0 is value, r6 is address to sum, avg or rem
	ldr	r4, =intHold		// r4 = address to hold ascii char
	
	mov	r1, #0		// r1 is counter
	cmp	r0, #10		// check if value >= 10
	blt	store1		// else check single digits
loop10:
	sub	r0, r0, #10	// value -= 10
	add	r1, #1		// inc counter
	cmp	r0, #10		// loop again if value still >= 10
	bge	loop10

	// convert counter to ascii
	add	r1, #48
	strb	r1, [r4], #1

store1:
	mov	r1, #0		// reset counter
	cmp	r0, #0		// check if last digit is 0
	beq	return
	
	add	r0, #48		// else convert to ascii and store
	strb	r0, [r4]


return:
	pop {r4-r9, lr}
	mov	pc,lr



// subroutine to print menu
.globl printMenu
printMenu:
	push {r4-r9,lr}
	
	ldr	r3, =classTitle	// r3 = address
	ldr	r4, =448	// x init
	ldr	r5, =256	// y init
	mov	r6, #8		// counter
	
pClassTitle:
	ldrb	r0, [r3], #1	// r0 = char	
	mov	r1, r4
	mov	r2, r5
	bl	DrawChar
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pClassTitle	// loop again



	ldr	r3, =gameTitle	// r3 = address
	ldr	r4, =448	// x init
	ldr	r5, =288	// y init
	mov	r6, #5		// counter
	
pGameTitle:
	ldrb	r0, [r3], #1	// r0 = char	
	mov	r1, r4
	mov	r2, r5
	bl	DrawChar
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pGameTitle	// loop again



	ldr	r3, =creators	// r3 = address
	ldr	r4, =448	// x init
	ldr	r5, =320	// y init
	mov	r6, #29		// counter
	
pCreators:
	ldrb	r0, [r3], #1	// r0 = char	
	mov	r1, r4
	mov	r2, r5
	bl	DrawChar
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pCreators	// loop again



	ldr	r3, =startGame	// r3 = address
	ldr	r4, =448	// x init
	ldr	r5, =352	// y init
	mov	r6, #10		// counter
	
pStart:
	ldrb	r0, [r3], #1	// r0 = char	
	mov	r1, r4
	mov	r2, r5
	bl	DrawChar
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pStart	// loop again



	ldr	r3, =quitGame	// r3 = address
	ldr	r4, =448	// x init
	ldr	r5, =384	// y init
	mov	r6, #9		// counter
	
pQuit:
	ldrb	r0, [r3], #1	// r0 = char	
	mov	r1, r4
	mov	r2, r5
	bl	DrawChar
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pQuit		// loop again



	pop {r4-r9,lr}
	mov	pc,lr





/* Draw the character in r0
r0 = character
r1 = x position
r2 = y position
 */
.globl DrawChar
DrawChar:
	push	{r4-r9, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8
	mov	px, r1
	mov	py, r2
	mov	r9, r1

	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

charLoop$:
	mov		px,		r9	// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	ldr		r2,		=0xFFFF		// white
	bl		DrawPixel			// draw red pixel at (px, py)

noPixel$:
	add		px,	#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,	#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$	// loop back to charLoop$, unless address evenly divisibly by 16 
					//(ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r9, pc}


.section .data

//Buffer for reading from screen
intHold:
	.ascii "00"

.align 4
font:		.incbin	"font.bin"

score:	.int	0
lives:	.int	3

.align 2
scoreTxt:
.ascii "Score: "
lifeTxt:
.ascii "Lives: "

classTitle: .ascii "CPSC 359"
gameTitle: .ascii "Snake"
creators: .ascii "Ryan Holoweckyj and Anna Tran"
startGame: .ascii "Start Game"
quitGame: .ascii "Quit Game"

