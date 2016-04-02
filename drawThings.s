.section .text


// subroutine to draw the background color
// starting from bottom to top
// r2 is the color to draw
.globl	drawBackground
drawBackground:
	push {r4, lr}			// push

	ldr		r0, =1023		// r0 = max width
	mov		r1, #768		// r1 = max length

	mov		r4, #768		// r4 = 768

drawBckVert:
	ldr		r3, =1023		// r3 = 1023

drawBckHorz:	
	bl		DrawPixel		// draw the pixel color
	subs		r0, r3, #1	// move to next horz pixel
	subs		r3, r3, #1	// update horz
	bge		drawBckHorz		// loop back to draw next horz pixel

	subs		r1, r4, #1	// move to next vert pixel
	subs		r4, r4, #1	// update vert
	bge		drawBckVert		// loop back to draw next vert pixel

	pop {r4, lr}			// pop
	mov	pc, lr				// return

// subroutine to draw the game background
.globl drawGameBck
drawGameBck:
	push	{lr}
	ldr	r2, =0xA098			// set color in r2
	bl	drawBackground		// draw the background

	pop	{lr}
	mov	pc,lr

// subroutine to draw the menu background
.globl drawMenuBck
drawMenuBck:
	push	{lr}
	ldr	r2, =0x0000			// set the color in r2
	bl	drawBackground		// draw the background

	pop	{lr}
	mov	pc,lr



// subroutine to put the random tiles on the game board
.globl putTiles
putTiles:

	push {r4, r5, r6, lr}

						// draw 5 vert tiles
	ldr	r4, =352		// to change the y
	mov	r5, #5			// set counter = 5
loop5:
	ldr	r0, =384		// starting x value
	mov	r1, r4			// set y value
	mov	r2, #0			// set tile code
	mov	r3, #32			// set tile size
	bl	drawTile		// draw tile
	add	r4, #32			// move to next right cell
	subs	r5, #1		// dec counter
	bne	loop5			// loop back if counter > 0

	
	ldr	r4, =192	// to change the x
	mov	r5, #7		// set the counter = 7
loop7:
	mov	r0, r4		// starting x value
	ldr	r1, =608	// set y value
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile
	add	r4, #64		// move to every other cell to the right
	subs	r5, #1	// dec counter
	bne	loop7		// loop back if counter > 0

// y is 352 for the top
// x is 640 for the left

	ldr	r4, =640	// to change the x
	mov	r5, #4		// set counter
make4:
	mov	r0, r4		// set x value
	ldr	r1, =352	// set y value
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile
	add	r4, #32		// move to next cell
	subs	r5, #1	// dec counter
	bne	make4		// loop again if counter > 0

	ldr	r0, =640	// set x value
	ldr	r1, =384	// set y value
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile

	ldr	r0, =736	// set x value
	ldr	r1, =384	// set y value	
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile

	ldr	r0, =672	// set x value
	ldr	r1, =448	// set y value	
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile

	ldr	r0, =704	// set x value 
	ldr	r1, =448	// set y value
	mov	r2, #0		// set tile code
	mov	r3, #32		// set tile size
	bl	drawTile	// draw tile

	pop {r4, r5, r6, lr}
	mov	pc,lr


// subroutine to draw the walls
.globl	drawWall
drawWall:
	push {r4, r5, lr}

// changing y using r1 to draw the vertical walls
	ldr	r1, =64		// initial y value
	mov	r4, r1		// counter for y
drawVertWall:
	mov	r0, #0		// set x value
	mov	r2, #1		// set wall code
	mov	r3, #64		// set wall cell size
	bl	drawTile	// draw tile

	ldr	r0, =960	// set x value
	mov	r1, r4		// reload r4 into r1
	mov	r2, #1		// set wall code
	mov	r3, #64		// set cell size
	bl	drawTile	// draw tile

	add	r1, r4, #64	// move to next cell down
	mov	r4, r1		// copy r1 into r4
	cmp	r4, #704	// if not yet hit the bottom of the screen
	ble	drawVertWall		// loop back


// changing x value to draw horizontal walls
	mov	r0, #64		// set x value
	mov	r4, r0		// r4 is copy of r0
drawHorzWall:
	ldr	r1, =64		// y position
	mov	r2, #1		// set wall code
	mov	r3, #64		// size of image
	bl	drawTile	// draw tile

	mov	r0, r4		// reload r4 into r0
	ldr	r1, =704	// set y value
	mov	r2, #1		// set wall code
	mov	r3, #64		// size of image
	bl	drawTile	// draw tile

	add	r0, r4, #64	// move to next cell right
	mov	r4, r0		// copy r0 into r4
	ldr	r5, =959	// if not yet hit the right of the screen
	cmp	r4, r5		// loop back
	ble	drawHorzWall

	pop {r4, r5, lr}
	mov	pc,lr

// subroutine to draw pointer for menu selection
// r0 = 0 main menu
// r0 = 1 pause menu
.globl drawStart
drawStart:
	push {r4-r9,lr}

	cmp	r0, #0				// if pause menu, go to
	bne	drawPauseStart		// drawPauseStart

	ldr	r0, =420			// set x value
	ldr	r1, =352			// set y value
	mov	r2, #7				// set pointer code
	mov	r3, #16				// set image size
	bl	drawTile			// draw pointer image

	ldr	r0, =420			// set x value
	ldr	r1, =384			// set y value
	mov	r2, #0				// set erase code
	mov	r3, #16				// set image size
	bl	eraseTile			// erase the old pointer location
	b	rDrawStart			// branch to end

drawPauseStart:
	ldr	r0, =420		// set x value
	ldr	r1, =330		// set y value
	mov	r2, #7			// set pointer code
	mov	r3, #16			// set image size
	bl	drawTile		// draw pointer

	ldr	r0, =420		// set x value
	ldr	r1, =388		// set y value
	mov	r2, #0			// set erase code
	mov	r3, #16			// set image size
	bl	eraseTile		// erase old pointer location

rDrawStart:
	pop {r4-r9,lr}
	mov	pc,lr

// subroutine to draw pointer for menu
// r0 = 0 main menu
// r0 = 1 pause menu
.globl drawQuit
drawQuit:
	push {r4-r9,lr}

	cmp	r0, #0			// if pause menu, branch to
	bne	drawPauseQuit	// drawPauseQuit

	ldr	r0, =420		// set x
	ldr	r1, =384		// set y
	mov	r2, #7			// set pointer code
	mov	r3, #16			// set image size
	bl	drawTile		// draw pointer

	ldr	r0, =420		// set x
	ldr	r1, =352		// set y
	mov	r2, #0			// set erase code
	mov	r3, #16			// set image size
	bl	eraseTile		// erase pointer
	b	rDrawQuit		// branch to end

drawPauseQuit:
	ldr	r0, =420		// set x
	ldr	r1, =388		// set y
	mov	r2, #7			// set pointer code
	mov	r3, #16			// set image size
	bl	drawTile		// draw pointer

	ldr	r0, =420		// set x
	ldr	r1, =330		// set y
	mov	r2, #0			// set erase code
	mov	r3, #16			// set image size
	bl	eraseTile		// erase pointer

rDrawQuit:
	pop {r4-r9,lr}
	mov	pc,lr


// subroutine to erase a tile
.globl eraseTile
// r0 is the x top left corner
// r1 is the y top left corner
// r2 color to replace
// r3 size of tile
eraseTile:
	push {r4-r9,lr}

// r6 is a copy of r0
// r7 is a copy of r1
	mov	r6, r0		
	mov	r7, r1

	// copy r2 into r5
	mov	r5, r2

// r8 = r0 + r3
// r9 = r1 + r3
	add	r8, r0, r3
	add	r9, r1, r3
	mov	r4, r7		// counter for y

eraseTileVert:
	mov	r3, r6		// counter for x
	mov	r0, r6		// reset x

eraseTileHorz:	
	mov		r2, r5		// get pixel color
	bl		DrawPixel	// draw pixel
	add		r0, r3, #1	// x = x+1
	add		r3, r3, #1	// inc x counter
	cmp		r3, r8		// if <32 px across 
	blt		eraseTileHorz	// loop back

	add		r1, r4, #1	// y = y + 1
	add		r4, r4, #1	// inc y counter
	cmp		r4, r9		// if < 32px down
	blt		eraseTileVert	// loop back

	pop {r4-r9,lr}
	mov	pc,lr


.globl drawSnake
// r0 is length of Snake
// r1 is direction of snake
drawSnake:
	push {r4-r10,lr}
	mov	r9, r0		// r9 = length of snake
	mov	r8, r1		// r8 = direction of snake
	
	ldr	r4, =64		//x of tail
	ldr	r5, =288	//y of tail

	mov	r0, r4		// set x
	mov	r1, r5		// set y
	mov	r2, #4		// draw tail
	mov	r3, #32		// image size
	bl	drawTile	// draw cell

	sub	r9, #1		// offset for tail
	

	ldr	r6, =snakePosition	// store the x and y coor of Snake tail in order at end of array
	lsl	r10, r9, #3		// r10 = length of snake * 4
	add	r6, r10			// move to next position
	str	r0, [r6], #4	// store snake position x
	str	r1, [r6], #4	// store snake position y

	sub	r9, #1		// discount tail
	add	r4, #32		// just add to x for now

//draw body
loopBody:
	
	mov	r0, r4		// get x
	mov	r1, r5		// get y
	mov	r2, #3		// draw body
	mov	r3, #32
	bl	drawTile
	
	ldr	r6, =snakePosition	//store x and y coor of snake body in order at ofset r9*4
	lsl	r10, r9, #3		// counter * 8
	add	r6, r10			// to move to next location in array
	str	r0, [r6], #4	// store snake position x
	str	r1, [r6], #4	// store snake position y
	
	add	r4, #32		// go to next x
	sub	r9, #1		// dec body length
	cmp	r9, #1		// check if counter == 1
	bge	loopBody

	mov	r0, r4		// copy x into r0
	mov	r1, r5		// copy y into r1

	cmp	r8, #9		// if direction is right
	moveq	r2, #2	// draw head right
	cmp	r8, #10		// if direction is left
	moveq	r2, #-2	// draw head left
	mov	r3, #32		// image size
	bl	drawTile

	ldr	r6, =snakePosition	//Store Head x and y coor at start of array
	lsl	r10, r9, #3			// counter * 8
	add	r3, r10				// to move to next location in array
	str	r0, [r6], #4		// store snake position x
	str	r1, [r6]			// store snake position y

	pop {r4-r10,lr}
	mov	pc,lr


.globl updateSnake
// r0 is length of snake
// r1 is directon of snake

updateSnake:
	push {r4-r9, lr}
	mov	r9, r0		//get length
	mov	r8, r1		//get direction
	ldr	r4, =snakePosition
	ldr	r5, =snakePosition
	ldr	r0, [r4], #4	// head x
	ldr	r1, [r4], #4	// head  y
	mov	r6, r0		//copy x location of head
	mov	r7, r1		// copy y location of head


	cmp	r8, #8		//move right
	moveq	r2, #2	// set head right
	addeq	r0, #32	// update x

	cmp	r8, #9		//move left
	moveq	r2, #-2	// set head left
	subeq	r0, #32		// update x

	cmp	r8, #10		//move down
	moveq	r2, #2	
	addeq	r1, #32	// update y

	cmp	r8, #11		//move up
	moveq	r2, #2
	subeq	r1, #32	// update y

	ldr	r3, =HeadDest	// save head destination
	str	r0, [r3], #4	
	str	r1, [r3]

	ldr	r3, =HeadDir	// save head direction
	str	r2, [r3]

// check death status of snake
	bl	checkDeath	// check if snake has died

	cmp	r0, #-1			// if r0 = -1, snake is dead
	moveq	r1, r9		// get snake length
	bleq	clearSnake	// clear snake off screen
	moveq	r0, #-1		// move -1 back into r0
	beq	returnUpdate	// if dead, return

// check if Value pack to be eaten
// value returned in r0
	bl	checkValuePack
	cmp	r0, #0		// if value pack eaten
	ldreq	r0, =Speed	// inc speed
	ldreq	r1, =60000	
	streq	r1, [r0]	// store speed in memory

// check if apple to be eaten

	bl	checkApple
	cmp	r0, #0		// if apple, then 0
	bne	drawUsual	// if no apple eaten, redraw snake as usual
					// if apple eaten
	bl	incLength	// increase snake length, update score and apple count
	ldr	r0, =appleCount
	ldr	r1, [r0]	// r0 = appleCount

	cmp	r1, #20		
	blt	nextApple	// if not yet eaten 20 apples, draw another
	beq	nextDoor	// if 20 apples eaten, draw a door
	bgt	nextWin		// if gone through door, win game

nextDoor:
	mov	r0, #0		// draw the door like an apple
	bl	getRand		// randomize
	bl	drawDoor
	b	drawUsual

nextWin:
	bl	storeWin	// store the win code
	b	drawUsual

nextApple:
	mov	r0, #0		// drawing an apple
	bl	getRand		// randomize
	bl	drawApple	// draw next apple
	
drawUsual:
	ldr	r3, =HeadDest	// load head destination
	ldr	r0, [r3], #4	
	ldr	r1, [r3]

	ldr	r3, =HeadDir	// load head direction
	ldr	r2, [r3]
	
	mov	r3, #32		// cell size
	
	bl	drawTile	// redraw head
	str	r0, [r5], #4
	str	r1, [r5], #4


	ldr	r3, =snakeLen	// r3 = snake length
	ldr	r9, [r3]
	sub	r9, #1			// dec length
reDrawBody:
	mov	r0, r6		// x
	mov	r1, r7		// y
	
	mov	r2, #3
	mov	r3, #32		//draw body piece
	bl	drawTile
	ldr	r6, [r4],#4		// get next body position
	ldr	r7, [r4],#4		// in r6, r7
	str	r0,[r5],#4		// update body position 
	str	r1,[r5],#4		// in snake position array

	sub	r9, #1		// dec body length
	cmp	r9, #1		// if not yet at tail
	bne	reDrawBody	// redraw body
	
	
	mov	r0, r6		// x
	mov	r1, r7		// y
	mov	r2, #4		// draw tail
	mov	r3, #32
	bl	drawTile
	
	ldr	r6, [r4],#4		// r6,r7 is previous tail location
	ldr	r7, [r4],#4
	str	r0,[r5],#4		// r0, r1 is updated tail location
	str	r1,[r5],#4		// update tail in snake position array

	mov	r0, r6			// copy r6, r7 to r0,r1
	mov	r1,r7
	ldr	r2, =0xA098		//erase previous tail
	mov	r3, #32
	bl	eraseTile
	
returnUpdate:
	pop {r4-r9, lr}
	mov	pc, lr


// subroutine to clear the snake off the screen
clearSnake:
	push	{r4-r9,lr}
	
	ldr	r4, =snakeLen
	ldr	r9, [r4]		// r9 is length of snake
	
	ldr	r4, =snakePosition		// r4 is snake position
	mov	r5, #0
clearLoop:
	ldr	r0, [r4]			// snake x
	ldr	r1, [r4, #4]		// snake y
	ldr	r2, =0xA098			// load background color
	mov	r3, #32
	bl	eraseTile			// erase snake cell
	
	str	r5, [r4], #4	// clear x in array
	str	r5, [r4], #4	// clear y in array

	subs	r9, #1		// dec length
	bne	clearLoop		// loop back until snake all cleared
	
	pop	{r4-r9,lr}
	mov	pc,lr

// subroutine to store the win code
.globl	storeWin
storeWin:
	push	{r4-r9, lr}

	ldr	r4, =endGame		
	mov	r5, #1			// r1 = 1 = win code
	str	r5, [r4]		// store win code

	pop	{r4-r9,lr}
	mov	pc,lr


// subroutineto draw the apple
.globl	drawApple
drawApple:

	push	{r4-r9,lr}

	ldr	r4, =applePosition	
	ldr	r0, [r4], #4		// apple x
	ldr	r1, [r4]			// apple y
	mov	r2, #5				// set apple code
	mov	r3, #32
	bl	drawTile			// draw apple

	pop	{r4-r9,lr}
	mov	pc,lr



// subroutine to draw the win, lose or pause screens
.globl	drawWLP
drawWLP:
	push	{r4-r9,lr}

// r0 is a code for the image
// 1 is win
// 2 is pause
// 3 is lose
// r9 is the address of the image
	cmp	r0, #1
	ldreq	r9, =Win
	cmp	r0, #2
	ldreq	r9, =Pause
	cmp	r0, #3
	ldreq	r9, =Lose

	ldr	r8, =480	// starting x
	
	ldr	r5, =204	// starting y

drawWLPVert:
	ldr	r4, =272	// reset x
	mov	r6, #0		// reset x counter


drawWLPHorz:
	mov	r0, r4		// copy x
	mov	r1, r5		// copy y
	ldrh	r2, [r9], #2	// get pixel color
	bl	DrawPixel

	add	r4, #1		// x = x+1
	add	r6, r6, #1	// inc x counter
	cmp	r6, r8		// if <480 px across 
	blt	drawWLPHorz	// loop back

	add	r5, #1		// move to next line of image
	ldr	r0, =457	// if not at end of image
	cmp	r5, r0		// loop back
	blt	drawWLPVert

	pop	{r4-r9,lr}

	mov	pc,lr

// subroutine to draw the value pack
.globl	drawValuePack
drawValuePack:
	push	{r4-r9,lr}
	
	
	ldr	r3, =VPPosition
	ldr	r0, [r3], #4		// r0 is value pack x
	ldr	r1, [r3]			// r1 is value pack y
	cmp	r0, #0		// if value pack already eaten,
	beq	endDrawVP	// don't draw again
	
	mov	r2, #10		// r2 = value pack
	mov	r3, #32		// size of tile
	bl	drawTile	// draw value pack
endDrawVP:
	pop	{r4-r9,lr}
	mov	pc,lr

	
// subroutine to draw the door
.globl	drawDoor
drawDoor:

	push	{r4-r9,lr}
	
	ldr	r4, =applePosition
	ldr	r0, [r4], #4		// door x
	ldr	r1, [r4]			// door y
	mov	r2, #6				// door code
	mov	r3, #32
	bl	drawTile			// draw door
	
	pop	{r4-r9,lr}
	mov	pc,lr

.globl	drawTile
// r0 is the x top left corner
// r1 is the y top left corner
// r2 int representing tile image to be displayed
// r3 size of tile
drawTile:
	push {r4-r9, lr}
// 0 - Brick
// 1 - Wall
// 2 - Snake headR
// -2 - Snake headL
// 3 - Snake body
// 4 - Snake tail
// 5 - Apple
// 6 - Door
// 7 - Pointer
// 10 - Value Pack

// r5 is address of image to draw
	cmp	r2, #0
	ldreq	r5, =Brick

	cmp	r2, #1
	ldreq	r5, =Hedgehog

	cmp	r2, #2
	ldreq	r5, =HeadR

	cmp	r2, #-2
	ldreq	r5, =HeadL

	cmp	r2, #3
	ldreq	r5, =Cat2

	cmp	r2, #4
	ldreq	r5, =Cat1

	cmp	r2, #5
	ldreq	r5, =Apple

	cmp	r2, #6
	ldreq	r5, =Door

	cmp	r2, #7
	ldreq	r5, =Duck

	cmp	r2, #10
	ldreq	r5, =Cake
	

// r6 is a copy of r0
// r7 is a copy of r1
	mov	r6, r0		
	mov	r7, r1

// r8 = r0 + r3
// r9 = r1 + r3
	add	r8, r0, r3
	add	r9, r1, r3
	mov	r4, r7		// counter for y

drawTileVert:
	mov	r3, r6		// counter for x
	mov	r0, r6		// reset x

drawTileHorz:	
	ldrh		r2, [r5], #2	// get pixel color


	bl		DrawPixel
	add		r0, r3, #1	// x = x+1
	add		r3, r3, #1	// inc x counter
	cmp		r3, r8		// if <32 px across 
	blt		drawTileHorz	// loop back

	add		r1, r4, #1	// y = y + 1
	add		r4, r4, #1	// inc y counter
	cmp		r4, r9		// if < 32px down
	blt		drawTileVert	// loop back


	mov		r0, r6		//return location of the tile
	mov		r1, r7
	pop {r4-r9, lr}
	mov	pc, lr
		




/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
.globl DrawPixel
DrawPixel:
	push	{r4}
	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr


.section .data

.align 4
font:		.incbin	"font.bin"



