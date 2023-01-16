; PCWO.ASM
; 
; Description: Main program for PC Workout - This small program is designed to 
; run multiple computer functions to ensure all aspects of the computer are 
; working as expected
;
; Author: Homero Trevino <homerotl@gmail.com>

; Constants
; 	Style
	BackgroundStyle	equ 40h	; Black text over red background
	TitleStyle 		equ 04h	; Red text over black background
	LableStyle		equ 4fh ; White text over red background
	
.MODEL small

.STACK 100h

.DATA
	
	; Text for the interactive mode
    WelcomeLbl					db 'PC Workout by Homero Trevino - v1.000$'
	InformationLbl				db 'Information$'
	CPULbl						db 'CPU$'
	FPULbl						db 'FPU$' 	
	CPUBenchmarkLbl				db 'CPU Benchmark$'
	FPUBenchmarkLbl				db 'FPU Benchmark$'
	
;	MenuOptionStyle				db 40h ; Black text over red background
;	SelectedOptionStyle 		db 70h ; Black text over white background

;	DynInfoStyle				db 40h ; Black text over red background
;	StatusStyle					db 40h ; Black text over red background
	
	; Text for the command line mode
    CommLineErrorMsg			db 'ERROR: Invalid command line option',13,10,'$' 

    SyntaxMsg					db 'Syntax:',13,10
    							db '   pcwo <options>',13,10
    							db '<options> can be:',13,10
    							db '   -v   Verbose mode enabled',13,10
    							db '   -a   Autorun. Skip all user prompts',13,10,'$' 
    
    VerboseEnMsg				db ' - Verbose mode enabled',13,10,'$'
    AutoRunMsg					db ' - Autorun mode enabled',13,10,'$'
    
    GoodbyeMsg					db 'Goodbye!',13,10,'$' 
    
    
    ; Variables defined somewhere else
    EXTRN _SCRN_VideoMode:BYTE						; From LIB/SCREEN.ASM  
    EXTRN _SCRN_Character:BYTE
	EXTRN _SCRN_Attribute:BYTE		
	EXTRN _SCRN_Position_X:WORD
	EXTRN _SCRN_Position_Y:BYTE

	
	; Public variables
	PUBLIC _VerboseEnableFlag
    _VerboseEnableFlag			db 0

	PUBLIC _AutoRunFlag
    _AutoRunFlag				db 0
	
	; Private variables
	CommandLineErrorFlag 		db 0
	ProgramExitSignal			db 0
	
.CODE

	EXTRN _CL_PARSE_COMMAND_LINE:PROC			; From COMMLN.ASM
	EXTRN _KB_WAIT_ANY_KEY:PROC					; From LIB/KB.ASM
	EXTRN _SCRN_SET_VIDEO_MODE:PROC				; From LIB/SCREEN.ASM
	EXTRN _SCRN_SET_BACKGROUND:PROC
	EXTRN _SCRN_DISABLE_CURSOR:PROC
	EXTRN _SCRN_DISABLE_BLINKING_TEXT:PROC
	EXTRN _SCRN_PRINT_TEXT:PROC
		
	
MAIN PROC										; Main program
	.8086
	call _CL_PARSE_COMMAND_LINE

	mov ax,@DATA		 						; Align data segment
	mov ds,ax									; Set DS to the data segment
	and sp, not 3

	call INITIALIZE								; This checks for command line parameters
	
	cmp CommandLineErrorFlag,1					; Check if command line parsing was fine
	je m_end

	call UI_SETUP								; Change video mode and paint initial screen
	
	; call OT_DETECTION							; Run one-time detection procedure
	
m_interactive_loop:

	; call DRAW_MENU							; Draw menu on its current state

	call INPUT_DISPATCH							; Wait for KB input and act on it

	;je ProgramExitSignal,0						; 
	
	;jmp m_interactive_loop

	call UI_TEARDOWN							; Return to 80 column text mode 
	
m_end:

	mov ah,09h									; INT 21h, Function 09h - Print string to console
	mov dx,OFFSET GoodbyeMsg	
	int 21h		
	
	mov ah,4ch									; INT 21h, Function 4ch - End program	
	int 21h	
	
MAIN ENDP

;----
; INITIALIZE
; Check parameters and determined run mode (command line vs interactive)
; Inputs:
; 	- cl contains the flags for command line
; Output: None
; Destroys: None
;----
INITIALIZE PROC
	mov ch,cl									; Copy cl
	and ch,1									; if the first bit is 1 then we have error
	cmp ch,1
	je command_line_error
	
	mov ch,cl									; Copy cl
	and ch,2									; if the second bit is 1 then Verbose is enabled
	cmp ch,2					
	jne check_autorun
	
	mov ah,09h									; Display Verbose enabled message									
	mov dx,OFFSET VerboseEnMsg	
	int 21h										; INT 21h, Function 09h - Print string to console
	mov _VerboseEnableFlag,1
	
check_autorun:
	mov ch,cl									; Copy cl
	and ch,4									; if the third bit is 1 then Autorun is enabled
	cmp ch,4					
	jne init_end
	
	mov ah,09h
	mov dx,OFFSET AutoRunMsg	
	int 21h										; INT 21h, Function 09h - Print string to console
	mov _AutoRunFlag,1
	jmp init_end	

command_line_error:
	mov ah,09h
	mov dx,OFFSET CommLineErrorMsg
	int 21h										; INT 21h, Function 09h - Print string to console
	
	mov ah,09h
	mov dx,OFFSET SyntaxMsg
	int 21h										; INT 21h, Function 09h - Print string to console
	
	mov CommandLineErrorFlag,1

init_end:	
	ret
INITIALIZE ENDP

;----
; UI_SETUP
; Set the basic screen with the video mode, background, titles and basic options.
; Inputs: None
; Output: None
; Destroys: None
;----
UI_SETUP PROC
	
	mov _SCRN_VideoMode,01h				
				
	call _SCRN_SET_VIDEO_MODE					; Setup text mode 1 (40x25x16)
	call _SCRN_DISABLE_CURSOR			 
	call _SCRN_DISABLE_BLINKING_TEXT	
	
	mov _SCRN_Character,20h						; Space ASCII
	mov _SCRN_Attribute,BackgroundStyle 
	call _SCRN_SET_BACKGROUND

	mov _SCRN_Attribute,TitleStyle	
	mov _SCRN_Position_X,1
	mov _SCRN_Position_Y,1
	lea si,WelcomeLbl
	call _SCRN_PRINT_TEXT

	mov _SCRN_Attribute,LableStyle	
	mov _SCRN_Position_Y,2
	lea si,InformationLbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,3
	lea si,CPULbl
	call _SCRN_PRINT_TEXT
	
	mov _SCRN_Position_Y,4
	lea si,FPULbl
	call _SCRN_PRINT_TEXT
	
	ret
UI_SETUP ENDP

;----
; UI_TEARDOWN
; Return text mode to 80x25.
; Inputs: None
; Output: None
; Destroys: None
;----
UI_TEARDOWN PROC
	mov _SCRN_VideoMode,03h					
	call _SCRN_SET_VIDEO_MODE					; Setup text mode 3 (80x25x16)
	ret
UI_TEARDOWN ENDP

;----
; INPUT_DISPATCH
; Wait for input on the keyboard and dpending on it take action
; Inputs: None
; Output: None
; Destroys: None
;----
INPUT_DISPATCH PROC
	call _KB_WAIT_ANY_KEY
	ret
INPUT_DISPATCH EndP

END