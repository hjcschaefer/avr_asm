;
; lcdtest.asm
;
; Created: 01/05/2018 18:36:17
; Author : heiko
;

.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

.equ BAUD_RATE = 300 

.include "..\lib\uart\uart.inc"


;; Hardware setup
.equ LCD_DATA     = PORTD  ; **** must be pins 4-7 !!!
.equ LCD_CTL      = PORTC
.equ LCD_RS       = 0
.equ LCD_RW       = 1
.equ LCD_E        = 2

.include "..\lib\misc\num2str.inc"
.include "..\lib\lcd\lcd4.inc"
.include "..\lib\delay\no_timer_delays.inc"

; --------------------- RAM -----------------------
.dseg

.org 0x0300    ; start of the free space

buffer:


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset
.org URXCaddr
                    rjmp ReceiveHandler

.org INT_VECTORS_SIZE

.include "..\lib\misc\num2str.asm"
.include "..\lib\delay\no_timer_delays.asm"
.include "..\lib\lcd\lcd4.asm"
                   
; --------------------------- MAIN ------------------------------
Reset:
                    ;; set up return stack
                    ldi r16, LOW(RAMEND)
                    out SPL, r16
                    ldi r16, HIGH(RAMEND)
                    out SPH, r16
                    ;; initialize buffer for serial commands
                    ldi XL, LOW(buffer)
                    ldi XH, HIGH(buffer)
                    ;; mark buffer end with zero
                    ldi r16, 0
                    st X, r16
                    ;; our flag that we have received a command is r0
                    mov r0, r16 ; set to 0, if 0xff we have a string
                    ;; init uart
                    rcall UartInit

                    sei

					rcall num2strInit
					rcall Lcd4Init
					rcall Lcd4ClearScreen
					ldi ZL, LOW(2*msg)
					ldi ZH, HIGH(2*msg)
					rcall Lcd4FlashString

                    ldi r16, 2
                    ldi r17, 0
                    rcall Lcd4SetXY

                    ;; here is our endless loop waiting for r0 to show incoming data
wait_for_serial:
                    mov r16, r0
                    cpi r16, 0xff
                    brne wait_for_serial
                    ; now we got something!

                    ldi r16, 0
                    mov r0, r16

                    ;mov r16, XL
                    ;rcall Lcd4_8BitOut
                    ;rjmp wait_for_serial

                    ldi ZL, LOW(buffer)
                    ldi ZH, HIGH(buffer)
                    rcall Lcd4String

                    ldi XL, LOW(buffer)
                    ldi XH, HIGH(buffer)
                    ;; mark buffer end with zero
                    ldi r16, 0
                    st X, r16

                    ldi r16, 2
                    ldi r17, 0
                    rcall Lcd4SetXY

                    rjmp wait_for_serial



Fini:               rjmp Fini



;----------------- IRQ Handler when receiving on serial -----------------------------
ReceiveHandler:     push r16      ; save state!
                    in r16, SREG
                    push r16

                    ; UDR is memory mapped -> in will not work
                    lds r16, UDR0     ; received -> is it line feed?
                    cpi r16, 0x0a
                    brne rcv_add_char
                    ldi r16, 0xff
                    mov r0, r16     ; mark that we have received a full string!!!
                    rjmp rcv_fini

rcv_add_char:       
                    st X+, r16      ; save to buffer
                    ldi r16, 0
                    st X, r16       ; mark end of string

rcv_fini:           pop r16
                    out SREG, r16
                    pop r16
                    reti

;;; adapted
UartInit:
                    ; setting baud rate
                    ldi r16, HIGH(UBRRVAL)
                    sts UBRR0H, r16
                    ldi r16, LOW(UBRRVAL)
                    sts UBRR0L, r16
                    ; setting 8N1: 8 data bits, no parity, 1 stop bit
                    ldi r16, (1<<UCSZ01) | (1<<UCSZ00);
                    sts UCSR0C, r16
                    ldi r16, (1<<TXEN0) | (1<<RXEN0)   ; also receive!!!
                    sts UCSR0B, r16
                    ;; set bit to enable rx irq
                    lds r16, UCSR0B
                    ori r16, (1<<RXCIE0)
                    sts UCSR0B, r16
                    ;sbi UCSR0B, RXCIE0 ; memory mapped
                    ret

;...........  UartSendByte ...........................
; IN : r16 (byte to send)
; OUT : -
;...........  UartSendByte ...........................
UartSendByte:   ; wait until UDRE1 is set
				    push r16
UartWaitToTransmit:

msg:   .db "Deskclock", 0
