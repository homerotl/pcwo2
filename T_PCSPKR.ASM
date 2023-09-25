; T_PCSPKR.ASM
; Source for the PC Speaker test
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

.DATA
    
    ; PC Speaker music format
    ; [00] - Tempo (see table)
    ; [00] - Note type (see table)
    ; [00] - Note (see table)
    ; ..
    ; ..
    ; [ff] - end
        
    MelodySwanLake  db 05h ; Moderato								; measures
    	;db 0dh														; 1 (skip initial silence)
    	db 06,39h, 02h,32h, 02h,34h, 02h,35h						; 2
    	db 02h,37h,  05h,39h, 02h,35h, 05h,39h, 02h,35h 			; 3 
    	db 05h,39h, 02h,32h, 02h,35h, 02h,32h, 02h,2eh, 02h,35h		; 4
    	db 06h,32h, 02h,32h, 02h,37h, 02h,35h, 02h,34h				; 5
    	db 06h,39h, 02h,32h, 02h,34h, 02h,35h, 02h,37h				; 6
    	db 05h,39h, 02h,35h, 05h,39h, 02h,35h						; 7
    	db 05h,39h, 02h,32h, 02h,35h, 02h,32h, 02h,2eh, 02h,35h		; 8
    	db 07h,32h, 04h,32h											; 9
    	db 04h,34h, 04h,35h, 04h,37h, 02h,39h, 02h,3ah				; 10
    	db 05h,3ch, 02h,3ah, 04h,39h, 02h,3ah, 02h,3ch				; 11
    	db 05h,3eh, 02h,3ch, 04h,3ah, 02h,3ch, 02h,3eh				; 12
    	db 05h,40h, 02h,3eh, 02h,39h, 02h,35h, 02h,34h, 02h,32h		; 13
    	db 04h,34h, 04h,35h, 04h,37h, 02h,39h, 02h,3ah				; 14
    	db 05h,3ch, 02h,3ah, 04h,39h, 02h,3ah, 02h,3ch				; 15
    	db 05h,3eh, 02h,3ch, 04h,3ah, 02h,3ch, 02h,3eh				; 16
    	db 05h,3fh, 02h,3ah, 04h,37h, 02h,3ah, 02h,40h				; 17
    	db 05h,40h, 02h,3bh, 05h,40h, 02h,39h						; 18
    	db 0ffh ; ending
    
    ; Allegro
    NoteTypes db 00h, 02h, 0a9h, 53h		; 1/16 note
    	db 00h, 03h, 0fdh, 0fch				; 1/16 dotted
    	db 00h, 05h, 52h, 0a5h				; 1/8 note
    	db 00h, 07h, 0fbh, 0f8h				; 1/8 note dotted
    	db 00h, 0ah, 0a5h, 4ah				; 1/4 note
    	db 00h, 0fh, 0f7h, 0f0h				; 1/4 note dotted
    	db 00h, 15h, 4ah, 95h				; 1/2 note
    	db 00h, 1fh, 0efh, 0dfh				; 1/2 note dotted
    	db 00h, 2ah, 95h, 2ah				; whole note
    	db 00h, 02h, 0a9h, 53h				; 1/16 rest
    	db 00h, 05h, 52h, 0a5h				; 1/8 rest
    	db 00h, 0ah, 0a5h, 4ah				; 1/4 rest
    	db 00h, 15h, 4ah, 95h				; 1/2 rest
    	db 00h, 2ah, 95h, 2ah				; whole rest
   
   NoteFrequencies db 27h, 11h, 0d1h		; C4
   		db 28h, 10h, 0d1h					; C#4
   		db 29h, 0fh, 0e0h					; D4
   		db 2ah, 0eh, 0fbh					; ..
   		db 2bh, 0eh, 24h
   		db 2ch, 0dh, 59h
   		db 2dh, 0ch, 99h
   		db 2eh, 0bh, 0e4h
   		db 2fh, 0bh, 3ah
   		db 30h, 0ah, 98h
   		db 31h, 0ah, 00h					; ..
   		db 32h, 09h, 70h					; B4
   		db 33h, 08h, 0e9h					; C5
   		db 34h, 08h, 69h					; C#5
   		db 35h, 07h, 0f0h					; ..
   		db 36h, 07h, 7eh
   		db 37h, 07h, 12h
   		db 38h, 06h, 0adh
   		db 39h, 06h, 4dh
   		db 3ah, 05h, 0f2h
   		db 3bh, 05h, 9dh
   		db 3ch, 05h, 4ch
   		db 3dh, 05h, 00h
   		db 3eh, 04h, 0b8h					; ..
   		db 3fh, 04h, 75h					; C6
   		db 40h, 04h, 35h					; C#6
   		db 0ffh							; End of the table
   
.CODE
	.8086
	JUMPS
	
	EXTRN _UI_PROMPT_PCSPKR_PLAYING:PROC	; From UI.ASM 
	EXTRN _UI_CLEAR_PROMPT:PROC				
	EXTRN _UI_CLEAR_STATUS:PROC	

;----
; _TEST_PC_SPEAKER 
; Test the PC Speaker by sending one C note for 1/4 time
; Inputs:
;   - None
; Output: 
;	- None
; Destroys:
;	- si,di
;----
PUBLIC _TEST_PC_SPEAKER
_TEST_PC_SPEAKER PROC
	
	push ax
	push bx
	push cx
	push dx
	
	call _UI_PROMPT_PCSPKR_PLAYING
	
	mov al,0b6h
	out 43h,al								; Send value 182 to port 43h. This setups the speaker
	
	lea di,MelodySwanLake					; Get pointer to the music
	
	inc di									; For now, skip the tempo
	
_T_PCST_ReadNextNote:

	; check for a key stroke
	mov ah,0bh
	int 21h
	cmp al,00h								; no character available
	je _T_PCST_NoChar
	
	jmp _T_PCST_EndOfSong
	
_T_PCST_NoChar:
	cmp byte ptr [di],0ffh
	je _T_PCST_EndOfSong					; check if we are at the end
	
	cmp byte ptr [di],08h
	jle _T_PCST_PlayNote					; looks like a playing note?
	
	cmp byte ptr [di],0dh
	jle _T_PCST_Rest						; looks like rest?
	
	jmp _T_PCST_EndOfSong					; Unknown code, just exit  

_T_PCST_PlayNote:
	
	xor ax,ax								; ax = 0
	mov al,[di]								; Copy note code
	
	; Lookup note type in NoteTypes for duration
	mov bl,04h
	mul bl									; (offset) ax = code * 04h
	lea si,NoteTypes	
	add si,ax								; si = si + offset

	mov ch,[si]								; Load CX:DX with the note duration
	inc si
	mov cl,[si]
	inc si
	mov dh,[si]
	inc si
	mov dl,[si]
	
	; Lookup note frequency in NoteFrequencies	
	inc di									; load next song byte
	mov al,[di]

	lea si,NoteFrequencies

_T_PCST_NextFreq:

	mov bl,0ffh
	cmp [si],bl								; At the end of the table?
	je _T_PCST_EndOfSong					; ERROR: Could not find frequency. End

	cmp [si],al
	je _T_PCST_FreqFound
	add si,03h
	jmp _T_PCST_NextFreq
 
_T_PCST_FreqFound:
	inc si									; move over one byte to skip the node code
	
	mov ah,[si]								; Set frequency in AX
	inc si
	mov al,[si]
	
	out 42h,al								; Out can only be done from al or AX
	mov al,ah
	out 42h,al
	
	; Play the note
	in al,61h								; Enable speaker
	or al,03h								; Set lower 2 bits to 1
	out 61h,al								; without affecting the other bits
	
	mov ah,86h								; Int 15h, Function 86h
	int 15h									; Wait for CX:DX micro seconds
	
	; Stop the note
	in al,61h								; Disable speaker
	and al,0fch								; Set lower 2 bits to 0
	out 61h,al								; without affecting the other bits
	
	inc di									; move on to the next byte
	jmp _T_PCST_ReadNextNote
	
_T_PCST_Rest:

	xor ax,ax								; ax = 0
	mov al,[di]								; Copy note code
	
	; Lookup note type in NoteTypes for duration
	mov bl,04h
	mul bl									; (offset) ax = code * 04h
	lea si,NoteTypes	
	add si,ax								; si = si + offset

	mov ch,[si]								; Load CX:DX with the note duration
	inc si
	mov cl,[si]
	inc si
	mov dh,[si]
	inc si
	mov dl,[si]
	
	; Wait
	mov ah,86h								; Int 15h, Function 86h
	int 15h									; Wait for CX:DX micro seconds
	
	inc di
	jmp _T_PCST_ReadNextNote

_T_PCST_EndOfSong:
	
	call _UI_CLEAR_STATUS
	call _UI_CLEAR_PROMPT	
	
	pop dx
	pop cx
	pop bx
	pop ax	
	
	ret
	
_TEST_PC_SPEAKER ENDP

END