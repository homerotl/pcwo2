; SCREEN.ASM
; Operations affecting the screen like text mode changes and other routines
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

.DATA
    
    SAVE_SCR_BUFF               db 2000 dup(0)  ; Buffer to save the screen

	_SCRN_VideoMode 			db 01h			; Public value for the video mode
	PUBLIC _SCRN_VideoMode
	
	_SCRN_Character				db 20h
	PUBLIC _SCRN_Character
	
	_SCRN_Attribute 			db 07h
	PUBLIC _SCRN_Attribute

	_SCRN_Position_X 			dw 0
	PUBLIC _SCRN_Position_X
	
	_SCRN_Position_Y 			db 0
	PUBLIC _SCRN_Position_Y
		
.CODE		
	  
	PUBLIC _SCRN_SET_VIDEO_MODE
	PUBLIC _SCRN_SET_BACKGROUND
	PUBLIC _SCRN_DISABLE_CURSOR
	PUBLIC _SCRN_DISABLE_BLINKING_TEXT
	PUBLIC _SCRN_PRINT_TEXT
	PUBLIC _SCRN_SAVE_SCR
	PUBLIC _SCRN_RESTORE_SCR
	
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
; Destroys: ES
;----
_SCRN_PRINT_TEXT PROC
	push ax						; Save registers
	push cx
	
	mov ax,0b800h				; Text mode memory starts at 0b800h
	mov es,ax					; Align ES
	
	mov al,_SCRN_Position_Y
	mov cl,28h                  ; 28h = 40 for 40 col  mode					
	mul cl						; ax = (Y * 40) + X
	add ax,_SCRN_Position_X     
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
    pop cx
	pop ax                      ; Restore registers
	ret
_SCRN_PRINT_TEXT ENDP

;----
; _SCRN_SAVE_SCR
; Save the current content of the screen on the buffer SAVE_SCR_BUFF
; Inputs: none
; Output: none
; Destroys: none
;----
_SCRN_SAVE_SCR PROC
    push ax                     ; Save registers we are going to use
    push cx
    push di                     
    push si
    mov ax,es                
	push ax
	mov ax,ds
	push ax
	mov di,0                   ; start indexes at 0
	mov si,0
    
    mov ax,0b800h
    mov ds,ax                  ; align DS with start of text video segment
    lea ax,SAVE_SCR_BUFF       ; align ES with the save screen buffer
    mov es,ax                  
    
    cld                        ; clear direction flag
	mov cx,07f0h               ; set counter, 40x2x25 = 2000d = 07f0h 
	rep                        ; repeat the next string operation CX times
	movsb                      ; move a byte from DS:SI to ES:DI
	
	pop ax                     ; Restore used registers
	mov ds,ax
	pop ax
	mov es,ax
	pop si
	pop di
	pop cx
	pop ax
	ret
_SCRN_SAVE_SCR ENDP


;----
; _SCRN_RESTORE_SCR
; Restore screen with the content saved in SAVE_SCR_BUFF
; Inputs: none
; Output: none
; Destroys: none
;----
_SCRN_RESTORE_SCR PROC
    push ax                     ; Save registers we are going to use
    push cx
    push di                     
    push si
    mov ax,es                
	push ax
	mov ax,ds
	push ax
	mov di,0                   ; start indexes at 0
	mov si,0
    
    lea ax,SAVE_SCR_BUFF
    mov ds,ax                  ; align DS with the save screen buffer
    mov ax,0b800h              ; align ES with start of text video segment
    mov es,ax                  
    
    cld                        ; clear direction flag
	mov cx,07f0h               ; set counter, 40x2x25 = 2000d = 07f0h 
	rep                        ; repeat the next string operation CX times
	movsb                      ; move a byte from DS:SI to ES:DI
	
	pop ax                     ; Restore used registers
	mov ds,ax
	pop ax
	mov es,ax
	pop si
	pop di
	pop cx
	pop ax
	ret
_SCRN_RESTORE_SCR ENDP

END