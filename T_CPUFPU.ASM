; T_CPU_FPU.ASM
;
; Routines for CPU and FPU identification and testing
; Author: Homero Trevino <homerotl@gmail.com>

.MODEL small

.DATA

	EXTRN _cpu_type:BYTE						; From LIB/CPUID3A.ASM
	EXTRN _fpu_type:BYTE
	EXTRN _cpuid_flag:BYTE
	
	EXTRN _PRIME_N:WORD							; From LIB/MATH.ASM
	EXTRN _PRIME_NSQ:WORD

	EXTRN _IntToStringBuffer:BYTE				; FROM LIB/STRINGS.ASM
	
	EXTRN _TimerTimeLapse:BYTE					; From LIB/TIME.ASM
	EXTRN _TimerTimerExpired:BYTE
	
	CPU8086Lbl					db '8086/8088    $'
	CPU286Lbl					db '80286        $'	
	CPU386Lbl					db '80386        $'
	CPU486Lbl					db '80486        $'			
	CPUPentiumLbl				db 'Pentium      $'	
	CPUPentiumProLbl			db 'PentiumPro   $'		
	CPUUnknownLbl				db 'Unknown      $'
	
	FPUNoLbl					db 'Not present  $'
	FPUPresentLbl				db 'Present      $'
	FPU287Lbl					db '287          $'
	FPU387Lbl					db '387          $'
	FPUUnknownLbl				db 'Unknown      $'
	
.CODE
	.8086
	JUMPS
	
	EXTRN _get_cpu_type:PROC					; From LIB/CPUID3A.ASM
	EXTRN _get_fpu_type:PROC

    EXTRN _STR_INT_TO_STRING:PROC				; From LIB/STRINGS

    EXTRN _UI_PRINT_CPU_ID:PROC					; FROM UI.ASM
    EXTRN _UI_PRINT_FPU_ID:PROC
    EXTRN _UI_PRINT_CPU_BENCHMARK:PROC
    EXTRN _UI_SET_CPU_BENCH_TEST_MSG:PROC
   	EXTRN _UI_CLEAR_STATUS:PROC
        
    EXTRN _TIME_SETUP_PIT:PROC					; FROM LIB/TIME.ASM
    EXTRN _TIME_START_TIMER:PROC
    EXTRN _TIME_HAS_TIMER_EXPIRED:PROC

	EXTRN _MATH_PRIME_SIEVE:PROC				; FROM LIB/MATH.ASM
	EXTRN _MATH_PRIME_COUNT:PROC
        
;----
; _TEST_CPU_FPU_DETECTION
; Run one-time detection routines. Set found values to the screen
; Inputs: None
; Output: None
; Destroys: None
;----
PUBLIC _TEST_CPU_FPU_DETECTION
_TEST_CPU_FPU_DETECTION PROC
	
	call _get_cpu_type
	call _get_fpu_type
		
	cmp _cpu_type,0
	je otd_8086
	
	cmp _cpu_type,2
	je otd_286
	
	cmp _cpu_type,3
	je otd_386
	
	cmp _cpu_type,4
	je otd_486
	
	cmp _cpu_type,5
	je otd_Pentium		
	
	cmp _cpu_type,6
	je otd_PentiumPro

	lea si,CPUUnknownLbl
	jmp otd_fpu_detection

otd_8086:
	lea si,CPU8086Lbl
	jmp otd_fpu_detection
	
otd_286:
	lea si,CPU286Lbl
	jmp otd_fpu_detection

otd_386:
	lea si,CPU386Lbl
	jmp otd_fpu_detection
	
otd_486:
	lea si,CPU486Lbl
	jmp otd_fpu_detection
	
otd_Pentium:
	lea si,CPUPentiumLbl
	jmp otd_fpu_detection
	
otd_PentiumPro:
	lea si,CPUPentiumProLbl
	jmp otd_fpu_detection
	
otd_fpu_detection:

    call _UI_PRINT_CPU_ID
	
	cmp _fpu_type,0
	je otd_no_fpu
	
	cmp _fpu_type,1
	je otd_fpu
	
	cmp _fpu_type,2
	je otd_287

	cmp _fpu_type,3
	je otd_387

	lea si,FPUUnknownLbl
	jmp otd_end

otd_no_fpu:
	lea si,FPUNoLbl
	jmp otd_end

otd_fpu:
	lea si,FPUPresentLbl
	jmp otd_end
	
otd_287:
	lea si,FPU287Lbl
	jmp otd_end
	
otd_387:
	lea si,FPU387Lbl
	jmp otd_end
		
otd_end:
    call _UI_PRINT_FPU_ID
	ret
_TEST_CPU_FPU_DETECTION ENDP

;----
; _TEST_CPU_BENCHMARK
; Run a CPU intensive process as many times as we can in 2 seconds
; to determine a benchmark
; Inputs: None
; Output: None
; Destroys: None
;----
PUBLIC _TEST_BENCHMARK_CPU
_TEST_BENCHMARK_CPU PROC

	push ax	
	push cx
	
	call _UI_SET_CPU_BENCH_TEST_MSG
	
	mov _PRIME_N,2710h						; Set N, length of the array
	mov _PRIME_NSQ,0064h					; Set SQRT(N)
	
	call _TIME_SETUP_PIT					; Setup PIT
	
	lea si,_TimerTimeLapse

	mov word ptr [si],0000h					; Load timer with 2 seconds
	mov word ptr [si+2],0024h
	mov word ptr [si+4],69b8h
	
	xor cx,cx								; cx=0
	
	call _TIME_START_TIMER

T_BCPU_Repeat:

	call _MATH_PRIME_SIEVE
	call _MATH_PRIME_COUNT
	inc cx
	
	call _TIME_HAS_TIMER_EXPIRED			; Check if timer expired	

	cmp _TimerTimerExpired,01h				; 01 = expired
	je T_BCPU_Ended
	jmp T_BCPU_Repeat
	
T_BCPU_Ended:
	
	mov ax,cx
	call _STR_INT_TO_STRING
	
	lea si,_IntToStringBuffer

	call _UI_PRINT_CPU_BENCHMARK
	
	call _UI_CLEAR_STATUS
	
	pop cx
	pop ax
	
	ret
_TEST_BENCHMARK_CPU ENDP

END