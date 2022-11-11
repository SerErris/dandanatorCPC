;rescue loader to load the code into memory and start it
org #a000

  di					;disable intertupts
  ld hl,#7005			;load address (revers)
  ld de,#1005			;number of bytes (4101)
  ld a,e				;setup dandantor for serial read
  db &FD, &FD			;send trigger
  ld (iy+#00),a			;send command to dandantor (setup serial read)
loadserialbyte:			;load a serial byte
  ld b,#08				;set counter to 8 bit
waitstartbit:			;wait for the start bit
  ld a,(hl)				;continue reading (HL) from dandanator
  rrca					;check if D0 is 1
  jr c,waitstartbit		;no? loop and read again.

  ;decrement memory address for the next byte and wait for 17us + (6ums)
  ex (sp),hl			;timing useless statements in total we need to wait for  +6 NOPs
  ex (sp),hl			;timing useless statements                               +6 NOPs
  dec hl				;decrement memory address to write the byte to           +2 NOPs
  inc (hl)				;more timing (dummy)                                     +3 NOPs
readserial:
  ;wait for 6 NOPs (=6us)
  inc (hl)				;more timing (dummy)                                     +3 NOPs
  dec (hl)				;more timing (dummy)                                     +3 NOPs

  ld a,(hl)				;now read the bit from HL to A
  rra					;rotate the lowest bit into Carry
  rr c					;rotate carry into C
  nop					;timing
  djnz readserial		;check if we have read b=8 bits - if no - read next bit
  ld (hl),c				;store the resulting byte in C to Memory
  dec de				;Decrement DE and
  ld a,e				;check
  or d					;if DE is >0
  jr nz,loadserialbyte	;then read next byte
  ei					;else enable interrupt
  ld a,4				;load DNTR command (disable serial)
  db &FD,&FD			;TRIGGER Dandanator
  ld (IY+0),a			;send command to dandanator
  JP (HL)				;downloaded the loader, execute it.
