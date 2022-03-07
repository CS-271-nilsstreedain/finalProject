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
MIN = 15
MAX = 200
LO = 100
HI = 999

.data
	; interface strings
	intro		BYTE		"Sorting Random Integers", 13, 10, "Programmed by Nils Streedain", 13, 10, "This program generates random numbers in the range [100 .. 999],", 13, 10, "displays the original list, sorts the list, and calculates the", 13, 10, "median value. Finally, it displays the list sorted in descending order.", 13, 10, "**EC: Random TA Name: Megan Black", 13, 10, 0
	prompt		BYTE		"How many numbers should be generated? [15 .. 200]: ", 0
	error		BYTE		"Invalid input", 13, 10, 0
	unsortTitle	BYTE		"The unsorted random numbers:", 13, 10, 0
	medTitle	BYTE		13, 10, "The median is ", 0
	sortTitle	BYTE		".", 13, 10, "The sorted list:", 13, 11, 0
	bye			BYTE		13, 10, "Thanks for using my program!", 0

	; program variables
	request		DWORD		?
	list		DWORD		MAX DUP(?)

.code
main PROC
	push	OFFSET intro
	call	introduction	; Prints the program title, author's name, & extra credit tag.
	
	push	OFFSET prompt
	push	OFFSET error
	push	OFFSET request
	call	getData			; Repeatedly prompts the user for a number until one is given between MIN & MAX.
	
	call	Randomize		; Makes sure different random numbers are generated each time.
	push	OFFSET list
	push	request
	call	fillArray		; Fills the array with randomly generated numbers between HI & LO.

	push	OFFSET list
	push	request
	push	OFFSET unsortTitle
	call	displayList		; Prints a string representation of the unsorted array to the console

	push	OFFSET list
	push	request
	call	sortList		; Sorts the array usinging selection sort

	push	OFFSET list
	push	request
	push	OFFSET medTitle
	call	displayMedian	; Prints the median element to the console

	push	OFFSET list
	push	request
	push	OFFSET sortTitle
	call	displayList		; Prints a string representation of the sorted array to the console

	push	OFFSET bye
	call	introduction	; tells the user goodbye
	exit					; exit to operating system
main ENDP

; Description:				Prints the program title, author's name, extra credit stats, & instructions
; Receives:					[ebp + 8]:	Introduction string
; Returns:					N/A
; Preconditions:			string must be pushed
; Register changed:			edx
introduction PROC
	push	ebp
	mov		ebp, esp
	
	mov		edx, [ebp + 8]	; intro
	call	WriteString

	pop		ebp
	ret		4
introduction ENDP

; Description:				Repeatedly prompts the user for a number until the user inputs a valid integer between LO & HI
; Receives:					[ebp + 16]:	Prompt string, [ebp + 12]:	Error string, [ebp + 8]:	request
; Returns:					Number input by user to request
; Preconditions:			Prompt, Error, & request must be given
; Register changed:			eax, ebx, edx
getData PROC
	push	ebp
	mov		ebp, esp

promptUser:
	mov		edx, [ebp + 16]	; prompt string
	call	WriteString
	call	ReadInt

	cmp		eax, MIN		; validate input is between min & max
	jl		outOfRange		; if invalid, outOfRange is called
	cmp		eax, MAX
	jg		outOfRange
	jmp		valid
outOfRange:					; prints error, asks for new input
	mov		edx, [ebp + 12]	; error string
	call	WriteString
	jmp		promptUser
valid:						; returns when valid number is given
	mov		ebx, [ebp + 8]	; request int
	mov		[ebx], eax
	
	pop		ebp
	ret		12
getData ENDP

; Description:				Fills the given array with random number values between LO & HI
; Receives:					[ebp + 8]:	Length, [ebp + 12]:	Array
; Returns:					Array filled with random numbers
; Preconditions:			Array & length must be provided
; Register changed:			eax, ecx, esi
fillArray PROC
	push	ebp
	mov		ebp, esp
	
	mov		ecx, [ebp + 8]	; num times to loop
	mov		esi, [ebp + 12]	; list ref
fillLoop:
	mov		eax, HI
	sub		eax, LO
	inc		eax				; find difference between LO & HI
	call	RandomRange
	add		eax, LO			; find random int between LO & HI
	mov		[esi], eax		; insert into array
	add		esi, 4
	loop	fillLoop		; loop over every array element

	pop		ebp
	ret		8
fillArray ENDP

; Description:				Sorts the given number array from largest to smallest
; Receives:					[ebp + 8]:	Array, [ebp + 12]:	Length
; Returns:					Sorted array in array
; Preconditions:			Array must contain number elements & length must be the length of array
; Register changed:			eax, ebx, ecx, edx, esi
sortList PROC
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]	; num times to loop
	mov		esi, [ebp + 12]	; list ref
iterateLoop:
	mov		edx, esi		; store esi to edx to change in swapLoop
	push	ecx				; push counter for swapLoop
	
	sub		edx, 4
swapLoop:
	add		edx, 4
	mov		eax, [esi]		; curr
	mov		ebx, [edx]		; next
	cmp		eax, ebx
	jg		noSwap			; if curr is greater than next, don't swap
	push	esi
	push	edx
	call	exchange		; swap pushed addresses
noSwap:
	loop	swapLoop
	pop		ecx
	add		esi, 4
	loop	iterateLoop

	pop		ebp
	ret		8
sortList ENDP

; Description:				Swaps to elements in a number array using their given addresses
; Receives:					[ebp + 8]:	Addr1, [ebp + 12]:	Addr2
; Returns:					Val of Addr1 in Addr2 and val of Addr2 in Addr1
; Preconditions:			Addr must be valid addresses to elements in an array
; Register changed:			eax, ebx, ecx, edx
exchange PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		eax, [ebp + 8]	; item 1 addr
	mov		ebx, [ebp + 12]	; item 2 addr
	mov		ecx, [eax]		; item 1 value
	mov		edx, [ebx]		; item 2 value
	mov		[ebx], ecx		; put item 1 value in item 2 addr
	mov		[eax], edx		; put item 2 value in item 1 addr

	popad
	pop		ebp
	ret		8
exchange ENDP

; Description:				Finds & prints the median element of an array
; Receives:					[ebp + 8]:	Title, [ebp + 12]:	Length, [ebp + 16]:	Array
; Returns:					N/A
; Preconditions:			Array must contain number elements & length must be the length of the array
; Register changed:			eax, ebx, ecx, edx, esi
displayMedian PROC
	push	ebp
	mov		ebp, esp
	
	mov		edx, [ebp + 8]
	call	WriteString		; prints median text
	mov		esi, [ebp + 16]	; array
	mov		eax, [ebp + 12]	; length
	mov		ebx, 2
	cdq
	div		ebx
	mov		ecx, edx		; Move remainder to ecx so edx is clear for mul
	mov		ebx, 4
	mul		ebx				; multiply by to to find middle address
	cmp		ecx, 0			; checks if length is even by seeing if it's divisible by 2
	je		isEven
	mov		eax, [esi + eax]; when length is odd, median is 1/2 the length
	jmp		medCalculated
isEven:
	mov		ebx, [esi + eax] ; find lower median
	sub		eax, 4
	mov		eax, [esi + eax] ; fina upper median
	add		eax, ebx
	mov		ebx, 2
	div		ebx				; calc average of medians
medCalculated:
	call	WriteDec		; length divided in last step, just need to calc address

	pop		ebp
	ret		16
displayMedian ENDP

; Description:				Prints a string representation of a given array
; Receives:					[ebp + 8]:	Title, [ebp + 12]:	Length, [ebp + 16]:	Array
; Returns:					N/A
; Preconditions:			Length must be the length of the array
; Register changed:			eax, ebx, ecx, edx, esi, al
displayList PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp + 8]	; print title
	call	WriteString
	mov		ecx, [ebp + 12]	; num times to loop
	mov		esi, [ebp + 16]	; list ref
	mov		ebx, 0			; newline counter
displayLoop:
	mov		eax, [esi]
	call	WriteDec		; print next array element
	mov		al, 9
	call	WriteChar		; print tab
	inc		ebx
	cmp		ebx, 10
	jl		noNewLine
	call	Crlf
	mov		ebx, 0			; new line every 10 elements
noNewLine:
	add		esi, 4
	loop	displayLoop		; loop over length of array

	pop		ebp
	ret		12
displayList ENDP

END main
