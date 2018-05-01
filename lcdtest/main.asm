;
; lcdtest.asm
;
; Created: 01/05/2018 18:36:17
; Author : heiko
;

.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

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

.org 0x0100    ; start of the free space


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


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
                    sei

					rcall num2strInit
					rcall Lcd4Init
					rcall Lcd4ClearScreen
					ldi ZL, LOW(2*msg)
					ldi ZH, HIGH(2*msg)
					rcall Lcd4FlashString
Fini:               rjmp Fini

msg:   .db "HELLO", 0