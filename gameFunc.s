// subroutine to check death of snake
.globl checkDeath
// r0 is x
// r1 is y
// return in r0
checkDeath:

	push {r4-r9, lr}
	
	mov	r8, r0		// copy x
	mov	r9, r1		// copy y
	
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
	mov	r5, #19
	
loopBricks:
	ldr	r5, [r4], #4	// check x
	ldr	r6, [r4], #4	// check y
	cmp	r8, r5		// cmp x and y
	cmpeq	r9, r6
	beq	dead		// if a brick, dead

	subs	r5, #1
	bne	loopBricks	// if not that brick, check again

alive:
	mov	r0, r8		// if not dead then return original x
	b	returnDead

dead:
	mov	r0, #-1

returnDead:
	pop {r4-r9,lr}
	mov	pc,lr

.globl	checkApple
// get apple coordinates i.e. rand coordinates
// to be completed
checkApple:

	push	{r4-r9,lr}
	ldr	r4, =applePosition
	ldm	r4, {r0,r1}	// r0 = x
				// r1 = y

	ldr	r2, =bricks
	mov	r3, #19
checkAppleBrick:

	ldr	r5, [r2], #4	// check x
	ldr	r6, [r2], #4	// check y
	cmp	r0, r5		// cmp x and y
	cmpeq	r1, r6
	moveq	r0, #-1
	beq	callRedo	// if a brick, try again

	subs	r3, #1
	bne	checkAppleBrick	// if not that brick, check again


	ldr	r2, =snakePosition
	ldr	r4, =snakeLen
	ldr	r3, [r4]	// counter for loop

checkAppleSnake:
	ldr	r5, [r2], #4	// check x
	ldr	r6, [r2], #4	// check y
	cmp	r0, r5		// cmp x and y
	cmpeq	r1, r6
	moveq	r0, #-1
	beq	callRedo	// if a snake body piece, try again

	subs	r3, #1
	bne	checkAppleSnake	// if not that brick, check again

	mov	r0, #0
callRedo:
// 0 if ok
// -1 if redo
	pop	{r4-r9,lr}
	mov	pc,lr

.globl getRand
// returns rand x in r0
// returns rand y in r1
getRand:
	push	{r4-r9,lr}
randAgain:
	ldr	r4, =applePosition
	ldm	r4, {r0,r1}

	mov	r5, r0		// copy x
	mov	r6, r1		// copy y

	// xorshift x
redoX:
	lsl	r2, r0, #4	// x ^ 4
	eor	r5, r2
	lsr	r2, r0, #2	// x ^ 3
	eor	r5, r2
	eor	r5, r0

	ldr	r2, =0x3C0	// at min 64
	and	r5, r2		// at most 896
	cmp	r5, #64
	blt	redoX
	cmp	r5, #928
	bgt	redoX

	// xorshift y
redoY:
	lsl	r2, r1, #4	// x ^ 4
	eor	r6, r2
	lsr	r2, r1, #2	// x ^ 3
	eor	r6, r2
	eor	r6, r1

	ldr	r2, =0x3B0	// at min 256
	and	r6, r2		// at most 672

	cmp	r5, #256
	blt	redoY
	cmp	r5, #672
	bgt	redoY

	stm	r4, {r5,r6}	// update apple position

	bl	checkApple
	cmp	r0, #0
	bne	randAgain	// if apple in spot of snake or brick,
				// try again

	pop	{r4-r9,lr}
	mov	pc,lr



.section .data

.align 4
.globl	applePosition
applePosition:
	.int 640
	.int 608


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
