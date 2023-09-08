; DISK_IO.ASM
; Source for Disk I/O Procedures, mostly INT 13h calls
; Author: Homero Trevino <homerotl@gmail.com>

.MODEL small

.DATA      
	DIO_DiskReadBuf				db 9216 dup(0)	; 
	
	public _DIO_NumberOfDisks
	_DIO_NumberOfDisks 			db 0

	; Drive types
	DIO_DriveType_5_25_360KB	db 0
	DIO_DriveType_5_25_1200KB	db 1
	DIO_DriveType_3_5_720KB		db 2
	DIO_DriveType_3_5_1440KB	db 3
	DIO_DriveType_3_5_2880KB	db 4
	DIO_DriveType_UNKNOWN 		db 0ffh
	
	public _DIO_DriveType
	_DIO_DriveType 				db 0

	; Media types
	DIO_MediaType_360K			db 0
	DIO_MediaType_1200K			db 1
	DIO_MediaType_720K			db 2
	DIO_MediaType_1440K			db 3
	DIO_MediaType_2880K			db 4	
	DIO_MediaType_UNKNOWN		db 0fch		; No error, but type unknown
	DIO_MediaType_SYS_RET_ERROR	db 0fdh		; System retryable error
	DIO_MediaType_USR_RET_ERROR	db 0feh		; User retryable error
	DIO_MediaType_FATAL_ERROR	db 0ffh		; Fatal error

	public _DIO_MediaType
	_DIO_MediaType				db 0
	
.CODE
	.8086
		
	PUBLIC _DIO_READ_SECTOR			; Declare public
	PUBLIC _DIO_RESET_DISK_SYSTEM
	PUBLIC _DIO_INT13H_ERROR_IS_SYS_RETRIABLE
	PUBLIC _DIO_INT13H_ERROR_IS_USER_RETRIABLE
	PUBLIC _DIO_GET_NUMBER_OF_FD
	PUBLIC _DIO_DETECT_FD_TYPE
	PUBLIC _DIO_DETECT_MEDIA_TYPE
	
;----
; _DIO_READ_SECTOR 
; Read one disk sector into memory with 3 automatic retries
; Inputs:
; 	- ch - track (0,79)
;   - dh - head / side (0-1)
;   - dl - drive (0 = a:, 1=b: ...)
;   - al - sectors to read
; Output: 
;	- Carry flag set if there was an error. Register ah contains error code
; Destroys:
;----
_DIO_READ_SECTOR PROC

DIO_RetryRead:
	clc							; Clear carry flag
	cld							; Ensure the right direction
	mov ah,02h					; Function
	mov cl,01h					; sector number (bits 0-5) (high 2 bits of cylinder, 6-7 HD only) (1-18)
	mov bx,@DATA				; Align es with the data segment
	mov es,bx
	lea bx,DIO_DiskReadBuf		; load es:bx with the segment:offset to the read buffer
	int 13h						; Function 02h int 13h - Read sector(s) into memory
	ret
_DIO_READ_SECTOR ENDP

_DIO_RESET_DISK_SYSTEM PROC
	mov ah,00h					; 
	int 13h						; Function 00h int 13h - Reset disk system 
	ret
_DIO_RESET_DISK_SYSTEM ENDP

;----
; _DIO_INT13H_ERROR_IS_SYS_RETRIABLE 
; Check if an int 13h error code status should be auto-retried by the system
; Inputs:
;   ah = status from the int 13h operation
; Output: 
;	al = 1 if yes, 0 if not
; Destroys: al
;----
_DIO_INT13H_ERROR_IS_SYS_RETRIABLE PROC
	cmp ah,06h
	je YesSysRetriable
	cmp ah,0Ah
	je YesSysRetriable
	cmp ah,0Bh
	je YesSysRetriable
	cmp ah,10h
	je YesSysRetriable
	cmp ah,80h
	je YesSysRetriable
	cmp ah,0AAh
	je YesSysRetriable
	cmp ah,0CCh
	je YesSysRetriable
	cmp ah,0FFh
	je YesSysRetriable
	mov al,0
	ret
YesSysRetriable:
	mov al,1
	ret
_DIO_INT13H_ERROR_IS_SYS_RETRIABLE ENDP

;----
; _DIO_INT13H_ERROR_IS_USER_RETRIABLE 
; Check if we should ask the user to retry for a given int 13h error code
; Inputs:
;   ah = status from the int 13h operation
; Output: 
;	al = 1 if yes, 0 if not
; Destroys: al
;----
_DIO_INT13H_ERROR_IS_USER_RETRIABLE PROC
	cmp ah,03h
	je YesUsrRetriable
	cmp ah,0Ah
	je YesUsrRetriable
	cmp ah,0Bh
	je YesUsrRetriable
	cmp ah,10h
	je YesUsrRetriable
	cmp ah,80h
	je YesUsrRetriable
	cmp ah,0AAh
	je YesUsrRetriable
	cmp ah,0CCh
	je YesUsrRetriable
	cmp ah,0FFh
	je YesUsrRetriable
	mov al,0
	ret
YesUsrRetriable:
	mov al,1
	ret
_DIO_INT13H_ERROR_IS_USER_RETRIABLE ENDP

;----
; _DIO_GET_NUMBER_OF_FD
; Get the number of floppy drives in the system
; Inputs:
;   none
; Output: 
;	result is in public byte DIONumberOfDisks. If error, then returns 255 (ffh)
; Destroys: none
;----
_DIO_GET_NUMBER_OF_FD PROC	
	push ax							; save registers
	push dx
	
	clc								; clear carry flag	
	
	mov ah,08h						; Function 08h int 13h - Get drive params
	mov dl,0
	int 13h

	jc DIO_GNumFDError				; If error jump
	
	mov _DIO_NumberOfDisks,dl		; save the number of drives in the public variable
	jmp DIO_GNumFDRet				; get to the end
	
DIO_GNumFDError:
	mov _DIO_NumberOfDisks,0ffh		; 255 = error
	
DIO_GNumFDRet:
	pop dx							; restore registers and return
	pop ax
	ret
_DIO_GET_NUMBER_OF_FD EndP

;----
; _DIO_DETECT_FD_TYPE
; Get the number of floppy drives in the system
; Inputs:
;   dl = drive number
; Output: 
;	DIO_DriveType will have a number with the type
; Destroys: ES:DI
;----
_DIO_DETECT_FD_TYPE PROC
	
	push ax							; save registers
	push bx
	push cx
	push dx
									; Do I have to worry about ES:DI?
	mov ah,08h						; Function 08h int 13h - Get drive params
	int 13h
	
	cmp bl,01h						; Check type
	je DIO_DFDT_01

	cmp bl,02h						
	je DIO_DFDT_02

	cmp bl,03h						
	je DIO_DFDT_03

	cmp bl,04h						
	je DIO_DFDT_04

	cmp bl,05h						
	je DIO_DFDT_05
	
	jmp DIO_DFDT_UNKNOWN

DIO_DFDT_01:						; Type 1 5.25" 360KB
	mov ah,DIO_DriveType_5_25_360KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END
	
DIO_DFDT_02:						; Type 2, depends on cylinders
	cmp ch,27h
	je DIO_DFDT_02_CYL_27H			; 39 cylinders
	cmp ch,4fh
	je DIO_DFDT_02_CYL_4FH			; 79 cylinders
	
	jmp DIO_DFDT_UNKNOWN

DIO_DFDT_03:						; Type 3, need more examples
	jmp DIO_DFDT_UNKNOWN

DIO_DFDT_04:						; Type 4, depends on sectors
	cmp cl,09h
	je DIO_DFDT_04_SEC09			; 9 sectores
	cmp cl,12h
	je DIO_DFDT_04_SEC12			; 18 sectors

	jmp DIO_DFDT_UNKNOWN
	
DIO_DFDT_05:						; Type 5
	mov ah,DIO_DriveType_3_5_2880KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END

DIO_DFDT_02_CYL_27H:
	mov ah,DIO_DriveType_5_25_360KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END

DIO_DFDT_02_CYL_4FH:
	mov ah,DIO_DriveType_5_25_1200KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END
	
DIO_DFDT_04_SEC12:
	mov ah,DIO_DriveType_3_5_1440KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END

DIO_DFDT_04_SEC09:
	mov ah,DIO_DriveType_3_5_720KB
	mov _DIO_DriveType,ah
	jmp DIO_DFDT_END

DIO_DFDT_UNKNOWN:
	mov ah,DIO_DriveType_UNKNOWN
	mov _DIO_DriveType,ah		

DIO_DFDT_END:
	pop ax							; restore registers
	pop bx
	pop cx
	pop dx	
	ret
_DIO_DETECT_FD_TYPE ENDP

;----
; _DIO_DETECT_MEDIA_TYPE
; Detect the type of media currently in the dirive.
; Inputs:
;   dl = drive number
; Output: 
;	_DIO_MediaType will have a number with the type
; Destroys: none
;----
_DIO_DETECT_MEDIA_TYPE PROC

	push ax
	push bx
	push cx
								; Read boot sector
	mov ch,0					; track 0
	mov dh,0					; side/head 0
	mov al,1					; read 1 sector
								; data will be at DIO_DiskReadBuf
	call _DIO_READ_SECTOR

DIO_DMT_Continue:
	
	lea di,DIO_DiskReadBuf		; align di with the read buffer
	mov ax,di[13h]				; copy to ax the total number of sectors

	cmp ax,02d0h				; 02d0h (720 total sectors)
	je DIO_DMT_360KB

	cmp ax,0960h				; 0960h (2400 total sectors)
	je DIO_DMT_1220KB

	cmp ax,05a0h				; 05a0h (1440 total sectors)
	je DIO_DMT_720KB
	
	cmp ax,0b40h				; 0b40h (2880 total sectors)
	je DIO_DMT_1440KB

	cmp ax,1680h				; 0b40h (5760 total sectors)
	je DIO_DMT_2880KB
	
	jmp DIO_DMT_UNKNOWN

DIO_DMT_360KB:
	mov al,DIO_MediaType_360K
	mov _DIO_MediaType,al
	jmp DIO_DMT_End

DIO_DMT_1220KB:
	mov al,DIO_MediaType_1200K
	mov _DIO_MediaType,al
	jmp DIO_DMT_End

DIO_DMT_720KB:
	mov al,DIO_MediaType_720K
	mov _DIO_MediaType,al	
	jmp DIO_DMT_End

DIO_DMT_1440KB:
	mov al,DIO_MediaType_1440K
	mov _DIO_MediaType,al	
	jmp DIO_DMT_End

DIO_DMT_2880KB:
	mov al,DIO_MediaType_2880K
	mov _DIO_MediaType,al	
	jmp DIO_DMT_End
	
DIO_DMT_UNKNOWN:	
	mov al,DIO_MediaType_UNKNOWN
	mov _DIO_MediaType,al		
	
DIO_DMT_End:
	pop cx
	pop bx
	pop ax
	ret
_DIO_DETECT_MEDIA_TYPE ENDP

END