; yes.s: implementation of the `yes` utility in x86_64 linux nasm.
;
; Copyright (c) ezntek, 2025.
; All source code in this directory is licensed under the bsd 0-clause license.

%include "common.inc"

section .text
global main

strlen:
    ; rdi: const char*
    ; rax: counter

    ; clear counter
    xor rax, rax
    strlen_loop:
        ; check null termination
        ; rax is our offset
        cmp byte [rdi+rax], 0
        je strlen_loop_end
        inc rax
        jmp strlen_loop
    strlen_loop_end:
    ret

main:
    ; rdi: int argc
    ; rsi: char** argv
    ; rcx: counter
    ; r8: const char* temp
    ; r9: size_t temp_item_length
    cmp rdi, 1
    jne main_args_loop
    main_args_default_loop:
        ; we know sizeof("y\n") is always 2
        syscall3 SYS_write, 1, yes, 2 
        jmp main_args_default_loop

    main_args_loop:
        ; rcx keeps the counter for iterating through argv,
        ; we must reset every iteration
        mov rcx, 1
        main_print_one_arg_loop:
            ; we keep printing until argc is 0
            mov r8, qword [rsi+8*rcx]
            ; call strlen
            ; we dont care about rax
            push rdi
            push rsi
            push rcx
            mov rdi, r8
            call strlen
            pop rcx
            pop rsi
            pop rdi
            ; rax contains the length
            mov r9, rax
            ; syscall
            push rdi
            push rsi
            push rcx
            syscall3 SYS_write, 1, r8, r9
            lea rsi, [rel space]
            syscall3 SYS_write, 1, rsi, 1 
            pop rcx
            pop rsi
            pop rdi
            ; loop counter handling
            inc rcx
            cmp rdi, rcx
            jne main_print_one_arg_loop
        main_print_one_arg_loop_end:
            ; print newline
            push rdi
            push rsi
            push rcx
            lea rsi, [rel newline]
            syscall3 SYS_write, 1, rsi, 1 
            pop rcx
            pop rsi
            pop rdi
        jmp main_args_loop

section .data
    yes     db "y", 0xA
    space   db 0x20
    newline db 0xA
