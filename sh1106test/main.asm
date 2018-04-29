;
; sh1106.asm
;
; Created: 30/03/2018 14:27:25
; Author : heiko
;
; simple driver for SH1106 128x64 OLED display, ripped from sh1106 Arduino library

.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro

.include "..\lib\i2c\i2c.inc"
.include "..\lib\sh1106\sh1106.inc"

; --------------------- RAM -----------------------
.dseg

.org 0x0100    ; start of the free space


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


.org INT_VECTORS_SIZE

.include "..\lib\delay\no_timer_delays.asm"
.include "..\lib\i2c\i2c.asm"
.include "..\lib\sh1106\sh1106.asm"
                   
; --------------------------- MAIN ------------------------------
Reset:
                    ;; set up return stack
                    ldi r16, LOW(RAMEND)
                    out SPL, r16
                    ldi r16, HIGH(RAMEND)
                    out SPH, r16
                    sei


Display:
                    ; this is SH1106 test code
                    rcall SH1106_init
                    rcall SH1106_clear

                    ldi r19, 8
                    ldi r18, 16 
                    ldi r20, 0x00  ; row 
              b2:   ldi r21, 0x00  ; column
                    ldi r18, 16
              b1:   mov r16, r21
                    mov r17, r20
                    rcall SH1106_set_xy
                    ldi r16, 'R'
                    rcall SH1106_putchar
                    rcall SH1106_show
                    rcall Delay100ms

                    inc r21
                    dec r18   ; column iterator
                    brne b1
                    inc r20
                    dec r19
                    brne b2
                    rjmp Fini
                    

Fini:               rjmp Fini


; =============== SUBROUTINES =======================

                   


