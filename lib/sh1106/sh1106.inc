; CODE FOR TALKING to SH1106 VIA I2C
;
; make sure you include i2c.inc, i2c.asm
; *** note we use r16, r17 and !!! r0, r1 !!!! (=CL/CH)
; also note that we need a massive 1k buffer in ram!!!!


; ---------------- SLAVE ADDRESS ----------------
.equ SH1106_ADDR = 0x3c    ; this is the write address. Read address is 0x3d but we never read stuff
.equ SH1106_CMD  = 0x00    ; command code
.equ SH1106_DATA = 0x40    ; data code

; ======================= API =================================
;
; SH1106_init           : initialize and switch on display
;
; SH1106_clear          : clean the frame buffer and send to device
;
; SH1106_fill_buffer    : fill buffer with byte in r16 (does not send to device)
;
; SH1106_show           : send buffer to device (and see it!)
;
; SH1106_putchar        : put char in r16 into buffer (at cursor position)
;                       : only 0-9, A-Z and space are allowed
;
; SH1106_set_xy         : move cursor to column (0-15) in r16 and
;                       : row (0-7) in r17
;
; ==============================================================

; ----------------SH1106 commands ----------------
.equ  SET_PAGE_ADDRESS =                0xB0 ; sets the page address from 0 to 7 
.equ  SHDISPLAY_OFF =                     0xAE
.equ  SHDISPLAY_ON =                      0xAF
.equ  SET_MEMORY_ADDRESSING_MODE =      0x20
.equ  SET_COM_OUTPUT_SCAN_DIRECTION =   0xC8
.equ  LOW_COLUMN_ADDRESS =              0x00
.equ  HIGH_COLUMN_ADDRESS =             0x10
.equ  START_LINE_ADDRESS =              0x40
.equ  SET_CONTRAST_CTRL_REG =           0x81
.equ  SET_SEGMENT_REMAP =               0xA1 ; 0 to 127
.equ  SET_NORMAL_DISPLAY =              0xA6
.equ  SET_MULTIPLEX_RATIO =             0xA8
.equ  OUTPUT_FOLLOWS_RAM =              0xA4
.equ  OUTPUT_IGNORES_RAM =              0xA5
.equ  SET_DISPLAY_OFFSET =              0xD3
.equ  SET_DISPLAY_CLOCK_DIVIDE =        0xD5
.equ  SET_PRE_CHARGE_PERIOD =           0xD9
.equ  SET_COM_PINS_HARDWARE_CONFIG =    0xDA
.equ  SET_VCOMH =                       0xDB
.equ  SET_DC_DC_ENABLE =                0x8D
.equ  PAGE_MODE =                       0x02  ; addressing mode ?


; special registers
.def CL = r0        ; this is the address in the frame buffer where we are
.def CH = r1        ; after putting in a char, we move one on



