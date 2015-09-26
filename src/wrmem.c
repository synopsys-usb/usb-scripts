#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/mman.h>

int
main(int argc, char *argv[])
{
	unsigned n, a;
	int fd;
	char *adr;

	if (argc != 3) {
		printf("Usage:\n");
		printf(" w <hexadr> <hexval>    write <hexval> to memory address <hexaddr>\n");
		return 1;
	}

	a = (unsigned)strtoul(argv[1], NULL, 16);
	n = (unsigned)strtoul(argv[2], NULL, 16);

	fd = open("/dev/mem", O_RDWR | O_SYNC);

	if (fd < 0) {
		fprintf(stderr, "Couldn't open /dev/mem\n");
		return 2;
	}

	adr = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, a & 0xfffff000U);

	if ((long) adr == -1) {
		fprintf(stderr, "Couldn't mmap /dev/mem\n");
		close(fd);
		return 3;
	}

	*(unsigned *)(adr + (a & 0xffcU)) = n;

	munmap(adr, 0x1000);
	close(fd);
	return 0;
}
