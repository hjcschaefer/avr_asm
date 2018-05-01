.cseg

; private:
Lcd4NibbleCmd:      ; write the high nibble of r16
                    ; r16 stays intact
                    push r17
                    push r16
                    andi r16, 0xf0   ; delete lower nibble which we are not going to write
                    in r17, LCD_DATA ; read in LCD data port (we do not want to change the unused bytes -03
                    andi r17, 0x0F   ; delete upper nibble 
                    or  r16, r17    ; combine current bytes 0-3 with bytes 4-7 that we want to write
                    out LCD_DATA, r16
                    cbi LCD_CTL, LCD_RS ; RS = 0 -> command byte
                    sbi LCD_CTL, LCD_E  ; E  = 1 -> signal LCD has new command
                    rcall Delay450ns
                    cbi LCD_CTL, LCD_E  ; E  = 0 -> signal finished
                    rcall Delay500ns
                    pop r16
                    pop r17
                    ret
                    
Lcd4NibbleData:     ; write the high nibble of r16
                    ; r16 stays intact
                    push r17
                    push r16
                    andi r16, 0xf0   ; delete lower nibble which we are not going to write
                    in r17, LCD_DATA ; read in LCD data port (we do not want to change the unused bytes -03
                    andi r17, 0x0F   ; delete upper nibble 
                    or  r16, r17    ; combine current bytes 0-3 with bytes 4-7 that we want to write
                    out LCD_DATA, r16
                    sbi LCD_CTL, LCD_RS ; RS = 1 -> data byte
                    sbi LCD_CTL, LCD_E  ; E  = 1 -> signal LCD has new command
                    rcall Delay450ns
                    cbi LCD_CTL, LCD_E  ; E  = 0 -> signal finished
                    rcall Delay500ns
                    pop r16
                    pop r17
                    ret
 
; ====================== PUBLIC =========================================================
Lcd4Cmd:            ; write command byte in r16 (gets destroyed)
                    ; write high nibble first
                    rcall Lcd4NibbleCmd
                    swap r16
                    rcall Lcd4NibbleCmd
                    rcall Delay40us
                    ret

Lcd4Data:           ; write data byte in r16 (gets destroyed)
                    ; write high nibble first
                    rcall Lcd4NibbleData
                    swap r16
                    rcall Lcd4NibbleData
                    rcall Delay40us
                    ret


Lcd4Init:           ; 4 bit lcd init blinking cursor
                    push r16
                    push ZL
                    push ZH
                    rcall Delay100ms           ; just to be on the save side

                    ldi r16, LCD_DATA_DIR  ; set directions for LCD pins: we only use pins 4-7!
                    ori r16, 0xF0          ; 4-7 bits = 1
                    out LCD_DATA_DIR, r16
                    sbi LCD_CTL_DIR, LCD_RS
                    sbi LCD_CTL_DIR, LCD_RW
                    sbi LCD_CTL_DIR, LCD_E

                    ; control lines to zero
                    cbi LCD_CTL, LCD_RS
                    cbi LCD_CTL, LCD_RW
                    cbi LCD_CTL, LCD_E

                    ; wakeup
                    ldi r16, 0x30
                    rcall Lcd4NibbleCmd
                    rcall Delay100ms
                    ldi r16, 0x30
                    rcall Lcd4NibbleCmd
                    rcall Delay100ms
                    ldi r16, 0x30
                    rcall Lcd4NibbleCmd
                    rcall Delay100ms

                    ; init by writing single(!) nibble to initialize to 4 bit
                    ; by default controller is in 8 bit mode and this looks 8 bit to hime
                    ldi r16, 0x20
                    rcall Lcd4NibbleCmd
                    rcall Delay2ms

                    ldi r16, 0x28     ; rewrite the 4 bit command byte to pass the lower
                    rcall Lcd4Cmd     ; nibble part that switches 1/2 line interface on
                                      ; for a 4 line one we need to re-use 2
                    rcall Delay2ms

                    ; now cursor
                    ldi r16, 0x08 | LCD_MODE
                    rcall Lcd4Cmd
                    rcall Delay2ms       ; here we need to wait long!


                    ; clear screen
                    ldi r16, 0x01
                    rcall Lcd4Cmd
                    rcall Delay2ms       ; here we need to wait long!
                    pop ZH
                    pop ZL
                    pop r16
                    ret


;-------------------------------------------------------------------------------------------------
Lcd4FlashString:    ; put out string in flash, pointed to by ZH/ZL
                    lpm r16, Z+
                    cpi r16, 0
                    breq Lcd4FlashStringExit
                    rcall Lcd4Data
                    rjmp Lcd4FlashString
Lcd4FlashStringExit:ret

;-------------------------------------------------------------------------------------------------
Lcd4String:         ; put out string in memory, pointed to by ZH/ZL
                    ld r16, Z+
                    cpi r16, 0
                    breq Lcd4StringExit
                    rcall Lcd4Data
                    rjmp Lcd4String
Lcd4StringExit:     ret

;-------------------------------------------------------------------------------------------------
Lcd4SetXY:          ; 4x20 display
                    ; r16: row => 0-3
                    ; r17 column => 0-19
                    push ZL
                    push ZH
                    push r18
                    inc r16
                    ldi ZH, HIGH(2*LcdRowStarts)
                    ldi ZL, LOW(2*LcdRowStarts)
Lcd4SetXY_r:        lpm r18, Z+
                    dec r16
                    brne Lcd4SetXY_r
                    mov r16, r17
                    add r16, r18
                    ori r16, 0x80     ; this is the command bit
                    rcall Lcd4Cmd
                    rcall Delay2ms
                    pop r18
                    pop ZH
                    pop ZL
                    ret


;-------------------------------------------------------------------------------------------------
Lcd4ClearScreen:    ; just clear screen
                    ldi r16, 0x01
                    rcall Lcd4Cmd
                    rcall Delay2ms
                    ret

;-------------------------------------------------------------------------------------------------
Lcd4Home:           push r16
                    ldi r16, 0x02 ; move cursor to home position
                    rcall Lcd4Cmd
                    rcall Delay2ms
                    pop r16
                    ret

;-------------------------------------------------------------------------------------------------
Lcd4BCDOut:         ; r16 contains a BCD number, print it out as 2 digit decimal
                    push r16
                    swap r16
                    andi r16, 0x0F  ; zero out MSNibble
                    ori r16, 0x30   ; this adds '0'
                    rcall Lcd4Data
                    pop r16
                    andi r16, 0x0F  ; zero out MSNibble
                    ori r16, 0x30   ; this adds '0'
                    rcall Lcd4Data
                    ret

;-------------------------------------------------------------------------------------------------
Lcd4BinaryOut:      push r17
                    push r16
                    ldi r17, 8
Lcd4BinaryOutNext:  pop r16
                    sbrs r16, 7
                    jmp Lcd4BinOutZero
                    lsl r16
                    push r16
                    ldi r16, '1'
                    rcall Lcd4Data
                    rjmp Lcd4BinaryOutX
Lcd4BinOutZero:     lsl r16
                    push r16
                    ldi r16, '0'
                    rcall Lcd4Data
Lcd4BinaryOutX:     dec r17
                    brne Lcd4BinaryOutNext
                    pop r16
                    pop r17
                    ret

; --------------------------------------------------------------------
Lcd4ClearLine:     push r17
                   push r16
                   ldi r17, 0x00
                   rcall Lcd4SetXY
                   ldi r17, 19
Lcd4ClearLineL:    ldi r16, ' '
                   rcall Lcd4Data
                   dec r17
                   brne Lcd4ClearLineL
                   pop r16
                   ldi r17, 0x00
                   rcall Lcd4SetXY
                   pop r17
                   ret

; --------------------------------------------------------------------
Lcd4_16BitOut:     push ZL
                   push ZH
                   rcall Unsigned16Bit2Ascii
                   rcall Lcd4String
                   pop ZH
                   pop ZL
                   ret

; --------------------------------------------------------------------
Lcd4_8BitOut:      push ZL
                   push ZH
                   rcall Unsigned8Bit2Ascii
                   rcall Lcd4String
                   pop ZH
                   pop ZL
                   ret




.cseg
LcdRowStarts:      .db 0, 0x40, 0x14, 0x54   ; 4x20 LCD row start addresses


