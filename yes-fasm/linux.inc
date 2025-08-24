SYS_write = 1
SYS_exit = 60

macro syscall1 name, a1 {
    mov rax, name
    mov rdi, a1
    syscall
}

macro syscall2 name,a1,a2 {
    mov rax, name
    mov rdi, a1
    mov rsi, a2
    syscall
}

macro syscall3 name,a1,a2,a3 {
    mov rax, name
    mov rdi, a1
    mov rsi, a2
    mov rdx, a3
    syscall
}

