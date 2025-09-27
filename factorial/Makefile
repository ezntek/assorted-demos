.POSIX:

#CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie 
CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g 

build:
	fasm fac.fasm
	$(CC) -lc -m64 $(CFLAGS) -o fac fac.o

clean:
	rm *.o fac
