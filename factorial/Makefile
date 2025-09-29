.POSIX:

CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g -m64 -lc

build:
	nasm -felf64 -o fac.o fac.nasm
	$(CC) $(CFLAGS) -o fac fac.o

clean:
	rm *.o fac
