; DOS keyboard polling skeleton for VIS homebrew.
;
; Avoid INT 9h hooks on VIS.
;
; Pseudocode:
; loop:
;   mov ah,01h
;   int 16h
;   jz loop
;   mov ah,00h
;   int 16h
;   ; AL/AH contain key data
