.POSIX:

all: assembly

assembly:
	fasm rayhello.asm rayhello.o
	$(CC) -lraylib -m64 -lc -lm -Wl,--no-warn-execstack -no-pie -o rayhello rayhello.o

clean:
	rm -f *.o rayhello *_c
