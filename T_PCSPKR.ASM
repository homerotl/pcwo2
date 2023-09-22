; T_PCSPKR.ASM
; Source for the PC Speaker test
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

.DATA
    
    ; Status texts
    PCSpeakerMsg    db 'Playing Sound...$'
    
.CODE
	.8086
	JUMPS
	
	EXTRN _UI_SET_STATUS:PROC              ; From UI.ASM 
	EXTRN _UI_CLEAR_STATUS:PROC	

;----
; _TEST_PC_SPEAKER 
; Test the PC Speaker by sending one C note for 1/4 time
; Inputs:
;   - None
; Output: 
;	- None
; Destroys:
;	- None
;----
PUBLIC _TEST_PC_SPEAKER
_TEST_PC_SPEAKER PROC
	
	lea si,PCSpeakerMsg		
    call _UI_SET_STATUS
	
	mov al,0b6h					;
	out 43h,al					; Send value 182 to port 43h. This setups the speaker
	
	mov ax,11cbh				; Set frequency DO
	out 42h,al					; Out can only be done from al or AX
	mov al,ah
	out 42h,al

	in al,61h					; Enable speaker
	or al,03h					; Set lower 2 bits to 1
	out 61h,al					; without affecting the other bits

	mov cx,0009h				; Wait for cx:dx micro seconds
	mov dx,0f38eh				; This instruction has a bug in DOSBox. 
	mov ah,86h					; Int 15h, Function 86h
	int 15h
	
	in al,61h					; Disable speaker
	and al,0fch					; Set lower 2 bits to 0
	out 61h,al					; without affecting the other bits
	
	call _UI_CLEAR_STATUS
	
	ret
_TEST_PC_SPEAKER ENDP

END