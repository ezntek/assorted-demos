.POSIX:

all: assembly cvers

assembly:
	@echo "making assembly version"
	nasm -felf64 -g -o randomrect.o randomrect.s
	$(CC) -lraylib -lc -lm -no-pie -o randomrect randomrect.o

cvers:
	@echo "making C version"
	$(CC) -lraylib -lc -lm -no-pie -O3 -mtune=native -march=native -o randomrect_c randomrect.c

clean:
	rm -f *.o randomrect randomrect_c
