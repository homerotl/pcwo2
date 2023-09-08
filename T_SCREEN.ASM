; T_SCREEN.ASM
; Tests for the screen
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small
	
.DATA

	EXTRN _SCRN_VideoMode:BYTE			; From LIB/SCREEN.ASM
	
.CODE

	EXTRN _KB_WAIT_ANY_KEY:PROC			; From KB.ASM
	
	EXTRN _SCRN_SET_VIDEO_MODE:PROC		; From LIB/SCREEN.ASM
	EXTRN _SCRN_DISABLE_CURSOR:PROC
	EXTRN _SCRN_DISABLE_BLINKING_TEXT:PROC
		
    PUBLIC _SCREEN_GEOMETRY_TEST

;----
; _SCREEN_GEOMETRY_TEST
; Draws a 2D grid pattern on the screen, which can be useful to calibrate 
; a monitor
; Inputs:
; 	- none
; Output: none
; Destroys: None
;----
_SCREEN_GEOMETRY_TEST PROC NEAR

	push ax						; Save used registers
	push bx
	push cx
	push dx
	push di
	push es
	
	mov _SCRN_VideoMode,13h								
	call _SCRN_SET_VIDEO_MODE   ; Set graphics mode 13h (Graphics, 320x200)
	
	mov ax,1010h				; Function 10h, Subfunction 10h, int 10h - Set individual DAC register	  
	mov bx,00feh				; Color for the lines (white)
	mov cl,3fh                 	; RGB for magenta (0-63)
	mov ch,00h
	mov dh,3fh
	int 10h    

	mov ax,0a000h				; Align with video memory address
	mov es,ax                   ; 
	mov ah,0feh					; pen color is white, using AH for the pen color
	mov di,0					; we are using DI to index inside the video mem. Starts at 0
	mov cx,0					; we will use CX for columns
	mov bh,0					; we will use BH to count the number of time the pattern needs to repeat
	
DrawPattern:

	mov cx,140h
DrawFullLine:	
	mov es:[di],ah				; draw pixel
	inc di						; increment DI
	loop DrawFullLine

	mov cx,130h					; 19x16=288 130h	
DrawOnluColumns:
	mov es:[di],ah				; draw pixel
	add di,14h					; DI = DI+20
	mov es:[di],ah				; draw pixel
	loop DrawOnluColumns

	inc bh						; increase the count of times we will do the pattern
	cmp bh,0Ah					; Do it 10 (0Ah) times
	jl DrawPattern				; are we not yet done, repeat
	
	mov cx,140h
	mov di,0f8C0h				; move to the last line
DrawLastLine:
	mov es:[di],ah				; draw pixel
	inc di						; increment DI
	loop DrawLastLine

	mov cx,00c8h				; Do it 200 times
	mov di,013Fh				; Top right corner
DarwRightLastLine:
	mov es:[di],ah				; draw pixel
	add di,140h					; +320
	loop DarwRightLastLine
	
	call _KB_WAIT_ANY_KEY
	
    mov _SCRN_VideoMode,01h     ; Setup text mode 1 (40x25x16)				
	call _SCRN_SET_VIDEO_MODE
	call _SCRN_DISABLE_CURSOR		 
	call _SCRN_DISABLE_BLINKING_TEXT
	
	pop es						; Restore used registers
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
_SCREEN_GEOMETRY_TEST ENDP

END