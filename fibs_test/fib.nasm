; fib: mr. marcos's Java test #1 (calculating fibonaccis) done in assembly,
;      because Java is cringe
;
; Copyright (c) ezntek, 2025.
; All source code in this directory is licensed under the bsd 0-clause license.

extern printf
extern scanf
extern getchar
extern putchar
extern puts

section .text
printnum:
    ; rdi: long long num
    push rbp
    mov rbp, rsp
    mov rsi, rdi
    mov rdi, num_fmt 
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
        mov rdi, num_fmt
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

calcfib:
    ; n: rdi
    push rbp
    mov rbp, rsp
    sub rsp, 48 ; 4 vars, 8 bytes (signed long long)
    ; [rbp - 8]:  int64_t a
    ; [rbp - 16]: int64_t b
    ; [rbp - 24]: int64_t c
    ; [rbp - 32]: int64_t n
    ; [rbp - 40]: int64_t sum
    
    mov qword [rbp - 8], 0
    mov qword [rbp - 16], 0
    mov qword [rbp - 24], 0
    mov qword [rbp - 32], 0
    mov qword [rbp - 40], 0

    ; rax: a
    ; rcx: b
    ; rdx: c
    mov rax, -1
    mov rcx, 1
    .loop:
        mov rdx, rax ; c = a + b
        add rdx, rcx
        add qword [rbp - 40], rdx
        ; back vars up on the stack
        mov qword [rbp - 8], rax
        mov qword [rbp - 16], rcx
        mov qword [rbp - 24], rdx
        mov qword [rbp - 32], rdi
        ; print the number
        mov rdi, rdx
        call printnum
        ; print the delimiter
        mov rdi, qword [rbp - 32] ; restore num because we need it now
        test rdi, rdi
        jz .loop_continue_calculating
        mov rdi, ';'
        call putchar
        mov rdi, ' '
        call putchar
        .loop_continue_calculating:
        ; restore vars
        mov rax, qword [rbp - 8]
        mov rcx, qword [rbp - 16]
        mov rdx, qword [rbp - 24]
        mov rdi, qword [rbp - 32]
        ; a = b
        mov rax, rcx
        ; b = c
        mov rcx, rdx
        ; condition
        dec rdi ; decrement n
        jns .loop ; jump if not signed
    mov rdi, 0xA
    call putchar

    ; set up return
    mov rax, qword [rbp - 24] ; nth
    ; WARNING! very scuffed. multiple return values
    ; for the broke and homeless                       
    mov rbx, qword [rbp - 40] ; sum
    add rsp, 48
    pop rbp
    ret

nthfib:
    ; int64_t n
    ; int64_t rax (return nth)
    ; int64_t rbx (return sum)
    push rbp
    mov rbp, rsp
    ; rax: c
    ; rbx: acc (return)
    ; rcx: a
    ; rdx: b
    mov rcx, -1
    mov rdx, 1
    .loop:
        mov rax, rcx
        add rax, rdx
        ; a = b
        mov rcx, rdx
        ; b = c
        mov rdx, rax
        add rbx, rax ; add to accumulator
        dec rdi
        jns .loop
    pop rbp
    ret

countdigits:
    ; rdi: int64_t n
    push rbp
    mov rbp, rsp
    ; r8: int divisor
    ; rcx: int ndigits
    mov rax, rdi ; set up for idiv
    mov r8, 10
    mov rcx, 1
    .loop:
        cmp rax, 10
        jl .done
        cqo
        idiv r8
        inc rcx
        jmp .loop
    .done:
    mov rax, rcx
    pop rbp
    ret

global main
main:
    ; rdi: int argc
    ; rsi: char** argv
    push rbp
    mov rbp, rsp
    sub rsp, 32
    ; [rbp - 8]: nth term (input)
    ; [rbp - 16]: sum
    ; [rbp - 24]: nth term

    ; task 1: name
    mov rdi, name
    call puts

    .loop: 
        ; task 2: enter a number, task 3: loop until it is positive
        .enter_number_loop:
            call getnum
            cmp rax, 0
            jge .enter_number_loop_after
            mov rdi, numerr_msg
            call puts
            jmp .enter_number_loop
        .enter_number_loop_after:
        test rax, rax ; break if number is 0
        jz .end
        ; rax has our number
        mov qword [rbp - 8], rax
        mov rdi, rax ; set up arg for calls to calcfib and nthfib
        cmp rdi, 20 ; if (rdi < 20) goto printmany;
        jle .printmany
        ; get nth fib, print it
            call nthfib ; rdi already populated
            mov qword [rbp - 24], rax ; nth fib
            mov qword [rbp - 16], rbx ; the sum (cursed but ok)
            mov rdx, rax
            mov rsi, qword [rbp - 8]
            mov rdi, nthterm_fmt
            call printf
            mov rax, qword [rbp - 16]
            jmp .carry_on
        .printmany:
            mov rdi, rax
            call calcfib ; print the fibs
            mov qword [rbp - 24], rax ; nth fib
            mov rax, rbx
        .carry_on:
        ; get the average
        cvtsi2sd xmm0, rax ; the sum
        cvtsi2sd xmm1, qword [rbp - 8] ; the num
        divsd xmm0, xmm1 ; sum /= num
        mov rax, 1 ; 1 floating point arg
        mov rdi, average_fmt
        call printf
        ; count digits and print
        mov rdi, qword [rbp - 24] ; the sum
        call countdigits
        mov rsi, qword [rbp - 24] ; nth fib
        mov rdx, rax
        mov rdi, digits_fmt
        call printf
        jmp .loop

    .end:
    add rsp, 32
    pop rbp
    xor eax, eax
    ret

section .data
    ; useful strings
    name          db "ezntek", 0x0
    ; messages and formats
    digits_fmt    db "%lld has %d digits", 0xA, 0x0
    nthterm_fmt   db "Term %d: %lld", 0xA, 0x0
    enter_prompt  db "Calculate up to term (n)? ", 0x0
    num_fmt       db "%lld", 0x0
    average_fmt   db "Average = %.1lf", 0xA, 0x0
    tryagain_msg  db "invalid input, try again", 0xA, 0x0
    numerr_msg    db "Error– enter a positive number", 0x0
    equalstring   db " = ", 0x0
    toobig        db "number too big, it will overflow", 0xA, 0x0
    space         db 0x20
    newline       db 0xA
