	TITLE	MEM
	PAGE	66,132
;
; Memory size reporting utility
;
; Bob Eager   June 1998
;
	.386
	.MODEL	FLAT
;
	SUBTTL	Constants
	PAGE+
;
; Constant definitions
;
STDOUT	EQU	1			; Handle for standard output
;
CR	EQU	0DH			; Carriage return
LF	EQU	0AH			; Linefeed
;
NDIGITS	EQU	6			; Maximum number of digits for output
;
	SUBTTL	Include files and external references
	PAGE+
;
	INCL_DOSMISC	EQU	1
	INCL_DOSFILEMGR	EQU	1
;
	INCLUDE		BSEDOS.INC
;
	INCLUDELIB	OS2386.LIB
;
	EXTRN	DosExit:NEAR
	EXTRN	DosQuerySysInfo:NEAR
	EXTRN	DosWrite:NEAR
;
	SUBTTL	Uninitialised data and stack
	PAGE+
;
DGROUP	GROUP	DSEG
;
DSEG	SEGMENT
;
; Uninitialised data
;
MEMSIZE	DD	?			; Number of bytes
WLEN	DD	?			; Receives bytes written
BUF	DB	NDIGITS DUP (?)		; Digit string buffer
;
; Stack
;
STK	.STACK	4096
;
DSEG	ENDS
;
	SUBTTL	Constant data
	PAGE+
;
	.CONST
;
MES0	DB	'Physical memory seen by OS/2: ',0
MES1	DB	'Failed to get mem info',CR,LF,0
MES2	DB	'MB + ',0
MES3	DB	'KB',CR,LF,0
;
	SUBTTL	Main code
	PAGE+
;
	.CODE
;
BEGIN	PROC	NEAR
;
	PUSH	SIZEOF MEMSIZE		; sizeof(memsize)
	LEA	EAX,MEMSIZE		; &memsize
	PUSH	EAX
	PUSH	QSV_TOTPHYSMEM		; high index
	PUSH	QSV_TOTPHYSMEM		; low index
	CALL	DosQuerySysInfo		; get value to memsize
	ADD	ESP,16			; reset stack
	OR	EAX,EAX			; success?
	JZ	SHORT GOTVAL		; j if so
	LEA	EAX,MES1		; "Failed to get memory information"
	CALL	PUTMES			; output it
	MOV	EAX,1			; failure code
	JMP	SHORT EXIT
;
GOTVAL:	LEA	EAX,MES0		; "Physical memory seen by OS/2: "
	CALL	PUTMES			; output it
	MOV	EAX,MEMSIZE		; size in bytes
	SHR	EAX,20			; convert to MB
	CALL	PUTNUM			; output it
	LEA	EAX,MES2		; "MB + "
	CALL	PUTMES			; output it
	MOV	EAX,MEMSIZE		; get bytes again
	AND	EAX,000FFFFFH		; mask out odd kilobytes
	SHR	EAX,10			; convert to KB
	CALL	PUTNUM			; output it
	LEA	EAX,MES3		; "KB<CR><LF>"
	CALL	PUTMES			; output it
;
	PUSH	0			; success completion code
;
; Exit with completion code in EAX
;
EXIT:	PUSH	EXIT_PROCESS
	CALL	DosExit
;
BEGIN	ENDP
;
	SUBTTL	Output message
	PAGE+
;
; Routine to output a string to the screen.
;
; Inputs:
;	EAX	- offset of zero terminated message
;
; Outputs:
;	EAX	- not preserved
;
PUTMES	PROC	NEAR
;
	PUSH	EDI			; save EDI
	PUSH	ECX			; save ECX
	PUSH	EDX			; save EDX
;
	PUSH	EAX			; save message pointer
	MOV	EDI,EAX			; EDI points to message
	XOR	AL,AL			; set AL=0 for scan value
	MOV	ECX,100			; just a large value
	REPNZ	SCASB			; scan for zero byte
	POP	EAX			; recover message pointer
	SUB	EDI,EAX			; get size to EDI
	DEC	EDI			; adjust
	LEA	EDX,WLEN		; address for length written
	PUSH	EDX
	PUSH	EDI			; length of message
	PUSH	EAX			; address of message
	PUSH	STDOUT			; standard output handle
	CALL	DosWrite		; write message
	ADD	ESP,16			; reset stack
;
	POP	EDX			; recover EDX
	POP	ECX			; recover ECX
	POP	EDI			; recover DI
;
	RET
;
PUTMES	ENDP
;
	SUBTTL	Output number
	PAGE+
;
; Routine to output a number to the screen.
;
; Inputs:
;	EAX	- value to be output
;
; Outputs:
;	EAX	- not preserved
;
PUTNUM	PROC	NEAR
;
	PUSH	EDI			; save EDI
	PUSH	ECX			; save ECX
	PUSH	EDX			; save EDX
;
	MOV	BUF+NDIGITS-1,0		; set terminator
	LEA	EDI,BUF+NDIGITS-2	; point to last slot in buffer
	MOV	ECX,10			; set divisor
;
PUTN10:	CDQ				; make 64-bit
	DIV	ECX			; divide by 10, quotient in EAX
	ADD	EDX,'0'			; remainder to digit
	MOV	[EDI],DL		; store it
	DEC	EDI			; back to next slot
	OR	EAX,EAX			; finished?
	JNZ	PUTN10			; j if not
;
	INC	EDI			; point to first digit
	MOV	EAX,EDI			; set up to output
	CALL	PUTMES			; do it
;
	POP	EDX			; recover EDX
	POP	ECX			; recover ECX
	POP	EDI			; recover DI
;
	RET
;
PUTNUM	ENDP
;
	END	BEGIN
