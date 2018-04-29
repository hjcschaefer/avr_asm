; ---------------------------------------------------------------------------------
; 
; Delays that do NOT use any timer. Tuned for 16MHz Atmega 328p
;
; API
; Delay100ms       Delays for 100ms , pushes all registers, but flags might get changed
; Delay1s          Delays roughly for 1s
; Delay2ms
; Delay40us
; Delay450ns      ; very inaccurate
; Delay500ns      ; very inaccurate
; 
; ---------------------------------------------------------------------------------

Delay100ms:         push r16    ; quite accurate!!! osci tuned
                    push r17
                    push r18
                    ldi r16, 0x07
DelayOuter:         ldi r17, 0xe0
DelayInner:         ldi r18, 0xff
DelayInner2:        nop
                    dec r18
                    brne DelayInner2
                    dec r17
                    brne DelayInner
                    dec r16
                    brne DelayOuter
                    pop r18
                    pop r17
                    pop r16
                    ret

Delay2ms:           push r16    ; quite accurate!!! osci tuned
                    push r17
                    ldi r16, 0x23
Delay2msOuter:      ldi r17, 0xe0
Delay2msInner:      nop
                    dec r17
                    brne Delay2msInner
                    dec r16
                    brne Delay2msOuter
                    pop r17
                    pop r16
                    ret

Delay40us:          push r16    ; quite accurate!!! osci tuned
                    ldi r16, 0xA0
Delay40usLoop:      nop
                    dec r16
                    brne Delay40usLoop
                    pop r16
                    ret



Delay1s:            rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    ret

; ------- most of these are for the LCD interface 
Delay450ns:         nop   ; not very accurate
                    nop
                    ret


Delay500ns:         nop
                    nop
                    nop
                    ret
