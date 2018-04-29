;
; Blink.asm
;
; Created: 29/04/2018 17:38:11
; Author : heiko
;

.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


.org INT_VECTORS_SIZE

.include "..\lib\delay\no_timer_delays.asm"

Reset:          sbi DDRB, 0

Loop:           sbi PORTB, 0
                rcall Delay100ms
                cbi PORTB, 0
                rcall Delay1s
                rjmp Loop
                

