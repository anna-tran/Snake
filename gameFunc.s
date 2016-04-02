// subroutine to check death of snake
.globl checkDeath
// r0 is x
// r1 is y
// return in r0
checkDeath:

	push {r4-r9, lr}
	ldr	r1, =HeadDest	// get head destination
	ldr	r0, [r1], #4
	ldr	r1, [r1]
	
	mov	r8, r0		// copy x of head destination
	mov	r9, r1		// copy y of head destination
	
// check if destination is any of the walls
loopWalls:	
	ldr	r4, =wall
	ldr	r5, [r4], #4	// wall left
	ldr	r6, [r4], #4	// wall right
	cmp	r8, r5			// if hit left wall
	beq	dead			// go to dead
	cmp	r8, r6			// if hit right wall
	beq	dead			// go to dead
	
	ldr	r5, [r4], #4	// wall up
	ldr	r6, [r4], #4	// wall down
	cmp	r9, r5			// if hit either top
	beq	dead			// or bottom wall
	cmp	r9, r6			// go to dead
	beq	dead

	// check bricks
	ldr	r4, =bricks	// x
	mov	r7, #20		// counter for the 20 bricks
	
loopBricks:
	ldr	r5, [r4], #4	// check x
	ldr	r6, [r4], #4	// check y
	cmp	r8, r5			// cmp x and y
	cmpeq	r9, r6
	beq	dead			// if a brick, dead

	subs	r7, #1		// dec counter
	bne	loopBricks		// if not that brick, check again


	ldr	r4, =snakePosition
	add	r4, #8			// start after head
	ldr	r5, =snakeLen	
	ldr	r7, [r5] 		// counter = snake length

loopBody:
	ldr	r5, [r4], #4	// check x
	ldr	r6, [r4], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	dead		// if part of snake, dead

	subs	r7, #1	// dec counter
	bne	loopBody	// if not that snake body cell, check again

alive:
	mov	r0, r8		// if not dead then return original x
	b	returnDead	// go to end of routine

dead:
	mov	r0, #-1		// r0 = -1 if dead

returnDead:
	pop {r4-r9,lr}
	mov	pc,lr

	
// subroutine to check if apple has been eaten
.globl checkApple
checkApple:
	push	{r4-r9,lr}

	ldr	r4, =HeadDest	// load head destination
	ldr	r0, [r4], #4	
	ldr	r1, [r4]

	ldr	r4, =applePosition
	ldr	r5, [r4], #4	// get apple x
	ldr	r6, [r4]		// get apple y
printApplePos:
	cmp	r0, r5			// check if head x = apple x
	cmpeq	r1, r6		// and head y = apple y
	moveq	r0, #0		// r0 = 0 if going to apple position
						// otherwise r0 = head position

	pop	{r4-r9,lr}
	mov	pc,lr



.globl	correctApple
// subroutine to check if random location for apple does not conflict
// with any tiles or snake position
// r0 = 0 apple
// r0 = 1 value pack
correctApple:

	push	{r4-r9,lr}
	cmp	r0, #0
	ldreq	r4, =applePosition
	ldrne	r4, =VPPosition
	ldr	r8, [r4], #4		// r8 = x
	ldr	r9, [r4]			// r9 = y

	ldr	r7, =bricks			// check if apple location conflicts with brick
	mov	r3, #20				// set counter = 20
checkAppleBrick:

	ldr	r5, [r7], #4	// check x
	ldr	r6, [r7], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if a brick, try again

	subs	r3, #1		// dec counter
	bne	checkAppleBrick	// if not that brick, check again


	ldr	r7, =snakePosition	// r7 = address of snake position
	ldr	r4, =snakeLen		// r4 = address of snakeLen
	ldr	r3, [r4]	// counter for loop

checkAppleSnake:
	ldr	r5, [r7], #4	// check x
	ldr	r6, [r7], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if a snake body piece, try again

	subs	r3, #1		// dec counter
	bne	checkAppleSnake	// if not that brick, check again
	
/*
	cmp r0, #0
	beq checkVPConflict
	bne checkAppleConflict
	
checkVPConflict:
	ldr	r4, =VPPosition		// get apple position
	ldr	r5, [r4], #4
	ldr r6, [r4]
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if apple falls on value pack, try again
	
	
checkAppleConflict:
	ldr	r4, =applePosition		// get apple position
	ldr	r5, [r4], #4
	ldr r6, [r4]
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if value pack falls on apple, try again
*/	

	b endAppleCheck		// go to end of routine if no conflict
callRedo:
	mov	r0, #-1
// 0 if ok
// -1 if redo
endAppleCheck:
	pop	{r4-r9,lr}
	mov	pc,lr

.globl getRand
getRand:
	push	{r4-r9,lr}
	
	// xorshift x
	mov	r9, r0		// store r0
	// if r9 = 0, draw apple
	// if r9 = 1, draw valuePack
	
	mov	r0, #0		// start with x

randAgain:
	ldr	r4, =rand
	ldm	r4, {r5-r8}	// r5 - r8 contain the random integers
	eor	r2, r5, lsl #11	// r2 ^= r5 << 11
	eor	r2, r2, lsr #9	// r2 ^= r2 >> 9
	mov	r5, r6		// move the random integers down by one
	mov	r6, r7
	mov	r7, r8
	eor	r8, r8, lsr #16	// r8 ^= r8 >> 16
	eor	r8, r2		// r8 ^= r2

	ldr	r4, =rand	// store these new random numbers
	stm	r4, {r5-r8}

	// r8 is our random number
	
	lsl	r8, #5		// lsl by 5 to 32-bit align
	ldr	r2, =0x3FF	// r2 is 0011 1111 1111
	and	r8, r2		// get max number of 10 bits
	cmp	r0, #0		// if randomizing x value, go to checkAppleX
	bne	checkAppleY	// else if randomizing y value, go to checkAppleY
	
checkAppleX:	
	cmp	r8, #64		// if x < 64
	blt	randAgain
	cmp	r8, #928	// or x > 928
	bgt	randAgain	// randomize x again

	cmp	r9, #0		// check if apple or value pack
	ldreq	r4, =applePosition	// if apple, get address
	ldrne	r4, =VPPosition		// if value pack get address
	b	storeAppleXY		// go to store
	
checkAppleY:
	
	cmp	r8, #128	// if y < 128
	blt	randAgain
	cmp	r8, #672	// or y > 672
	bgt	randAgain	// randomize y again

	cmp	r9, #0		// check if apple or value pack
	ldr	r4, =applePosition	// apple address
	ldrne	r4, =VPPosition	// value pack address
	add	r4, #4		// go to y location in memory for address


storeAppleXY:	
	str	r8, [r4]	// store new x or y position for apple or value pack
	add	r0, #1		// change to y if r0 = 0
	cmp	r0, #1		
	beq	randAgain	// generate random value for y
	
	ldr	r4, =rand	// store new random numbers
	stm	r4, {r5-r8}

	mov	r0, r9		// move code for apple or value pack into r0
	bl	correctApple	// check if position conflicts with tiles or snake body
	cmp	r0, #-1		// r0 = -1 if there is a conflict
	beq	randAgain	// if apple in spot of snake or brick,
					// randomize again

	pop	{r4-r9,lr}
	mov	pc,lr


.globl	incLength
// subroutine to increase snake length by 1
// and increase number of apples eaten by 1
// inc score by 3 every time an apple is eaten
incLength:
	push	{r4-r9,lr}

	ldr	r4, =snakeLen	// load snake length
	ldr	r5, [r4]
	add	r5, #1			// inc and store length
	str	r5, [r4]

	ldr	r4, =score		// load score
	ldr	r5, [r4]
	add	r5, #3			// add 3 to score
	str	r5, [r4]		// store into memoru

	ldr	r4, =appleCount
	ldr	r5, [r4]		// load apple count
	add	r5, #1			// inc and store count
	str	r5, [r4]

	bl	printSL			// reprint score and lives

	pop	{r4-r9,lr}
	mov	pc,lr

.globl	clearSnakeBody
// clears the snake body positions
clearSnakeBody:
	push	{r4-r9,lr}

	ldr	r4, =origSnake		// load array of 0s for original snake array
	ldr	r5, =snakePosition	// load current snake position
	ldr	r6, =256			// number of array entries
clearBodyLoop:
	ldr	r7, [r4], #4		// load 0
	str	r7, [r5], #4		// clear entry
	
	subs	r6, #1			// dec counter
	bgt	clearBodyLoop		// if counter > 0, loop again

	pop	{r4-r9,lr}
	mov	pc,lr


// subroutine to check if value pack is next cell
.globl	checkValuePack
// return value in r0
checkValuePack:

	push	{r4-r9,lr}
	mov	r9, #-1			// default return value if there is no value pack
	ldr	r4, =HeadDest	// get head destination
	ldm	r4, {r5,r6}		// r5 = x
						// r6 = y
	ldr	r4, =VPPosition
	ldm	r4, {r7,r8}		// get value pack position
	cmp	r5, r7			// if head destination = value pack position
	cmpeq	r6, r8
	bne	endVP			// if not equal, go to end	
isVP:					// if equal
	moveq	r9, #0			// clear value pack position
	moveq	r5, #0
	stmeq	r4, {r5,r9}		// store into memory
	ldr	r4, =score
	ldr	r5, [r4]		// increase the score by 5
	add	r5, #5
	str	r5, [r4]		// store into memory
	bl	printSL			// reprint score and lives
	mov	r0, r9			// r0 = 0 to indicate that value pack has been cleared
endVP:
	pop	{r4-r9,lr}
	mov	pc,lr

// array of brick positions
bricks:
	.int 384, 352, 384, 384, 384, 416, 384, 448, 384, 480
	.int 192, 608, 256, 608, 320, 608, 384, 608, 448, 608, 512, 608, 576, 608
	.int 640, 352, 672, 352, 704, 352, 736, 352
	.int 640, 384, 736, 384, 672, 448, 704, 448


// if snake destined to go further than the bound it dies
// x and y positions of snake if it hits the bound
wall:	.int 32
	.int 960
	.int 96
	.int 704


.section .data
// integers for randomizing
.align 4
rand:
	.int 35290, 103666, 3009, 6123


