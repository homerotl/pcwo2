; UI.ASM
; User interface routines for PCWO2
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

	LableStyle             equ 4fh ; White text over red background
	DynInfoStyle           equ 40h ; Black text over red background
	StatusStyle            equ 40h ; Black text over red background

.DATA
	
	EXTRN _SCRN_Attribute:BYTE      ; From LIB/SCREEN.ASM
	EXTRN _SCRN_Position_X:BYTE
	EXTRN _SCRN_Position_Y:BYTE
	
    _UI_Drive_Index             db 0            ; Index of the drive being tested (0 = a;)
    PUBLIC _UI_Drive_Index
	
	_UI_Progress_FDT 			db 0            ; number from 0 to 10 indicating progress
	PUBLIC _UI_Progress_FDT
	
	DriveTypeNMediaMsg	        db 'Drive X              Media$' 
	DriveReadTestMsg	        db 'Reading Test [          ] Track$' 
	BlankStatusMsg              db '                         $'
	ProgressChar                db '=$'
	
.CODE		
	.8086
JUMPS

	EXTRN _SCRN_PRINT_TEXT:PROC                      ; From LIB/SCREEN.ASM

	PUBLIC _UI_SET_STATUS
	PUBLIC _UI_CLEAR_STATUS
	PUBLIC _UI_DRIVE_TEST_TITLES
	PUBLIC _UI_ADD_FD_TYPE_VALUE
	PUBLIC _UI_ADD_FD_MEDIA_VALUE
	PUBLIC _UI_PRINT_TRACK_NUM
	PUBLIC _UI_DISPLAY_FD_PROGRESS

;----
; _UI_SET_STATUS
; Display text in the status area
; Inputs: si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
_UI_SET_STATUS PROC
	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,0eh           ; 14
	mov _SCRN_Position_Y,17h           ; 23
	call _SCRN_PRINT_TEXT
	ret
_UI_SET_STATUS ENDP

;----
; _UI_CLEAR_STATUS
; Clear the status bar text
; Inputs: none
; Output: none
; Destroys: none
;----
_UI_CLEAR_STATUS PROC
    lea si,BlankStatusMsg
	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,0eh           ; 14
	mov _SCRN_Position_Y,17h           ; 23
	call _SCRN_PRINT_TEXT
	ret
_UI_CLEAR_STATUS ENDP

;----
; _UI_DRIVE_TEST_TITLES
; Display titles for one drive info
; Inputs: _UI_Drive_Index
; Output: none
; Destroys: none
;----
_UI_DRIVE_TEST_TITLES PROC
    mov _SCRN_Attribute,LableStyle	   ; set style
    mov _SCRN_Position_X,03h           ; set the column 
                                       ; calculate the row
    push ax                            ; save registers
    push bx
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h
    mul bl                             ; each drive takes 3 rows
    add al,0ch                         ; add start row (12 = 0ch)
    mov _SCRN_Position_Y,al            
    pop bx                             ; restore registers
    pop ax                             
	
	lea si,DriveTypeNMediaMsg	
	call _SCRN_PRINT_TEXT

	inc _SCRN_Position_Y
	lea si,DriveReadTestMsg	
	call _SCRN_PRINT_TEXT
	
	ret
_UI_DRIVE_TEST_TITLES ENDP

;----
; _UI_ADD_FD_TYPE_VALUE
; Display the value for drive type
; Inputs: 
;  - _UI_Drive_Index
;  - si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
_UI_ADD_FD_TYPE_VALUE PROC
    mov _SCRN_Attribute,DynInfoStyle   ; set style
    mov _SCRN_Position_X,0bh           ; set the column 
                                       ; calculate the row
    push ax                            ; save registers
    push bx
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h                         
    mul bl                             ; each drive takes 3 rows
    add al,0ch                         ; add start row (12 = 0ch)
    mov _SCRN_Position_Y,al            

    pop bx                             ; restore registers
    pop ax                             
	call _SCRN_PRINT_TEXT
	ret
_UI_ADD_FD_TYPE_VALUE ENDP

;----
; _UI_ADD_FD_MEDIA_VALUE
; Display the value for media type
; Inputs: 
;  - _UI_Drive_Index
;  - si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
_UI_ADD_FD_MEDIA_VALUE PROC
    mov _SCRN_Attribute,DynInfoStyle   ; set style
    mov _SCRN_Position_X,1eh           ; set the column 
                                       ; calculate the row
    push ax                            ; save registers
    push bx
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h                         
    mul bl                             ; each drive takes 3 rows
    add al,0ch                         ; add start row (12 = 0ch)
    mov _SCRN_Position_Y,al            

    pop bx                             ; restore registers
    pop ax                             
	call _SCRN_PRINT_TEXT
	ret
_UI_ADD_FD_MEDIA_VALUE ENDP

;----
; _UI_PRINT_TRACK_NUM
; Display the track number being read
; Inputs: 
;  - _UI_Drive_Index
;  - si points to a string with the track number being read
; Output: none
; Destroys: none
;----
_UI_PRINT_TRACK_NUM PROC
    mov _SCRN_Attribute,DynInfoStyle   ; set style
    mov _SCRN_Position_X,23h           ; set the column 
                                       ; calculate the row
    push ax                            ; save registers
    push bx
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h                         
    mul bl                             ; each drive takes 3 rows
    add al,0dh                         ; add start row (13 = 0dh)
    mov _SCRN_Position_Y,al            

    pop bx                             ; restore registers
    pop ax                             
	call _SCRN_PRINT_TEXT
	ret
_UI_PRINT_TRACK_NUM ENDP

;----
; _UI_DISPLAY_FD_PROGRESS
; Fill the progress bar of the current drive index with as many marks
; as indicated in _UI_Progress_FDT [0 to 10]
; Inputs: 
;  - _UI_Drive_Index
;  - _UI_Progress_FDT
; Output: none
; Destroys: none
;----
_UI_DISPLAY_FD_PROGRESS PROC

    cmp _UI_Progress_FDT,0
    je ui_display_fd_prog_end
    
    lea si,ProgressChar
    mov _SCRN_Attribute,DynInfoStyle   ; set style
    mov _SCRN_Position_X,11h           ; set the column 
                                       ; calculate the row
    push ax                            ; save registers
    push bx
    push cx
    
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h                         
    mul bl                             ; each drive takes 3 rows
    add al,0dh                         ; add start row (13 = 0dh)
    mov _SCRN_Position_Y,al            
    
    xor cx,cx
    mov cl,_UI_Progress_FDT

repeat_print_prog_char:
    call _SCRN_PRINT_TEXT
    mov bl,_SCRN_Position_X
    inc bl
    mov _SCRN_Position_X,bl    
    loop repeat_print_prog_char                 
    
    pop cx
    pop bx
    pop ax
    
ui_display_fd_prog_end:
	ret
_UI_DISPLAY_FD_PROGRESS ENDP

END