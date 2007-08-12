#include <stdio.h>
#include <strings.h>
#include <errno.h>

#define BUFSIZE 8095

/**
 * Writes padding zero-bytes after the first encountered zero-byte.
 * Returns padding if no zero-byte was seen, or 0 if padding was
 * applied.
 */
size_t padonwrite(size_t padding, char *buf, size_t len, FILE *fout) {
	char *z;
	if (padding == 0 || (z = strchr(buf, '\0')) == NULL || z > buf + len) {
		/* cheap case, nothing complicated to do here */
		fwrite(buf, len, 1, fout);
	} else {
		/* found a zero-byte, insert padding */
		fwrite(buf, z - buf, 1, fout);
		/* now pad with zeros so we don't screw up
		 * the positions in the file */
		buf[0] = '\0';
		while (padding-- > 0)
			fwrite(buf, 1, 1, fout);
		fwrite(z, len - (z - buf), 1, fout);
	}

	return(padding);
}

int main(int argc, char **argv) {
	FILE *fin;
	FILE *fout;
	char *magic;
	char *value;
	char buf[BUFSIZE + 1];
	char *tmp;
	size_t len;
	size_t pos;
	size_t padding;
	size_t magiclen;
	size_t valuelen;

	if (argc != 5) {
		fprintf(stderr, "usage: in-file out-file magic value\n");
		return(-1);
	}

	magic    = argv[3];
	value    = argv[4];
	magiclen = strlen(magic);
	valuelen = strlen(value);

	if (magiclen < valuelen) {
		fprintf(stderr, "value length (%zd) is bigger than "
				"the magic length (%zd)\n", valuelen, magiclen);
		return(-1);
	}

	fin      = fopen(argv[1], "r");
	if (fin == NULL) {
		fprintf(stderr, "unable to open %s: %s\n", argv[1], strerror(errno));
		return(-1);
	}

	fout     = fopen(argv[2], "w");
	if (fin == NULL) {
		fprintf(stderr, "unable to open %s: %s\n", argv[2], strerror(errno));
		return(-1);
	}

	/* make sure there is a trailing zero-byte, such that strstr and
	 * strchr won't go out of bounds causing segfaults.  */
	buf[BUFSIZE] = '\0';

	pos = 0;
	padding = 0;
	while ((len = fread(buf + pos, 1, BUFSIZE - pos, fin)) != 0 || pos > 0) {
		len += pos;
		if ((tmp = strstr(buf, magic)) != NULL) {
			if (tmp > buf + len) {
				/* get out of here, we're done (seeing results in
				 * garbage) */
				padonwrite(padding, buf, len, fout);
				break;
			} else if (tmp == buf) {
printf("magic found here\n");
				/* do some magic, overwrite it basically */
				fwrite(value, valuelen, 1, fout);
				/* store what we need to correct */
				padding += magiclen - valuelen;
				/* move away the magic */
				pos = len - magiclen;
				memmove(buf, buf + magiclen, pos);
				continue;
			} else {
printf("magic found\n");
				/* move this bunch to the front */
				pos = len - (tmp - buf);
			}
		} else {
printf("no magic in block :(\n");
			/* magic is not in here, but might just start at the end
			 * missing it's last char, so move that */
			if (len != BUFSIZE) {
				/* last piece */
				padonwrite(padding, buf, len, fout);
				break;
			} else {
				pos = magiclen - 1;
				tmp = buf + (len - pos);
			}
		}
		padding = padonwrite(padding, buf, len - pos, fout);
		memmove(buf, tmp, pos);
	}
	fflush(fout);
	fclose(fout);
	fclose(fin);

	return(0);
}
