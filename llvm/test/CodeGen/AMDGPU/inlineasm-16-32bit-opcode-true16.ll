; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1201 -mattr=+real-true16 < %s | FileCheck -enable-var-scope -check-prefix=CHECK %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1201 -mattr=-real-true16 < %s | FileCheck -enable-var-scope -check-prefix=CHECK %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1100 -mattr=+real-true16 < %s | FileCheck -enable-var-scope -check-prefix=CHECK %s

; The "v" constraint denotes a full 32-bit VGPR, so a 16-bit value must not be
; printed as a half register even in true16 mode. Asm written with 32-bit
; opcodes only assembles when the operand is a whole VGPR.

; CHECK-LABEL: v_output_f16_32bit_opcode:
; CHECK: ;;#ASMSTART
; CHECK-NEXT: v_add_f32 v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; CHECK-NEXT: v_cvt_f16_f32 v{{[0-9]+}}, v{{[0-9]+}}
; CHECK-NEXT: ;;#ASMEND
define amdgpu_kernel void @v_output_f16_32bit_opcode(ptr addrspace(1) %out, float %a, float %b) {
  %v = tail call half asm "v_add_f32 $0, $1, $2\0Av_cvt_f16_f32 $0, $0", "=v,v,v"(float %a, float %b)
  store half %v, ptr addrspace(1) %out
  ret void
}

; CHECK-LABEL: v_output_i16_32bit_opcode:
; CHECK: ;;#ASMSTART
; CHECK-NEXT: v_bfe_u32 v{{[0-9]+}}, v{{[0-9]+}}, 0, 16
; CHECK-NEXT: ;;#ASMEND
define amdgpu_kernel void @v_output_i16_32bit_opcode(ptr addrspace(1) %out, i32 %a) {
  %v = tail call i16 asm "v_bfe_u32 $0, $1, 0, 16", "=v,v"(i32 %a)
  store i16 %v, ptr addrspace(1) %out
  ret void
}

; CHECK-LABEL: v_input_i16_32bit_opcode:
; CHECK: ;;#ASMSTART
; CHECK-NEXT: v_and_b32 v{{[0-9]+}}, 0xffff, v{{[0-9]+}}
; CHECK-NEXT: ;;#ASMEND
define amdgpu_kernel void @v_input_i16_32bit_opcode(ptr addrspace(1) %out, i16 %a) {
  %v = tail call i32 asm "v_and_b32 $0, 0xffff, $1", "=v,v"(i16 %a)
  store i32 %v, ptr addrspace(1) %out
  ret void
}
