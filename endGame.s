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
	ldrh	r5, [r4], #2	// wall left
	ldrh	r6, [r4], #2	// wall right
	cmp	r8, r5		
	beq	dead
	cmp	r8, r6
	beq	dead
	ldrh	r5, [r4], #2	// wall up
	ldrh	r6, [r4], #2	// wall down
	cmp	r9, r5		
	beq	dead
	cmp	r9, r6
	beq	dead

	// check bricks
	ldr	r4, =bricks	// x
	mov	r5, #19
	
loopBricks:
	ldrh	r5, [r4], #2	// check x
	ldrh	r6, [r4], #2	// check y
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

.section .data

.align 4
bricks:
	.hword 384, 352, 384, 384, 384, 416, 384, 448, 384, 480
	.hword 192, 608, 256, 608, 320, 608, 384, 608, 448, 608, 512, 608, 576, 608
	.hword 640, 352, 672, 352, 704, 352, 736, 352
	.hword 640, 384, 736, 384, 672, 448, 704, 448
// if snake destined to go further than the bound it dies
// x and y positions of snake if it hits the bound
wall:	.hword 32
	.hword 960
	.hword 224
	.hword 704
