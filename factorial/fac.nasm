; fac.fasm: factorial in fasm. compsci homework but instead of Java I use assembly :)
;
; Copyright (c) ezntek, 2025.
; All source code in this directory is licensed under the bsd 0-clause license.

extern printf
extern scanf
extern getchar
extern putchar

section .text
printnum:
    ; rdi: long long num
    push rbp
    mov rbp, rsp
    mov rsi, rdi
    mov rdi, fmtnumstring
    call printf
    pop rbp
    ret

getnum:
    ; rax: return
    push rbp
    mov rbp, rsp
    sub rsp, 16
    ; int num = 0, res = 0;
    ; [rbp - 8]: long long num
    ; [rbp - 12]: int res
    mov qword [rbp - 8], 0
    mov dword [rbp - 12], 0
    .loop:
        ; scanf boilerplate
        mov rdi, enter_prompt
        call printf
        mov rdi, scanf_fmt
        lea rsi, qword [rbp - 8]
        call scanf
        ; we call printf so we save it on the stack
        mov dword [rbp - 12], eax
        test eax, eax
        jnz .loop_end
        .loop_invalid:
            mov rdi, tryagain_msg
            call printf
            ; al: ch
            .loop_clearloop:
                call getchar
            cmp al, 0xA
            jne .loop_clearloop
    .loop_end: ; conditional
    cmp dword [rbp - 12], 1
    jne .loop

    mov rax, qword [rbp - 8]
    add rsp, 16
    pop rbp
    ret

global main
main:
    ; rdi: int argc
    ; rsi: char** argv
    push rbp
    mov rbp, rsp
    sub rsp, 16
    ; [rbp - 8]: temporary
    ; [rbp - 16]: int accumulator
    call getnum

    cmp rax, 20
    jle .calc
    mov rdi, toobig
    call printf
    jmp .end
    
    .calc:
    ; we need the num later, printf will overwrite eax
    mov qword [rbp - 8], rax

    ; format output "nicely"
    mov rdi, rax
    call printnum
    mov rdi, '!'
    call putchar
    mov rdi, equalstring
    call printf

    ; set up multiplication loop
    ; rax: acculumator
    ; rbx: multiplier
    mov qword [rbp - 16], 1
    .loop:
        ; back value up on stack due to printf call
        mov rbx, qword [rbp - 8] ; rbx is callee-saved
        mov rax, qword [rbp - 16] 
        imul rax, rbx
        mov qword [rbp - 16], rax
        ; print the current multiplier
        mov rdi, rbx
        call printnum
        ; print ' x ' if ebx != 0
        dec rbx
        mov qword [rbp - 8], rbx
        test rbx, rbx
        jz .loop_end ; skip if ebx == 0
        mov rdi, timesstring
        call printf
    .loop_end:
    test rbx, rbx
    jnz .loop
  
    ; print final ' = '
    mov rdi, equalstring
    call printf
    
    ; print number and newline
    mov rdi, qword [rbp - 16]
    call printnum
    mov edi, 0xA
    call putchar
    
    .end:
    add rsp, 16
    pop rbp
    xor eax, eax
    ret

section .data
    scanf_fmt     db "%lld", 0x0
    enter_prompt  db "n = ", 0x0
    tryagain_msg  db "invalid input, try again", 0xA, 0x0
    fmtnumstring  db "%lld", 0x0
    timesstring   db " x ", 0x0
    equalstring   db " = ", 0x0
    toobig        db "number too big, it will overflow", 0xA, 0x0
    space         db 0x20
    newline       db 0xA
