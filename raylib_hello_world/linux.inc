stdin = 0
stdout = 1
stderr = 2

EXIT_SUCCESS = 0
EXIT_FAILURE = 1

; chatjippety
SYS_read = 0
SYS_write = 1
SYS_open = 2
SYS_close = 3
SYS_stat = 4
SYS_fstat = 5
SYS_lstat = 6
SYS_poll = 7
SYS_lseek = 8
SYS_mmap = 9
SYS_munmap = 11
SYS_brk = 12
SYS_rt_sigaction = 13
SYS_rt_sigprocmask = 14
SYS_ioctl = 16
SYS_pread64 = 17
SYS_pwrite64 = 18
SYS_readv = 19
SYS_writev = 20

SYS_access = 21
SYS_pipe = 22
SYS_select = 23
SYS_sched_yield = 24
SYS_mremap = 25
SYS_msync = 26
SYS_mincore = 27
SYS_madvise = 28

SYS_dup = 32
SYS_dup2 = 33
SYS_nanosleep = 35
SYS_getpid = 39
SYS_socket = 41
SYS_connect = 42
SYS_accept = 43
SYS_sendto = 44
SYS_recvfrom = 45

SYS_execve = 59
SYS_exit = 60
SYS_wait4 = 61
SYS_kill = 62

SYS_uname = 63
SYS_fcntl = 72
SYS_fsync = 74
SYS_fdatasync = 75
SYS_ftruncate = 77

SYS_getcwd = 79
SYS_chdir = 80
SYS_rename = 82
SYS_mkdir = 83
SYS_rmdir = 84
SYS_creat = 85
SYS_link = 86
SYS_unlink = 87

SYS_symlink = 88
SYS_readlink = 89
SYS_chmod = 90
SYS_fchmod = 91

SYS_openat = 257
SYS_newfstatat = 262

O_RDONLY = 0
O_WRONLY = 1
O_RDWR = 2
O_CREAT = 0x40 
O_EXCL = 0x80
O_NOCTTY = 0x100
O_TRUNC = 0x200
O_APPEND = 0x400
O_NONBLOCK = 0x800
O_DSYNC = 0x1000
O_SYNC = 0x101000 
O_CLOEXEC = 0x80000

PROT_READ = 0x1
PROT_WRITE = 0x2
PROT_EXEC = 0x4	
PROT_NONE = 0x0

MAP_SHARED = 0x01	
MAP_PRIVATE = 0x02

SEEK_SET = 0x0
SEEK_CUR = 0x1
SEEK_END = 0x2

macro call1 name, a1 {
    mov rdi, a1
    call name
}

macro call2 name, a1, a2 {
    mov rdi, a1
    mov rsi, a2
    call name
}

macro call3 name, a1, a2, a3 {
    mov rdi, a1
    mov rsi, a2
    mov rdx, a3
    call name
}

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

