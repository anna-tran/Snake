
.section    .init
.globl     _start

_start:
    b       main
    
.section .text


main:
    	bl	InstallIntTable			// *** MUST COME FIRST, sets the stack pointer
	

	bl	EnableJTAG // Enable JTAG
	
	bl	InitFrameBuffer
	bl	init_menu
	bl	mSelect

	ldr	r0, =endGame
	ldr	r1, [r0]
	mov	r2, #0
	str	r2, [r0]
	cmp	r1, #2
	beq	end

	
gameStart:
	bl 	interruptSetUp		// reset value pack

	bl	gameLoop

	ldr	r0, =endGame
	ldr	r1, [r0]
	mov	r2, #0
	str	r2, [r0]
	cmp	r1, #2
	beq	main			// always go back to main menu
readButtons:

	ldr	r3, =0x249F0
	bl	Wait
	bl	Read_SNES	// read from SNES, r0 contains buttons stored
	ldr	r1, =0xFFFFFFFF
	eor	r0, r1
	
	ldr	r1, =0xFFF0
	ands	r1, r0
	beq	readButtons
	b	main


	b	haltLoop$

end:
	bl	drawMenuBck
haltLoop$:
	b	haltLoop$


// Subroutine for game loop
gameLoop:
	push {r4-r9, lr}		//draw initial snake

restartGameIteration:

	ldr 	r3, =200000		// wait a bit
	bl 	Wait
	
	bl	printSL

	ldr	r2, =direction
	mov	r1, #8
	str	r1, [r2]


	ldr	r1, =snakeLen
	ldr	r0, [r1]
	ldr	r2, =direction
	ldr	r1, [r2]
	bl	drawSnake

	ldr	r0, =appleCount
	ldr	r0, [r0]	// r0 = appleCount
	cmp	r0, #2
	bllt	drawApple

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

	cmp	r0, #12			// check if start button, r0 is return value
	bne	continueGameLoop	// if not start button, check if anything was pressed
	

	ldr	r4, =0x20003004	//CLO
	ldr	r5, [r4]	//read CLO
	ldr	r4, =TimeElapsed	
	ldr	r6, [r4]	// read start time
	sub	r5, r6		// find time elapsed; present - start
	str	r5, [r4]	// store time elapsed into TimeElapsed

	ldr	r2, =endGame
	mov	r3, #5		// endGame now on pause
	str	r3, [r2]
	bl	pauseMenu


// 0 - restart
// 1 - quit
// 2 - resume
isPause:
	cmp	r1, #0			
	bleq	resetGame		// if game restart
	
	ldreq	r2, =endGame
	moveq	r3, #0
	streq	r3, [r2]
	bleq 	interruptSetUp		// reset value pack

	beq	restartGameIteration
shouldQuit:
	cmp	r1, #1
	ldreq	r2, =endGame
	moveq	r3, #2
	streq	r3, [r2]		// store quit value in endGame
	beq	finish			// if r1 = 2, resume game as normal.
	

	cmp	r1, #2			// if resume
	bleq	init_map
	bleq	printSL
	bleq	drawApple
	bleq	drawValuePack
	beq	toUpdate
	
	mov	r0, #0

continueGameLoop:	
	cmp	r0, #0			// make sure somthing was pressed
	ldr	r1, =direction
	strne	r0, [r1]		// update direction
notOposite:
	
	ldr	r1, =snakeLen		// get length
	ldr	r0, [r1]

toUpdate:	
	ldr	r2, =direction		// get direction
	ldr	r1, [r2]
	bl	updateSnake		// update snakes position


	cmp	r0, #-1			// r0 contains dead (-1) if dead
	bne	wait			// go to wait if still alive
	bl	resetSnake
	
	ldr	r0, =lives
	ldr	r1, [r0]
	sub	r1, #1			// decrease # lives
	str	r1, [r0]
	cmp	r1, #0
isLose:
	ldreq	r0, =endGame
	moveq	r9, #3
	streq	r9, [r0]
	mov	r0, #3
	
	bleq	drawWLP
	ble	finish
	b	restartGameIteration		//restart game loop
	
wait:
	ldr	r0, =endGame		// check if game is won
	ldr	r9, [r0]
	cmp	r9, #1
	bne	nextTurn		// if not 1, then game is not yet won
isWin:	moveq	r0, #1
	bleq	drawWLP			// draw win message
	beq	finish			// finish game
nextTurn:
	ldr	r0, =Speed
checkSpeed:
	ldr	r3, [r0]
//	ldr 	r3, =120000//100000		//wait a bit
	bl 	Wait

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

	bl	clearSnakeBody

	pop	{r4-r9,lr}
	mov	pc,lr


// subroutine to initialize game map
init_map:
	push {lr}
	bl	drawGameBck
	bl	drawWall
	bl	putTiles

	pop {lr}
	mov	pc,lr

//subroutine to init menu
init_menu:
	push 	{lr}
	bl	drawMenuBck
	bl	printMenu
	mov	r0, #0
	bl	drawStart
	pop 	{lr}
	mov 	pc,lr

// subroutine to answer the menu pausing
// return value in r1
pauseMenu:
	push	{r4-r9,lr}
	mov	r0, #2		// draw pause menu
	bl	drawWLP

	mov	r0, #1
	bl	drawStart
	mov	r5, #0

	ldr 	r3, =100000		// wait a bit
	bl 	Wait
	

selectFromPause:
	mov	r0, #1
	bl	selectMenu	// see if there's any buttons pressed
				// r0 contains return value
	mov	r4, r0		// copy r0 into r4

	cmp	r4, #11		// if up
	moveq	r0, #1
	bleq	drawStart
	moveq	r5, #0		// if r5 = 0 then we're on restart
	beq	selectFromPause	// check buttons again


	cmp	r4, #10		// if down
	moveq	r0, #1
	bleq	drawQuit	
	moveq	r5, #1		// if r5 = 1 then we're on quit
	beq	selectFromPause

	cmp	r4, #7		// if A
	moveq	r1, r5
	beq	breakForP

	cmp	r4, #12		// if start button pressed
	moveq	r1, #2
	beq	breakForP

	b	selectFromPause	// if none of start, up, down or up pressed
				// select from menu again

// 0 - restart
// 1 - quit
// 2 - resume
	
breakForP:
	pop	{r4-r9,lr}
	mov	pc,lr



// subroutine to select from menu
mSelect:
	push {r4-r5,lr}
	bl	init_GPIO
	mov	r5, #0
mSelect2:
	mov	r0, #0
	bl	selectMenu	// see if there's any buttons pressed
				// r0 contains return value
	mov	r4, r0		// copy r0 into r4
	cmp	r4, #0		// nothing pressed
	beq	mSelect2


	cmp	r4, #11		// if up
	moveq	r0, #0
	bleq	drawStart
	moveq	r5, #0
	beq	mSelect2	// check buttons again


	cmp	r4, #10		// if down
	moveq	r0, #0
	bleq	drawQuit	
	moveq	r5, #1
	beq	mSelect2

	cmp	r4, #7		// if A
	bne	mSelect2	// if none of up, down or A, select from Menu again
	cmpeq	r5, #0
	bleq	resetGame	// start a new game
	ldr	r0, =endGame	// quit game value
	moveq	r1, #4		// start game = 4
	movne	r1, #2		// end game = 4
	str	r1, [r0]
	
endMenuSelect:	
	pop {r4-r5,lr}
	mov	pc,lr


resetGame:
	push	{r4-r9,lr}

	ldr	r4, =0x20003004	//CLO
	ldr	r5, [r4]	//read CLO
	ldr	r4, =TimeElapsed	// store start time into TimeElapsed
	str	r5, [r4]
	
	ldr	r4, =score		// reset score
	mov	r5, #0
	str	r5, [r4]
	ldr	r4, =appleCount		// reset apple count
	str	r5, [r4]	

	ldr	r4, =lives		// reset lives
	mov	r6, #5
	str	r6, [r4]
	mov	r6, #3
	ldr	r4, =snakeLen		// reset length
	str	r6, [r4]

	ldr	r4, =Speed		// reset speed
	ldr	r5, =120000
	str	r5, [r4]		

	bl	init_map		// reinitiate the map

	bl	clearSnakeBody

	pop	{r4-r9,lr}
	mov	pc,lr



.section .data  


FrameBufferPointer:
	.int 0
	



.align 4
.globl score
score:	.int	0
.globl lives
lives:	.int	5

.globl	snakeLen
snakeLen: .int	3
// directions based on button number for up down left right
direction: .int 8



