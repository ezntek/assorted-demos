.POSIX:

CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g -m64 -lc

build:
	nasm -felf64 -g -o fib.o fib.nasm
	$(CC) $(CFLAGS) -o fib fib.o

clean:
	rm *.o fib
