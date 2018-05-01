

;-----------------------------------------------------------------
num2strInit:
                    ; set up powers of 10 in ram, used in unsigned -> ascii conversion
                    push ZL
                    push ZH
                    push r16
                    ldi ZL, LOW(Power10)
                    ldi ZH, HIGH(Power10)
                    ldi r16, LOW(10000)
                    st Z+, r16
                    ldi r16, HIGH(10000)
                    st Z+, r16
                    ldi r16, LOW(1000)
                    st Z+, r16
                    ldi r16, HIGH(1000)
                    st Z+, r16
                    ldi r16, LOW(100)
                    st Z+, r16
                    ldi r16, HIGH(100)
                    st Z+, r16
                    ldi r16, LOW(10)
                    st Z+, r16
                    ldi r16, HIGH(10)
                    st Z+, r16
                    ldi r16, LOW(1)
                    st Z+, r16
                    ldi r16, HIGH(1)
                    st Z+, r16
                    pop r16
                    pop ZH
                    pop ZL
                    ret


;-----------------------------------------------------------------
Binary2BCD:         push r17
                    push r18
                    mov r17, r16
                    ldi r18, 10
                    rcall Div8by8
                    mov r18, r16   ; save remainder
                    mov r16, r17
                    lsl r16
                    lsl r16
                    lsl r16
                    lsl r16
                    add r16, r18
                    pop r18
                    pop r17
                    ret


;-----------------------------------------------------------------
Div8by8:            ; r17/r18 -> quotient in r17, remainder r16
                    push r19
                    clr r16
                    ldi r19, 9
Div8by8Loop:        rol r17
                    dec r19
                    breq Div8by8Exit
                    rol r16
                    sub r16, r18
                    brcc Div8by8X
                    add r16, r18
                    clc
                    rjmp Div8by8Loop
Div8by8X:           sec
                    rjmp Div8by8Loop
Div8by8Exit:        pop r19
                    ret

;-----------------------------------------------------------------
Unsigned8Bit2Ascii: ; convert unsigned in r16 to 3 bytes in buffer
                    push r17
                    mov r17, r16
                    push r18
                    push r20
                    ldi ZL, LOW(StrBuffer+5)
                    ldi ZH, HIGH(StrBuffer+5)
                    ldi r18, 0
                    st -Z, r18
                    st -Z, r18
                    ldi r18, 10
                    ldi r20, 3
u2aNext:            rcall Div8by8
                    ori r16, '0'
                    st -Z, r16
                    dec r20
                    breq u2aDone
                    tst r17
                    brne u2aNext
                    ldi r16, ' '
u2aLeading:         st -Z, r16
                    dec r20
                    brne u2aLeading
u2aDone:            pop r20
                    pop r18
                    pop r17
                    ldi ZL, LOW(StrBuffer)
                    ldi ZH, HIGH(StrBuffer)
                    ret

; ------------  16 bit conversion --------------------------------

Unsigned16Bit2Ascii:
                    ; convert r17:16 to Ascii and store in StrBuffer
                    ; return StrBuffer beginning in ZL/ZH
                    ; note that we have this zero terminated
                    push XL
                    push XH
                    push r18
                    push r19
                    push r20
                    push r21
                    ldi XL, LOW(Power10)
                    ldi XH, HIGH(Power10)
                    ldi ZL, LOW(StrBuffer)
                    ldi ZH, HIGH(StrBuffer)

				    ldi r18, 5  ; 5 digits
U16ToAL2:
				    ld r19, X+   ; power 10 in r20:r19
				    ld r20, X+
				    ldi r21, 0xFF  ; our counter
U16ToAL1:           inc r21
                    sub r16, r19
			    	sbc r17, r20
	     			brcc U16ToAL1
	     			ori r21, '0'
		    		st Z+, r21
		    		; add the factoor back in!
		    		add r16, r19
		    		adc r17, r20
				    dec r18
			    	brne  U16ToAL2
                    ; add zero termination for string
                    ldi r21, 0x00
                    st Z+, r21

                    pop r21
                    pop r20
                    pop r19
                    pop r18
                    pop XH
                    pop XL
                    ldi ZL, LOW(StrBuffer)
                    ldi ZH, HIGH(StrBuffer)
                    ret

.dseg
Power10: .byte 10
StrBuffer: .byte 10  ; used for LCD output


.cseg
