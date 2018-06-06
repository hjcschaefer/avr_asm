;
; pwm_example.asm
;
; Created: 10/05/2018 13:05:15
; Author : heiko
;
; just a slowly pulsing LED: demonstrate PWM

; Hardware:
.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

.equ LED_PIN = 6                  ; PWM pin is D6
.equ LED_PORT = PORTD
.equ LED_DIR = DDRD

; --------------------- RAM -----------------------
.dseg

.org 0x0100    ; start of the free space


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


.org INT_VECTORS_SIZE

.include "..\lib\delay\no_timer_delays.asm"

; --------------------------- MAIN ------------------------------
Reset:
                    ;; set up return stack
                    ldi r16, LOW(RAMEND)
                    out SPL, r16
                    ldi r16, HIGH(RAMEND)
                    out SPH, r16
                    sei

                    sbi LED_DIR, LED_PIN                     ; PD6 is output
                    
                    ; counter goes always all the way up to 256, output (non-inverted mode) is high from 0 until
                    ; OCR0A, then cleared-> duty cycle 
                    lds r16, TCCR0A
                    ori r16, (1<<COM0A1)            ; non-inverting mode -> also makes sure we are connected to pin
                    ori r16, (1<<WGM01) | (1<<WGM00); fast PWM mode
                    out TCCR0A, r16
                    lds r16, TCCR0B
                    ori r16, (1<<CS01)              ; prescaler of 8 -> 8khz
                    out TCCR0B, r16

                    ; here we change the duty cycle
                    ldi r17, 1
					neg r17                         ; r17 is no -1
                    ldi r18, 0
L1:                 out OCR0A, r18                  ; output compare register

                    sub r18, r17                    ; if r17 = -1 we add, other make smaller
                    rcall Delay2ms                  ; some delay
					rcall Delay2ms
					rcall Delay2ms
                    cpi r18, 0xB0                   ; have we reached maximal duty cycle (no FF as you hardly see the
                    breq switch                     ; LED go brighter
                    cpi r18, 0x00                   ; are we at zero duty cycle?
                    breq switch                     ; also switch
                    rjmp L1

switch:             neg r17                         ; negate the step: -1/1
                    rjmp L1

                    
                    cpi r17, 0x00   ; means increae
                    breq increase

invert:             ldi r17, 0x80

increase:           inc r18
                    rjmp L1

