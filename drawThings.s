
    
.section .text


// subroutine to draw the background color
.globl	drawBackground
drawBackground:
	push {r4, lr}

	ldr		r0, =1023
	mov		r1, #768

	mov		r4, #768

drawBckVert:
	ldr		r3, =1023

drawBckHorz:	
	bl		DrawPixel
	subs		r0, r3, #1
	subs		r3, r3, #1
	bge		drawBckHorz

	subs		r1, r4, #1
	subs		r4, r4, #1
	bge		drawBckVert	

	pop {r4, lr}
	mov	pc, lr

.globl drawGameBck
drawGameBck:
	push	{lr}
	ldr	r2, =0xA098
	bl	drawBackground

	pop	{lr}
	mov	pc,lr

.globl drawMenuBck
drawMenuBck:
	push	{lr}
	ldr	r2, =0x0000
	bl	drawBackground

	pop	{lr}
	mov	pc,lr



// subroutine to put the random tiles
.globl putTiles
putTiles:

	push {r4, r5, r6, lr}

	// draw 5 vert tiles
	ldr	r4, =352	//to change the y
	mov	r5, #5
loop5:
	ldr	r0, =384
	mov	r1, r4		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile
	add	r4, #32
	subs	r5, #1
	bne	loop5

	
	ldr	r4, =192	// to change the x
	mov	r5, #7
loop7:
	mov	r0, r4
	ldr	r1, =608		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile
	add	r4, #64
	subs	r5, #1
	bne	loop7

// y is 352 for the top
// x is 640 for the left

	ldr	r4, =640	// to change the x
	mov	r5, #4
make4:
	mov	r0, r4
	ldr	r1, =352		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile
	add	r4, #32
	subs	r5, #1
	bne	make4

	ldr	r0, =640
	ldr	r1, =384		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile

	ldr	r0, =736
	ldr	r1, =384		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile

	ldr	r0, =672
	ldr	r1, =448		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile

	ldr	r0, =704
	ldr	r1, =448		
	mov	r2, #0
	mov	r3, #32
	bl	drawTile



	pop {r4, r5, r6, lr}
	mov	pc,lr


// subroutine to draw the walls
.globl	drawWall
drawWall:
	push {r4, r5, lr}

// changing y -> r1
	ldr	r1, =192
	mov	r4, r1		// counter for y
drawVertWall:
	mov	r0, #0
	mov	r2, #1
	mov	r3, #64
	bl	drawTile

	ldr	r0, =960
	mov	r1, r4		// reload r4 into r1
	mov	r2, #1
	mov	r3, #64
	bl	drawTile

	add	r1, r4, #64
	mov	r4, r1		// copy r1 into r4
	cmp	r4, #704
	ble	drawVertWall



	mov	r0, #64
	mov	r4, r0		// r4 is copy of r0
drawHorzWall:
	ldr	r1, =192	// y position
	mov	r2, #1		// draw wall
	mov	r3, #64		// size of image
	bl	drawTile

	mov	r0, r4
	ldr	r1, =704		// reload r4 into r1
	mov	r2, #1
	mov	r3, #64
	bl	drawTile

	add	r0, r4, #64
	mov	r4, r0		// copy r0 into r4
	ldr	r5, =959
	cmp	r4, r5
	ble	drawHorzWall

	pop {r4, r5, lr}
	mov	pc,lr

// subroutine to draw pointer for menu
.globl drawStart
drawStart:
	push {r4-r9,lr}

	ldr	r0, =420
	ldr	r1, =352
	mov	r2, #7
	mov	r3, #16
	bl	drawTile

	ldr	r0, =420
	ldr	r1, =384
	mov	r2, #0
	mov	r3, #16
	bl	eraseTile

	pop {r4-r9,lr}
	mov	pc,lr

// subroutine to draw pointer for menu
.globl drawQuit
drawQuit:
	push {r4-r9,lr}

	ldr	r0, =420
	ldr	r1, =384
	mov	r2, #7
	mov	r3, #16
	bl	drawTile

	ldr	r0, =420
	ldr	r1, =352
	mov	r2, #0
	mov	r3, #16
	bl	eraseTile

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
	bl		DrawPixel
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
	
	ldr	r4, =160	//x of tail
	ldr	r5, =288	//y of tail

	mov	r0, r4		// set x
	mov	r1, r5		// set y
	mov	r2, #4		// draw tail
	mov	r3, #32
	bl	drawTile

	sub	r9, #1		// offset for tail
	

	ldr	r6, =snakePosition	// store the x and y coor of Snake tail in order at end of array
	lsl	r10, r9, #3		// r10 = length of snake * 4
	add	r6, r10
	str	r0, [r6], #4		
	str	r1, [r6], #4

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
	lsl	r10, r9, #3
	add	r6, r10
	str	r0, [r6], #4
	str	r1, [r6], #4
	
	add	r4, #32		// go to next x
	sub	r9, #1		// dec body length
	cmp	r9, #1
	bge	loopBody

	mov	r0, r4
	mov	r1, r5

	cmp	r8, #9
	moveq	r2, #2
	cmp	r8, #10
	moveq	r2, #-2
	mov	r3, #32
	bl	drawTile

	ldr	r6, =snakePosition	//Store Head x and y coor at start of array
	lsl	r10, r9, #3
	add	r3, r10
	str	r0, [r6], #4
	str	r1, [r6]

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
	moveq	r2, #2
	addeq	r0, #32

	cmp	r8, #9		//move left
	moveq	r2, #-2
	subeq	r0, #32	

	cmp	r8, #10		//move down
	moveq	r2, #2
	addeq	r1, #32

	cmp	r8, #11		//move up
	moveq	r2, #2
	subeq	r1, #32

	bl	checkDeath	// check if snake has died
	cmp	r0, #-1
	moveq	r1, r9		// get snake length
	bleq	clearSnake
	moveq	r0, #-1		// move -1 back into r0
	beq	returnUpdate	// if dead, return

	mov	r3, #32
	
	bl	drawTile	// redraw head
	str	r0, [r5], #4
	str	r1, [r5], #4
	sub	r9, #1
reDrawBody:
	mov	r0, r6		// x
	mov	r1, r7		// y
	
	mov	r2, #3
	mov	r3, #32		//draw body piece
	bl	drawTile
	ldr	r6, [r4],#4
	ldr	r7, [r4],#4
	str	r0,[r5],#4
	str	r1,[r5],#4

	sub	r9, #1		// dec body length
	cmp	r9, #1



	bne	reDrawBody
	mov	r0, r6
	mov	r1,r7
	mov	r2, #4		// draw tail
	mov	r3, #32
	bl	drawTile
	
	ldr	r6, [r4],#4
	ldr	r7, [r4],#4
	str	r0,[r5],#4
	str	r1,[r5],#4

	mov	r0, r6
	mov	r1,r7
	ldr	r2, =0xA098		//erase previous tail
	mov	r3, #32
	bl	eraseTile
	
returnUpdate:
	pop {r4-r9, lr}
	mov	pc, lr



clearSnake:

	push	{r4-r9,lr}
	// r1 contains length of snake
	mov	r9, r1		// r9 is length of snake
	
	ldr	r4, =snakePosition
	mov	r5, #0
clearLoop:
	ldr	r0, [r4]
	ldr	r1, [r4, #4]
	ldr	r2, =0xA098
	mov	r3, #32
	bl	eraseTile
	
	str	r5, [r4], #4	// clear x
	str	r5, [r4], #4	// clear y

	subs	r9, #1		// dec length
	bne	clearLoop

	pop	{r4-r9,lr}
	mov	pc,lr


.globl	drawApple
drawApple:

	push	{r4-r9,lr}

	bl	getRand
	mov	r2, #5
	mov	r3, #32
	bl	drawTile

	pop	{r4-r9,lr}
	mov	pc,lr

.globl	clearSL
// subroutine to clear the lives text

clearSL:
	push	{r4-r9,lr}
	ldr	r4, =320	// starting x coor
	ldr	r5, =630	// ending x coor

clearSLLoop:
	mov	r0, r4
	mov	r1, #70		// y coor
	ldr	r2, =0xA098	// magenta
	mov	r3, #32		// size of tile
	bl	eraseTile

	add	r4, #32

	cmp	r4, r5		// check if end of lives
	blt	clearSLLoop

	pop	{r4-r9,lr}
	mov	pc,lr

/*
.globl	drawLose
drawLose:
	push	{r4-r9,lr}

	bl	drawMenuBck
	ldr	r0, =272
	ldr	r1, =204
	mov	r2, #8
	ldr	r3, =350
	bl	drawTile

	pop	{r4-r9,lr}

	mov	pc,lr
*/


.globl	drawTile
// r0 is the x top left corner
// r1 is the y top left corner
// r2 int representing tile image to be displayed
// r3 size of tile
drawTile:
	push {r4, r5, r6, r7, r8, r9, r10, lr}
// 0 - Brick
// 1 - Wall
// 2 - Snake headR
// -2 - Snake headL
// 3 - Snake body
// 4 - Snake tail
// 5 - Apple
// 6 - Door
// 7 - Pointer
// 8 - Game Lost

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

	cmp	r2, #7
	ldreq	r5, =Duck

//	cmp	r2, #8
//	ldreq	r5, =Lost




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
	pop {r4, r5, r6, r7, r8, r9, r10, lr}
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



