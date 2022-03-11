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
.data
	myKey      BYTE   "efbcdghijklmnopqrstuvwxyza"
	message    BYTE   "the contents of this message will be a mystery.",0
	dest       DWORD   -1
	
	encryptTest	BYTE		"encrypt: ", 0
	decryptTest	BYTE		"deccrypt: ", 0

.code
main PROC
	push   OFFSET myKey
	push   OFFSET message
	push   OFFSET dest
	call   compute
	;; message now contains the encrypted string
	mov    edx, OFFSET message
	call   WriteString
	;; should display "uid bpoudout pg uijt ndttehd xjmm fd e nztudsz."

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

	cmp		eax, -1
	je		callEncrypt

	cmp		eax, -2
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

; Description:				Decoy procedure to add 2 16 bit opperands into a 32 bit address
; Receives:					[ebp + 8]: Given Signed DWORD, [ebp + 12]: Opp1, [ebp + 14]: Opp2
; Returns:					DWORD sum of two WORDs
; Preconditions:			valid DWORD OFFSET & opperands must be provided
; Register changed:			eax, ebx
decoy PROC
	movsx	eax,WORD PTR [ebp + 14]
	movsx	ebx,WORD PTR [ebp + 12]
	add		eax, ebx		; Find and add opp1 & opp2
	
	mov		ebx, [ebp + 8]
	mov		[ebx], eax		; Store sum in given DWORD OFFSET

	ret
decoy ENDP

; Description:				Encryption cypher mode to swap characters of a string with their
;							correspoding characters in a given input key.
; Receives:					[ebp + 8]: Mode, [ebp + 12]: Input string, [ebp + 16]: Key
; Returns:					Encrypted string
; Preconditions:			key and input string must be provided
; Register changed:			eax, edx, esi, edi
encrypt PROC
	mov		esi, [ebp + 12]
	mov		edi, esi
	mov		edx, [ebp + 16]

loopString:				; loop over each char in input
	xor		eax, eax
	lodsb
	inc		edi			; inc when skip char (re-dec later when not skiping)
	
	cmp		al, 0		; if end of string, endLoop
	je		endLoopString
	cmp		al, 97		; if out of range from lower case chars, skip char
	jl		loopString
	cmp		al, 122
	jg		loopString

	dec		edi
	mov		eax, [edx + eax - 97] ; replace char with char at index in key
	stosb

	jmp		loopString
endLoopString:
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
