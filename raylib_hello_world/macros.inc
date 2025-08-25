macro frame {
    push rbp
    mov rbp, rsp
}

macro return val {
    pop rbp
    mov eax, val
    ret
}
