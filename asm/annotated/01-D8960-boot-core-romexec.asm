; ===========================================================================
; 01 - D8960 Boot Core and EXEC COMMAND Handoff
; ===========================================================================
; ROM range: 0xD8960-0xDC3BF
; Entry model: INT 19h hook from D8800 enters this ROM DOS-like substrate.
;
; VIS-specific role:
;   Creates the DOS-like process environment and launches COMMAND through INT 21h AH=4Bh using a bare ROM export name.
;
; Dependencies:
;   D8800 boot hook and export table.
;
; VISENV stub guidance:
;   VISENV v0.1 may bypass most of this by creating the process/register state directly, but this file is the reference for the real boot core.
;
; Confidence:
;   High for EXEC COMMAND anchor; medium for complete boot-core procedure boundaries.
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

; Module: D8960 boot/core ROM DOS-like substrate
; ROM range: D8960-DC3BF
; Role: creates the process/runtime environment and EXECs COMMAND
; Entry model: reached from the D8800 INT 19h custom boot path.
; VIS-specific significance:
;   This is the layer that makes the VIS feel DOS-like even though it did not boot DOS from a disk.
;   It installs vectors, creates PSP/process state, and eventually uses INT 21h AH=4Bh to EXEC "COMMAND".
; Stub priority: highest. VISENV must emulate the parts of this that ROM modules assume.

; ---------------------------------------------------------------------------
; SECTION: process/vector setup anchors around D9B70
; ---------------------------------------------------------------------------
D9B70_setup_vectors_and_process:
D9B70:  cli
D9B71:  mov  ax,ss
D9B73:  mov  word ptr [00BCh],1337h
D9B79:  mov  byte ptr [00C0h],0EAh
D9B7E:  mov  word ptr [00C1h],0428h
D9B84:  mov  [00C3h],ax
; LIKELY: creates a far jump / process control structure in the resident block.

D9B87:  mov  word ptr [0080h],041Fh
D9B8D:  mov  word ptr [0084h],0455h
D9B93:  mov  word ptr [0088h],0100h
D9B99:  mov  [008Ah],dx
D9B9D:  mov  word ptr [009Ch],1B96h
; CONFIRMED anchor: writes vector-like offsets into the low process/PSP region.
; Working interpretation:
;   0080h area corresponds to INT 20h/21h/22h style process vectors in a DOS-like environment.
;   0455h is a strong candidate for the boot core's INT 21h entry point.
; VISENV implication:
;   ROM modules may return/terminate through these vectors. A simple far-call without PSP state is probably insufficient.

D9BA3:  push ss
D9BA4:  pop  ds
D9BA5:  push ss
D9BA6:  pop  es
; DS=ES=SS for local process/bootstrap data.

; ---------------------------------------------------------------------------
; SECTION: boot core prepares EXEC "COMMAND"
; ---------------------------------------------------------------------------
; This is the crucial bridge from the boot core to the custom COMMAND dispatcher.
; It proves COMMAND is launched through the same INT 21h AH=4Bh ROM EXEC mechanism used later.

D9433_exec_COMMAND:
D9433:  mov  dx,0158h
; DS:DX points to the bare string "COMMAND" in the boot core's resident data.

D9436:  push ds
D9437:  pop  es
D9438:  mov  bx,013Ah
D943B:  mov  [bx+04h],ds
D943E:  mov  [bx+08h],ds
D9441:  mov  [bx+0Ch],ds
; LIKELY: prepares the DOS EXEC parameter block at DS:013A.
; These fields resemble environment / command-tail / FCB pointers in DOS EXEC data.

D9444:  xor  ax,ax
D9446:  mov  ah,4Bh
D9448:  stc
D9449:  int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "COMMAND"
; Meaning:
;   This is not COMMAND.COM from disk. The ROM EXEC resolver scans option-ROM exports, finds COMMAND, and enters DC3C0.
; Why this matters:
;   The entire VIS runtime startup sequence is built on the idea that DOS EXEC can resolve ROM modules by bare name.

D944B:  mov  dx,023Ah
D944E:  jmp  D944E
; If COMMAND returns unexpectedly or fails, the boot core appears to enter a dead loop.

; ---------------------------------------------------------------------------
; SECTION: source-quality TODOs
; ---------------------------------------------------------------------------
; TODO: Fully recover the INT 21h service entry around offset 0455.
; TODO: Identify how termination returns from ROM exports are handled.
; TODO: Confirm exact PSP and MCB layout created here.
; TODO: Determine whether any part of this boot core relocates before COMMAND is launched.
