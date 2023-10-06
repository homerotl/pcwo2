; SCREEN.ASM
; Operations affecting the screen like text mode changes and other routines
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small
	
.DATA
    
    SAVE_SCR_BUFF               db 2000 dup(?)  ; Buffer to save the screen, uninitialized

	_SCRN_VideoMode 			db 01h			; Public value for the video mode
	PUBLIC _SCRN_VideoMode
	
	_SCRN_Attribute 			db 07h
	PUBLIC _SCRN_Attribute

	_SCRN_Position_X 			db 0
	PUBLIC _SCRN_Position_X
	
	_SCRN_Position_Y 			db 0
	PUBLIC _SCRN_Position_Y
	
	_SCRN_One_Char				db 0
	PUBLIC _SCRN_One_Char
	
.CODE		
	.8086
	JUMPS
	
;----
; _SCRN_SET_VIDEO_MODE
; Set screen to the mode specified on the public byte _VideoMode
; Inputs: Uses the value at the public byte _VideoMode
; Output: none
; Destroys: none
;----
PUBLIC _SCRN_SET_VIDEO_MODE
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
; Inputs: _SCRN_Attribute has the byte with the color schema
; Output: none
; Destroys: none
;----
PUBLIC _SCRN_SET_BACKGROUND
_SCRN_SET_BACKGROUND PROC
	
	push ax						; Save registers
	push bx
	push cx
	push es
	push di	
	
	mov ax,0b800h				; Text mode memory starts at 0b800h
	mov es,ax					; Align es
	mov di,0					; start index di with 0
	mov cx,03e8h				; 40x25 = 1000 = 03e8h, do it 1000 times 
	mov bl,20h					; Use space	to fill up the screen		
	mov bh,_SCRN_Attribute	
fill_screen:
	mov es:[di],bx
	add di,2
	loop fill_screen
	
	pop di						; restore registers
	pop es
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
PUBLIC _SCRN_DISABLE_CURSOR
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
PUBLIC _SCRN_DISABLE_BLINKING_TEXT
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

;----
; _SCRN_PRINT_TEXT
; Print text on the screen using the parameters provided. 
; Assume DS is already pointing to the data segment and SI has the effective address
; data segment
; Inputs:
;	_SCRN_Attribute - Attribute byte
; 	_SCRN_Position_X - horizontal index where text will be displayed (byte)
; 	_SCRN_Position_Y - vertical index where text will be displated (byte)
; Output: none
; Destroys: none
;----
PUBLIC _SCRN_PRINT_TEXT
_SCRN_PRINT_TEXT PROC
	push ax						; Save registers
	push cx
	push di
	push si
	push es
	
	mov ax,0b800h				; Text mode memory starts at 0b800h
	mov es,ax					; Align ES
	
	mov al,_SCRN_Position_Y
	mov cl,28h                  ; 28h = 40 for 40 col  mode					
	mul cl						; ax = (Y * 40) + X
	mov cl,_SCRN_Position_X     ; cx = 00 xx
	mov ch,00h
	add ax,cx                   ; ax = ax + cx
	shl ax,1                    ; shift bits left to multiply by 2
	mov di,ax
	mov ch,_SCRN_Attribute
	
pt_loop:
	mov cl,[si]					; Copy character from the source
	cmp cl,'$'					; While ref[si]!='$' {
	je pt_end
	
	mov es:[di],cl				; Copy character
	inc di
	mov es:[di],ch				; Copy attribute byte to destination
	inc di
	inc si
	jmp pt_loop
	
pt_end:
    pop es
    pop si
    pop di
    pop cx
	pop ax                      ; Restore registers
	ret
_SCRN_PRINT_TEXT ENDP

;----
; _SCRN_SAVE_SCR
; Save the current content of the screen on the buffer SAVE_SCR_BUFF
; Inputs: none
; Output: none
; Destroys: si,di
;----
PUBLIC _SCRN_SAVE_SCR
_SCRN_SAVE_SCR PROC
                               ; Save registers we are going to use    
    push cx               
    push es
	                           ; start indexes at 0
	mov si,0
    
    mov cx,ds                  ; copy Data segment (DS) to ES
    mov es,cx
    
    mov cx,0b800h
    mov ds,cx                  ; align DS with start of text video segment
    mov di,OFFSET SAVE_SCR_BUFF ; align ES with the save screen buffer               
    
    cld                        ; clear direction flag
	mov cx,07d0h               ; set counter, 40x2x25 = 2000 = 07d0h 
	rep movsb                  ; repeat: move a byte from DS:SI to ES:DI, CX times
	
    mov cx,es                  ; restore Data Segment
    mov ds,cx    
	                           ; Restore registers
	pop es
	pop cx

	ret
_SCRN_SAVE_SCR ENDP


;----
; _SCRN_RESTORE_SCR
; Restore screen with the content saved in SAVE_SCR_BUFF
; Inputs: none
; Output: none
; Destroys: si,di
;----
PUBLIC _SCRN_RESTORE_SCR
_SCRN_RESTORE_SCR PROC
                               ; Save registers we are going to use    
    push cx
    push es
                               ; start indexes at 0
	mov di,0                   
	    
    mov si,OFFSET SAVE_SCR_BUFF

    mov cx,0b800h              ; align ES with start of text video segment
    mov es,cx                  
    
    cld                        ; clear direction flag
	mov cx,07d0h               ; set counter, 40x2x25 = 2000 = 07d0h 
	rep movsb                  ; repeat: move a byte from DS:SI to ES:DI, CX times
	                           
	                           ; Restore registers
	pop es
	pop cx

	ret
_SCRN_RESTORE_SCR ENDP

;----
; _SCRN_PRINT_CHAR
; Print one character on the screen coordinates _SCRN_Position_X,_SCRN_Position_Y
; using color attribute _SCRN_Attribute
;   - _SCRN_One_Char
;	- _SCRN_Position_X
;	- _SCRN_Position_Y coordinates
;	- _SCRN_Attribute
; Output: none
; Destroys:none
;----
PUBLIC _SCRN_PRINT_CHAR
_SCRN_PRINT_CHAR PROC

	push ax							; Save registers
	push cx
	push es
	push di
	
	mov ax,0b800h					; Text mode memory starts at 0b800h
	mov es,ax						; Align ES
	
	mov al,_SCRN_Position_Y
	mov cl,28h						; 28h = 40 for 40 col  mode					
	mul cl							; ax = (Y * 40) + X
	mov cl,_SCRN_Position_X			; cx = 00 xx
	mov ch,00h
	add ax,cx						; ax = ax + cx
	shl ax,1						; shift bits left to multiply by 2	
	mov di,ax
	mov al,_SCRN_One_Char
	mov es:[di],al					; Copy character
	inc di
	mov al,_SCRN_Attribute
	mov es:[di],al					; Copy attribute byte to destination
	
    pop di							; Restore used registers
    pop es
    pop cx
	pop ax
	
	ret
_SCRN_PRINT_CHAR ENDP


END