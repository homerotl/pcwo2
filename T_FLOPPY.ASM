; T_FLOPPY.ASM
; Source for the Floppy drive tests
; Author: Homero Trevino <homerotl@gmail.com>
;
.MODEL small

MAX_RETRIES EQU 4

.DATA

	ReadRetries    		db 0
	CurrentDriveIndex 	db 0

	SectorsToRead		db 0
	CylindersToRead		db 0
	
	TryingDriveMsg		db 'Identifying drive $' 
	DriveTypeMsg		db 'Drive type: $' 
	MediaTypeMsg		db 'Media type: $'
	RetryMsgQ      		db 'Would you like to retry? (Y/N)',13,10,'$' 
	ErrorMessage   		db 'Error reading disk: $' 
	ReadingSec     		db 'Reading track: $'
    FloppyFailed   		db 'Floppy read test FAILED',13,10,'$'
    FloppyOKMsg    		db 'Floppy read test SUCCESS!',13,10,'$'
    NoFloppyDrivesMsg	db 'No floppy drives detected. Skipping test.',13,10,'$'
    
	DDT_0				db '5.25" - 360 KB$'
	DDT_1				db '5.25" - 1.2 MB$'
	DDT_2				db '3.5" - 720 KB$'
	DDT_3				db '3.5" - 1.44 MB$'
	DDT_4				db '3.5" - 2.88 MB$'
	DDT_UK				db 'Unknown$'
    
    DMT_0				db '360 KB$'
	DMT_1				db '1.2 MB$'
	DMT_2				db '720 KB$'
	DMT_3				db '1.44 MB$'
	DMT_4				db '2.88 MB$'
	DMT_UK				db 'Unknown$'
    
	EXTRN _VerboseEnableFlag:BYTE	; Global flags
	EXTRN _AutoRunFlag:BYTE							

	EXTRN _DIO_NumberOfDisks:BYTE	; From DISK_IO.ASM
	EXTRN _DIO_DriveType:BYTE	
	EXTRN _DIO_MediaType:BYTE	
  						
	EXTRN _NumToAsciiB:BYTE			; From STRINGS.ASM
	EXTRN _CRLF:BYTE
	
.CODE
JUMPS

	EXTRN _TOSTRING:PROC				 	; Required predures defined elsewhere	
	
	EXTRN _DIO_READ_SECTOR:PROC
	EXTRN _DIO_RESET_DISK_SYSTEM:PROC	
	EXTRN _DIO_INT13H_ERROR_IS_SYS_RETRIABLE:PROC
	EXTRN _DIO_INT13H_ERROR_IS_USER_RETRIABLE:PROC
	EXTRN _DIO_GET_NUMBER_OF_FD:PROC	
	EXTRN _DIO_DETECT_FD_TYPE:PROC
	EXTRN _DIO_DETECT_MEDIA_TYPE:PROC
	
	EXTRN _KB_WAIT_ANY_KEY:PROC
	EXTRN _KB_YES_NO_Q:PROC
	
	PUBLIC _TEST_FLOPPY
	
;----
; _TEST_FLOPPY 
; Procedure to detect system floppy drives, identify and test them
; Inputs: None
; Output: None
; Destroys: All registers
;----
_TEST_FLOPPY PROC
	
	call _DIO_GET_NUMBER_OF_FD			; Check number of floppy drives,
										; retuns DIONumberOfDisks

	cmp _DIO_NumberOfDisks,0				; If its 0 we are done
	je TF_NoFloppyDrives
	
	mov CurrentDriveIndex,0				; start with drive 0
	
TF_Continue:

	mov dl,CurrentDriveIndex			
	call TRYING_DRIVE_MSG

	mov dl,CurrentDriveIndex
	call _DIO_DETECT_FD_TYPE

	call DISPLAY_DRIVE_TYPE			
	
	cmp _DIO_DriveType,0ffh				; Check if we know the drive type
	je TF_NextDrive

	mov dl,CurrentDriveIndex
	call _DIO_DETECT_MEDIA_TYPE
	
	cmp _DIO_MediaType,0ffh				; Check for error
	je TF_NextDrive

	call DISPLAY_MEDIA_TYPE
	
	mov dl,CurrentDriveIndex	
	call TF_READ_TEST

	jmp TF_NextDrive
	
TF_NoFloppyDrives:
	mov ah,09h							; Function 09h int 21h - Print string to console
	mov dx,OFFSET NoFloppyDrivesMsg	
	int 21h
	jmp TF_Done

TF_NextDrive:
	inc CurrentDriveIndex
	mov dl,CurrentDriveIndex
	cmp dl,_DIO_NumberOfDisks
	je TF_Done

	jmp TF_Continue

TF_Done:
	ret
_TEST_FLOPPY EndP

;----
; TF_READ_TEST 
; Prompt the use to insert a floppy disk on drive A and test it
; Assumes 2 side, assumes 512 bytes per sector/track
; Inputs:
;	- dl = drive to use (Flopies 0 = a:, 1 = b:,)
;   - SectorsToRead is a byte in the data segment to indicate the number of sectors to read
;	- CylindersToRead is a byte in the data segment to indicate the number of tracks/cylinders to read
; Output: 
;	- None
; Destroys:
;	- None
;----
TF_READ_TEST PROC

	mov ReadRetries,0			; Reset retries
	
	mov ch,0					; start cylinder
	mov dh,0					; start head 
	
ContinueReading:

	cmp ch,CylindersToRead
	jge DoneReadingOk

	mov al,SectorsToRead
	call _DIO_READ_SECTOR
	
	jnc SuccessReading			; Carry flag, that means error

                                ; Error handling. We assume ah has the error code
    call _DIO_INT13H_ERROR_IS_SYS_RETRIABLE
    cmp al,0
    je ErrorNotSystemRetryable
    
    							; It is system retryable
	cmp ReadRetries,MAX_RETRIES ; Failed, lets check retries
	jge ErrorNotSystemRetryable ; Maybe it could be user retriable
	inc ReadRetries				; increment Retries

	call _DIO_RESET_DISK_SYSTEM
	
	jmp ContinueReading			; Try again

ErrorNotSystemRetryable:
	
	call _DIO_INT13H_ERROR_IS_USER_RETRIABLE
	
	cmp al,0
	je DoneWithError

	call PRINT_ERROR_CODE		; If it ended in error
	
	push ax						; Save registers
	push dx
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET RetryMsgQ	    ; 
	int 21h
	
	call _KB_YES_NO_Q			; Check for the answer
	cmp al,0					; If No
	
	pop dx						; Restore registers
	pop ax
	
	jz TF_RT_Done				; Go to the end
	
	mov ReadRetries,0			; Reset retries
	jmp ContinueReading

SuccessReading:

	cmp dh,0					; Is this head 0? yes, change to 1,
	je ChangeSide
	mov dh,0					; set back to head 0
	inc ch						; cylinder++
	jmp ContinueReading

ChangeSide:

	push ax
	push dx
	
	mov ah,ch					; put the track on ah for converting to string
	call _TOSTRING				; convert the value in ah to an ASCII decimal string
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET ReadingSec	; String to show
	int 21h
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET _NumToAsciiB	; String to show
	int 21h
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET _CRLF			; String to show
	int 21h

	pop dx
	pop ax	

	mov dh,1					; set head to 1
	jmp ContinueReading
	
DoneWithError:

	call PRINT_ERROR_CODE		; If it ended in error
	
	push ax
	push dx
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET FloppyFailed	
	int 21h
	
	pop dx
	pop ax
	
	jmp	TF_RT_Done

DoneReadingOk:

	push ax
	push dx
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET FloppyOKMsg	
	int 21h

	pop dx
	pop ax
	
TF_RT_Done:
	ret
TF_READ_TEST ENDP

;----
; PRINT_ERROR_CODE 
; Handles error codes returned by int 13h and prints the error code as a decimal
; Inputs:
; 	- ah - error code
; Output: 
;	- none
; Destroys: none
;----
PRINT_ERROR_CODE PROC
	
	call _TOSTRING				; convert the value in ah to an ASCII decimal string
	
	push dx
	push ax
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET ErrorMessage	; String to show
	int 21h		
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET _NumToAsciiB	; Point to NumToAsciiB	
	int 21h		
	
	mov ah,09h					; Function 09h int 21h - Print string to console
	mov dx,OFFSET _CRLF			; Point to CRLF	
	int 21h	
	
	pop ax
	pop dx

	ret
PRINT_ERROR_CODE ENDP

;----
; TRYING_DRIVE_MSG 
; Display the message for trying one drive and makes
; an educated guess about the drive letter
; Inputs:
; 	- ah - error code
; Output: 
;	- none
; Destroys: none
;----
TRYING_DRIVE_MSG PROC

	mov ah,09h						; Function 09h int 21h - Print string to console
	mov dx,OFFSET TryingDriveMsg
	int 21h
	
	mov ah,02h						; Function 09h int 21h - Write character to std out
	mov dl,CurrentDriveIndex
	add dl,61h						; Make it ASCII lowercase alpha
	int 21h	
	
	mov ah,09h						; Function 09h int 21h - Print string to console
	mov dx,OFFSET _CRLF				; Point to CRLF	
	int 21h	
	
	ret
TRYING_DRIVE_MSG ENDP

;----
; DISPLAY_DRIVE_TYPE 
; Display the type of drive
; Inputs:
; 	- DIO_DriveType
; Output: 
;	- none
; Destroys: none
;----
DISPLAY_DRIVE_TYPE PROC
	
	mov ah,09h						; Function 09h int 21h - Print string to console
	mov dx,OFFSET DriveTypeMsg
	int 21h
	
	cmp _DIO_DriveType,0
	je TF_DDT_0
	
	cmp _DIO_DriveType,1
	je TF_DDT_1
	
	cmp _DIO_DriveType,2
	je TF_DDT_2

	cmp _DIO_DriveType,3
	je TF_DDT_3
	
	cmp _DIO_DriveType,4
	je TF_DDT_4
	
	mov dx,OFFSET DDT_UK
	jmp TF_DDT_End
	
TF_DDT_0:
	mov dx,OFFSET DDT_0
	jmp TF_DDT_End

TF_DDT_1:
	mov dx,OFFSET DDT_1
	jmp TF_DDT_End

TF_DDT_2:
	mov dx,OFFSET DDT_2
	jmp TF_DDT_End

TF_DDT_3:
	mov dx,OFFSET DDT_3
	jmp TF_DDT_End

TF_DDT_4:
	mov dx,OFFSET DDT_4
	jmp TF_DDT_End

TF_DDT_End:
	mov ah,09h						; Print the type
	int 21h

	mov ah,09h						; Print CRLF
	mov dx,OFFSET _CRLF
	int 21h	
	
	ret
DISPLAY_DRIVE_TYPE ENDP


DISPLAY_MEDIA_TYPE PROC

	mov ah,09h						; Function 09h int 21h - Print string to console
	mov dx,OFFSET MediaTypeMsg
	int 21h

	cmp _DIO_MediaType,0
	je FT_DMT_360K
	
	cmp _DIO_MediaType,1
	je FT_DMT_1220K

	cmp _DIO_MediaType,2
	je FT_DMT_720K
	
	cmp _DIO_MediaType,3
	je FT_DMT_1440K

	cmp _DIO_MediaType,4
	je FT_DMT_2880K
	
	mov dx,OFFSET DMT_UK
	jmp FT_DMT_End

FT_DMT_360K:
	mov dx,OFFSET DMT_0
	mov SectorsToRead,09h			; 09 (09h) sectors
	mov CylindersToRead,28h			; 40 (28h) cylinders/tracks
	jmp FT_DMT_End
	
FT_DMT_1220K:
	mov dx,OFFSET DMT_1
	mov SectorsToRead,0fh			; 15 (0fh) sectors
	mov CylindersToRead,50h			; 80 (50h) cylinders/tracks
	jmp FT_DMT_End

FT_DMT_720K:
	mov dx,OFFSET DMT_2
	mov SectorsToRead,09h			; 09 (09h) sectors
	mov CylindersToRead,50h			; 80 (50h) cylinders/tracks	
	jmp FT_DMT_End

FT_DMT_1440K:
	mov dx,OFFSET DMT_3
	mov SectorsToRead,12h			; 18 (12h) sectors
	mov CylindersToRead,50h			; 80 (50h) cylinders/tracks
	jmp FT_DMT_End

FT_DMT_2880K:
	mov dx,OFFSET DMT_4
	mov SectorsToRead,24h			; 36 (24h) sectors
	mov CylindersToRead,50h			; 80 (50h) cylinders/tracks
	jmp FT_DMT_End

FT_DMT_End:
	mov ah,09h						; Print the type
	int 21h

	mov ah,09h						; Print CRLF
	mov dx,OFFSET _CRLF
	int 21h	
	ret
DISPLAY_MEDIA_TYPE ENDP

END