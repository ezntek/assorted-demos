.POSIX:

build:
	nasm -felf64 -g -o yes.o yes.s
	$(CC) -no-pie -o yes yes.o
	
clean:
	rm *.o yes
