.section    .init
.globl     _start

_start:
    b       main
    
.section .text


main:
    bl	InstallIntTable			// set the stack pointer and install
									// interrup table
	

	bl	EnableJTAG 				// Enable JTAG
	
	bl	InitFrameBuffer			// initialize frame buffer
	bl	init_menu				// initialize game menu
	bl	mSelect					// select option from menu

	ldr	r0, =endGame			// get end game code in r1
	ldr	r1, [r0]				
	mov	r2, #0					// clear the game code in memory
	str	r2, [r0]				
	cmp	r1, #2					// if code = 2, quit game
	beq	end						// by branchingto end

	
gameStart:
	bl 	interruptSetUp		// reset value pack

	bl	gameLoop			// go into game loop

	ldr	r0, =endGame		// get end game code in r1
	ldr	r1, [r0]			
	mov	r2, #0				// clear the game code in memory
	str	r2, [r0]
	cmp	r1, #2			// if code = 2, quit current game and go back to
	beq	main			// main menu
readButtons:

	ldr	r3, =0x249F0	// set wait time
	bl	Wait			// wait for a button to be pressed
	bl	Read_SNES		// read from SNES, r0 contains buttons stored
	ldr	r1, =0xFFFFFFFF	// toggle bits for easy reading
	eor	r0, r1
	
	ldr	r1, =0xFFF0		// check if any buttons pressed
	ands	r1, r0
	beq	readButtons		// if no button pressed, check again
	b	main			// if button pressed, go back to main menu


	b	haltLoop$		// go to haltLoop$

end:
	bl	drawMenuBck		// draw empty screen if user quits from main menu
haltLoop$:
	b	haltLoop$


// Subroutine for game loop
gameLoop:
	push {r4-r9, lr}		

restartGameIteration:

	ldr 	r3, =200000		// wait a bit before starting game
	bl 	Wait
	
	bl	printSL				// print score and lives

	ldr	r2, =direction		// reset snake direction
	mov	r1, #8
	str	r1, [r2]


	ldr	r1, =snakeLen		// get the snake length
	ldr	r0, [r1]
	ldr	r2, =direction		// and direction
	ldr	r1, [r2]
	bl	drawSnake			// draw the snake in initial position

	ldr	r0, =appleCount
	ldr	r0, [r0]		// r0 = appleCount
	cmp	r0, #2			// if only 0 or 1 apples eaten
	bllt	drawApple	// draw the apple

stateLoop:
	bl	getDirection		//get the direction the user wants the snake to go from the Snes
	ldr	r1, =direction
	ldr	r4, [r1]		//check that the direction pressed is not directly opposed to current
	cmp	r4, #8			// if direction right
	cmpeq	r0, #9		// and user presses left, do not update direction
	beq	notOposite		
	cmp	r4,#9			// if direction left
	cmpeq	r0,#8		// and user presses right, do not update direction
	beq	notOposite
	cmp	r4, #10			// if direction down
	cmpeq	r0, #11		// and user presses up, do not update direction
	beq	notOposite
	cmp	r4, #11			// if direction up
	cmpeq	r0, #10		// and user presses down, do not update direction
	beq	notOposite

	cmp	r0, #12			// check if start button
	bne	continueGameLoop	// if not start button, check if anything was pressed
	bleq	pauseMenu		// otherwise draw pause menu, return in r1
// 0 - restart
// 1 - quit
// 2 - resume
isPause:
	cmp	r1, #0				// if game restart
	bleq	resetGame		// reset the game
	
	ldreq	r2, =endGame
	moveq	r3, #0			// store reset code
	streq	r3, [r2]
	bleq 	interruptSetUp		// reset value pack

	beq	restartGameIteration	// restart the game
	
shouldQuit:
	cmp	r1, #1				// if quit game
	ldreq	r2, =endGame
	moveq	r3, #2
	streq	r3, [r2]		// store quit value in endGame
	beq	finish			// go to end of game loop
	

	cmp	r1, #2			// if resume game
	bleq	init_map		// redraw map
	bleq	printSL			// reprint SL
	bleq	drawApple		// redraw apple
	bleq	drawValuePack	// redraw value pack
	beq	toUpdate			// go right to updating the snake
	
	mov	r0, #0			// no directional changes in snake

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
	bl	resetSnake		// otherwise reset the snake
	
	ldr	r0, =lives		// get lives
	ldr	r1, [r0]
	sub	r1, #1			// decrease # lives
	str	r1, [r0]		// store back
	cmp	r1, #0			// if lives are now 0
isLose:
	ldreq	r0, =endGame
	moveq	r9, #3
	streq	r9, [r0]	// set and store death in end game
	mov	r0, #3			// set lose code
	
	bleq	drawWLP		// draw lose message
	ble	finish			// end game loop
	b	restartGameIteration		// otherwise restart game loop
	
wait:
	ldr	r0, =endGame		// check if game is won
	ldr	r9, [r0]
	cmp	r9, #1
	bne	nextTurn		// if not 1, then game is not yet won
						// go to nextTurn
isWin:	
	moveq	r0, #1			// set win code
	bleq	drawWLP			// draw win message
	beq	finish				// finish game
nextTurn:
	ldr	r0, =Speed			// load speed
checkSpeed:
	ldr	r3, [r0]			// wait speed duration to draw next snake
	bl 	Wait

	b 	stateLoop		// loop back
finish:	
	pop {r4-r9, lr}	
	mov	pc, lr

// subroutine to reset snake
resetSnake:
	push	{r4-r9,lr}

	mov	r0, #8				// reset directoin
	ldr	r1, =direction
	str	r0, [r1]

	bl	clearSnakeBody		// clear the snake body

	pop	{r4-r9,lr}
	mov	pc,lr


// subroutine to initialize game map
init_map:
	push {lr}
	bl	drawGameBck		// draw game background
	bl	drawWall		// draw walls
	bl	putTiles		// draw bricks

	pop {lr}
	mov	pc,lr

//subroutine to init menu
init_menu:
	push 	{lr}
	bl	drawMenuBck		// draw menu background
	bl	printMenu		// print menu
	mov	r0, #0			
	bl	drawStart		// draw starting position of pointer
	pop 	{lr}
	mov 	pc,lr

// subroutine to answer the menu pausing
// return value in r1
pauseMenu:
	push	{r4-r9,lr}
	mov	r0, #2		// draw pause menu
	bl	drawWLP

	mov	r0, #1
	bl	drawStart	// draw starting position of pointer
	mov	r5, #0		// r5 is code for restart, quit or resume

	ldr 	r3, =100000		// wait a bit
	bl 	Wait
	

selectFromPause:
	mov	r0, #1		// code for pause menu
	bl	selectMenu	// see if there's any buttons pressed
					// r0 contains return value
	mov	r4, r0		// copy r0 into r4

	cmp	r4, #11			// if up
	moveq	r0, #1
	bleq	drawStart	// draw pointer up
	moveq	r5, #0		// if r5 = 0 then we're on restart
	beq	selectFromPause	// check buttons again

	cmp	r4, #10			// if down
	moveq	r0, #1
	bleq	drawQuit	// draw pointer down
	moveq	r5, #1		// if r5 = 1 then we're on quit
	beq	selectFromPause

	cmp	r4, #7		// if A
	moveq	r1, r5	// move code into r1
	beq	breakForP	// go to end

	cmp	r4, #12		// if start button pressed
	moveq	r1, #2	// r1 = 2 if resume
	beq	breakForP	// go to end

	b	selectFromPause	// if none of start, up, down or up pressed
					// select from menu again

	
breakForP:
	pop	{r4-r9,lr}
	mov	pc,lr



// subroutine to select from menu
mSelect:
	push {r4-r5,lr}
	bl	init_GPIO	// initiate gpio
	mov	r5, #0		// set starting code in r5 to start game
mSelect2:
	mov	r0, #0		// set starting code in r0
	bl	selectMenu	// see if there's any buttons pressed
					// r0 contains return value
	mov	r4, r0		// copy r0 into r4
	cmp	r4, #0		// nothing pressed
	beq	mSelect2


	cmp	r4, #11		// if up
	moveq	r0, #0	// draw pointer up
	bleq	drawStart
	moveq	r5, #0	// set code start game
	beq	mSelect2	// check buttons again


	cmp	r4, #10		// if down
	moveq	r0, #0	// draw pointer down
	bleq	drawQuit	
	moveq	r5, #1	// set code quit game
	beq	mSelect2	// check buttons again

	cmp	r4, #7		// if A
	bne	mSelect2	// if none of up, down or A, select from Menu again
	cmpeq	r5, #0	// if A then check value of r5
						// if r5 = 0
	bleq	resetGame	// start a new game
	ldr	r0, =endGame	// quit game value
	moveq	r1, #4		// start game = 4
						// else set quit game value
	movne	r1, #2		// end game = 2
	str	r1, [r0]		// store updated end game value
	
endMenuSelect:	
	pop {r4-r5,lr}
	mov	pc,lr

// subroutine to reset the game
resetGame:
	push	{r4-r9,lr}
	
	ldr	r4, =score		// reset score to 0
	mov	r5, #0
	str	r5, [r4]
	ldr	r4, =appleCount		// reset apple count to 0
	str	r5, [r4]	

	ldr	r4, =lives		// reset lives to 5
	mov	r6, #5
	str	r6, [r4]
	
	mov	r6, #3
	ldr	r4, =snakeLen		// reset length to 3
	str	r6, [r4]

	ldr	r4, =Speed		// reset speed
	ldr	r5, =120000
	str	r5, [r4]		

	bl	init_map		// reinitiate the map

	bl	clearSnakeBody	// clear snake off map

	pop	{r4-r9,lr}
	mov	pc,lr



.section .data  


FrameBufferPointer:
	.int 0
	

.align 4
// addresses for score, lives, snakeLength and direction
.globl score
score:	.int	0
.globl lives
lives:	.int	5

.globl	snakeLen
snakeLen: .int	3
// directions based on button number for up down left right
direction: .int 8



