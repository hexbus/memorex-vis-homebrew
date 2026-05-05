; DOS video mode test skeleton for VIS homebrew.
; Assemble with your preferred 16-bit assembler.
;
; This is intentionally a skeleton. Verify modes on real VIS hardware.
;
; Pseudocode:
;   mov ax,0013h
;   int 10h
;   draw pixels
;   wait with INT 16h or safe polling
;   exit
