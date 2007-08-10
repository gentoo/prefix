#include <stdio.h>
#include <strings.h>

#define BUFSIZE 8096

int main(int argc, char** argv) {
	FILE *fin;
	FILE *fout;
	char* magic;
	char* value;
	char buf[BUFSIZE];
	char* tmp;
	size_t len;
	size_t tlen;
	size_t pos;
	size_t magiclen;
	size_t valuelen;

	if (argc != 5) {
		fprintf(stderr, "usage: in-file out-file magic value\n");
		return(-1);
	}

	fin      = fopen(argv[1], "r");
	fout     = fopen(argv[2], "w");
	magic    = argv[3];
	value    = argv[4];
	magiclen = strlen(magic);
	valuelen = strlen(value);

	pos = 0;
	while ((len = fread(buf + pos, 1, BUFSIZE - pos, fin)) != 0 || pos > 0) {
		len += pos;
		if ((tmp = strstr(buf, magic)) != NULL) {
			if (tmp > buf + len) {
				/* get out of here, we're done (seeing results in
				 * garbage) */
				fwrite(buf, len, 1, fout);
				break;
			} else if (tmp == buf) {
				/* do some magic, overwrite it basically */
				fwrite(value, valuelen, 1, fout);
				/* find the end of the string */
				pos = magiclen;
				while (pos < len && buf[pos] != '\0')
					pos++;
				if (pos == len) {
					/* alert for now */
					fprintf(stderr, "couldn't find end of string within "
							"block, resulting binary may be corrupt!\n");
				}
				fwrite(buf + magiclen, pos - magiclen, 1, fout);
				/* now pad the remainder with zeros so we don't screw up
				 * the positions in the file */
				tlen = magiclen - valuelen;
				buf[0] = '\0';
				while (tlen-- > 0)
					fwrite(buf, 1, 1, fout);
				memmove(buf, buf + pos, len - pos);
				pos = len - pos;
				continue;
			} else {
				/* move this bunch to the front */
				pos = len - (tmp - buf);
			}
		} else {
			/* magic is not in here, but might just start at the end
			 * missing it's last char, so move that */
			if (len != BUFSIZE) {
				/* last piece */
				fwrite(buf, len, 1, fout);
				break;
			} else {
				pos = magiclen - 1;
				tmp = buf + (len - pos);
			}
		}
		fwrite(buf, len - pos, 1, fout);
		memmove(buf, tmp, pos);
	}
	fflush(fout);
	fclose(fout);
	fclose(fin);

	return(0);
}
