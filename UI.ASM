; UI.ASM
;
; User interface routines for PCWO2
; Author: Homero Trevino <homerotl@gmail.com>

.MODEL small

; Color schema

	BACKGROUND_STYLE		EQU 40h ; Black text over red background
	TITLE_STYLE				EQU 04h ; Red text over black background
	LABEL_STYLE				EQU 4fh ; White text over red background
	DYN_INFO_STYLE			EQU 40h ; Black text over red background
	MENU_OPTION_STYLE		EQU 04h ; Red text over black background
	STATUS_STYLE			EQU 40h ; Black text over red background
	
; Text mode 40x25 layout

    STATUS_COL 				EQU 0ch
    STATUS_ROW				EQU 16h
    PROMPT_COL				EQU 0ch
    PROMPT_ROW 				EQU 17h
    TITLE_COL				EQU 01h
    TITLE_ROW				EQU 01h
    INFO_TITLE_ROW			EQU 02h
    INFO_TITLE_COL			EQU 01h
    CPU_TITLE_ROW			EQU 03h
    FPU_TITLE_ROW			EQU 04h
	CPU_ID_COL				EQU 05h
    CPU_ID_ROW				EQU 03h
	FPU_ID_COL				EQU 05h
    FPU_ID_ROW				EQU 04h
    CPU_BENCH_TITLE_COL		EQU 13h
    CPU_BENCH_TITLE_ROW		EQU	03h    
    FPU_BENCH_TITLE_ROW		EQU	04h    
    DRIVE_TEST_COL			EQU 03h
    DRIVE_ID_COL			EQU 0bh
    DRIVE_MEDIA_COL			EQU 1eh
    TRACK_NUM_COL			EQU 23h
    FD_READ_TEST_COL		EQU 11h    
    OPTION1_COL				EQU 01h
    OPTION1_ROW				EQU 06h
    OPTION2_ROW				EQU 08h
    OPTION3_ROW				EQU 0Ah
    EXIT_ROW				EQU 17h
    FD_START_ROW			EQU 0ch
    VERSION_COL				EQU 1ch        
        
.DATA

	
    EXTRN _SCRN_VideoMode:BYTE					; From LIB/SCREEN.ASM
	EXTRN _SCRN_Attribute:BYTE		
	EXTRN _SCRN_Position_X:BYTE
	EXTRN _SCRN_Position_Y:BYTE					
	
	EXTRN _VER_VersionLbl:BYTE					; From VERSION.ASM

    PUBLIC _UI_Drive_Index		
    _UI_Drive_Index             db 0			; Index of the drive being tested (0 = a;)

	PUBLIC _UI_Progress_FDT	
	_UI_Progress_FDT 			db 0			; number from 0 to 10 indicating progress

	PUBLIC _UI_Enter_Esc_Diag_Resp	
	_UI_Enter_Esc_Diag_Resp     db 0			; Response to ENTER or ESC dialog
												; 0=ESC, 1 = ENTER 
	
	FDTestBaseRow               db 0

    WelcomeLbl					db 'PC Workout        v2-build-$'
    GoodbyeMsg					db 'Goodbye!',13,10,'$' 
	InformationLbl				db 'Information$'
	CPULbl						db 'CPU$'
	FPULbl						db 'FPU$' 	
	CPUBenchmarkLbl				db 'CPU Benchmark$'
	FPUBenchmarkLbl				db 'FPU Benchmark$'
	DriveTypeNMediaMsg	        db 'Drive X              Media$' 
	DriveReadTestMsg	        db 'Reading Test [          ] Track$' 
	BlankStatusMsg              db '                           $'
    MediaNotPresentMsg          db 'Media not present$'
    RetrySkipMsg                db '[ENTER] retry  [ESC] skip  $'
	ProgressChar                db '=$'
    MenuOp1Lbl                  db '[F2] Floppy Test  $'
    MenuOp1Lb2                  db '[F3] Video Test   $'
    MenuOp1Lb3                  db '[F4] Speaker Test $'
	EscExitLbl                  db '[F10] Exit$'
    PCSpeakerTestPlaying		db 'PC Speaker music playing..$'
   	PressAnyKeyToStop			db 'Press any key to stop$'
   	
.CODE		
	.8086
	JUMPS

    EXTRN _KB_ENTER_ESC_Q:PROC					; From LIB/KB.ASM    
	EXTRN _SCRN_PRINT_TEXT:PROC                 ; From LIB/SCREEN.ASM
	EXTRN _SCRN_SET_VIDEO_MODE:PROC				
	EXTRN _SCRN_SET_BACKGROUND:PROC
	EXTRN _SCRN_DISABLE_CURSOR:PROC
	EXTRN _SCRN_DISABLE_BLINKING_TEXT:PROC
	EXTRN _SCRN_PRINT_TEXT:PROC

;----
; _UI_SETUP
; Set the basic screen with the video mode, background, titles and basic options.
; Inputs: None
; Output: None
; Destroys: None
;----
PUBLIC _UI_SETUP
_UI_SETUP PROC
	
	mov _SCRN_VideoMode,01h								
	call _SCRN_SET_VIDEO_MODE					; Setup text mode 1 (40x25x16)
	
	call _SCRN_DISABLE_CURSOR			 
	call _SCRN_DISABLE_BLINKING_TEXT	
	
	mov _SCRN_Attribute,BACKGROUND_STYLE 
	call _SCRN_SET_BACKGROUND

	mov _SCRN_Attribute,TITLE_STYLE	
	mov _SCRN_Position_X,TITLE_COL
	mov _SCRN_Position_Y,TITLE_ROW
	lea si,WelcomeLbl
	call _SCRN_PRINT_TEXT

	mov _SCRN_Position_X,VERSION_COL
	lea si,_VER_VersionLbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Attribute,LABEL_STYLE	
	mov _SCRN_Position_X,INFO_TITLE_COL
	mov _SCRN_Position_Y,INFO_TITLE_ROW
	lea si,InformationLbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,CPU_TITLE_ROW
	lea si,CPULbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,FPU_TITLE_ROW
	lea si,FPULbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_X,CPU_BENCH_TITLE_COL
	mov _SCRN_Position_Y,CPU_BENCH_TITLE_ROW
	lea si,CPUBenchmarkLbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,FPU_BENCH_TITLE_ROW
	lea si,FPUBenchmarkLbl
	call _SCRN_PRINT_TEXT	

	ret
_UI_SETUP ENDP

;----
; _UI_SET_STATUS
; Display text in the status area
; Inputs: si points to the text to display. Must be $ terminated.
; Output: none
; Destroys: none
;----
PUBLIC _UI_SET_STATUS
_UI_SET_STATUS PROC
	mov _SCRN_Attribute,STATUS_STYLE	
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
PUBLIC _UI_SET_PROMPT
_UI_SET_PROMPT PROC
	mov _SCRN_Attribute,STATUS_STYLE	
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
PUBLIC _UI_CLEAR_STATUS
_UI_CLEAR_STATUS PROC
    lea si,BlankStatusMsg
	mov _SCRN_Attribute,STATUS_STYLE	
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
PUBLIC _UI_CLEAR_PROMPT
_UI_CLEAR_PROMPT PROC
    lea si,BlankStatusMsg
	mov _SCRN_Attribute,STATUS_STYLE	
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
PUBLIC _UI_DRIVE_TEST_TITLES
_UI_DRIVE_TEST_TITLES PROC
    mov _SCRN_Attribute,LABEL_STYLE			; set style
    mov _SCRN_Position_X,DRIVE_TEST_COL		; set the column 
                                       		; calculate the row
    call FD_TEST_CALCULATE_BASE_ROW
											; calculate the row
    push ax                            		; save registers
    
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            
	
	lea si,DriveTypeNMediaMsg	
	call _SCRN_PRINT_TEXT

	inc _SCRN_Position_Y
	lea si,DriveReadTestMsg	
	call _SCRN_PRINT_TEXT
	
	pop ax									; restore registers                         

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
PUBLIC _UI_ADD_FD_TYPE_VALUE
_UI_ADD_FD_TYPE_VALUE PROC
    mov _SCRN_Attribute,DYN_INFO_STYLE		; set style
    mov _SCRN_Position_X,DRIVE_ID_COL		; set the column 
											; calculate the row
    call FD_TEST_CALCULATE_BASE_ROW
											; calculate the row
    push ax									; save registers
    
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            

    pop ax 									; restore register                         
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
PUBLIC _UI_ADD_FD_MEDIA_VALUE
_UI_ADD_FD_MEDIA_VALUE PROC
    mov _SCRN_Attribute,DYN_INFO_STYLE		; set style
    mov _SCRN_Position_X,DRIVE_MEDIA_COL	; set the column 
											; calculate the row
    call FD_TEST_CALCULATE_BASE_ROW
											; calculate the row
    push ax									; save registers
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al            

    pop ax									; restore register                        
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
PUBLIC _UI_PRINT_TRACK_NUM
_UI_PRINT_TRACK_NUM PROC
    mov _SCRN_Attribute,DYN_INFO_STYLE	; set style
    mov _SCRN_Position_X,TRACK_NUM_COL	; set the column 
    
    call FD_TEST_CALCULATE_BASE_ROW
										; calculate the row
    push ax								; save registers
    mov al,FDTestBaseRow
    inc al								; 2nd row    
    mov _SCRN_Position_Y,al            

    pop ax								; restore registers
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
PUBLIC _UI_DISPLAY_FD_PROGRESS
_UI_DISPLAY_FD_PROGRESS PROC

    cmp _UI_Progress_FDT,0					; Reset progress at 0
    je ui_display_fd_prog_end
    
    lea si,ProgressChar
    mov _SCRN_Attribute,DYN_INFO_STYLE   	; set style
    mov _SCRN_Position_X,FD_READ_TEST_COL	; set the column 
											; calculate the row

    call FD_TEST_CALCULATE_BASE_ROW
    
    push ax									; save registers
    push cx
    
    mov al,FDTestBaseRow
    inc al									; 2nd row
    mov _SCRN_Position_Y,al            
    
    xor cx,cx								; setup the counter
    mov cl,_UI_Progress_FDT

repeat_print_prog_char:
    call _SCRN_PRINT_TEXT 
    inc _SCRN_Position_X
    loop repeat_print_prog_char                 
    
    pop cx									; restore registers
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
PUBLIC _UI_FD_READ_TEST_RESULT
_UI_FD_READ_TEST_RESULT PROC
    
    call FD_TEST_CALCULATE_BASE_ROW
    
    push ax
    
    mov _SCRN_Attribute,DYN_INFO_STYLE		; set style
    mov _SCRN_Position_X,FD_READ_TEST_COL	; set the column 
    inc FDTestBaseRow
    mov al,FDTestBaseRow
    mov _SCRN_Position_Y,al
    call _SCRN_PRINT_TEXT 
    
    pop ax
    
	ret
_UI_FD_READ_TEST_RESULT ENDP

;----
; _UI_PROMPT_INSERT_MEDIA
; Display a user prompt to select between two options
; Inputs:
; Output: _UI_Enter_Esc_Diag_Resp = 0 if ESC, = 1 if ENTER
; Destroys: none
;----
PUBLIC _UI_PROMPT_INSERT_MEDIA
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

;----
; _UI_TEARDOWN
; Return text mode to 80x25.
; Inputs: None
; Output: None
; Destroys: None
;----
PUBLIC _UI_TEARDOWN
_UI_TEARDOWN PROC

	mov _SCRN_VideoMode,03h					
	call _SCRN_SET_VIDEO_MODE					; Setup text mode 3 (80x25x16)
	
	mov ah,09h									; INT 21h, Function 09h - Print string to console
	mov dx,OFFSET GoodbyeMsg	
	int 21h		
	
	ret
_UI_TEARDOWN ENDP


;----
; _UI_DISPLAY_MENU
; Render all menu options in their correct status
; Inputs: None
; Output: None
; Destroys: None
;----
PUBLIC _UI_DISPLAY_MENU
_UI_DISPLAY_MENU PROC

	mov _SCRN_Attribute,MENU_OPTION_STYLE	
	mov _SCRN_Position_X,OPTION1_COL
	mov _SCRN_Position_Y,OPTION1_ROW
	lea si,MenuOp1Lbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,OPTION2_ROW
	lea si,MenuOp1Lb2
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,OPTION3_ROW
	lea si,MenuOp1Lb3
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,EXIT_ROW
	lea si,EscExitLbl
	call _SCRN_PRINT_TEXT
	
	ret
_UI_DISPLAY_MENU ENDP

;----
; _UI_PRINT_CPU_ID
; Print the CPU ID
; Inputs: SI has the label to display
; Output: None
; Destroys: None
;----
PUBLIC _UI_PRINT_CPU_ID
_UI_PRINT_CPU_ID PROC    
	mov _SCRN_Attribute,DYN_INFO_STYLE	
	mov _SCRN_Position_X,CPU_ID_COL
	mov _SCRN_Position_Y,CPU_ID_ROW
	call _SCRN_PRINT_TEXT
	
	ret
_UI_PRINT_CPU_ID ENDP

;----
; _UI_PRINT_FPU_ID
; Print the FPU ID
; Inputs: SI has the label to display
; Output: None
; Destroys: None
;----
PUBLIC _UI_PRINT_FPU_ID
_UI_PRINT_FPU_ID PROC
	mov _SCRN_Attribute,DYN_INFO_STYLE	
	mov _SCRN_Position_X,FPU_ID_COL
	mov _SCRN_Position_Y,FPU_ID_ROW			; Move cursor down
	call _SCRN_PRINT_TEXT
	ret
_UI_PRINT_FPU_ID ENDP

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
    mov bl,03h                         ; 
    mul bl                             ; each drive takes 3 rows,  ax = al*bl
    add al,FD_START_ROW                ; add start row
    mov FDTestBaseRow,al  
    pop bx                             ; restore registers
    pop ax  
	ret
FD_TEST_CALCULATE_BASE_ROW ENDP



;----
; _UI_PROMPT_PCSPKR_PLAYING
; Display a message to the user that the speaker test is playing,
; but that it can be interrupted with any key
; Inputs: none
; Output: none
; Destroys: none
;----
PUBLIC _UI_PROMPT_PCSPKR_PLAYING
_UI_PROMPT_PCSPKR_PLAYING PROC
        
    call _UI_CLEAR_PROMPT
    call _UI_CLEAR_STATUS

    lea si,PCSpeakerTestPlaying
    call _UI_SET_STATUS
    
    lea si,PressAnyKeyToStop
    call _UI_SET_PROMPT
    
    ret
_UI_PROMPT_PCSPKR_PLAYING ENDP
    
END