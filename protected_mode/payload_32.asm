;----------------------------------------------------------------------
; Payloads get loaded at memory 0x8000 (protected mode code)
;----------------------------------------------------------------------
        [BITS 32]
        [ORG 0x8000]
        jmp     entry

;----------------------------------------------------------------------
; program entry point
;----------------------------------------------------------------------
entry:
run:
        ; write char to VGA memory
        mov     byte [0xb8000], 'Z'
        mov     byte [0xb8001], 0x1b

hang:
        jmp     hang