/*
     4 Bit LCD Interface HD44780

     4x20 Display

In order to use this, you need the Delay library and need to set the pins:

.equ LCD_DATA     = PORTF  ; **** must be pins 4-7 !!!
.equ LCD_DATA_DIR = DDRF   ; 
.equ LCD_CTL      = PORTB
.equ LCD_CTL_DIR  = DDRB
.equ LCD_RS       = 4
.equ LCD_RW       = 5
.equ LCD_E        = 6

Library uses two 10 Bytes buffers in SRAM

Functions:
------------------------------------------------------------------------
Lcd4Init:       initialize library
------------------------------------------------------------------------
Lcd4Cmd:        write command in r16 to controller
------------------------------------------------------------------------
Lcd4Data:       write data in r16 to controller
------------------------------------------------------------------------
Lcd4FlashString:    print string in flash (ZH/ZL) to lcd  r16 destroyed
------------------------------------------------------------------------
Lcd4String:         print string SRAM (ZH/ZL) to lcd  r16 destroyed
------------------------------------------------------------------------
Lcd4SetXY:          set cursor to row r16 (0-3) and column r17
------------------------------------------------------------------------
Lcd4ClearScreen:    clear screen
------------------------------------------------------------------------
Lcd4BCDOut:         print out BCD in r16
------------------------------------------------------------------------
Lcd4BinaryOut:      print out binary in r16
------------------------------------------------------------------------
Lcd4ClearLine:      clear line (r16 = 0..3)  cursor then moved to start of line
------------------------------------------------------------------------
Lcd4_16BitOut:       print out r17:r16
------------------------------------------------------------------------
Lcd4Home:           set cursor to 0,0
------------------------------------------------------------------------
Lcd4_8BitOut:        print out 16

DEPENDENCIES: delay/no_delay_timer, misc/num2str
*/


; check that we have all pins defined

.ifndef LCD_DATA
.error "Define LCD_DATA: port of 4 data lines, bits 4-7"
.endif
.ifndef LCD_CTL
.error "Define LCD_CTL: port where control lines are"
.endif
.ifndef LCD_RS
.error "Define LCD_RS: pin for RS"
.endif
.ifndef LCD_RW
.error "Define LCD_RW: pin for RW"
.endif
.ifndef LCD_E
.error "Define LCD_E: pin for E"
.endif

.ifdef LCD_DATA
.if (LCD_DATA==PORTB)
.equ LCD_DATA_DIR = DDRB
.elif (LCD_DATA==PORTC)
.equ LCD_DATA_DIR = DDRC
.elif (LCD_DATA==PORTD)
.equ LCD_DATA_DIR = DDRD
.else
.error "Unknown port defined for LCD_DATA"
.endif
.endif

.ifdef LCD_CTL
.if (LCD_CTL==PORTB)
.equ LCD_CTL_DIR = DDRB
.elif (LCD_CTL==PORTC)
.equ LCD_CTL_DIR = DDRC
.elif (LCD_CTL==PORTD)
.equ LCD_CTL_DIR = DDRD
.else
.error "Unknown port defined for LCD_CTL"
.endif
.endif

; some Lcd command stuff
.equ DISPLAY_ON = 0b00000100
.equ CURSOR_ON  = 0b00000010
.equ BLINK_ON   = 0b00000001

; ****************  CONFIGURE THIS DOR YOUR MODE
.equ LCD_MODE = DISPLAY_ON
;.equ LCD_MODE = DISPLAY_ON | CURSOR_ON | BLINK_ON

