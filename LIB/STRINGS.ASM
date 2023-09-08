; STRINGS.ASM
; Source for string related procedures
; Author: Homero Trevino <homerotl@gmail.com>

.MODEL small

.DATA  
	PUBLIC _NumToAsciiB
	PUBLIC _CRLF
	_NumToAsciiB  db '   $'
	_CRLF		 db 13,10,'$' 
.CODE
	.8086
	PUBLIC _TOSTRING

;----
; TOSTRING 
; Converts the value in ah to a decimal string. Only 8-bit unsigned int.
; Inputs:
; 	- ah = the value to conver to decimal 
; Output: 
;	- NumToAsciiB contains the decimal string.
; Destroys: None
;----
_TOSTRING PROC NEAR				; Assuming the value we want to convert is in ah

	lea di,_NumToAsciiB 			; Point di to the buffer where we are going to write number		

	push ax						; we are going to use these registers, so save them
	push bx			

	mov bl,20h					; Reset buffer with blank space char (20h)
	mov [di],bl	
	mov [di+1],bl	
	mov [di+2],bl	

	add di,2					; start from the back, move index to position 2

	mov bl,0ah					; prep to divide by 10 (0ah)
	mov al,ah					; Prep AX

NumToAsciiLoop:
	mov ah,0					; Prep AX
	div bl						; We divide ax/bl. al has the quotient and ah has the reminder
	add ah,30h					; Make ah ASCII
	mov [di],ah					; Copy the ASCII value to the buffer
	dec di						; increment the index for the buffer
	cmp al,0					; if the quotient is 0, we are done				
	je NumToAsciiDone			;
	jmp NumToAsciiLoop			; repeat

NumToAsciiDone:
	
	pop bx						; Restore registers
	pop ax						
	
	ret
_TOSTRING ENDP

END