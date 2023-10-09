; VERSION.ASM
;
; Version file
; Author: Homero Trevino <homerotl@gmail.com>
.MODEL small

	BACKGROUND_STYLE		EQU 07h ; White text over Black background

.DATA
	PUBLIC _VER_VersionLbl
    _VER_VersionLbl db 1ch, 18h, BACKGROUND_STYLE, '20231008.1$'
 END