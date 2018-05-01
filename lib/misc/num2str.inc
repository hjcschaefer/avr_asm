;=================== API ====================================
;
;
; ------- num2strInit --------------------------------------
; initialize library (setup Power10 array)
; IN: -
; OUT: - 
; ------- Div8by8 -------------------------------------------
; divide two 8 bit number
; IN: r17, r18  -> calculate r17/r18 (divided by)
; OUT: r17 : quotient    r16: remainder
; ------- Unsigned8Bit2Ascii --------------------------------
; convert 8 bit number to string
; IN: r16
; OUT: ZL/ZH location of string (StrBuffer) always 3 chars
; ------- Unsigned16Bit2Ascii --------------------------------
; convert 16 bit number to string
; IN: r16
; OUT: ZL/ZH location of string (StrBuffer) zero terminated
; ------- Binary2BCD  ----------------------------------------
; convert 8 bit binary to 8 bit BCD
; IN : r16
; OUT : r16



