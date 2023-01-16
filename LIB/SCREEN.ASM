; SCREEN.ASM
; Operations affecting the screen like text mode changes and other routines
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

.DATA

	_SCRN_VideoMode db 01h			; Public value for the video mode
	PUBLIC _SCRN_VideoMode
	
	_SCRN_Character	db 20h
	PUBLIC _SCRN_Character
	
	_SCRN_Attribute db 07h
	PUBLIC _SCRN_Attribute

.CODE		
	
	PUBLIC _SCRN_SET_VIDEO_MODE
	PUBLIC _SCRN_SET_BACKGROUND
	PUBLIC _SCRN_DISABLE_CURSOR
	PUBLIC _SCRN_DISABLE_BLINKING_TEXT
;----
; _SCRN_SET_VIDEO_MODE
; Set screen to the mode specified on the public byte _VideoMode
; Inputs: Uses the value at the public byte _VideoMode
; Output: none
; Destroys: none
;----
_SCRN_SET_VIDEO_MODE PROC
	push ax						; save ax
	mov ah,00h					; INT 10h, Function 00h - Set video mode
	mov al,_SCRN_VideoMode		; Set the value from the public byte _SCRN_VideoMode
	int 10h
	pop ax						; restore ax
	ret
_SCRN_SET_VIDEO_MODE ENDP

;----
; _SCRN_SET_BACKGROUND
; For text mode 1 (40x25) set the attribute c
; Inputs: none
; Output: none
; Destroys: es,di
;----
_SCRN_SET_BACKGROUND PROC
	push ax						; Save registers
	push bx
	push cx
	mov ax,0b800h				; Text mode memory starts at 0b800h
	mov es,ax					; Align es
	mov di,0					; start index di with 0
	mov cx,03e8h				; 40x25 = 1000 = 03e8h, do it 1000 times 
	mov bl,_SCRN_Character			
	mov bh,_SCRN_Attribute	
fill_screen:
	mov es:[di],bx
	add di,2
	loop fill_screen
	pop cx
	pop bx
	pop ax
	ret
_SCRN_SET_BACKGROUND ENDP

;----
; _SCRN_DISABLE_CURSOR
; Hides text mode cursor
; Inputs: none
; Output: none
; Destroys: none
;----
_SCRN_DISABLE_CURSOR PROC
	push ax						; Save registers
	push cx
	mov cx,2000h				; Hide cursor
	mov ah,1
	int 10h						; INT 10H, Function 01h - ????
	pop cx						; Restore registers
	pop ax
	ret
_SCRN_DISABLE_CURSOR ENDP

;----
; _SCRN_DISABLE_BLINKING_TEXT
; Disable text blinking in text modes
; Inputs: none
; Output: none
; Destroys: none
;----
_SCRN_DISABLE_BLINKING_TEXT PROC
	push ax
	push bx
	mov bl,0					; Disable text blinking
	mov ax,1003h
	int 10h						; INT 10h, ... ???
	pop bx
	pop ax
	ret
_SCRN_DISABLE_BLINKING_TEXT ENDP

END