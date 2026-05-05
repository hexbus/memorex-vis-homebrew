; ===========================================================================
; 07 - ROMA / ROMB External ROM Probes
; ===========================================================================
; ROM range: C000/C400 probe targets via D8800 stubs
; Entry model: Launched by COMMAND as EXEC "roma" and EXEC "romb".
;
; VIS-specific role:
;   Small probes for optional external ROM regions, likely development card or cartridge/expansion ROM support.
;
; Dependencies:
;   COMMAND sequence.
;
; VISENV stub guidance:
;   VISENV v0.1 can return “no external ROM present” unless testing external cartridge/developer ROM behavior.
;
; Confidence:
;   High for probe role; medium for ER signature semantics.
;
; ---------------------------------------------------------------------------
; VIS annotated-source style
; ---------------------------------------------------------------------------
; This is not intended to be reassembled as-is. It is source-style commented
; disassembly for engineering analysis and VISENV implementation.
;
; Comment conventions:
;   CONFIRMED  = directly observed in code/data.
;   HYPOTHESIS = likely interpretation that still needs runtime proof.
;   VISENV     = requirement or shortcut for a DOSBox/MS-DOS shim.
; ---------------------------------------------------------------------------

; Module: ROMA / ROMB external ROM probes
; ROM ranges:
;   ROMA entry: D8933-D894F
;   ROMB entry: D8950-D8955 plus shared ROMA code path
; Role: probe optional external ROM regions and transfer control if a signature exists
; Entry model: COMMAND dispatcher EXECs bare names "roma" and "romb"; ROM EXEC resolver enters these exports.
; VIS-specific significance:
;   These are part of the VIS startup sequence even though normal consumer systems may have no external ROM present.
;   They likely support cartridge/development ROM expansion points.
; Stub priority: high but simple. VISENV v0.1 can safely return "no external ROM present".

; ---------------------------------------------------------------------------
; SECTION: ROMA probes C000:0000
; ---------------------------------------------------------------------------
D8933_ROMA_probe:
D8933:  push ds
D8934:  mov  ax,0C000h
D8937:  mov  ds,ax
D8939:  cmp  word ptr [0000h],5245h   ; 'ER' little-endian bytes 45 52
D893F:  jne  D894C_no_external_rom
; CONFIRMED: ROMA checks for an 'ER' signature at C000:0000.
; HYPOTHESIS: 'ER' may mean external ROM or executable ROM.

D8941:  pop  ds
D8942:  inc  ax
D8943:  sub  ax,0010h
D8946:  push ax
D8947:  mov  ax,0100h
D894A:  push ax
D894B:  retf
; If signature is present, far-return into the external ROM region.
; The target looks like approximately C000:0100 adjusted by segment math.
; VISENV implication: if an external ROM image is supplied, this is where to chain it.

D894C_no_external_rom:
D894C:  xor  ax,ax
D894E:  push ax
D894F:  retf
; No signature. Return harmlessly enough for COMMAND to continue.
; This supports stubbing ROMA as a no-op in VISENV.

; ---------------------------------------------------------------------------
; SECTION: ROMB probes C400:0000 using same shared check path
; ---------------------------------------------------------------------------
D8950_ROMB_probe:
D8950:  push ds
D8951:  mov  ax,0C400h
D8954:  jmp  D8937
; ROMB is identical to ROMA except the probe segment is C400h.

; ---------------------------------------------------------------------------
; Developer interpretation
; ---------------------------------------------------------------------------
; The COMMAND dispatcher always tries ROMA and ROMB during boot:
;
;   EXEC "roma"
;   EXEC "romb"
;
; On a normal system with no external ROM signature, these should effectively do nothing.
; For a development-card or cartridge environment, these may allow extra ROM-provided modules to join the boot/runtime stack.
