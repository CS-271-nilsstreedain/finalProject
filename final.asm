TITLE Final Project		(final.asm)

; Author:					Nils Streedain
; Last Modified:			3/6/2022
; OSU email address:		streedan@oregonstate.edu
; Course number/section:	271-001
; Assignment Number:		6
; Due Date:					3/13/2022
; Description:				Alex and Sila are espionage agents working for the Top Secret Agency (TSA). Sometimes they discuss
;							sensitive intelligence information that needs to be kept secret from the Really Bad Guys (RBG). Alex
;							and Sila have decided to use a simple obfuscation algorithm that should be good enough to confuse
;							the RBG. As the TSA’s resident programmer you’ve been assigned to write a MASM procedure that will
;							implement the requested behavior. Your code must be capable of encrypting and decrypting messages.

INCLUDE Irvine32.inc

; constants
MODE_ENCRYPT = -1
MODE_DECRYPT = -2

.data
	operand1   WORD    -32767
	operand2   WORD    -32767
	dest       DWORD   0
	
	decoyTest	BYTE		"decoy: ", 0
	encryptTest	BYTE		"encrypt: ", 0
	decryptTest	BYTE		"deccrypt: ", 0

.code
main PROC
	push   operand1
	push   operand2
	push   OFFSET dest
	call   compute
	;; currently dest holds a value of +26
	mov    eax, dest
	call   WriteInt   ; should display +26

	exit					; exit to operating system
main ENDP

; Description:				
; Receives:					
; Returns:					
; Preconditions:			
; Register changed:			
compute PROC
	push	ebp
	mov		ebp, esp
	
	mov		eax, [ebp + 8]
	mov		eax, [eax]

	cmp		eax, MODE_ENCRYPT
	je		callEncrypt

	cmp		eax, MODE_DECRYPT
	je		decrypt
	
	call	decoy
	jmp		endCompute

callEncrypt:
	call	encrypt
	jmp		endCompute

callDecrypt:
	call	decrypt
	jmp		endCompute

endCompute:
	pop		ebp
	ret		8
compute ENDP

; Description:				
; Receives:					[ebp + 8]: Given Signed DWORD, [ebp + 12]: Opp1, [ebp + 14]: Opp2
; Returns:					
; Preconditions:			
; Register changed:			eax, ebx
decoy PROC
	movsx	eax,WORD PTR [ebp + 14]
	movsx	ebx,WORD PTR [ebp + 12]
	add		eax, ebx		; Find and add opp1 & opp2
	
	mov		ebx, [ebp + 8]
	mov		[ebx], eax		; Store sum in given DWORD OFFSET

	ret
decoy ENDP

; Description:				
; Receives:					[ebp + 8]: , [ebp + 12]: , [ebp + 16]: 
; Returns:					
; Preconditions:			
; Register changed:	
encrypt PROC
	mov		edx, OFFSET encryptTest
	call	WriteString

	ret
encrypt ENDP

; Description:				
; Receives:					[ebp + 8]: , [ebp + 12]: , [ebp + 16]: 
; Returns:					
; Preconditions:			
; Register changed:	
decrypt PROC
	mov		edx, OFFSET decryptTest
	call	WriteString

	ret
decrypt ENDP

END main
