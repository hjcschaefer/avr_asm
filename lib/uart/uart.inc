/*   UART : simple api for using the UART

Defines: you need to define

.equ BAUDRATE = (e.g. 300)

API ----------------

UartInitOnlySend      : init uart, but only for sending!
UartSendByte          : r16, send byte in r16
UartSendFlashString   : ZL/ZH, send 0 delimited string in flash
UartSendString        : ZL/ZH, send 0 delimited string in RAM


*/

.ifndef BAUD_RATE
.error "Define BAUD_RATE!"
.endif

.equ UBRRVAL = FCPU/(16*BAUD_RATE) -1  ; UBBR value
