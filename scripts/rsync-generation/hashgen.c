/* Copyright 2006-2017 Gentoo Foundation; Distributed under the GPL v2 */
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <dirent.h>
#include <time.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <openssl/sha.h>
#include <openssl/whrlpool.h>
#include <blake2.h>
#include <zlib.h>

/* Generate thick Manifests based on thin Manifests */

/* In order to build this program, the following packages are required:
 * - app-crypt/libb2 (for BLAKE2, for as long as openssl doesn't include it)
 * - dev-libs/openssl (for SHA, WHIRLPOOL)
 * - sys-libs/zlib (for compressing Manifest files)
 * compile like this
 *   ${CC} -o hashgen -fopenmp ${CFLAGS} -lssl -lcrypto -lb2 -lz hashgen.c
 */

enum hash_impls {
	HASH_SHA256    = 1<<0,
	HASH_SHA512    = 1<<1,
	HASH_WHIRLPOOL = 1<<2,
	HASH_BLAKE2B   = 1<<3
};
/* default changed from sha256, sha512, whirlpool
 * to blake2b, sha512 on 2017-11-21 */
static int hashes = HASH_BLAKE2B | HASH_SHA512;

static inline void
hex_hash(char *out, const unsigned char *buf, const int length)
{
	int i;
	for (i = 0; i < length; i++) {
		snprintf(&out[i * 2], 3, "%02x", buf[i]);
	}
}

static void
write_hashes(
		const char *root,
		const char *name,
		const char *type,
		FILE *m,
		gzFile gm)
{
	FILE *f;
	char fname[8192];
	size_t flen = 0;
	char sha256[(SHA256_DIGEST_LENGTH * 2) + 1];
	char sha512[(SHA512_DIGEST_LENGTH * 2) + 1];
	char whrlpl[(WHIRLPOOL_DIGEST_LENGTH * 2) + 1];
	char blak2b[(BLAKE2B_OUTBYTES * 2) + 1];
	char data[8192];
	size_t len;
	SHA256_CTX s256;
	SHA512_CTX s512;
	WHIRLPOOL_CTX whrl;
	blake2b_state bl2b;

	snprintf(fname, sizeof(fname), "%s/%s", root, name);
	if ((f = fopen(fname, "r")) == NULL)
		return;

	SHA256_Init(&s256);
	SHA512_Init(&s512);
	WHIRLPOOL_Init(&whrl);
	blake2b_init(&bl2b, BLAKE2B_OUTBYTES);

	while ((len = fread(data, 1, sizeof(data), f)) > 0) {
		flen += len;
#pragma omp parallel sections
		{
#pragma omp section
			{
				if (hashes & HASH_SHA256)
					SHA256_Update(&s256, data, len);
			}
#pragma omp section
			{
				if (hashes & HASH_SHA512)
					SHA512_Update(&s512, data, len);
			}
#pragma omp section
			{
				if (hashes & HASH_WHIRLPOOL)
					WHIRLPOOL_Update(&whrl, data, len);
			}
#pragma omp section
			{
				if (hashes & HASH_BLAKE2B)
					blake2b_update(&bl2b, (unsigned char *)data, len);
			}
		}
	}

#pragma omp parallel sections
	{
		{
			if (hashes & HASH_SHA256) {
				unsigned char sha256buf[SHA256_DIGEST_LENGTH];
				SHA256_Final(sha256buf, &s256);
				hex_hash(sha256, sha256buf, SHA256_DIGEST_LENGTH);
			}
		}
#pragma omp section
		{
			if (hashes & HASH_SHA512) {
				unsigned char sha512buf[SHA512_DIGEST_LENGTH];
				SHA512_Final(sha512buf, &s512);
				hex_hash(sha512, sha512buf, SHA512_DIGEST_LENGTH);
			}
		}
#pragma omp section
		{
			if (hashes & HASH_WHIRLPOOL) {
				unsigned char whrlplbuf[WHIRLPOOL_DIGEST_LENGTH];
				WHIRLPOOL_Final(whrlplbuf, &whrl);
				hex_hash(whrlpl, whrlplbuf, WHIRLPOOL_DIGEST_LENGTH);
			}
		}
#pragma omp section
		{
			if (hashes & HASH_BLAKE2B) {
				unsigned char blak2bbuf[BLAKE2B_OUTBYTES];
				blake2b_final(&bl2b, blak2bbuf, BLAKE2B_OUTBYTES);
				hex_hash(blak2b, blak2bbuf, BLAKE2B_OUTBYTES);
			}
		}
	}
	fclose(f);

	len = snprintf(data, sizeof(data), "%s %s %zd", type, name, flen);
	if (hashes & HASH_BLAKE2B)
		len += snprintf(data + len, sizeof(data) - len,
				" BLAKE2B %s", blak2b);
	if (hashes & HASH_SHA256)
		len += snprintf(data + len, sizeof(data) - len,
				" SHA256 %s", sha256);
	if (hashes & HASH_SHA512)
		len += snprintf(data + len, sizeof(data) - len,
				" SHA512 %s", sha512);
	if (hashes & HASH_WHIRLPOOL)
		len += snprintf(data + len, sizeof(data) - len,
				" WHIRLPOOL %s", whrlpl);
	len += snprintf(data + len, sizeof(data) - len, "\n");

	if (m != NULL)
		fwrite(data, len, 1, m);
	if (gm != NULL)
		gzwrite(gm, data, len);
}

static char
process_files(const char *dir, const char *off, FILE *m)
{
	char path[8192];
	DIR *d;
	struct dirent *e;

	snprintf(path, sizeof(path), "%s/%s", dir, off);
	if ((d = opendir(path)) != NULL) {
		while ((e = readdir(d)) != NULL) {
			/* skip all dotfiles */
			if (e->d_name[0] == '.')
				continue;
			snprintf(path, sizeof(path), "%s%s%s",
					off, *off == '\0' ? "" : "/", e->d_name);
			if (process_files(dir, path, m))
				continue;
			/* regular file */
			write_hashes(dir, path, "AUX", m, NULL);
		}
		closedir(d);
		return 1;
	} else {
		return 0;
	}
}

static int
parse_layout_conf(const char *path)
{
	FILE *f;
	char buf[8192];
	size_t len = 0;
	size_t sz;
	char *p;
	char *q;
	char *tok;
	char *last_nl;
	int ret = 0;

	if ((f = fopen(path, "r")) == NULL)
		return 0;

	/* read file, examine lines after encountering a newline, that is,
	 * if the file doesn't end with a newline, the final bit is ignored */
	while ((sz = fread(buf + len, 1, sizeof(buf) - len, f)) > 0) {
		len += sz;
		last_nl = NULL;
		for (p = buf; p - buf < len; p++) {
			if (*p == '\n') {
				last_nl = p;
				sz = strlen("manifest-hashes");
				if (strncmp(buf, "manifest-hashes", sz))
					continue;
				if ((q = strchr(buf + sz, '=')) == NULL)
					continue;
				q++;
				while (isspace((int)*q))
					q++;
				/* parse the tokens, whitespace separated */
				tok = q;
				do {
					while (!isspace((int)*q))
						q++;
					sz = q - tok;
					if (strncmp(tok, "SHA256", sz) == 0) {
						ret |= HASH_SHA256;
					} else if (strncmp(tok, "SHA512", sz) == 0) {
						ret |= HASH_SHA512;
					} else if (strncmp(tok, "WHIRLPOOL", sz) == 0) {
						ret |= HASH_WHIRLPOOL;
					} else if (strncmp(tok, "BLAKE2B", sz) == 0) {
						ret |= HASH_BLAKE2B;
					}
					while (isspace((int)*q) && *q != '\n')
						q++;
					tok = q;
				} while (*q != '\n');
				/* got it, expect only once, so stop processing */
				fclose(f);
				return ret;
			}
		}
		if (last_nl != NULL) {
			last_nl++;  /* skip \n */
			len = last_nl - buf;
			memmove(buf, last_nl, len);
		} else {
			/* too long line, just skip */
			len = 0;
		}
	}

	fclose(f);
	return 0;
}

static char *str_manifest = "Manifest";
static char *str_manifest_gz = "Manifest.gz";
static char *str_manifest_files_gz = "Manifest.files.gz";
static char *
process_dir(const char *dir)
{
	char manifest[8192];
	FILE *f;
	DIR *d;
	struct dirent *e;
	char path[8192];
	int newhashes;
	char global_manifest = 0;
	struct stat s;
	struct timeval tv[2];

	/* set mtime of Manifest(.gz) to the one of the parent dir, this way
	 * we ensure the Manifest gets mtime bumped upon any change made
	 * to the directory, that is, a DIST change (Manifest itself) or
	 * any other change (ebuild, files, metadata) */
	if (stat(dir, &s)) {
		tv[0].tv_sec = 0;
		tv[0].tv_usec = 0;
	} else {
		tv[0].tv_sec = s.st_atim.tv_sec;
		tv[0].tv_usec = s.st_atim.tv_nsec / 1000;
		tv[1].tv_sec = s.st_mtim.tv_sec;
		tv[1].tv_usec = s.st_mtim.tv_nsec / 1000;
	}

	snprintf(path, sizeof(path), "%s/metadata/layout.conf", dir);
	if ((newhashes = parse_layout_conf(path)) != 0) {
		global_manifest = 1;
		hashes = newhashes;
	}

	snprintf(manifest, sizeof(manifest), "%s/%s", dir, str_manifest);
	if ((f = fopen(manifest, "r")) == NULL) {
		gzFile mf;

		/* recurse into subdirs */
		if ((d = opendir(dir)) != NULL) {
			struct stat s;
			char *my_manifest =
				global_manifest ? str_manifest_files_gz : str_manifest_gz;

			/* open up a gzipped Manifest to keep the hashes of the
			 * Manifests in the subdirs */
			snprintf(manifest, sizeof(manifest), "%s/%s", dir, my_manifest);
			if ((mf = gzopen(manifest, "wb9")) == NULL) {
				fprintf(stderr, "failed to open file '%s' for writing: %s\n",
						manifest, strerror(errno));
				return NULL;
			}

			while ((e = readdir(d)) != NULL) {
				if (e->d_name[0] == '.')
					continue;
				if (strcmp(e->d_name, my_manifest) == 0)
					continue;
				snprintf(path, sizeof(path), "%s/%s", dir, e->d_name);
				if (!stat(path, &s)) {
					if (s.st_mode & S_IFDIR) {
						char *mfest = process_dir(path);
						if (mfest == NULL) {
							gzclose(mf);
							return NULL;
						}
						snprintf(path, sizeof(path), "%s/%s", e->d_name, mfest);
						write_hashes(dir, path, "MANIFEST", NULL, mf);
					} else if (s.st_mode & S_IFREG) {
						write_hashes(dir, e->d_name, "DATA", NULL, mf);
					}
				}
			}
			closedir(d);

			if (global_manifest) {
				char globmanifest[8192];
				char buf[2048];
				size_t len;
				FILE *m;
				time_t rtime;

				len = snprintf(buf, sizeof(buf),
						"IGNORE distfiles\n"
						"IGNORE local\n"
						"IGNORE lost+found\n"
						"IGNORE packages\n");
				gzwrite(mf, buf, len);
				gzclose(mf);

				/* create global Manifest */
				snprintf(globmanifest, sizeof(globmanifest),
						"%s/%s", dir, str_manifest);
				if ((m = fopen(globmanifest, "w")) == NULL) {
					fprintf(stderr, "failed to open file '%s' "
							"for writing: %s\n",
							globmanifest, strerror(errno));
					return NULL;
				}

				write_hashes(dir, my_manifest, "MANIFEST", m, NULL);
				time(&rtime);
				len = strftime(buf, sizeof(buf),
						"TIMESTAMP %Y-%m-%dT%H:%M:%SZ\n", gmtime(&rtime));
				fwrite(buf, len, 1, m);
				fflush(m);
				fclose(m);

				if (tv[0].tv_sec != 0) {
					/* restore dir mtime, and set Manifest mtime to match it */
					utimes(globmanifest, tv);
				}
			} else {
				gzclose(mf);
			}

			if (tv[0].tv_sec != 0) {
				/* restore dir mtime, and set Manifest mtime to match it */
				utimes(manifest, tv);
				utimes(dir, tv);
			}
		}

		return str_manifest_gz;
	} else {
		/* this looks like an ebuild dir, so update the Manifest */
		FILE *m;
		char newmanifest[8192];
		char buf[8192];

		snprintf(newmanifest, sizeof(newmanifest), "%s/.Manifest.new", dir);
		if ((m = fopen(newmanifest, "w")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					newmanifest, strerror(errno));
			return NULL;
		}

		/* we know the Manifest is sorted, and stuff in files/ is
		 * prefixed with AUX, hence, if it exists, we need to do it
		 * first */
		snprintf(path, sizeof(path), "%s/files", dir);
		process_files(path, "", m);

		/* copy the DIST entries, we could do it unconditional, but this
		 * way we can re-run without producing invalid Manifests */
		while (fgets(buf, sizeof(buf), f) != NULL) {
			if (strncmp(buf, "DIST ", 5) == 0)
				if (fwrite(buf, strlen(buf), 1, m) != 1) {
					fprintf(stderr, "failed to write to %s/.Manifest.new: %s\n",
							dir, strerror(errno));
					fclose(f);
					return NULL;
				}
		}
		fclose(f);

		if ((d = opendir(dir)) != NULL) {
			while ((e = readdir(d)) != NULL) {
				/* in ebuild land, stuff starting with a . isn't valid,
				 * so can safely ignore it, while at the same time
				 * skipping over . and .. (+need for .Manifest.new) */
				if (e->d_name[0] == '.')
					continue;
				if (strcmp(e->d_name + strlen(e->d_name) - 7, ".ebuild") != 0)
					continue;
				write_hashes(dir, e->d_name, "EBUILD", m, NULL);
			}
			closedir(d);
		}

		write_hashes(dir, "ChangeLog", "MISC", m, NULL);
		write_hashes(dir, "metadata.xml", "MISC", m, NULL);

		fflush(m);
		fclose(m);

		rename(newmanifest, manifest);
		if (tv[0].tv_sec != 0) {
			/* restore dir mtime, and set Manifest mtime to match it */
			utimes(manifest, tv);
			utimes(dir, tv);
		}

		return str_manifest;
	}
}

int
main(int argc, char *argv[])
{
	if (argc > 1) {
		int i;
		for (i = 1; i < argc; i++)
			process_dir(argv[i]);
	} else {
		process_dir(".");
	}

	return 0;
}
