;
; uart_test.asm
;
; Created: 10/05/2018 11:26:54
; Author : heiko
;

.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

.equ BAUD_RATE = 300 

.include "..\lib\uart\uart.inc"

; --------------------- RAM -----------------------
.dseg

.org 0x0100    ; start of the free space


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


.org INT_VECTORS_SIZE

.include "..\lib\uart\uart.asm"

Reset:
                    ;; set up return stack
                    ldi r16, LOW(RAMEND)
                    out SPL, r16
                    ldi r16, HIGH(RAMEND)
                    out SPH, r16
                    sei

                    rcall UartInitOnlySend
                    ldi ZL, LOW(2*msg)
                    ldi ZH, HIGH(2*msg)
                    rcall UartSendFlashString
Fini:               rjmp Fini

msg: .db "Hallo Welt", 0, 0


