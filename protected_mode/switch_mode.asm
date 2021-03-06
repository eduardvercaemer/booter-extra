;======================================================================
;
; -- switch_mode.asm
; -- Eduard Vercaemer
;
;  create a valid GDT with two entries, one code segment and one
;  data segment, then load the GDT and enter protected mode
;
;======================================================================

;======================================================================
; -- Memory
;
;  0x007c00 -> our code
;  0x0b8000 -> color text mode VGA memory
;======================================================================

        [BITS 16]
        [ORG 0x7c00]
        jmp 0x0000:entry

;======================================================================
; -- GDT
;
;  - 0x00 -> Null Descriptor
;  - 0x08 -> Code Segment Descriptor
;  - 0x10 -> Data Segment Descriptor
;======================================================================
gdt_start:
gdt_null:
        dd 0
        dd 0
gdt_code:
        dw 0xffff                       ; Limit 0:15                           
        dw 0x0000                       ; Base 0:15
        db 0x00                         ; Base 16:23
        db 0b10011010                   ; Present / Privilege / Type
        db 0b11001111                   ; Granularity / Size / Limit 16:23
        db 0x00                         ; Base 24:31
gdt_data:
        dw 0xffff                       ; Limit 0:15                           
        dw 0x0000                       ; Base 0:15
        db 0x00                         ; Base 16:23
        db 0b10010010                   ; Present / Privilege / Type
        db 0b11001111                   ; Granularity / Size / Limit 16:23
        db 0x00                         ; Base 24:31
gdt_end:
gdt_desc:
        dw gdt_end - gdt_start
        dd gdt_start
;======================================================================
; -- End of GDT
;======================================================================

entry:
setup:
        ; setup registers
        mov     ax, 0
        mov     ds, ax
enter_protected:
        ; load gdt descriptor from `ds`
        cli                             ; disable interrupts
        lgdt    [gdt_desc]              ; load gdt

        ; enter protected mode by setting bit 0 of `CR0`
        mov     eax, cr0
        or      eax, 0x1
        mov     cr0, eax

        ; clear pipeline and far-jump to code segment
        jmp     0x08:clear_pipe         ; 0x08 is code segment now

;======================================================================
; -- Here starts the protected mode code
;======================================================================
        [BITS 32]

clear_pipe:
setup_registers:
        ; set data segments from descriptor 0x10
        mov     ax, 0x10
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        ; set stack
        mov     ss, ax
        mov     ebp, 0x90000
        mov     esp, ebp

run:
        ; as a test, we draw to screen some char
        mov     byte [0xb8000], 'P'
        mov     byte [0xb8001], 0x1b

hang:
        jmp     $

;======================================================================
; -- Boot Magic Number
;======================================================================
magic_number:
        times 510-($-$$) db 0
        dw 0xaa55