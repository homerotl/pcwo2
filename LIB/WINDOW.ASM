; WINDOW.ASM
;
; Library to allow a text window which is resizable, movable
; scrollable and can be shown and hidden dynamically.
; Author: Homero Trevino <homerotl@gmail.com>

.MODEL small

    ; Window painting ASCII characters
    V_LINE                  EQU 179
    H_LINE                  EQU 196
    TOP_RIGHT_CORNER        EQU 191
    BOTTOM_LEFT_CORNER      EQU 192
    BOTTOM_RIGHT_CORNER     EQU 217 
    TOP_LEFT_CORNER         EQU 218

.DATA
    WINDOW_POS_ROW          db 0
    WINDOW_POS_COLUMN       db 0
    WINDOW_WIDTH            db 0
    WINDOW_HEIGHT           db 0
    WINDOW_CURSOR_ROW       db 0
    WINDOW_CURSOR_COLUMN    db 0
    WINDOW_BORDER_STYLE     db 0
    WINDOW_CONTENT_STYLE    db 0
    WINDOW_BG_SAVE_BUFFER   db 2000 dup (?)
    WINDOW_CONTENT_BUFFER   db 2000 dup (?)

.CODE		
	.8086

PUBLIC _WINDOW_SETUP
_WINDOW_SETUP PROC
    ; Hardcoded values for now
    mov WINDOW_POS_ROW,
    
	ret
_WINDOW_SETUP ENDP

PUBLIC _WINDOW_RENDER
_WINDOW_RENDER PROC
    ; Save background
    ; Draw window borders
    ; Render content
	ret
_WINDOW_RENDER ENDP

END