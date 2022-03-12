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
	message    BYTE   "uid bpoudout pg uijt ndttehd xjmm fd e nztudsz.",0
	dest       DWORD   -2

.code
main PROC
	;; inside the MAIN procedure
	push   OFFSET myKey
	push   OFFSET message
	push   OFFSET dest
	call   compute
	;; message now contains the encrypted string
	mov    edx, OFFSET message
	call   WriteString
	;; should display "uid bpoudout pg uijt ndttehd xjmm fd e nztudsz."
	exit
main ENDP

; Description:				
; Receives:					
; Returns:					
; Preconditions:			
; Register changed:			
compute PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 28

	mov		eax, [ebp + 16]
	mov		edi, [ebp + 8]
	mov		edi, [edi]		; get mode value
	
	cmp		edi, -2
	je		callDecrypt		; if mode is -1 or -2 call correct procedure
	cmp		edi, -1
	je		callEncrypt
	
	call	decoy
	pop		ebp
	ret		8				; otherwise decoy

callDecrypt:
	lea		ebx, [ebp - 26]
	push	eax
	push	ebx
	call	decrypt
	mov		eax, ebx

callEncrypt:
	push	eax
	push	[ebp + 12]
	call	encrypt

	add		esp, 28
	pop		ebp
	ret		12
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
; Receives:					[ebp + 8]: Input string, [ebp + 12]: Key
; Returns:					Encrypted string
; Preconditions:			key and input string must be provided
; Register changed:			eax, ebx, esi, edi
encrypt PROC
	push	ebp
	mov		ebp, esp
	
	mov		esi, [ebp + 8]
	mov		edi, esi
	mov		ebx, [ebp + 12]

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
	mov		eax, [ebx + eax - 97] ; replace char with char at index in key
	stosb

	jmp		loopString
endLoopString:
	pop		ebp
	ret		8
encrypt ENDP

; Description:				
; Receives:					[ebp + 12]: , [ebp + 16]: 
; Returns:					
; Preconditions:			
; Register changed:	
decrypt PROC
	push	ebp
	mov		ebp, esp
	pushad
	
	mov		esi, [ebp + 12] ; original key
	mov		edi, [ebp + 8] ; new key

	mov		bl, 97
inverseKey:
	xor		edx, edx
	findCharIndex:
		lodsb
		cmp		al, bl
		je		foundChar
		inc		dl
		jmp		findCharIndex

	foundChar:
		sub		esi, edx
		dec		esi
		add		dl, 97
		mov		al, dl
		stosb
		inc		bl

	cmp		bl, 123
	jl		inverseKey


	popad
	pop		ebp
	ret		8
decrypt ENDP

END main
