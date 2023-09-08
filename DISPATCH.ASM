; DISPATCH.ASM
; Handle interactive keyboard input and invokes the
; correct procedure
; Author: Homero Trevino <homerotl@gmail.com>

	StatusStyle            equ 40h ; Black text over red background

	ExitKeyScanCode        equ 44h ; F10
		
.MODEL small
		
.DATA
	
	; Status texts
    PCSpeakerMsg    db 'Playing Sound...$'
    BlankStatusMsg  db '                $'

    StatusLbl1  db 'Option 2$'
    StatusLbl2  db 'Option 3$'

	
	EXTRN _SCRN_Attribute:BYTE             ; From LIB/SCREEN.ASM 
	EXTRN _SCRN_Position_X:WORD
	EXTRN _SCRN_Position_Y:BYTE
	
    
    ; On this table we have the valid key inputs and the address
    ; where the corresponding procedure should be called if pressed
    ; The table format is:
    ;       db      72
    ;       dw      OFFSET_TEXT:PROCNAME
    ;       ... repeat for each option
    ;       db      0   ; End of table
    dispatch_table LABEL BYTE
        db  60                              ; F2
        dw  OFFSET _TEXT:_FLOPPY_TEST
        db  61                              ; F3
        dw  OFFSET _TEXT:_VIDEO_TEST
        db  62                              ; F4
        dw  OFFSET _TEXT:_PC_SPEAKER_TEST
        db  0                               ; End of table

.CODE
	.8086
	
	EXTRN _SCRN_PRINT_TEXT:PROC            ; From LIB/SCREEN.ASM
	EXTRN _SCRN_SAVE_SCR:PROC
	EXTRN _SCRN_RESTORE_SCR:PROC       
	
	EXTRN _TEST_PC_SPEAKER:PROC            ; From T_SPEAKER.ASM 
	EXTRN _SCREEN_GEOMETRY_TEST:PROC       ; From T_SCREEN.ASM 

    EXTRN _KB_READ_KEY:PROC                ; From LIB/KB.ASM
    	
    PUBLIC _DISPATCHER


_DISPATCHER PROC
    push ax
    push bx
    push dx
    
dis_loop:
    call _KB_READ_KEY                  ; Read a character into ax
    or ah,ah                           ; ax = -1 if no charcter read, 1 for
                                       ; extended code
    js dis_no_chars_read
    jnz dis_special_key
    jmp dis_loop
   
dis_special_key:
    cmp al,ExitKeyScanCode             ; Check for exit key
    je dis_end_dispatcher    

    lea bx,dispatch_table              ; Lookup code on the table    
dis_special_loop:
    cmp byte ptr [bx],0                ; End of table?
    je dis_not_in_table                ; Key was not in table
    cmp al,[bx]
    je dis_dispatch
    add bx,3
    jmp dis_special_loop               ; Check the next table entry

dis_dispatch:
    inc bx                             ; point to the address of procedure
    call word ptr[bx]                  ; call procedure
    jmp dis_loop                       ; wait for another key

dis_not_in_table:
    jmp dis_loop

dis_no_chars_read:
    ;lea dx,editor_prompt
    ;call WRITE_PROMPT_LINE
    jmp dis_loop
    
dis_end_dispatcher:
    pop dx
    pop bx
    pop ax
    ret
	
_DISPATCHER ENDP


; Dummy proc
_FLOPPY_TEST PROC
    mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,0eh
	mov _SCRN_Position_Y,17h
	lea si,StatusLbl1
	call _SCRN_PRINT_TEXT
    ret
_FLOPPY_TEST ENDP

; Dummy proc
_VIDEO_TEST PROC
	
	call _SCRN_SAVE_SCR                    ; save current screen

	call _SCREEN_GEOMETRY_TEST             ; execute the test and wait for a key

    call _SCRN_RESTORE_SCR	               ; restore screen
    	
	ret
_VIDEO_TEST ENDP

; Dummy proc
_PC_SPEAKER_TEST PROC

	mov _SCRN_Attribute,StatusStyle	
	mov _SCRN_Position_X,0eh     ; 14
	mov _SCRN_Position_Y,17h     ; 23
	lea si,PCSpeakerMsg
	call _SCRN_PRINT_TEXT
	
	call _TEST_PC_SPEAKER
	
	mov _SCRN_Position_X,0eh     ; 14
	mov _SCRN_Position_Y,17h     ; 23
	lea si,BlankStatusMsg
	call _SCRN_PRINT_TEXT
	
	ret
_PC_SPEAKER_TEST EndP

END