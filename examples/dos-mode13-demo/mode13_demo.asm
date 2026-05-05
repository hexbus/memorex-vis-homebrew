; Mode 13h skeleton for VIS testing
; org 100h
; mov ax,0013h
; int 10h
; mov ax,0A000h
; mov es,ax
; xor di,di
; mov cx,320*200
; mov al,04h
; rep stosb
; wait:
;   mov ah,01h
;   int 16h
;   jz wait
; mov ax,4C00h
; int 21h
