; DISPATCH.ASM
; Handle interactive keyboard input and invokes the
; correct procedure
; Author: Homero Trevino <homerotl@gmail.com>

	ExitKeyScanCode        equ 44h ; F10
		
.MODEL small
		
.DATA	
    
    ; On this table we have the valid key inputs and the address
    ; where the corresponding procedure should be called if pressed
    ; The table format is:
    ;       db      72
    ;       dw      OFFSET_TEXT:PROCNAME
    ;       ... repeat for each option
    ;       db      0   ; End of table
    dispatch_table LABEL BYTE
        db  60                              ; F2
        dw  OFFSET _TEXT:_TEST_FLOPPY
        db  61                              ; F3
        dw  OFFSET _TEXT:_SCREEN_GEOMETRY_TEST
        db  62                              ; F4
        dw  OFFSET _TEXT:_TEST_PC_SPEAKER
        db  0                               ; End of table

.CODE
	.8086

	EXTRN _UI_SET_STATUS:PROC              ; From UI.ASM 
	EXTRN _TEST_PC_SPEAKER:PROC            ; From T_SPEAKER.ASM 
	EXTRN _SCREEN_GEOMETRY_TEST:PROC       ; From T_SCREEN.ASM 
    EXTRN _TEST_FLOPPY:PROC                ; From T_FLOPPY.ASM
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
    js dis_loop
    jnz dis_special_key
    jmp dis_loop
   
dis_special_key:
    
    cmp al,ExitKeyScanCode             ; Check for exit key
    je dis_end_dispatcher    
    lea bx,dispatch_table              ; Lookup code on the table    
    
dis_special_loop:
    cmp byte ptr [bx],0                ; End of table?
    je dis_loop                        ; Key was not in table
    cmp al,[bx]
    je dis_dispatch
    add bx,3
    jmp dis_special_loop               ; Check the next table entry

dis_dispatch:
    inc bx                             ; point to the address of procedure
    call word ptr[bx]                  ; call procedure
    jmp dis_loop                       ; wait for another key

dis_end_dispatcher:
    pop dx
    pop bx
    pop ax
    ret
	
_DISPATCHER ENDP

END