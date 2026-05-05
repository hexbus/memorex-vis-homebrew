; ===========================================================================
; 02 - ROM EXEC Resolver
; ===========================================================================
; ROM range: around 0xD9FEC-0xDA162
; Entry model: Reached from INT 21h AH=4Bh path when the requested program name is a bare ROM module name.
;
; VIS-specific role:
;   Custom VIS resolver that makes EXEC "gbios" or EXEC "tlaunch" mean “enter a ROM export” instead of “open a disk file.”
;
; Dependencies:
;   D8800 export table; DOS-like EXEC machinery in D8960 boot core.
;
; VISENV stub guidance:
;   This is the first function VISENV should reimplement directly. It maps bare names to module segment blobs.
;
; Confidence:
;   High for functional model; medium for exact local variable meanings.
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

; Module: ROM EXEC resolver candidate
; ROM range: D9FEC-DA162 focus window inside D8960 boot core
; Role: implements the VIS-specific branch of INT 21h AH=4Bh for bare ROM export names
; Entry model: called from the boot core's INT 21h handler when AH=4Bh EXEC is requested.
; VIS-specific significance:
;   This is the mechanism that lets EXEC "gbios" launch ROM code instead of loading GBIOS.EXE from disk.
; Stub priority: highest. VISENV must reproduce this behavior.

; ---------------------------------------------------------------------------
; SECTION: EXEC request classifier and ROM export lookup
; ---------------------------------------------------------------------------
D9FEC_exec_rom_name_handler:
D9FEC:  mov  si,dx
D9FEE:  call DA045_check_for_path_qualified_name
D9FF1:  jb   DA00A_bad_path_or_reject
; If the name contains ':' or '\', it is path-qualified and should not be treated as a ROM export.
; Bare names like COMMAND, MSCDEX, GBIOS, REDIR, ROMA, ROMB, TLAUNCH continue here.

D9FF3:  mov  ax,0D000h
D9FF6:  mov  es,ax
D9FF8:  xor  ax,ax
D9FFA:  call DA05E_scan_option_rom_exports
; Starts scanning option ROM space for a matching export.
; ES begins at D000, so the resolver is not hard-coded only to D8800.
; It can walk option ROMs until it finds an export table containing the requested name.

D9FFD:  jb   DA010_not_found
D9FFF:  call DA0CC_build_exec_metadata_for_export
DA002:  call D9F51_enter_or_finish_exec_context
DA005:  and  word ptr [si+16h],0FFFEh
DA009:  ret
; Clears carry/error flag in saved result context.
; VIS meaning: ROM export found and launch metadata was prepared.

DA00A_bad_path_or_reject:
DA00A:  mov  ax,0003h
DA00D:  jmp  DA013_return_exec_error
; Path-qualified names are not handled by the ROM export branch.
; They probably fall to a normal file EXEC path elsewhere, or return a path error from this branch.

DA010_not_found:
DA010:  mov  ax,0002h
; DOS error 2 = file not found. This is the right behavior if a bare name is not a ROM export.

DA013_return_exec_error:
DA013:  call D9F51_enter_or_finish_exec_context
DA016:  mov  [si],ax
DA018:  or   word ptr [si+16h],0001h
DA01C:  ret
; Sets carry/error in saved return context.

; ---------------------------------------------------------------------------
; SECTION: path-qualified name check
; ---------------------------------------------------------------------------
DA045_check_for_path_qualified_name:
DA045:  push si
DA046_loop:
DA046:  cmp  byte ptr [si],00h
DA049:  je   DA058_bare_name
DA04B:  cmp  byte ptr [si],':'
DA04E:  je   DA05B_path_qualified
DA050:  cmp  byte ptr [si],'\'
DA053:  je   DA05B_path_qualified
DA055:  inc  si
DA056:  jmp  DA046_loop

DA058_bare_name:
DA058:  pop  si
DA059:  clc
DA05A:  ret
; Bare name. Candidate for ROM export lookup.

DA05B_path_qualified:
DA05B:  pop  si
DA05C:  stc
DA05D:  ret
; Path-qualified name. Do not treat as ROM export.
; Examples: A:\FOO.EXE, \INIT.EXE.

; ---------------------------------------------------------------------------
; SECTION: scan option ROMs and their export tables
; ---------------------------------------------------------------------------
DA05E_scan_option_rom_exports:
DA05E:  push bx
DA05F:  push si
DA060:  push di
DA061:  xor  di,di
DA063:  or   ax,ax
DA065:  je   DA06C_check_option_header
DA067:  add  di,ax
DA069:  jmp  DA085_scan_exports_at_current_rom

DA06C_check_option_header:
DA06C:  cmp  word ptr es:[di],0AA55h
DA071:  je   DA082_found_option_rom
; CONFIRMED: normal PC option-ROM signature check.

DA073:  mov  bx,es
DA075:  add  bx,0080h
DA079:  mov  es,bx
DA07B:  jae  DA06C_check_option_header
DA07D:  pop  di
DA07E:  pop  si
DA07F:  pop  bx
DA080:  stc
DA081:  ret
; No matching ROM/export found.

DA082_found_option_rom:
DA082:  add  di,0006h
; Export table begins six bytes into the option ROM. At D8800 this lands at D8806.

DA085_scan_exports_at_current_rom:
DA085:  xor  cx,cx
DA087_next_export:
DA087:  mov  bx,cx
DA089:  mov  cl,es:[di]
DA08C:  or   cl,cl
DA08E:  je   DA0A7_advance_to_next_option_rom
; cl = export-name length. Zero ends this ROM's export table.

DA090:  inc  di
DA091:  xor  ch,ch
DA093:  mov  dx,di
DA095:  push si
DA096:  call DA0FC_match_export_name
DA099:  pop  si
DA09A:  jae  DA0C3_match_found
; If name did not match, skip length + 3-byte jump stub.

DA09C:  mov  di,dx
DA09E:  add  di,cx
DA0A0:  add  di,0003h
DA0A3:  mov  cx,bx
DA0A5:  loop DA087_next_export

DA0A7_advance_to_next_option_rom:
DA0A7:  xor  di,di
DA0A9:  mov  al,es:[di+02h]
DA0AD:  xor  ah,ah
DA0AF:  add  ax,0003h
DA0B2:  and  ax,0FFFCh
DA0B5:  mov  cl,05h
DA0B7:  shl  ax,cl
DA0B9:  mov  bx,es
DA0BB:  add  bx,ax
DA0BD:  mov  es,bx
DA0BF:  jb   DA07D_not_found
DA0C1:  jmp  DA06C_check_option_header
; Uses the option-ROM size byte to advance to the next ROM.
; VIS implication: the resolver is general enough to search multiple option ROMs.

DA0C3_match_found:
DA0C3:  add  di,cx
DA0C5:  mov  ax,di
DA0C7:  pop  di
DA0C8:  pop  si
DA0C9:  pop  bx
DA0CA:  clc
DA0CB:  ret
; Returns with ES pointing to the option ROM and AX giving the offset after the matched export name.
; The following bytes are the near jump stub used to enter the export.

; ---------------------------------------------------------------------------
; SECTION: build launch metadata for matched export
; ---------------------------------------------------------------------------
DA0CC_build_exec_metadata_for_export:
DA0CC:  mov  bx,es
DA0CE:  les  di,ss:[02DAh]
DA0D3:  mov  es:[di+0Fh],bx
DA0D7:  add  ax,0003h
DA0DA:  mov  es:[di+0Dh],ax
; Stores matched ROM segment and offset-ish metadata into an EXEC context block.
; The +3 likely steps past the near jump opcode/operand or aligns to the transfer target metadata.

DA0DE:  push si
DA0DF:  push ds
DA0E0:  mov  si,dx
DA0E2:  mov  ds,bx
DA0E4:  rep  movsb
DA0E6:  xor  al,al
DA0E8:  stosb
DA0E9:  pop  ds
DA0EA:  pop  si
; Copies the export name / associated text into the process context.

DA0EB:  mov  di,ss:[02DAh]
DA0F0:  add  di,0011h
DA0F3_copy_original_exec_name:
DA0F3:  lodsb
DA0F4:  stosb
DA0F5:  or   al,al
DA0F7:  je   DA0FB_done
DA0F9:  jmp  DA0F3_copy_original_exec_name
DA0FB_done:
DA0FB:  ret
; Preserves the original requested name string as well.

; ---------------------------------------------------------------------------
; SECTION: case-insensitive export-name matcher
; ---------------------------------------------------------------------------
DA0FC_match_export_name:
DA0FC:  push cx
DA0FD:  push ax
DA0FE:  push es
DA0FF:  push ds
DA100:  push si
DA101:  push di
DA102:  mov  ax,cx
DA104:  cld
; DS:SI = requested EXEC name.
; ES:DI = export-table name.
; CX    = export name length.

DA105_match_loop:
DA105:  cmp  byte ptr [si],'?'
DA108:  je   DA119_question_wildcard
DA10A:  cmp  byte ptr [si],'*'
DA10D:  je   DA124_star_wildcard
DA10F:  call DA152_compare_char_casefold
DA112:  jne  DA14A_no_match
DA114:  dec  cx
DA115:  jcxz DA141_check_requested_name_ended
DA117:  jmp  DA105_match_loop

DA141_check_requested_name_ended:
DA141:  cmp  byte ptr [si],00h
DA144:  jne  DA14A_no_match
DA146:  clc
DA147:  jmp  DA14B_return

DA14A_no_match:
DA14A:  stc
DA14B_return:
DA14B:  pop  di
DA14C:  pop  si
DA14D:  pop  ds
DA14E:  pop  es
DA14F:  pop  ax
DA150:  pop  cx
DA151:  ret

DA152_compare_char_casefold:
DA152:  push ax
DA153:  lodsb
DA154:  cmp  al,es:[di]
DA157:  je   DA15E_advance
DA159:  xor  al,20h
DA15B:  cmp  al,es:[di]
DA15E_advance:
DA15E:  lea  di,[di+1]
DA161:  pop  ax
DA162:  ret
; Case-insensitive ASCII compare by toggling bit 5.
; This is why EXEC "gbios" can match export "GBIOS".

; ---------------------------------------------------------------------------
; VISENV implementation note
; ---------------------------------------------------------------------------
; VISENV v0.1 can implement this behavior directly:
;
;   if EXEC name contains ':' or '\\': pass to real DOS / fake media layer
;   else uppercase name and compare against D8800 exports
;   if match: transfer into mapped ROM segment with DS/CS/PSP assumptions
;   if no match: return DOS error 2
