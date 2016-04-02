
.section .text

// subroutine to write to screen

.globl printSL
printSL:
	push {r4-r9, lr}
// start at 320
	bl	clearSL		// clear the score and lives frist

	px	.req r1		// rename r1, r2 and r8
	py	.req r2
	count	.req r8


	ldr	r6, =scoreTxt
	ldr	r7, =lifeTxt

	
	ldr	px, =320	// init x coor
	mov	r3, px		// copy x to r3
	mov	count, #7	// init counter
loopScore:
	ldrb	r0, [r6], #1	// load one char
	mov	py, #32		// init y coor
	bl	DrawChar	// write char
	add	px, r3, #8	// move to next pixel location
	mov	r3, px		// update r3
	subs	count, #1	// dec counter
	bgt	loopScore	// loop back if counter > 0

// add 48 to score digits and lives to get ascii
	ldr	r9, =score	// load score
	ldr	r0, [r9]
	bl	itoa		// convert int to ascii
	ldr	r0, [r9]	// check if score is 1 or 2 digits long
	cmp	r0, #0		// if one digit, count = 1
	movge	count, #1
	cmp	r0, #10		// if two digits count = 2
	movge	count, #2

	ldr	r6, =intHold	// holder for int in ascii form
	
	ldr	px, =376	// init x coor
getScore:
	ldrb	r0, [r6], #1	// load one char
	mov	py, #32		// init y coor
	bl	DrawChar	// write char
	ldr	px, =384	// move to next x
	subs	count, #1	// dec counter
	bgt	getScore	// if two digits, print second digit


	ldr	px, =512	// init x coor
	mov	r3, px
	mov	count, #7	// init counter
loopLives:
	ldrb	r0, [r7], #1	// load one char
	mov	py, #32		// init y coor
	bl	DrawChar	// write char
	add	px, r3, #8	// move to next pixel location
	mov	r3, px		// update r3
	subs	count, #1	// dec counter
	bgt	loopLives	// loop back if counter > 0

// add 48 to score digits and lives to get ascii
	ldr	r0, =lives
	ldr	r0, [r0]
	bl	itoa		// convert int lives into ascii

	ldr	r6, =intHold	// load address for intHold
	
	ldr	px, =568	// init x coor
getLives:
	ldrb	r0, [r6]	// load one char
	mov	py, #32		// init y coor
	bl	DrawChar	// write char


	.unreq	px		// take off label from r1, r2, r8
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
	strb	r1, [r4], #1	// store into intHold

store1:
	mov	r1, #0		// reset counter	
	add	r0, #48		// else convert to ascii and store
	strb	r0, [r4]	// store into intHold


return:
	pop {r4-r9, lr}
	mov	pc,lr



.globl	clearSL
// subroutine to clear the lives text

clearSL:
	push	{r4-r9,lr}
	ldr	r4, =320	// starting x coor
	ldr	r5, =630	// ending x coor

clearSLLoop:
	mov	r0, r4
	mov	r1, #32		// y coor
	ldr	r2, =0xA098	// magenta
	mov	r3, #32		// size of cell
	bl	eraseTile	// erase cell

	add	r4, #32		// move to next right cell

	cmp	r4, r5		// check if end of lives
	blt	clearSLLoop

	pop	{r4-r9,lr}
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
	mov	r1, r4		// copy x into r1
	mov	r2, r5		// copy y into r2
	bl	DrawChar	// draw character
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
	mov	r1, r4		// copy x into r1
	mov	r2, r5		// copy y into r2
	bl	DrawChar	// draw character
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
	mov	r1, r4		// copy x into r1
	mov	r2, r5		// copy y into r2
	bl	DrawChar	// draw char
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
	mov	r1, r4		// copy x into r1
	mov	r2, r5		// copy y into r2
	bl	DrawChar	// draw char
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
	mov	r1, r4		// copy x into r1
	mov	r2, r5		// copy y into r2
	bl	DrawChar	// draw char
	add	r4, #8		// next char space
	mov	r1, r4		// update x
	mov	r2, r5		// repaste y
	subs	r6, #1		// if counter != 0
	bne	pQuit		// loop again

	pop {r4-r9,lr}
	mov	pc,lr





/* subroutine to draw the character in r0
r0 = character
r1 = x position
r2 = y position
 */
.globl DrawChar
DrawChar:
	push	{r4-r9, lr}

	// label registers
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
	.ascii "  "
.align 4
font:		.incbin	"font.bin"

.align 2
scoreTxt:
.ascii "Score: "
lifeTxt:
.ascii "Lives: "

// string to print out on main menu screen
classTitle: .ascii "CPSC 359"
gameTitle: .ascii "Snake"
creators: .ascii "Ryan Holoweckyj and Anna Tran"
startGame: .ascii "Start Game"
quitGame: .ascii "Quit Game"

