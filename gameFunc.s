// subroutine to check death of snake
.globl checkDeath
// r0 is x
// r1 is y
// return in r0
checkDeath:

	push {r4-r9, lr}
	
	mov	r8, r0		// copy x
	mov	r9, r1		// copy y
loopWalls:	
	ldr	r4, =wall
	ldr	r5, [r4], #4	// wall left
	ldr	r6, [r4], #4	// wall right
	cmp	r8, r5		
	beq	dead
	cmp	r8, r6
	beq	dead
	ldr	r5, [r4], #4	// wall up
	ldr	r6, [r4], #4	// wall down
	cmp	r9, r5		
	beq	dead
	cmp	r9, r6
	beq	dead

	// check bricks
	ldr	r4, =bricks	// x
	mov	r7, #20
	
loopBricks:
	ldr	r5, [r4], #4	// check x
	ldr	r6, [r4], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	dead		// if a brick, dead

	subs	r7, #1
	bne	loopBricks	// if not that brick, check again


	ldr	r4, =snakePosition
	add	r4, #8		// start after head
	ldr	r5, =snakeLen
	ldr	r7, [r5] 

loopBody:
	ldr	r5, [r4], #4	// check x
	ldr	r6, [r4], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	dead		// if part of snake, dead

	subs	r7, #1
	bne	loopBody

alive:
	mov	r0, r8		// if not dead then return original x
	b	returnDead

dead:
	mov	r0, #-1

returnDead:
	pop {r4-r9,lr}
	mov	pc,lr

.globl checkApple
// r0 is x
// r1 is y
checkApple:
	push	{r4-r9,lr}

	ldr	r4, =applePosition
	ldr	r5, [r4], #4	// get apple x
	ldr	r6, [r4]	// get apple y
printApplePos:
	cmp	r0, r5
	cmpeq	r1, r6
	moveq	r0, #0		// r0 = 0 if going to apple position
	

	pop	{r4-r9,lr}
	mov	pc,lr



.globl	correctApple
// get apple coordinates i.e. rand coordinates
// to be completed
correctApple:

	push	{r4-r9,lr}
	ldr	r4, =applePosition
	ldr	r8, [r4], #4
	ldr	r9, [r4]
//	ldm	r4, {r8,r9}	// r8 = x
				// r9 = y

	ldr	r7, =bricks
	mov	r3, #20
checkAppleBrick:

	ldr	r5, [r7], #4	// check x
	ldr	r6, [r7], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if a brick, try again

	subs	r3, #1
	bne	checkAppleBrick	// if not that brick, check again


	ldr	r7, =snakePosition
	ldr	r4, =snakeLen
	ldr	r3, [r4]	// counter for loop

checkAppleSnake:
	ldr	r5, [r7], #4	// check x
	ldr	r6, [r7], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	callRedo	// if a snake body piece, try again

	subs	r3, #1
	bne	checkAppleSnake	// if not that brick, check again

	b endAppleCheck
callRedo:
	mov	r0, #0
// 0 if ok
// -1 if redo
endAppleCheck:
	pop	{r4-r9,lr}
	mov	pc,lr

.globl getRand
getRand:
	push	{r4-r9,lr}
	
	// xorshift x
	
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
	cmp	r0, #0
	bne	checkAppleY
	
checkAppleX:	
	cmp	r8, #64
	blt	randAgain
	cmp	r8, #928
	bgt	randAgain
	ldr	r4, =applePosition	// apple x
	b	storeAppleXY
	
checkAppleY:
	
	cmp	r8, #256
	blt	randAgain
	cmp	r8, #672
	ldr	r4, =applePosition	// apple y
	add	r4, #4
	bgt	randAgain

storeAppleXY:	

	str	r8, [r4]	// store new x position for apple
	add	r0, #1		// change to y
	cmp	r0, #1
	beq	randAgain	// generate another random value for y
	
	ldr	r4, =rand
	stm	r4, {r5-r8}

	bl	correctApple
	cmp	r0, #0
	beq	randAgain	// if apple in spot of snake or brick,
				// try again

	pop	{r4-r9,lr}
	mov	pc,lr


.globl	incLength
// subroutine to increase snake length by 1
incLength:
	push	{r4-r9,lr}

	ldr	r4, =snakeLen
	ldr	r5, [r4]
	add	r5, #1
	str	r5, [r4]

	pop	{r4-r9,lr}
	mov	pc,lr

.section .data

.align 4
rand:
	.int 35290, 103666, 3009, 6123

bricks:
	.int 384, 352, 384, 384, 384, 416, 384, 448, 384, 480
	.int 192, 608, 256, 608, 320, 608, 384, 608, 448, 608, 512, 608, 576, 608
	.int 640, 352, 672, 352, 704, 352, 736, 352
	.int 640, 384, 736, 384, 672, 448, 704, 448
// if snake destined to go further than the bound it dies
// x and y positions of snake if it hits the bound
wall:	.int 32
	.int 960
	.int 224
	.int 704
