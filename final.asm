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
	operand1				WORD	46
	operand2				WORD	-20
	myKey					BYTE   "efbcdghijklmnopqrstuvwxyza"
	message					BYTE   "the contents of this message will be a mystery.",0
	dest					DWORD	0
	dest1					DWORD   -1
	dest2					DWORD   -2

.code
main PROC
	; Decoy Mode Test
	push	operand1
	push	operand2
	push	OFFSET dest
	call	compute
	;; currently dest holds a value of +26
	mov		eax, dest
	call	WriteInt
	call	crlf
	;; should display +26

	; Encrypt Mode Test
	push	OFFSET myKey
	push	OFFSET message
	push	OFFSET dest1
	call	compute
	;; message now contains the encrypted string
	mov		edx, OFFSET message
	call	WriteString
	call	crlf
	;; should display "uid bpoudout pg uijt ndttehd xjmm fd e nztudsz."

	; Decrypt Mode Test
	push	OFFSET myKey
	push	OFFSET message
	push	OFFSET dest2
	call	compute
	;; message now contains the decrypted string
	mov		edx, OFFSET message
	call	WriteString
	call	crlf
	;; should display "the contents of this message will be a mystery."
	exit
main ENDP

; Description:				Procedue to compute an output based various input modes.
;							1. A default "decoy" mode of operation where the procedure accepts two 16-bit operands by value and
;							one operand by OFFSET. The procedure will calculate the sum of the two operands and will store the
;							result into memory at the OFFSET specified.
;								- Accepts 3 parameters on the stack
;									- [ebp + 16]: 16 bit signed WORD operand
;									- [ebp + 12]: 16 bit signed WORD operand
;									- [ebp + 18]: 32 bit OFFSET of a signed DWORD (the sum will be placed here)
;							2. An encryption mode
;								- Accepts 3 parameters on the stack
;									- [ebp + 16]: 32 bit OFFSET of a BYTE array (containing 26 character key)
;									- [ebp + 12]: 32 bit OFFSET of a BYTE array (containing message to encrypt)
;									- [ebp + 18]: 32 bit OFFSET of a signed DWORD (containing the integer -1)
;								- Note that the plaintext message will be in a BYTE array that ends with a NULL character
;								- This operational mode will encrypt the requested message. By the time your function returns,
;								theoriginal plaintext message array will be overwritten with the correctly encrypted message.
;							3. A decryption mode
;								- Accepts 3 parameters on the stack
;									- [ebp + 16]: 32 bit OFFSET of a BYTE array (containing 26 character key)
;									- [ebp + 12]: 32 bit OFFSET of a BYTE array (containing encrypted message)
;									- [ebp + 18]: 32 bit OFFSET of a signed DWORD (containing the integer -2)
;								- Note that the encrypted message will be in a BYTE array that ends with a NULL character
;								- This operational mode will decrypt the requested message. By the time your function returns,
;								the encrypted characters (inside the array) will be overwritten with the decrypted message.
; Receives:					Based on mode, see above
; Returns:					Based on mode, see above
; Preconditions:			All three valid inputs required for specified mode must be provided
; Register changed:			eax, ebx, ecx
compute PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 28

	mov		eax, [ebp + 16]
	mov		ebx, [ebp + 8]
	mov		ebx, [ebx]		; get mode value
	
	cmp		ebx, -2
	je		decryptMessage		; if mode is -1 or -2 call correct procedure
	cmp		ebx, -1
	je		encryptMessage
	
	call	decoy
	add		esp, 28
	pop		ebp
	ret		8				; otherwise decoy

decryptMessage:				; calls find inverse key to find the key to decrypt the message and then moves onto encrypt
	lea		ecx, [ebp - 26]
	push	eax
	push	ecx
	call	findInverseKey
	mov		eax, ecx

encryptMessage:				; encrypts or decrypts depending on if key or inverse key being provided
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

; Description:				Encryption cypher mode to swap characters of a string with their correspoding characters in a given
;							input key.
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

loopString:					; loop over each char in input
	xor		eax, eax
	lodsb
	inc		edi				; inc when skip char (re-dec later when not skiping)
	
	cmp		al, 0			; if end of string, endLoop
	je		endLoopString
	cmp		al, 97			; if out of range from lower case chars, skip char
	jl		loopString
	cmp		al, 122
	jg		loopString

	dec		edi
	mov		eax, [ebx + eax - 97]
	stosb					; replace char with char at index in key

	jmp		loopString
endLoopString:
	pop		ebp
	ret		8
encrypt ENDP

; Description:				Sub-procedure used to decrypt a message. Finds the inverse key of key. The inverse key can then be
;							used with encryptMessgae to decrypt a message.
; Receives:					[ebp + 8]: key, [ebp + 12]: pointer for inverse key
; Returns:					Inverse key of key
; Preconditions:			key and register for inverse key must be provided
; Register changed:			eax, ebx, edx, esi, edi
findInverseKey PROC
	push	ebp
	mov		ebp, esp
	
	mov		esi, [ebp + 12] ; original key
	mov		edi, [ebp + 8]	; new key

	mov		bl, 97
inverseKey:					; loop to create an inverse key
	xor		edx, edx
findCharIndex:				; finds index of char with ascii code of bl
	lodsb
	cmp		al, bl
	je		foundChar
	inc		dl
	jmp		findCharIndex

foundChar:					; places char with ascii code of index, at index bl
	sub		esi, edx
	dec		esi
	add		dl, 97
	mov		al, dl
	stosb
	inc		bl

	cmp		bl, 123
	jl		inverseKey		; repeats for all lower case ascii chars

	pop		ebp
	ret		8
findInverseKey ENDP

END main
