.POSIX:

#CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie 
CFLAGS = -m64 -Wl,--no-warn-execstack -no-pie -g 

build:
	fasm hello.fasm
	$(CC) -m64 $(CFLAGS) -o hello hello.o

clean:
	rm *.o yes
