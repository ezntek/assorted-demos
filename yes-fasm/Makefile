.POSIX:

#CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie 
CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g 

build:
	fasm yes.fasm
	$(CC) -m64 $(CFLAGS) -o yes yes.o

clean:
	rm *.o yes
