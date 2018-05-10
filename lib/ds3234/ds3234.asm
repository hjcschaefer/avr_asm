
;  returned in r16 as a BCD
DS3234GetSeconds: ldi r16, 0x00
                  rcall SPIReadByte
                  ret

DS3234GetMinutes: ldi r16, 0x01
                  rcall SPIReadByte
                  ret

DS3234GetHours:   ldi r16, 0x02
                  rcall SPIReadByte
                  sbrc r16, 6
                  andi r16, 0x1f
                  ret

DS3234GetYear:    ldi r16, 6
                  rcall SPIReadByte
                  ret
                  
DS3234GetMonth:   ldi r16, 5
                  rcall SPIReadByte
                  andi r16, 0x1f  ; blend out century
                  ret

DS3234GetMonthStr:
                  push r0
                  push r1
                  push r17
                  rcall DS3234GetMonth
                  ; check that we are 1-7
                  ldi r17, 1
                  cp r16, r17
                  brlt DS3234BadWeekDay
                  ldi r17, 12
                  cp r16, r17
                  brge DS3234BadWeekDay
                  dec r16
                  ldi r17, 6  ; each string is 6 bytes
                  mul r16, r17
                  ldi ZL, LOW(2*MonthNames);
                  ldi ZH, HIGH(2*MonthNames);
                  add ZL, r0
                  adc ZH, r1
                  pop r17
                  pop r1
                  pop r0
                  ret

DS3234GetDay:     ldi r16, 4
                  rcall SPIReadByte
                  ret

DS3234GetWeekDay: ldi r16, 3
                  rcall SPIReadByte
                  ret

DS3234GetWeekDayStr:  ; returns string in flash ZL/ZH
                  push r0
                  push r1
                  push r17
                  rcall DS3234GetWeekDay
                  ; check that we are 1-7
                  ldi r17, 1
                  cp r16, r17
                  brlt DS3234BadWeekDay
                  ldi r17, 8
                  cp r16, r17
                  brge DS3234BadWeekDay
                  dec r16     ; zero based
                  ldi r17, 6  ; each string is 6 bytes
                  mul r16, r17
                  ldi ZL, LOW(2*WeekDayNames);
                  ldi ZH, HIGH(2*WeekDayNames);
                  add ZL, r0
                  adc ZH, r1
                  pop r17
                  pop r1
                  pop r0
                  ret
DS3234BadWeekDay:
                  ldi ZL, LOW(2*BadName);
                  ldi ZH, HIGH(2*BadName);
                  pop r17
                  pop r1
                  pop r0
                  ret

; value passed in r16!
DS3234SetHours:   push r17
                  push r16
                  ldi r16, 0x02
                  pop r17
                  rcall SPIWriteByte
                  pop r17
                  ret

DS3234SetMinutes: push r17
                  push r16
                  ldi r16, 0x01
                  pop r17
                  rcall SPIWriteByte
                  pop r17
                  ret

DS3234SetWeekDay: push r17
                  push r16
                  ldi r16, 0x03
                  pop r17
                  rcall SPIWriteByte
                  pop r17
                  ret


DS3234GetTempInt:
                  ldi r16, 0x11
                  rcall SPIReadByte
                  ret

DS3234GetTempFrac:
                  ldi r16, 0x12
                  rcall SPIReadByte
                  ret

; build temp string in ZL/ZH
DS3234TempStr:    push r16
                  push r17
                  rcall DS3234GetTempInt
                  push r16
                  rcall Unsigned8Bit2Ascii
                  ;; now we have it in ZH/ZL. we know 
                  ;; it is < 100, so we can reuse the first digit
                  ;; to add a sign
                  pop r16
                  sbrs r16, 7
                  rjmp DS3234TempStrPos
                  ldi r16, '-'
                  st Z, r16
                  rjmp DS3234TempStrCont
DS3234TempStrPos: ldi r16, '+'
                  st Z, r16
DS3234TempStrCont:
                  push ZL    ; need to return the start, but now we build fractional part
                  push ZH
                  ldi r17, 3 ; move to end of ZH/ZL buffer
                  eor r16, r16 ; set to 0
                  add ZL, r17
                  adc ZH, r16
                  ldi r16, '.'
                  st Z+, r16     ; adding decimal point
                  rcall DS3234GetTempFrac
                  ; bit 7,6 are it, we shift it so that it is
                  ; multiplied by 2
                  lsr r16
                  lsr r16
                  lsr r16
                  lsr r16
                  lsr r16
                  ; now copy the fractional part from flash to ram
                  push XL
                  push XH
                  ; we can only load from flash using Z so we need to swap roled
                  mov XH, ZH
                  mov XL, ZL
                  ldi ZH, HIGH(2*FractionalTemp)
                  ldi ZL, LOW(2*FractionalTemp)
                  add ZL, r16
                  eor r17, r17
                  adc ZH, r17
                  ; now we have to copy the two characters from flash to ram
                  lpm r16, Z+
                  st X+, r16
                  lpm r16, Z+
                  st X+, r16
                  pop XH
                  pop XL

                  ; DO NOT FORGET TO ADD 0 to END!!
                  ldi r16, 0
                  st Z+, r16

                  pop ZH
                  pop ZL
                  pop r17
                  pop r16
                  ret





; weekday short names in flash
BadName:
                   .db "---", 0, 0, 0
WeekDayNames:
                   .db "Sun", 0, 0, 0
                   .db "Mon", 0, 0, 0
                   .db "Tue", 0, 0, 0
                   .db "Wed", 0, 0, 0
                   .db "Thu", 0, 0, 0
                   .db "Fri", 0, 0, 0
                   .db "Sat", 0, 0, 0
MonthNames:
                   .db "Jan", 0, 0, 0
                   .db "Feb", 0, 0, 0
                   .db "Mar", 0, 0, 0
                   .db "Apr", 0, 0, 0
                   .db "May", 0, 0, 0
                   .db "Jun", 0, 0, 0
                   .db "Jul", 0, 0, 0
                   .db "Aug", 0, 0, 0
                   .db "Sep", 0, 0, 0
                   .db "Oct", 0, 0, 0
                   .db "Nov", 0, 0, 0
                   .db "Dec", 0, 0, 0

FractionalTemp: .db '0', '0'
                .db '2', '5'
                .db '5', '0'
                .db '7', '5'



