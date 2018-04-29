.dseg

; ============ 1K buffer !!! ================================
.org 0x0400    ; frame buffer is 128*64 bit = 1024 bytes!
SH1106_buffer:

.cseg

; --------------- SH1106 routines ---------------------
SH1106_init:        ; run initialization sequence of commands stored in flash
                    push ZL
                    push ZH
                    ldi ZL, LOW(2*InitSH1106)               ; sequence of commands is in flash
                    ldi ZH, HIGH(2*InitSH1106)              ; the end is marked by 0xff
                    rcall I2C_init                          ; init pins, set clock
                    rcall I2C_start                         ; init I2C
                    ldi r16, SH1106_ADDR
                    rcall I2C_sendAddress                   ; send SH1106 write address
                    ldi r16, SH1106_CMD                     ; we are going to send commands
                    rcall I2C_put                           ; put on bus
SH1106_init_l:      lpm r16, Z+                             ; read command
                    cpi r16, 0xff                           ; is this the end flag?
                    breq  SH1106_init_fini                  ; yes, stpo
                    rcall I2C_put                           ; send command
                    rjmp SH1106_init_l
SH1106_init_fini:
                    rcall I2C_stop                          ; end I2C transmission
                    pop ZH
                    pop ZL
                    ret

SH1106_clear:       ldi r16, 0x00                           ; fill buffer with 0x00
                    rcall SH1106_fill_buffer
                    rcall SH1106_show
                    ldi r16, LOW(SH1106_buffer)               ; reset CL/CH the cursor to 0 position
                    mov r0, r16
                    ldi r16, HIGH(SH1106_buffer)
                    mov r1, r16
                    ret

SH1106_fill_buffer:  ; fill buffer with byte given in r16
                    push ZL
                    push ZH
                    push r18
                    push r19

                    ldi ZL, LOW(SH1106_buffer)    ; load base of buffer
                    ldi ZH, HIGH(SH1106_buffer)

                    ; we do two loops, one over the 8 rows
                    ; the inner loop over the 128 columns
                    ldi r18, 8
SH1106_fill_l1:     ldi r19, 128
SH1106_fill_l2:     st Z+, r16
                    dec r19
                    brne SH1106_fill_l2
                    dec r18
                    brne SH1106_fill_l1

                    pop r19
                    pop r18
                    pop ZH
                    pop ZL
                    ret

SH1106_set_row:     ; we set addressing to row passed in r16
                    push r16
                    rcall I2C_start
                    ldi r16, SH1106_ADDR
                    rcall I2C_sendAddress
                    ldi r16, SH1106_CMD         ; we are sending command
                    rcall I2C_put
                    pop r16
                    ori r16, SET_PAGE_ADDRESS   ; lower bits are row index
                    rcall I2C_put               
                    ldi r16, 0x00               ; the following set column to zero?
                    rcall I2C_put
                    ldi r16, 0x10
                    rcall I2C_put
                    rcall I2C_stop
                    ret

SH1106_put_data:         ; send data in r16
                    push r16
                    rcall I2C_start
                    ldi r16, SH1106_ADDR
                    rcall I2C_sendAddress
                    ldi r16, SH1106_DATA
                    rcall I2C_put
                    pop r16
                    rcall I2C_put
                    rcall I2C_stop
                    ret

SH1106_show:         ; move full frame buffer to SH1106
                    push ZL
                    push ZH
                    push r18                        ; counter rows 8->0
                    push r19                        ; counter cols 128->0
                    push r20                        ; row index 0->8

                    ldi ZL, LOW(SH1106_buffer)      ; load base of buffer
                    ldi ZH, HIGH(SH1106_buffer)

                    ; we do two loops, one over the 8 rows
                    ; the inner loop over the 128 columns
                    ldi r20, 0x00                   ; start row 0
                    ldi r18, 8                      ; go backward for easier check against 0
SH1106_show_l1:     ; need to set page address for row in r20
                    mov r16, r20
                    rcall SH1106_set_row
                    ;rjmp Fini

                    ldi r19, 128
SH1106_show_l2:     
                    ld r16, Z+                      ; read value from buffer
                    rcall SH1106_put_data           ; starts and stops I2C, each byte self contained
                    dec r19
                    brne SH1106_show_l2
                    inc r20                         ; move to next row
                    dec r18
                    brne SH1106_show_l1

                    ; ???? Necessary  rcall I2C_stop
                    pop r20
                    pop r19
                    pop r18
                    pop ZH
                    pop ZL
                    ret

SH1106_putchar:     ; r16 holds character (must be 0-9, A-Z, and also space!!!
                    ; will get put at current cursor position (CL/CH) in buffer
                    ; need to call show to see it
                    push ZL
                    push ZH
                    push YL
                    push YH
                    push r17
                    cpi r16, 0x20                   ; is it space?
                    brne SH1106_putchar_j1
                    ldi ZL, LOW(2*SPACE)            ; SPACE (8 zeros) has its special location
                    ldi ZH, HIGH(2*SPACE)
                    rjmp SH1106_putchar_out         ; write to buffer

SH1106_putchar_j1:
                    cpi r16, '0'
                    brlt SH1106_putchar_e           ; smaller than '0' -> we do not display that!
                    cpi r16, ':'                    ; right after 9, 
                    brge SH1106_putchar_j2          ; we do not have a greater than! Could be A-Z, a-z
                    subi r16, '0'                   ; 0-9, base on 0. But each char consists of 8 bytes, so * 8
                    lsl r16                         ; shift 3 left = * 8
                    lsl r16
                    lsl r16
                    ldi ZL, LOW(2*C09)              ; 0-9 characters are here
                    ldi ZH, HIGH(2*C09)
                    ldi r17, 0x00
                    add ZL, r16
                    adc ZH, r17
                    rjmp SH1106_putchar_out
SH1106_putchar_j2:  ; it could be a character
                    cpi r16, 'A'
                    brlt SH1106_putchar_e           ; not 0-9 or space but smaller A -> don't print
                    cpi r16, '['                    ; one beyond 'Z'
                    brge SH1106_putchar_e           ; also don't print
                    subi r16, 'A'                   ; base again on A
                    lsl r16                         ; again * 8
                    lsl r16
                    lsl r16
                    ldi ZL, LOW(2*AZ)               ; A-Z characters are here
                    ldi ZH, HIGH(2*AZ)
                    ldi r17, 0x00                   ; add offset in table
                    add ZL, r16
                    adc ZH, r17




SH1106_putchar_out: ; we have to have the character address in ZL/ZH here -> put into buffer
                    ldi r17, 8                      ; each character consists of 8 bytes
                    mov YL, CL                      ; current cursort position
                    mov YH, CH
SH1106_putchar_l1:
                    lpm r16, Z+
                    st Y+, r16
                    dec r17
                    brne SH1106_putchar_l1
                    mov CL, YL                      ; save current cursor position
                    mov CH, YH

SH1106_putchar_e:   pop r17
                    pop YH
                    pop YL  
                    pop ZH
                    pop ZL
                    ret

SH1106_set_xy:      ; r16 holds the column (0-15), r17 the row (0-7) any other bits just get wiped out'
                    ; so that we do not write into bad memory
                    push r18
                    ldi r18, LOW(SH1106_buffer)     ; reset cursor to position 0,0. Later we add the correct number
                    mov CL, r18
                    ldi r18, HIGH(SH1106_buffer)
                    mov CH, r18
                    andi r16, 0x0f                  ; only keep 0-15, bits 0000 1111
                    andi r17, 0x07                  ; only keep bits  0000 0111
                    lsl r16                         ; need *8, i.e. 3 times left to multiply
                    lsl r16
                    lsl r16
                    ror r17                         ; rows must be *128. If we keep r16 as higher byte, it is
                                                    ; de factor *256. We need to /2 which means shift right.
                                                    ; we do need the carry tough(!)
                    brcc SH1106_set_xy_j            ; if the carry is not set we don't need to do anything special
                    ori r16, 0x80                   ; set most significant bit
SH1106_set_xy_j:    add CL, r16                     ; now we add to the cursor position
                    adc CH, r17                     ; don't forget the carry

                    pop r18
                    ret


; ========================= DATA ======================
InitSH1106:   ; initialization seqence for SH1106
	.db SHDISPLAY_OFF, SET_MEMORY_ADDRESSING_MODE
	.db PAGE_MODE, SET_PAGE_ADDRESS
	.db SET_COM_OUTPUT_SCAN_DIRECTION, LOW_COLUMN_ADDRESS
	.db HIGH_COLUMN_ADDRESS, START_LINE_ADDRESS
	.db SET_CONTRAST_CTRL_REG, 0x7F
	.db SET_SEGMENT_REMAP, SET_NORMAL_DISPLAY
	.db SET_MULTIPLEX_RATIO, 0x3F
	.db OUTPUT_FOLLOWS_RAM, SET_DISPLAY_OFFSET
	.db 0x00, SET_DISPLAY_CLOCK_DIVIDE
	.db 0xF0, SET_PRE_CHARGE_PERIOD
	.db 0x22, SET_COM_PINS_HARDWARE_CONFIG
	.db 0x12, SET_VCOMH
	.db 0x20, SET_DC_DC_ENABLE
	.db 0x14, SHDISPLAY_ON
    .db 0xFF, 0xFF    ; *** this is NOT a command but the marker for the end!
 
 AZ:
        .db 0x00, 0x7E, 0x09, 0x09, 0x09, 0x09, 0x7E, 0x00  ; A 
        .db 0x00, 0x7F, 0x49, 0x49, 0x49, 0x49, 0x36, 0x00  ; B ... and so on
        .db 0x00, 0x3E, 0x41, 0x41, 0x41, 0x41, 0x22, 0x00
        .db 0x00, 0x7F, 0x41, 0x41, 0x41, 0x22, 0x1C, 0x00
        .db 0x00, 0x7F, 0x49, 0x49, 0x49, 0x49, 0x41, 0x00
        .db 0x00, 0x7F, 0x09, 0x09, 0x09, 0x09, 0x01, 0x00
        .db 0x00, 0x3E, 0x41, 0x41, 0x51, 0x51, 0x72, 0x00
        .db 0x00, 0x7F, 0x08, 0x08, 0x08, 0x08, 0x7F, 0x00
        .db 0x00, 0x00, 0x41, 0x41, 0x7F, 0x41, 0x41, 0x00
        .db 0x00, 0x31, 0x41, 0x41, 0x7F, 0x01, 0x01, 0x00
        .db 0x00, 0x7F, 0x18, 0x18, 0x14, 0x24, 0x43, 0x00
        .db 0x00, 0x7F, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00
        .db 0x00, 0x7F, 0x01, 0x06, 0x08, 0x06, 0x01, 0x7F
        .db 0x00, 0x7F, 0x02, 0x06, 0x08, 0x30, 0x40, 0x7F
        .db 0x00, 0x3E, 0x41, 0x41, 0x41, 0x41, 0x3E, 0x00
        .db 0x00, 0x7F, 0x09, 0x09, 0x09, 0x09, 0x06, 0x00
        .db 0x00, 0x3E, 0x41, 0x51, 0x51, 0x21, 0x5E, 0x00
        .db 0x00, 0x7F, 0x09, 0x09, 0x19, 0x29, 0x49, 0x46
        .db 0x00, 0x26, 0x49, 0x49, 0x49, 0x49, 0x49, 0x32
        .db 0x00, 0x01, 0x01, 0x01, 0x7F, 0x01, 0x01, 0x01
        .db 0x00, 0x3F, 0x40, 0x40, 0x40, 0x40, 0x3F, 0x00
        .db 0x00, 0x07, 0x18, 0x30, 0x40, 0x30, 0x18, 0x07
        .db 0x00, 0x3F, 0x40, 0x30, 0x50, 0x30, 0x40, 0x3F
        .db 0x00, 0x43, 0x36, 0x18, 0x08, 0x18, 0x36, 0x43
        .db 0x00, 0x03, 0x06, 0x08, 0x70, 0x08, 0x06, 0x03
        .db 0x00, 0x41, 0x61, 0x51, 0x49, 0x49, 0x45, 0x43

SPACE:
        .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

C09:
        .db 0x00, 0x3E, 0x41, 0x49, 0x49, 0x41, 0x3E, 0x00
        .db 0x00, 0x40, 0x44, 0x42, 0x7F, 0x40, 0x40, 0x40
        .db 0x00, 0x62, 0x51, 0x49, 0x49, 0x45, 0x46, 0x00
        .db 0x00, 0x22, 0x41, 0x41, 0x49, 0x49, 0x49, 0x36
        .db 0x00, 0x0C, 0x0A, 0x09, 0x09, 0x7F, 0x08, 0x08
        .db 0x00, 0x2F, 0x49, 0x49, 0x49, 0x49, 0x49, 0x39
        .db 0x00, 0x3E, 0x49, 0x49, 0x49, 0x49, 0x49, 0x32
        .db 0x00, 0x01, 0x01, 0x71, 0x09, 0x05, 0x03, 0x00
        .db 0x00, 0x36, 0x49, 0x49, 0x49, 0x49, 0x49, 0x36
        .db 0x00, 0x46, 0x49, 0x49, 0x49, 0x49, 0x49, 0x3E
