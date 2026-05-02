	; lots of converting from segment <--> physical addresses
	bits 16		; tells assembler 16-bit real mode
	
	mov ax, 0x7C0	; code starts at 0x7C00, so adjusting for 
	mov ds, ax	; offset (/0x10), data segment will begin at 0x7C0.
			; using ax as intermediate register for ds,
			; cannot store directly into segment register.
	mov ax, 0x7E0	; starting storage for stack directly after
	cli
	mov ss, ax	; 512 bytes of bootloader, @ memory (0x7C00 + 512)/x10.
	mov sp, 0x2000	; initial 8k stack pointer (higher value, lower level on stack).
	sti
	
	call clearscreen

	push 0x0000	; pushes coordinate
	call movecursor
	add sp, 2	; cleans the argument

	push msg
	call print
	add sp, 2	; cleans argument

	cli		; do not accept interrupts after printing
	hlt		; halt processing
	
	
clearscreen:
	; to pass control to different functions, use push to store caller-saved
	; registers on the stack, pass parameters to callee with push, then use call
	; to save the current pc on the stack, and perform a jump to the label
	push bp		; bp is kind of the start of the functions stack frame,
			; you are saving it on the stack.
	mov bp, sp	; now the current sp (stack pointer/top) is your new bp for this frame
	pusha		; pushes general registers on stack
	
			; next, we store values and let the BIOS read registers
			; to perform functions
	
	mov ah, 0x07	; tells BIOS to use scroll function, to be read by int(errupt) 0x10
	mov al, 0x00	; tells it to clear the whole window, actually
	mov bh, 0x07	; higher bits tell background to be black, lower tell it to be white
	mov cx, 0x00	; cx dictates coordinate using high and low bits, so dictates
			; top left of screen, (0,0) to be cleared
	mov dh, 0x18	; high bit, or 24 rows
	mov dl, 0x4f	; lower bits (of dx), so 79 columns
			; zero-indexed, so 25 rows, 80 columns
	int 0x10	; looks at registers and performs clear screen based on parameters
			; 0x10 is video register code
			
	popa		; pops registers stored on stack
	mov sp, bp	; start of function stack frame becomes stack top
	pop bp		
	ret

movecursor:
	; moves cursor to arbitrary row, col, needs to pass in argument
	push bp
	mov bp, sp
	pusha
	
	mov dx, [bp+4]	; "[]" deferences
			; get the argument that was pushed onto the stack
			; need to offset by 4 due to pushed bp and
			; argument being on the stack
	mov ah, 0x02    ; sets ah to the "cursor position" code
	mov bh, 0x00	; tells BIOS to move to default page, 0
	int 0x10	
	
	popa
	mov sp, bp
	pop bp
	ret

print:
	push bp
	mov bp, sp
	pusha
	
	mov si, [bp+4]	; "source index" to handle string and memory management
			; grabs the pointer to the data which was on the stack and offset
	mov bh, 0x00	; page 0
	mov bl, 0x00	; little redundant, but making sure register is cleared and black
	mov ah, 0x0E	; sets ah to "teletype" function, handling printing of al and move cursor

.char:
	mov al, [si]	; dereferences pointer to get current char
	add si, 1	; keeps incrementing until null char
	or al, 0	; ORs al with 0, so that FLAG register will have al's value
	je .return	; "jump if equal" or if ZF = 1
	int 0x10	; BIOS interrupt to print character
	jmp .char	; uncondtional jump
	
.return:
	popa
	mov sp, bp
	pop bp
	ret


	
msg:    db "Oh boy do I sure love ECE! Will I get an internship?? Who knows!", 0	; terminates with null

	times 510-($-$$) db 0	; make sure bootsector is 512 bytes, this pads to 510
	dw 0xAA55		; defines last 2 bytes as 0xAA55 so it is a bootloader

