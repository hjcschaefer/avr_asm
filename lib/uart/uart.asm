
;...........  UartInitOnlySend ...........................
; IN : -
; OUT : -
;...........  UartInitOnlySend ...........................
UartInitOnlySend:
                    ; setting baud rate
                    ldi r16, HIGH(UBRRVAL)
                    sts UBRR0H, r16
                    ldi r16, LOW(UBRRVAL)
                    sts UBRR0L, r16
                    ; setting 8N1: 8 data bits, no parity, 1 stop bit
                    ldi r16, (1<<UCSZ01) | (1<<UCSZ00);
                    sts UCSR0C, r16
                    ldi r16, (1<<TXEN0)
                    sts UCSR0B, r16    ; only send!
                    ret

;...........  UartSendByte ...........................
; IN : r16 (byte to send)
; OUT : -
;...........  UartSendByte ...........................
UartSendByte:   ; wait until UDRE1 is set
				    push r16
UartWaitToTransmit:
				    lds r16, UCSR0A
				    andi r16, (1<<UDRE0)
				    breq UartWaitToTransmit
				    pop r16
				    sts UDR0, r16
				    ret

;...........  UartSendFlashString ...........................
; IN : ZH/ZL points to string in flash (!) must be delimited by 0 word
; OUT : -
;...........  UartSendFlashString ...........................
UartSendFlashString:
                    push r16

UartSendFlashStringLoop:
                    lpm r16, Z+
                    cpi r16, 0
                    breq UartSendFlashStringExit
                    rcall UartSendByte
                    rjmp UartSendFlashStringLoop
UartSendFlashStringExit:
                    pop r16
                    ret

;...........  UartSendString ...........................
; IN : ZH/ZL points to string in sram must be delimited by 0 word
; OUT : -
;...........  UartSendString ...........................
UartSendString:
                    push r16

UartSendStringLoop:
                    ld r16, Z+
                    cpi r16, 0
                    breq UartSendStringExit
                    rcall UartSendByte
                    rjmp UartSendStringLoop
UartSendStringExit:
                    pop r16
                    ret



