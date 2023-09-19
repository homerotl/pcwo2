; UI.ASM
; User interface routines for PCWO2
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

	LableStyle             equ 4fh ; White text over red background
	DynInfoStyle           equ 40h ; Black text over red background
	StatusStyle            equ 40h ; Black text over red background

    STATUS_COL EQU 0ch  ; 12
    STATUS_ROW EQU 16h  ; 22	

    PROMPT_COL EQU 0ch  ; 12
    PROMPT_ROW EQU 17h  ; 23

.DATA
	
	EXTRN _SCRN_Attribute:BYTE      ; From LIB/SCREEN.ASM
	EXTRN _SCRN_Position_X:BYTE
	EXTRN _SCRN_Position_Y:BYTE
	
    _UI_Drive_Index             db 0            ; Index of the drive being tested (0 = a;)
    PUBLIC _UI_Drive_Index
	
	_UI_Progress_FDT 			db 0            ; number from 0 to 10 indicating progress
	PUBLIC _UI_Progress_FDT
	
	_UI_Enter_Esc_Diag_Resp     db 0            ; Response to ENTER or ESC dialog
	PUBLIC _UI_Enter_Esc_Diag_Resp              ; 0=ESC, 1 = ENTER 
	
	FDTestBaseRow               db 0

	DriveTypeNMediaMsg	        db 'Drive X              Media$' 
	DriveReadTestMsg	        db 'Reading Test [          ] Track$' 

	BlankStatusMsg              db '                           $'

    MediaNotPresentMsg          db 'Media not present$'
    RetrySkipMsg                db '[ENTER] retry  [ESC] skip  $'

		
	ProgressChar                db '=$'

    		
.CODE		
	.8086
JUMPS

	EXTRN _SCRN_PRINT_TEXT:PROC            ; From LIB/SCREEN.ASM
    EXTRN _KB_ENTER_ESC_Q:PROC             ; From LIB/KB.ASM

	PUBLIC _UI_SET_STATUS
	PUBLIC _UI_SET_PROMPT
	PUBLIC _UI_CLEAR_STATUS
    PUBLIC _UI_CLEAR_PROMPT
    	
	PUBLIC _UI_DRIVE_TEST_TITLES
	PUBLIC _UI_ADD_FD_TYPE_VALUE
	PUBLIC _UI_ADD_FD_MEDIA_VALUE
	PUBLIC _UI_PRINT_TRACK_NUM
	PUBLIC _UI_DISPLAY_FD_PROGRESS
    PUBLIC _UI_FD_READ_TEST_RESULT
    PUBLIC _UI_PROMPT_INSERT_MEDIA

;----
; _UI_SET_STATUS
; Display text in the status area
; Inputs: si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
_UI_SET_STATUS PROC
	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,STATUS_COL
	mov _SCRN_Position_Y,STATUS_ROW
	call _SCRN_PRINT_TEXT
	ret
_UI_SET_STATUS ENDP

;----
; _UI_SET_PROMPT
; Display text in the prompt area
; Inputs: si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
_UI_SET_PROMPT PROC
	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,PROMPT_COL
	mov _SCRN_Position_Y,PROMPT_ROW
	call _SCRN_PRINT_TEXT
	ret
_UI_SET_PROMPT ENDP


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
	mov _SCRN_Position_X,STATUS_COL
	mov _SCRN_Position_Y,STATUS_ROW
	call _SCRN_PRINT_TEXT
	ret
_UI_CLEAR_STATUS ENDP

;----
; _UI_CLEAR_PROMPT
; Clear the prompt text label
; Inputs: none
; Output: none
; Destroys: none
;----
_UI_CLEAR_PROMPT PROC
    lea si,BlankStatusMsg
	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,PROMPT_COL
	mov _SCRN_Position_Y,PROMPT_ROW
	call _SCRN_PRINT_TEXT
	ret
_UI_CLEAR_PROMPT ENDP

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
    call FD_TEST_CALCULATE_BASE_ROW
                                       ; calculate the row
    push ax                            ; save registers
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            
	
	lea si,DriveTypeNMediaMsg	
	call _SCRN_PRINT_TEXT

	inc _SCRN_Position_Y
	lea si,DriveReadTestMsg	
	call _SCRN_PRINT_TEXT
	
	pop ax                            

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
    call FD_TEST_CALCULATE_BASE_ROW
                                       ; calculate the row
    push ax                            ; save registers
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            

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
    call FD_TEST_CALCULATE_BASE_ROW
                                       ; calculate the row
    push ax                            ; save registers
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            

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
    
    call FD_TEST_CALCULATE_BASE_ROW
                                       ; calculate the row
    push ax                            ; save registers
    mov al,FDTestBaseRow
    inc al                             ; 2nd row    
    mov _SCRN_Position_Y,al            

    pop ax                           ; restore registers
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

    call FD_TEST_CALCULATE_BASE_ROW
    
    push ax                            ; save registers
    push cx
    
    mov al,FDTestBaseRow
    inc al                             ; 2nd row
    mov _SCRN_Position_Y,al            
    
    xor cx,cx                          ; setup the counter
    mov cl,_UI_Progress_FDT

repeat_print_prog_char:
    call _SCRN_PRINT_TEXT 
    inc _SCRN_Position_X
    loop repeat_print_prog_char                 
    
    pop cx
    pop ax
    
ui_display_fd_prog_end:
	ret
_UI_DISPLAY_FD_PROGRESS ENDP


;----
; _UI_FD_READ_TEST_RESULT
; Display drive test status message
; Inputs: 
;  - _UI_Drive_Index
;  - si points to a string '$' terminated of 10 chars
; Output: none
; Destroys: none
;----
_UI_FD_READ_TEST_RESULT PROC
    
    call FD_TEST_CALCULATE_BASE_ROW
    
    push ax
    mov _SCRN_Attribute,DynInfoStyle   ; set style
    mov _SCRN_Position_X,11h           ; set the column 
    inc FDTestBaseRow
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al
    call _SCRN_PRINT_TEXT 
    pop ax
	ret
_UI_FD_READ_TEST_RESULT ENDP

;----
; FD_TEST_CALCULATE_BASE_ROW
; Calculate the base row for the floppy drive test results
; Inputs: 
;  - _UI_Drive_Index
; Output: FDTestBaseRow has the Y value for the base row
; Destroys: none
;----
FD_TEST_CALCULATE_BASE_ROW PROC
    push ax                            ; save registers
    push bx
    xor ax,ax                          ; ax=0
    mov al,_UI_Drive_Index
    mov bl,03h                         
    mul bl                             ; each drive takes 3 rows
    add al,0ch                         ; add start row (12 = 0dh)
    mov FDTestBaseRow,al  
    pop bx                             ; restore registers
    pop ax  
	ret
FD_TEST_CALCULATE_BASE_ROW ENDP

;----
; _UI_PROMPT_INSERT_MEDIA
; Display a user prompt to select between two options
; Inputs:
; Output: _UI_Enter_Esc_Diag_Resp = 0 if ESC, = 1 if ENTER
; Destroys: none
;----
_UI_PROMPT_INSERT_MEDIA PROC
    
    push ax
    
    call _UI_CLEAR_PROMPT
    call _UI_CLEAR_STATUS

    lea si,MediaNotPresentMsg
    call _UI_SET_STATUS
    
    lea si,RetrySkipMsg
    call _UI_SET_PROMPT
 
 kb_pimp_retry:
   
    call _KB_ENTER_ESC_Q

    cmp al,00h                 ; is it ESC?
    je kb_pimp_esc
    
    cmp al,01h                 ; is it ENTER?
    je kb_pimp_enter
    
    jmp kb_pimp_retry

kb_pimp_esc:
    mov _UI_Enter_Esc_Diag_Resp,0
    jmp kb_pimp_end

kb_pimp_enter:
    mov _UI_Enter_Esc_Diag_Resp,1
    jmp kb_pimp_end
       
kb_pimp_end:
    
    call _UI_CLEAR_PROMPT
    call _UI_CLEAR_STATUS
    
    pop ax
    
	ret
_UI_PROMPT_INSERT_MEDIA ENDP

END