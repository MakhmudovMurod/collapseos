; Fill B bytes at (HL) with A
fill:
	push	bc
	push	hl
.loop:
	ld	(hl), a
	inc	hl
	djnz	.loop
	pop	hl
	pop	bc
	ret

; Increase HL until the memory address it points to is equal to A for a maximum
; of 0xff bytes. Returns the new HL value as well as the number of bytes
; iterated in A.
; If a null char is encountered before we find A, processing is stopped in the
; same way as if we found our char (so, we look for A *or* 0)
; Set Z if the character is found. Unsets it if not
findchar:
	push	bc
	ld	c, a	; let's use C as our cp target
	ld	a, 0xff
	ld	b, a

.loop:	ld	a, (hl)
	cp	c
	jr	z, .match
	or	a		; cp 0
	jr	z, .nomatch
	inc	hl
	djnz	.loop
.nomatch:
	call	unsetZ
	jr	.end
.match:
	; We ran 0xff-B loops. That's the result that goes in A.
	ld	a, 0xff
	sub	b
	cp	a	; ensure Z
.end:
	pop	bc
	ret


; Format the lower nibble of A into a hex char and stores the result in A.
fmtHex:
	; The idea here is that there's 7 characters between '9' and 'A'
	; in the ASCII table, and so we add 7 if the digit is >9.
	; daa is designed for using Binary Coded Decimal format, where each
	; nibble represents a single base 10 digit. If a nibble has a value >9,
	; it adds 6 to that nibble, carrying to the next nibble and bringing the
	; value back between 0-9. This gives us 6 of that 7 we needed to add, so
	; then we just condtionally set the carry and add that carry, along with
	; a number that maps 0 to '0'. We also need the upper nibble to be a
	; set value, and have the N, C and H flags clear.
	or 	0xf0
	daa	; now a =0x50 + the original value + 0x06 if >= 0xfa
	add 	a, 0xa0	; cause a carry for the values that were >=0x0a
	adc 	a, 0x40
	ret

; Formats value in A into a string hex pair. Stores it in the memory location
; that HL points to. Does *not* add a null char at the end.
fmtHexPair:
	push	af

	; let's start with the rightmost char
	inc	hl
	call	fmtHex
	ld	(hl), a

	; and now with the leftmost
	dec	hl
	pop	af
	push	af
	rra \ rra \ rra \ rra
	call	fmtHex
	ld	(hl), a

	pop	af
	ret


; Compares strings pointed to by HL and DE up to A count of characters. If
; equal, Z is set. If not equal, Z is reset.
strncmp:
	push	bc
	push	hl
	push	de

	ld	b, a
.loop:
	ld	a, (de)
	cp	(hl)
	jr	nz, .end	; not equal? break early. NZ is carried out
				; to the called
	cp	0		; If our chars are null, stop the cmp
	jr	z, .end		; The positive result will be carried to the
	                        ; caller
	inc	hl
	inc	de
	djnz	.loop
	; We went through all chars with success, but our current Z flag is
	; unset because of the cp 0. Let's do a dummy CP to set the Z flag.
	cp	a

.end:
	pop	de
	pop	hl
	pop	bc
	; Because we don't call anything else than CP that modify the Z flag,
	; our Z value will be that of the last cp (reset if we broke the loop
	; early, set otherwise)
	ret

; Transforms the character in A, if it's in the a-z range, into its upcase
; version.
upcase:
	cp	'a'
	ret	c	; A < 'a'. nothing to do
	cp	'z'+1
	ret	nc	; A >= 'z'+1. nothing to do
	; 'a' - 'A' == 0x20
	sub	0x20
	ret