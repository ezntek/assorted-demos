; assembly random rects 
;
; Copyright (c) ezntek, 2025.
; All source code in this directory is licensed under the bsd 2-clause license.

%include "common.inc"
%include "raylib.inc"

;libc functions
extern srand
extern rand
extern time

; some defines
MAXRECT equ 1000
WINWIDTH equ 800
WINHEIGHT equ 600
SIZEVARBITS equ 6
BASESIZE equ 100

section .text
global main

main:
    sub rsp, 8
    ; init bss values 
    mov dword [last], 0

    ; initialization work
    ; time(NULL);
    mov rdi, 0 ; NULL is just 0
    call time
    mov rdi, rax ; move retval
    ; srand(time(NULL));
    call srand

    ; InitWindow(800, 600, "title")
    mov rdi, 800
    mov rsi, 600
    mov rdx, title
    call InitWindow
    
    ; result is in rax
    main_loop:
        call WindowShouldClose 
        test rax, rax
        jne end
        
        call BeginDrawing

        mov rdi, RAYWHITE 
        call ClearBackground 
        
        ; ==== display subroutine ==== 
        ; r9: i (counter)
        xor r9, r9
        display_rect_loop:
            mov r10d, dword [last]
            cmp r9, r10
            je display_rect_loop_end

            mov edi, dword [arr_x+4*r9]
            mov esi, dword [arr_y+4*r9]
            mov edx, dword [arr_w+4*r9]
            mov ecx, dword [arr_h+4*r9]
            mov r8d, dword [arr_c+4*r9]
            push r9
            call DrawRectangle
            pop r9
            inc r9
            jmp display_rect_loop
        display_rect_loop_end:
        ; ============================

        mov rdi, 20
        mov rsi, 20
        call DrawFPS

        call EndDrawing

        ; ==== generate subroutine ====
        ; generate colors
        ; r10d: temp for last
        
        ; generate a width
        push r10
        call rand
        pop r10
        and rax, SIZEVARBITS
        mov r10d, dword [last]
        lea r11, [rax+BASESIZE]
        mov dword [arr_w+4*r10], r11d

        ; generate a height
        push r10
        call rand
        pop r10
        and rax, SIZEVARBITS
        mov r10d, dword [last]
        lea r11, [rax+BASESIZE]
        mov dword [arr_h+4*r10], r11d

        ; generate an X
        push r10
        call rand
        pop r10
        ; rand() % WINWIDTH
        ; our dividend is already in rax
        mov rbx, WINWIDTH
        idiv rbx
        ; remainder is in rdx
        mov r10d, dword [last]
        mov dword [arr_x+4*r10d], edx 

        ; generate a Y
        push r10
        call rand
        pop r10
        ; rand() % WINHEIGHT
        mov rbx, WINHEIGHT
        idiv rbx
        ; remainder is in rdx
        mov r10d, dword [last]
        mov dword [arr_y+4*r10d], edx

        ; generate a color
        push r10
        call rand
        pop r10
        or eax, 0xff000000 ; force alpha channel to be ff
        mov r10d, dword [last]
        mov dword [arr_c+4*r10d], eax
        ; =============================

        ; increment last
        mov r10d, dword [last]
        ; weird aah c compiler bs
        inc r10d
        mov dword [last], r10d
        cmp r10d, MAXRECT
        jbe main_loop

        ; === COMMENT THE FOLLOWING 2 LINES OUT TO RUN IT ONCE ===
        mov dword [last], 0
        jmp main_loop

    end:
    call CloseWindow
    add rsp, 8
    xor rax, rax
    ret

section .bss
    ; SOA (andrew kelley would be PROUD)
    arr_x resw MAXRECT
    arr_y resw MAXRECT
    arr_w resw MAXRECT
    arr_h resw MAXRECT
    ; colors (packed)
    arr_c resw MAXRECT
    ; last index of array
    last  resw 1

section .data
    title     db "3abdullah magical program (assembly pain version by ezntek)", 0x0
