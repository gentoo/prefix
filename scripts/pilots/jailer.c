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
	if (padding == 0 || (z = memchr(buf, '\0', len)) == NULL) {
		/* cheap case, nothing complicated to do here */
		fwrite(buf, len, 1, fout);
	} else {
		/* found a zero-byte, insert padding */
		fwrite(buf, z - buf, 1, fout);
		/* now pad with zeros so we don't screw up
		 * the positions in the file */
		buf[0] = '\0';
		while (padding > 0) {
			fwrite(buf, 1, 1, fout);
			padding--;
		}
		fwrite(z, len - (z - buf), 1, fout);
	}

	return(padding);
}

/**
 * Searches buf for an occurrence of needle, doing a byte-based match,
 * disregarding end of string markers (zero-bytes), as strstr does.
 * Returns a pointer to the first occurrence of needle in buf, or NULL
 * if not found.
 */
char *memstr(const char *buf, const char *needle, size_t len) {
	const char *ret;
	size_t off;
	for (ret = buf; ret - buf < len; ret++) {
		off = 0;
		while (needle[off] != '\0' &&
				(ret - buf) + off < len &&
				needle[off] == ret[off])
		{
			off++;
		}
		if (needle[off] == '\0')
			return((char *)ret);
	}
	return(NULL);
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
		if ((tmp = memstr(buf, magic, len)) != NULL) {
			if (tmp == buf) {
				/* do some magic, overwrite it basically */
				fwrite(value, valuelen, 1, fout);
				/* store what we need to correct */
				padding += magiclen - valuelen;
				/* move away the magic */
				pos = len - magiclen;
				memmove(buf, buf + magiclen, pos);
				continue;
			} else {
				/* move this bunch to the front */
				pos = len - (tmp - buf);
			}
		} else {
			/* magic is not in here, but might just start at the end
			 * missing its last char, so move that */
			if (len != BUFSIZE) {
				/* last piece */
				padding = padonwrite(padding, buf, len, fout);
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

	if (padding != 0) {
		fprintf(stderr, "warning: couldn't find a location to write "
				"%zd padding bytes\n", padding);
	}

	return(0);
}
