; ------------------------------------------------------
;
; API to access DS3234 RTC via SPI
;
;
; Dependency : spi
;
; API:
;
; DS3234GetSeconds       : returns seconds in r16 as a BCD
; DS3234GetMinutes       : same for minutes
; DS3234GetHours         : returns hours in r16
; DS3234GetYear          : returns years in r16  (0 - 99)
; DS3234GetMonth         : returns month in r16
; DS3234GetDay           : return day in r16
; DS3234GetWeekDay       : return weekday in r16
; DS3234GetMonthStr      : ZH/ZL point to 3 char month abbrv in flash(!)
; DS3234TempStr          : builds temperature string in ZH/ZL (RAM)


