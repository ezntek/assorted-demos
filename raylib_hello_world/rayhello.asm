; assembly random rects 
;
; Copyright (c) ezntek, 2025.
; All source code in this directory is licensed under the bsd 2-clause license.

format ELF64

include 'linux.inc'
include 'raylib.inc'
include 'macros.inc'

extrn printf

section '.text' executable
public main
main:
    frame
    
    call3 InitWindow, 800, 600, title
    call1 SetTargetFPS, 60

    call2 printf, fmt, 5

    .loop:
    call WindowShouldClose
    cmp rax, 0
    jne .loop_after

    call BeginDrawing
    call1 ClearBackground, RAYWHITE 
    call EndDrawing
    jmp .loop
    .loop_after:
    call CloseWindow

    return 0

section '.data'
title db "Raylib Assembly Hello World", 0x0
fmt db "number: %d\n", 0x0
