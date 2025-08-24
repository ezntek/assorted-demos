.POSIX:

#CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie 
CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g 

build: assembly c

assembly:
	fasm baseconv.fasm
	$(CC) -m64 $(CFLAGS) -o baseconv baseconv.o

c:
	$(CC) -o baseconv_c baseconv.c

clean:
	rm *.o baseconv*
