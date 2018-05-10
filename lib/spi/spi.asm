; ----------------------------------------------------------------
;   SPI
;
SPIInit:            push r16
                    sbi SPI_DIR, SPI_SS
                    sbi SPI_DIR, SPI_MOSI
                    sbi SPI_DIR, SPI_SCK
                    sbi SPI_PORT, SPI_SS ; no chip selected
                    ; SPI mode 3: CPHA = 1 CPOL = 1
                    ldi r16, (1<<SPE) | (1<<MSTR) | (1<<CPHA) | (1<<CPOL) | (1<<SPR1) | (1<<SPR0)
                    out SPCR, r16
                    pop r16
                    ret

SPITransceive:      ; transmit byte in  r16
                    ; client code is responsible for setting SS low!
                    push r0
                    out SPDR, r16
SPISendWait:
                    in r0, SPSR
                    sbrs r0, SPIF
                    rjmp SPISendWait
                    in r16, SPDR
                    pop r0
                    ret

SPIReadByte:        ; address is given in r16, value returned in r16
                    cbi SPI_PORT, SPI_SS
                    rcall SPITransceive
                    ldi r16, 0x00
                    rcall SPITransceive
                    sbi SPI_PORT, SPI_SS ; no chip selected
                    ret

SPIWriteByte:        ; address is given in r16, value in r17
                    ori r16, 0x80  ; set bit 7 to mark command
                    cbi SPI_PORT, SPI_SS
                    rcall SPITransceive
                    mov r16, r17
                    rcall SPITransceive
                    sbi SPI_PORT, SPI_SS ; no chip selected
                    ret



