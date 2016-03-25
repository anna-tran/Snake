
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

	ldr	r1, =snakeLen
	ldr	r0, [r1]
	ldr	r2, =direction
	ldr	r1, [r2]
	bl	drawSnake

	b	haltLoop$


end:
	bl	drawMenuBck
haltLoop$:
	b	haltLoop$


// subroutine to initialize game map
init_map:
	push {lr}
	bl	drawGameBck
	bl	drawWall
	bl	putTiles

	ldr	r0, =score
	ldr	r0, [r0]
	ldr	r1, =lives
	ldr	r1, [r1]
	bl	printSL
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
	
// all num are 1 less than their actual bound
// if snake destined to go further than the bound it dies
wallX:	.hword 63
	.hword 960
wallY:	.hword 255
	.hword 705

.align 4
score:	.int	23
lives:	.int	3

snakeLen: .int	3
// directions based on button number for up down left right
direction: .int 9


