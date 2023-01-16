; KB.ASM
; Source for keyboard realted procedures
; Author: Homero Trevino

.MODEL small

.CODE
	PUBLIC _KB_YES_NO_Q
	PUBLIC _KB_WAIT_ANY_KEY
	
;----
; _KB_YES_NO_Q 
; Wait for a Y/N answer (case insensitive)
; Inputs:
; 	- None
; Output: 
;	- al = 1 if YES, 0 if NO. 
; Destroys: AX
;----
_KB_YES_NO_Q PROC					
	
YNAskAgain:

	mov ah,07h					; Function 07h int 21h - Wait for a character w/o echo
	int 21h	
	
	cmp al,'y'					; Check Yes lowercase
	je YNAnswerYes
	cmp al,'Y'					; Check Yes uppercase
	je YNAnswerYes
	cmp al,'n'					; Check No lowercase
	je YNAnswerNo
	cmp al,'N'					; Check No uppercase
	je YNAnswerNo	
	jmp YNAskAgain				; None of them, then ask again
	
YNAnswerYes:
	mov al,1
	jmp YNEnd
	
YNAnswerNo:
	mov al,0
	
YNEnd:
	ret
_KB_YES_NO_Q ENDP

;----
; _KB_WAIT_ANY_KEY
; Wait for any key press and returns 
; Inputs:
; 	- None
; Output: 
;	- None
; Destroys: None
;----
_KB_WAIT_ANY_KEY PROC

	push ax
	mov ah,07h					; Function 07h int 21h - Wait for a character w/o echo
	int 21h	
	pop ax

	ret
_KB_WAIT_ANY_KEY EndP
END