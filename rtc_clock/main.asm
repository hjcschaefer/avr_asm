; Simple clock using DS3234 RTC and a LCD
;
; tests spi and DS3234 code


.include "m328pdef.inc"

.equ FCPU = 16000000              ; 16 Mhz arduino micro
; ====================== HARDWARE SETUP ======================================

; ---- LCD
.equ LCD_DATA     = PORTD  ; **** must be pins 4-7 !!!
.equ LCD_CTL      = PORTC
.equ LCD_RS       = 0
.equ LCD_RW       = 1
.equ LCD_E        = 2

.include "..\lib\spi\spi.inc"
.include "..\lib\misc\num2str.inc"
.include "..\lib\lcd\lcd4.inc"
.include "..\lib\delay\no_timer_delays.inc"
.include "..\lib\ds3234\ds3234.inc"

; ============================================================================


.cseg ;------------  FLASH ----------------------------------
.org 0x0000
                    rjmp Reset


.org INT_VECTORS_SIZE

.include "..\lib\spi\spi.asm"
.include "..\lib\misc\num2str.asm"
.include "..\lib\lcd\lcd4.asm"
.include "..\lib\delay\no_timer_delays.asm"
.include "..\lib\ds3234\ds3234.asm"


DisplayColon:       push r16
                    ldi r16, ':'
                    rcall Lcd4Data
                    pop r16
                    ret

DisplayClock:       push r16
                    push r17
                    rcall Lcd4Home
                    rcall DS3234GetHours
                    rcall Lcd4BCDOut
                    rcall DisplayColon
                    rcall DS3234GetMinutes
                    rcall Lcd4BCDOut
                    rcall DisplayColon
                    rcall DS3234GetSeconds
                    rcall Lcd4BCDOut
                    ldi r16, 2
                    ldi r17, 0
                    rcall Lcd4SetXY
                    ;rcall DS3234GetWeekDay
                    ;rcall Lcd4_8BitOut
                    rcall DS3234GetWeekDayStr
                    rcall Lcd4FlashString
                    ldi r16, ' '
                    rcall Lcd4Data
                    rcall DS3234GetDay
                    rcall Lcd4BCDOut
                    ldi r16, ' '
                    rcall Lcd4Data
                    rcall DS3234GetMonthStr
                    rcall Lcd4FlashString
                    ldi r16, ' '
                    rcall Lcd4Data
                    ldi r16, '2'     ; hard coded century
                    rcall Lcd4Data
                    ldi r16, '0'     ; hard coded century
                    rcall Lcd4Data
                    rcall DS3234GetYear
                    rcall Lcd4BCDOut

                    ldi r16, 0
                    ldi r17, 14
                    rcall Lcd4SetXY

                    rcall DS3234TempStr
                    rcall Lcd4String

                    ;rcall DS3234GetTempInt
                    ;rcall Lcd4_8BitOut
                    pop r17
                    pop r16
                    ret

                   
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
                    rcall SPIInit

                    ldi ZL, LOW(2*Msg)
                    ldi ZH, HIGH(2*Msg)
                    rcall Lcd4FlashString
                    rcall Delay1s
                    rcall Delay1s
                    rcall Lcd4ClearScreen

MainLoop:
                    rcall DisplayClock
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms
                    rcall Delay100ms

                    rjmp MainLoop


SetHour:  .db   "Hour:   ", 0, 0
SetMinute:  .db "Minute: ", 0, 0
Msg: .db "Wait...", 0



