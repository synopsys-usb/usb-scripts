#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define SIZE 4096

int main(void)
{
	char *file = "/dev/ram0";
	char *outfile = "ram0.bin";

	FILE *fp = fopen(file, "r+b");
	if (!fp) {
		perror("Could not open file");
		return -1;
	}

	FILE *out = fopen(outfile, "w+b");
	if (!out) {
		perror("Could not open file");
		return -1;
	}

	int i;
	int sum = 0;

	size_t size = 0;
	size_t total = 0;
	uint8_t buf[SIZE];

	size_t block_count = 0;
	while (1) {
		size = fread(buf, 1, SIZE, fp);
		if (size == 0)
			break;

		total += size;

		int sum = 0;
		for (i = 0; i < size; i ++) {
			sum += buf[i];
		}

		if (sum) {
			printf("block %lld set\n", block_count);
			fwrite(&block_count, sizeof(size_t), 1, out);
			fwrite(buf, 1, SIZE, out);
		}

		block_count ++;
	}

	printf("Total blocks = %lld\n", block_count);
	printf("Total size = %lld\n", total);

	return 0;
}
