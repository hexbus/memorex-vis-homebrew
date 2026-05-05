; VIS-safe DOS template skeleton
; ------------------------------
; org 100h
;
; set graphics mode
;   mov ax,0013h
;   int 10h
;
; main loop:
;   draw frame
;   poll keyboard with INT 16h
;   do not hook INT 9h
;
; exit:
;   mov ax,0003h
;   int 10h
;   mov ax,4C00h
;   int 21h
