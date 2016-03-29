
.section    .init
.globl     _start

_start:
    b       main
    
.section .text


main:
    	mov     sp, #0x8000 // Initializing the stack pointer
	bl	EnableJTAG // Enable JTAG
	bl	InitFrameBuffer
	bl	init_menu
	bl	mSelect
	bl	gameLoop


	b	haltLoop$

end:
	bl	drawMenuBck
haltLoop$:
	b	haltLoop$


// Subroutine for game loop
gameLoop:
	push {r4-r9, lr}		//draw initial snake

	ldr 	r3, =200000		//wait a bit
	bl 	Wait

	bl	clearSL

	ldr	r0, =score
	ldr	r0, [r0]
	ldr	r1, =lives
	ldr	r1, [r1]
	bl	printSL


	ldr	r1, =snakeLen
	ldr	r0, [r1]
	ldr	r2, =direction
	ldr	r1, [r2]
	bl	drawSnake
	bl	drawApple

stateLoop:
	bl	getDirection		//get the direction the user wants the snake to go from the Snes
	ldr	r1, =direction
	ldr	r4, [r1]		//check that the direction pressed is not directly opposed to current
	cmp	r4, #8
	cmpeq	r0, #9
	beq	notOposite
	cmp	r4,#9
	cmpeq	r0,#8
	beq	notOposite
	cmp	r4, #10
	cmpeq	r0, #11
	beq	notOposite
	cmp	r4, #11
	cmpeq	r0, #10
	beq	notOposite
	
	cmp	r0, #0			// make sure somthing was pressed
	strne	r0, [r1]		// update direction
notOposite:
	
	ldr	r1, =snakeLen		// get length
	ldr	r0, [r1]

	
	ldr	r2, =direction		// get direction
	ldr	r1, [r2]
breakb:	bl	updateSnake		// update snakes position

	cmp	r0, #-1			// r0 contains dead (-1) if dead
	bne	wait
	bl	resetSnake
	
	
	ldr	r0, =lives
	ldr	r1, [r0]
	sub	r1, #1			// decrease # lives
	str	r1, [r0]
	cmp	r1, #0
//	bleq	drawLose
breaka:	ble	finish
	b	gameLoop		//restart game loop
	
wait:
	ldr 	r3, =100000		//wait a bit
	bl 	Wait

//	add	r9, #1
	b 	stateLoop		// loop back
finish:	
	pop {r4-r9, lr}	

	mov	pc, lr

// subroutine to reset snake
resetSnake:
	push	{r4-r9,lr}

	mov	r0, #8
	ldr	r1, =direction
	str	r0, [r1]

	pop	{r4-r9,lr}
	mov	pc,lr


// subroutine to initialize game map
init_map:
	push {lr}
	bl	drawGameBck
	bl	drawWall
	bl	putTiles
/*
	ldr	r0, =score
	ldr	r0, [r0]
	ldr	r1, =lives
	ldr	r1, [r1]
	bl	printSL
*/
	pop {lr}
	mov	pc,lr

//subroutine to init menu
init_menu:
	push 	{lr}
	bl	drawMenuBck
	bl	printMenu
	bl	drawStart
	pop 	{lr}
	mov 	pc,lr




// subroutine to select from menu
mSelect:
	push {r4-r5,lr}
	bl	init_GPIO
	mov	r5, #0
mSelect2:
	bl	selectMenu	// see if there's any buttons pressed
				// r0 contains return value
	mov	r4, r0		// copy r0 into r4
	cmp	r4, #0		// nothing pressed
	beq	mSelect2


	cmp	r4, #11		// if up
	bleq	drawStart
	moveq	r5, #0
	beq	mSelect2	// check buttons again


	cmp	r4, #10		// if down
	bleq	drawQuit	
	moveq	r5, #1
	beq	mSelect2

	cmp	r4, #7		// if A
	cmpeq	r5, #0
	bleq	init_map	// draw background
	bne	end
	
	pop {r4-r5,lr}
	mov	pc,lr



.section .data  


FrameBufferPointer:
	.int 0
	



.align 4
score:	.int	3
lives:	.int	3

.globl	snakeLen
snakeLen: .int	6
// directions based on button number for up down left right
direction: .int 8



