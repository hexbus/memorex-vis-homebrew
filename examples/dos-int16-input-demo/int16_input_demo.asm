; INT 16h polling skeleton
; org 100h
; loop_start:
;   mov ah,01h
;   int 16h
;   jz loop_start
;   mov ah,00h
;   int 16h
;   ; AH scan code, AL ASCII if applicable
;   mov ax,4C00h
;   int 21h
