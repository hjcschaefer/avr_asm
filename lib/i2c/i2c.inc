
; FCPU must be defined
.IFNDEF FCPU
.ERROR "FCPU must (!) be defined"
.ENDIF

.equ I2C_FRQ     = 100000  ; frequency in Hz -> 100kHz
.equ I2C_TWBR = (FCPU/I2C_FRQ - 16)/2

; ====== HARDWARE =======
; I2C pins
.equ I2C_ERROR_PIN = 1         ; on this pin we expect an LED
.equ I2C_ERROR_PORT = PORTB
.equ I2C_ERROR_DDR  = DDRB
.equ SCK = 5   ; I2C clock pin, port C
.equ SDA = 4   ; I2C data pin, port C

; ERROR LED:
;
; - if it is continuously red, I2C could not initialize
; - if it blinks fast, we did not get an ack

;========================= API ===============================
;
;  I2C_init  : setup hardware and clocks
;
;  I2C_start : initiate a I2C connection
;
;  I2C_sendAddress : send the slave address (in r16)
;
;  I2C_put : put byte in r16 onto I2C bus
;
;  I2C_stop : stop I2C connection 
;
;==============================================================
;
; EXAMPLE:
;
;      rcall I2C_init                          ; init pins, set clock
;      rcall I2C_start                         ; init I2C
;      ldi r16, <addr>                         ; slave address
;      rcall I2C_sendAddress                   ; start to talk
;      ldi r16, <data>                         ; what to send
;      rcall I2C_put                           ; put on bus, we can repeat this
;      ....
;      rcall I2C_stop                          ; stop bus


; !!!! note that r16 gets used by a lot of functions. DONT rely on it
