; **** Include i2c.inc !!!!!

.cseg

; -------------- I2C Routines -------------------------

; Note, I2C is interrupt driven but we can use it without a interrupt handler:
; if we clear TWIE bit in TWCR we get flagged via TWINT in TWCR but no interrupt
; is dispatched. We need to poll TWINT

I2C_init:        ; initialize I2C connection -> configure pins
                    sbi I2C_ERROR_DDR, I2C_ERROR_PIN   ; init error led
                    cbi I2C_ERROR_PORT, I2C_ERROR_PIN  ; do not light

                    sbi DDRC, SCK        ; both I2C pins are outputs
                    sbi DDRC, SDA
                    sbi PORTC, SCK       ; put them on high, pullup? see at328 sec. 26.5.1
                    sbi PORTC, SDA

                    lds r16, TWSR        ; read status register to set prescaler
                    andi r16, 0b11111100 ; delete bits 0, 1
                    sts TWSR, r16

                    ; we have to set the clock speed for the bus. We have 16Mhz and want 400khz:
                    ; see sec 26.5.2: scl_freq = 16Mhz / (16+2*TWBR*prescale)   ; prescale default = 1?
                    ; TWBR= 12?
                    ; for 100 khz (which is what arduino uses) it is 72
                    ldi r16,  I2C_TWBR
                    sts TWBR, r16
                    ret

I2C_start:          ; start up I2C: no data, no address yet
                    ; below: setting TWINT clears it and starts I2C
                    ;        setting TWEN enables I2C, difference to above?
                    ;        setting TWSTA means we are the master
                    ldi r16, (1<<TWINT) | (1<<TWSTA) | (1<<TWEN)  
                    sts TWCR, r16
                    ; now we wait for TWINT so that we know the I2C is started up
I2C_start_wait:     lds r16, TWCR
                    sbrs r16, TWINT       ; skip if bit is set -> if TWINT is cleared we are ready
                    rjmp I2C_start_wait
                    lds r16, TWSR         ; we can do some error checks on TWSR
                    andi r16, 0xf8        ; no need for prescale bits
                    cpi r16, 0x08         ; 0x08 is if everything is ok
                    brne I2C_error        ; this is our error handler
                    ret

I2C_stop:           ; stop I2C: same as start, but with TWSTO instead of TWSTA
                    ldi r16, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN)
                    sts TWCR, r16
                    ; wait for confirmation 
I2C_stop_wait:      lds r16, TWCR
                    andi r16, 0b00010000
                    brne I2C_stop_wait
                    ret

I2C_sendAddress:    ; send the slaves address (in r16) - this is for write access only!
                    lsl r16                     ; we need to shift one bit left. If
                                                ; we wanted read access we would need
                                                ; to set bit 0 to 1
                    sts TWDR, r16               ; store in data reg
                    ldi r16, (1<<TWINT) | (1<<TWEN) ; start i2c
                    sts TWCR, r16
I2C_sendAddress_l:  lds r16, TWCR
                    sbrs r16, TWINT
                    rjmp I2C_sendAddress_l
                    ; now check that the slave acknowlegded
                    lds r16, TWSR
                    andi r16, 0xf8        ; mask prescale bits
                    cpi r16, 0x18         ; 0x18 -> all is ok
                    brne I2C_no_ack
                    ret
                    
I2C_put:            ; put byte onto bus byte is assumed to be in r16
                    sts TWDR, r16                           ; write byte to data register
                    ldi r16, (1<<TWINT) | (1<<TWEN)         ; start I2C
                    sts TWCR, r16                           ; now we have to wait again
I2C_put_wait:       lds r16, TWCR                           ; check if TWINT is set
                    sbrs r16, TWINT                         ; skip jump if TWINT is set
                    rjmp I2C_put_wait
                    ret

I2C_error:          sbi I2C_ERROR_PORT, I2C_ERROR_PIN       ; failure when starting i2c -> red light
                    rjmp I2C_error
I2C_no_ack:         sbi I2C_ERROR_PORT, I2C_ERROR_PIN       ; fast flash if no ack
                    rcall Delay100ms
                    cbi I2C_ERROR_PORT, I2C_ERROR_PIN
                    rcall Delay100ms
                    rjmp I2C_no_ack
 
