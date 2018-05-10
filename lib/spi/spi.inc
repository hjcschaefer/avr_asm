;-------------------- SPI ---------------------------
;
; API:
; 
; SPIInit        : call before first use 
; SPIReadByte    : input  : r16, address
;                  output : r16, received byte
; SPIWriteByte   : input  : r16, address
;                  output : r17, byte to write
;
; * Note: SPI Model 3 is hard coded !
;
; 
; Hardware: uses the normal SPI ports on ATMega328p:
; PORTB
.equ SPI_PORT     = PORTB
.equ SPI_DIR      = DDRB
.equ SPI_MISO     = 4
.equ SPI_MOSI     = 3
.equ SPI_SCK      = 5
.equ SPI_SS       = 2



