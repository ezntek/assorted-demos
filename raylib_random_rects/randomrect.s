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

strlen:
    ; rdi = const char *str
    ; rax = retval
    xor rax, rax
    strlen_loop:
        cmp byte [rdi+rax], 0
        je strlen_loop_end
        inc rax
        jmp strlen_loop
    strlen_loop_end:
    ret

strcmp:
    ; rdi = str1
    ; rsi = str2
    ; rax = isequal
    xor rcx, rcx
    strcmp_loop:
        movzx r8, byte [rdi+rcx]
        movzx r9, byte [rsi+rcx]
        test r8, r8 
        je strcmp_loop_end
        test r9, r9
        je strcmp_loop_end

        cmp r8, r9
        jne strcmp_loop_end
        inc rcx
        jmp strcmp_loop

    strcmp_loop_end:
    mov rax, r8
    sub rax, r9
    ret

atoi:
    ; rdi = const char *in
    ; rax = retval
    ; rcx = counter
    xor rax, rax
    xor rcx, rcx
    atoi_loop:
        movzx r8, byte [rdi+rcx]
        inc rcx
        ; if(!r8) break;
        test r8, r8
        je atoi_loop_end

        ; if(r8>9 || r8<0) goto invalid;
        cmp r8, '9'
        jg atoi_loop_invalid
        cmp r8, '0'
        jb atoi_loop_invalid

        ; r8 -= '0'
        sub r8, '0' ; 0-9

        ; rax = (rax*10) + r8
        imul rax, 10
        add rax, r8

        jmp atoi_loop

    atoi_loop_end:
    ret

    ; handle error
    atoi_loop_invalid:
    ; rdi = rdi
    call strlen
    mov r8, rdi
    mov r9, rax
    syscall3 SYS_write, 2, r8, r9
    syscall3 SYS_write, 2, atoi_invalid_input, atoi_invalid_input_len
    syscall1 SYS_exit, 1

parseargs:
    ; rdi: int argc
    ; rsi: const char* argv
    push rdi
    push rsi

    ; argc--, argv++
    dec rdi
    add rsi, 8

    ; if(!argc)
    test rdi, rdi
    je parseargs_end

    ; argv[0][0] == '-'
    mov r8, qword [rsi]
    cmp byte [r8], '-'
    je parseargs_flag_help

    ; atoi(argv[0])
    mov rdi, r8
    call atoi
    mov dword [maxcycle], eax
    jmp parseargs_end

    ; unknown flag
    parseargs_flag_help:
    syscall3 SYS_write, 2, help_string, help_string_len
    syscall1 SYS_exit, 1

    parseargs_end:
    pop rsi
    pop rdi
    ret

main:
    ; rdi: int argc
    ; rsi: const char* argv 
    sub rsp, 8

    ; init bss values 
    mov dword [last], 0
    mov dword [maxcycle], 0

    ; parse arguments
    call parseargs
    ; maxcycle is conditionally set
        
    ;mov dword [maxcycle], 3

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
    ; r10: temp value
    ; r11: counter
    xor r11, r11
    main_loop:
        ; i love stack alignment
        push r11
        push r11

        cycle:
            ; put inside because we want this to run every frame
            call WindowShouldClose 
            test rax, rax 
            je main_keep_going
            sub rsp, 16
            jmp end
            

            main_keep_going:
            call BeginDrawing

            mov rdi, RAYWHITE 
            call ClearBackground 
            
            ; ==== display subroutine ==== 
            ; r9d: i (counter)
            xor r9, r9
            display_rect_loop:
                mov r10d, dword [last]
                cmp r9d, r10d
                je display_rect_loop_end

                mov edi, dword [arr_x+4*r9]
                mov esi, dword [arr_y+4*r9]
                mov edx, dword [arr_w+4*r9]
                mov ecx, dword [arr_h+4*r9]
                
                ; the color is a dword
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
            lea r11d, [rax+BASESIZE]
            mov dword [arr_w+4*r10], r11d

            ; generate a height
            push r10
            call rand
            pop r10
            and rax, SIZEVARBITS
            mov r10d, dword [last]
            lea r11d, [rax+BASESIZE]
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
            mov dword [arr_x+4*r10], edx 

            ; generate a Y
            push r10
            call rand
            pop r10
            ; rand() % WINHEIGHT
            mov rbx, WINHEIGHT
            idiv rbx
            ; remainder is in rdx
            mov r10d, dword [last]
            mov dword [arr_y+4*r10], edx

            ; generate a color
            push r10
            call rand
            pop r10
            or eax, 0xff000000 ; force alpha channel to be ff
            mov r10d, dword [last]
            mov dword [arr_c+4*r10], eax
            ; =============================
            
            ; increment last
            mov r10d, dword [last]
            ; weird aah c compiler bs
            inc r10
            mov dword [last], r10d
            cmp r10d, MAXRECT
            jbe cycle ; cycle not done

        ; cycle is done
        pop r11
        pop r11
            
        ; handle maxcycle
        ; FIXME: reset this
        mov r10d, dword [maxcycle]
        mov r10, 1
        cmp r11, r10 ; if (counter > maxcycle) goto end;
        jg end
        mov dword [last], 0
        inc r11
        mov dword [maxcycle], r11d
        jmp main_loop
        add rsp, 16 
    
    end:
    call CloseWindow
    add rsp, 8
    xor rax, rax
    ret

section .bss
    ; SOA (andrew kelley would be PROUD)
    arr_x resd MAXRECT
    arr_y resd MAXRECT
    arr_w resd MAXRECT
    arr_h resd MAXRECT
    ; colors (packed)
    arr_c resd MAXRECT
    ; last index of array
    last  resd 1
    maxcycle resd 1

section .data
    help_string db "USAGE: randomrect [--help]", 0x0A, 0x0
    help_string_len equ $ - help_string
    atoi_invalid_input db ": Invalid number", 0x0A, 0x0
    atoi_invalid_input_len equ $ - atoi_invalid_input
    title db "3abdullah magical program (assembly pain version by ezntek)", 0x0
