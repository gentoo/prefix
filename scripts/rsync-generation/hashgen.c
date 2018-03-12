/* Copyright 2006-2018 Gentoo Foundation; Distributed under the GPL v2 */
#include <stdio.h>
#include <stdlib.h>
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
#include <gpgme.h>

/* Generate thick Manifests based on thin Manifests */

/* In order to build this program, the following packages are required:
 * - app-crypt/libb2 (for BLAKE2, for as long as openssl doesn't include it)
 * - dev-libs/openssl (for SHA, WHIRLPOOL)
 * - sys-libs/zlib (for compressing Manifest files)
 * - app-crypt/gpgme (for signing/verifying the top level manifest)
 * compile like this:
 *   ${CC} -o hashgen -fopenmp ${CFLAGS} \
 *         -lssl -lcrypto -lb2 -lz `gpgme-config --libs` hashgen.c
 */

enum hash_impls {
	HASH_SHA256    = 1<<0,
	HASH_SHA512    = 1<<1,
	HASH_WHIRLPOOL = 1<<2,
	HASH_BLAKE2B   = 1<<3
};
/* default changed from sha256, sha512, whirlpool
 * to blake2b, sha512 on 2017-11-21 */
#define HASH_DEFAULT  (HASH_BLAKE2B | HASH_SHA512);
static int hashes = HASH_DEFAULT;

static inline void
hex_hash(char *out, const unsigned char *buf, const int length)
{
	switch (length) {
		/* SHA256_DIGEST_LENGTH */
		case 32:
			snprintf(out, 64 + 1,
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x",
					buf[ 0], buf[ 1], buf[ 2], buf[ 3], buf[ 4],
					buf[ 5], buf[ 6], buf[ 7], buf[ 8], buf[ 9],
					buf[10], buf[11], buf[12], buf[13], buf[14],
					buf[15], buf[16], buf[17], buf[18], buf[19],
					buf[20], buf[21], buf[22], buf[23], buf[24],
					buf[25], buf[26], buf[27], buf[28], buf[29],
					buf[30], buf[31]
					);
			break;
		/* SHA512_DIGEST_LENGTH, WHIRLPOOL_DIGEST_LENGTH, BLAKE2B_OUTBYTES */
		case 64:
			snprintf(out, 128 + 1,
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
					"%02x%02x%02x%02x",
					buf[ 0], buf[ 1], buf[ 2], buf[ 3], buf[ 4],
					buf[ 5], buf[ 6], buf[ 7], buf[ 8], buf[ 9],
					buf[10], buf[11], buf[12], buf[13], buf[14],
					buf[15], buf[16], buf[17], buf[18], buf[19],
					buf[20], buf[21], buf[22], buf[23], buf[24],
					buf[25], buf[26], buf[27], buf[28], buf[29],
					buf[30], buf[31], buf[32], buf[33], buf[34],
					buf[35], buf[36], buf[37], buf[38], buf[39],
					buf[40], buf[41], buf[42], buf[43], buf[44],
					buf[45], buf[46], buf[47], buf[48], buf[49],
					buf[50], buf[51], buf[52], buf[53], buf[54],
					buf[55], buf[56], buf[57], buf[58], buf[59],
					buf[60], buf[61], buf[62], buf[63]
					);
			break;
		/* fallback case, should never be necessary */
		default:
			{
				int i;
				for (i = 0; i < length; i++) {
					snprintf(&out[i * 2], 3, "%02x", buf[i]);
				}
			}
			break;
	}
}

static inline void
update_times(struct timeval *tv, struct stat *s)
{
#ifdef __MACH__
# define st_mtim st_mtimespec
# define st_atim st_atimespec
#endif
	if (tv[1].tv_sec < s->st_mtim.tv_sec ||
			(tv[1].tv_sec == s->st_mtim.tv_sec &&
			 tv[1].tv_usec < s->st_mtim.tv_nsec / 1000))
	{
		tv[0].tv_sec = s->st_atim.tv_sec;
		tv[0].tv_usec = s->st_atim.tv_nsec / 1000;
		tv[1].tv_sec = s->st_mtim.tv_sec;
		tv[1].tv_usec = s->st_mtim.tv_nsec / 1000;
	}
}

static void
get_hashes(
		const char *fname,
		char *sha256,
		char *sha512,
		char *whrlpl,
		char *blak2b,
		size_t *flen)
{
	FILE *f;
	char data[8192];
	size_t len;
	SHA256_CTX s256;
	SHA512_CTX s512;
	WHIRLPOOL_CTX whrl;
	blake2b_state bl2b;

	if ((f = fopen(fname, "r")) == NULL)
		return;

	SHA256_Init(&s256);
	SHA512_Init(&s512);
	WHIRLPOOL_Init(&whrl);
	blake2b_init(&bl2b, BLAKE2B_OUTBYTES);

	while ((len = fread(data, 1, sizeof(data), f)) > 0) {
		*flen += len;
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
	fclose(f);

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
}

#define LISTSZ 64

static int
compare_strings(const void *l, const void *r)
{
	const char **strl = (const char **)l;
	const char **strr = (const char **)r;
	return strcmp(*strl, *strr);
}

/**
 * Return a sorted list of entries in the given directory.  All entries
 * starting with a dot are ignored, and not present in the returned
 * list.  The list and all entries are allocated using malloc() and need
 * to be freed.
 * This function returns 0 when everything is fine, non-zero otherwise.
 */
static char
list_dir(char ***retlist, size_t *retcnt, const char *path)
{
	DIR *d;
	struct dirent *e;
	size_t rlen = 0;
	size_t rsize = 0;
	char **rlist = NULL;

	if ((d = opendir(path)) != NULL) {
		while ((e = readdir(d)) != NULL) {
			/* skip all dotfiles */
			if (e->d_name[0] == '.')
				continue;

			if (rlen == rsize) {
				rsize += LISTSZ;
				rlist = realloc(rlist,
						rsize * sizeof(rlist[0]));
				if (rlist == NULL) {
					fprintf(stderr, "out of memory\n");
					return 1;
				}
			}
			rlist[rlen] = strdup(e->d_name);
			if (rlist[rlen] == NULL) {
				fprintf(stderr, "out of memory\n");
				return 1;
			}
			rlen++;
		}
		closedir(d);

		qsort(rlist, rlen, sizeof(rlist[0]), compare_strings);

		*retlist = rlist;
		*retcnt = rlen;
		return 0;
	} else {
		return 1;
	}
}

static void
write_hashes(
		struct timeval *tv,
		const char *root,
		const char *name,
		const char *type,
		FILE *m,
		gzFile gm)
{
	size_t flen = 0;
	char sha256[(SHA256_DIGEST_LENGTH * 2) + 1];
	char sha512[(SHA512_DIGEST_LENGTH * 2) + 1];
	char whrlpl[(WHIRLPOOL_DIGEST_LENGTH * 2) + 1];
	char blak2b[(BLAKE2B_OUTBYTES * 2) + 1];
	char data[8192];
	char fname[8192];
	size_t len;
	struct stat s;

	snprintf(fname, sizeof(fname), "%s/%s", root, name);

	if (stat(fname, &s) != 0)
		return;

	update_times(tv, &s);

	get_hashes(fname, sha256, sha512, whrlpl, blak2b, &flen);

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
write_hashes_dir(
		struct timeval *tv,
		const char *root,
		const char *name,
		gzFile zm)
{
	char path[8192];
	char **dentries;
	size_t dentrieslen;
	size_t i;

	snprintf(path, sizeof(path), "%s/%s", root, name);
	if (list_dir(&dentries, &dentrieslen, path) == 0) {
		for (i = 0; i < dentrieslen; i++) {
			snprintf(path, sizeof(path), "%s/%s", name, dentries[i]);
			free(dentries[i]);
			if (write_hashes_dir(tv, root, path, zm) == 0)
				continue;
			/* regular file */
			write_hashes(tv, root, path, "DATA", NULL, zm);
		}
		free(dentries);
		return 0;
	} else {
		return 1;
	}
}

static char
process_files(struct timeval *tv, const char *dir, const char *off, FILE *m)
{
	char path[8192];
	char **dentries;
	size_t dentrieslen;
	size_t i;

	snprintf(path, sizeof(path), "%s/%s", dir, off);
	if (list_dir(&dentries, &dentrieslen, path) == 0) {
		for (i = 0; i < dentrieslen; i++) {
			snprintf(path, sizeof(path), "%s%s%s",
					off, *off == '\0' ? "" : "/", dentries[i]);
			free(dentries[i]);
			if (process_files(tv, dir, path, m) == 0)
				continue;
			/* regular file */
			write_hashes(tv, dir, path, "AUX", m, NULL);
		}
		free(dentries);
		return 0;
	} else {
		return 1;
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
	char *start;
	int ret = 0;

	if ((f = fopen(path, "r")) == NULL)
		return 0;

	/* read file, examine lines after encountering a newline, that is,
	 * if the file doesn't end with a newline, the final bit is ignored */
	while ((sz = fread(buf + len, 1, sizeof(buf) - len, f)) > 0) {
		len += sz;
		start = buf;
		last_nl = NULL;
		for (p = buf; p - buf < len; p++) {
			if (*p == '\n') {
				if (last_nl != NULL)
					start = last_nl + 1;
				last_nl = p;
				do {
					sz = strlen("manifest-hashes");
					if (strncmp(start, "manifest-hashes", sz))
						break;
					if ((q = strchr(start + sz, '=')) == NULL)
						break;
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
						} else {
							fprintf(stderr, "warning: unsupported hash from "
									"layout.conf: %.*s\n", (int)sz, tok);
						}
						while (isspace((int)*q) && *q != '\n')
							q++;
						tok = q;
					} while (*q != '\n');
					/* got it, expect only once, so stop processing */
					fclose(f);
					return ret;
				} while (0);
			}
		}
		if (last_nl != NULL) {
			last_nl++;  /* skip \n */
			len = last_nl - buf;
			memmove(buf, last_nl, len);
			last_nl = buf;
		} else {
			/* skip too long line */
			len = 0;
		}
	}

	fclose(f);
	/* if we didn't find anything, return the default set */
	return HASH_DEFAULT;
}

static char *str_manifest = "Manifest";
static char *str_manifest_gz = "Manifest.gz";
static char *str_manifest_files_gz = "Manifest.files.gz";
enum type_manifest {
	GLOBAL_MANIFEST,   /* Manifest.files.gz + Manifest */
	SUBTREE_MANIFEST,  /* Manifest.gz for recursive list of files */
	EBUILD_MANIFEST,   /* Manifest thick from thin */
	CATEGORY_MANIFEST  /* Manifest.gz with Manifest entries */
};
static char *
generate_dir(const char *dir, enum type_manifest mtype)
{
	FILE *f;
	char path[8192];
	struct stat s;
	struct timeval tv[2];
	char **dentries;
	size_t dentrieslen;
	size_t i;

	/* our timestamp strategy is as follows:
	 * - when a Manifest exists, use its timestamp
	 * - when a meta-Manifest is written (non-ebuilds) use the timestamp
	 *   of the latest Manifest referenced
	 * - when a Manifest is written for something like eclasses, use the
	 *   timestamp of the latest file in the dir
	 * this way we should keep updates limited to where changes are, and
	 * also get reproducible mtimes. */
	tv[0].tv_sec = 0;
	tv[0].tv_usec = 0;
	tv[1].tv_sec = 0;
	tv[1].tv_usec = 0;

	if (mtype == GLOBAL_MANIFEST) {
		char *mfest;
		size_t len;
		gzFile mf;
		time_t rtime;

		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_files_gz);
		if ((mf = gzopen(path, "wb9")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					path, strerror(errno));
			return NULL;
		}

		/* These "IGNORE" entries are taken from gx86, there is no
		 * standardisation on this, on purpose, apparently. */
		len = snprintf(path, sizeof(path),
				"IGNORE distfiles\n"
				"IGNORE local\n"
				"IGNORE lost+found\n"
				"IGNORE packages\n");
		gzwrite(mf, path, len);

		if (list_dir(&dentries, &dentrieslen, dir) != 0)
			return NULL;

		for (i = 0; i < dentrieslen; i++) {
			/* ignore existing Manifests */
			if (strcmp(dentries[i], str_manifest_files_gz) == 0 ||
					strcmp(dentries[i], str_manifest) == 0)
			{
				free(dentries[i]);
				continue;
			}

			snprintf(path, sizeof(path), "%s/%s", dir, dentries[i]);

			mfest = NULL;
			if (!stat(path, &s)) {
				if (s.st_mode & S_IFDIR) {
					if (
							strcmp(dentries[i], "eclass")   == 0 ||
							strcmp(dentries[i], "licenses") == 0 ||
							strcmp(dentries[i], "metadata") == 0 ||
							strcmp(dentries[i], "profiles") == 0 ||
							strcmp(dentries[i], "scripts")  == 0
					   )
					{
						mfest = generate_dir(path, SUBTREE_MANIFEST);
					} else {
						mfest = generate_dir(path, CATEGORY_MANIFEST);
					}

					if (mfest == NULL) {
						fprintf(stderr, "generating Manifest for %s failed!\n",
								path);
						gzclose(mf);
						return NULL;
					}

					snprintf(path, sizeof(path), "%s/%s",
							dentries[i], mfest);
					write_hashes(tv, dir, path, "MANIFEST", NULL, mf);
				} else if (s.st_mode & S_IFREG) {
					write_hashes(tv, dir, dentries[i], "DATA", NULL, mf);
				} /* ignore other "things" (like symlinks) as they
					 don't belong in a tree */
			} else {
				fprintf(stderr, "stat(%s) failed: %s\n",
						path, strerror(errno));
			}
			free(dentries[i]);
		}
		free(dentries);
		gzclose(mf);

		if (tv[0].tv_sec != 0) {
			snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_files_gz);
			utimes(path, tv);
		}

		/* create global Manifest */
		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest);
		if ((f = fopen(path, "w")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					path, strerror(errno));
			return NULL;
		}

		write_hashes(tv, dir, str_manifest_files_gz, "MANIFEST", f, NULL);
		time(&rtime);
		len = strftime(path, sizeof(path),
				"TIMESTAMP %Y-%m-%dT%H:%M:%SZ\n", gmtime(&rtime));
		fwrite(path, len, 1, f);
		fflush(f);
		fclose(f);

		/* because we write a timestamp in Manifest, we don't mess with
		 * its mtime, else it would obviously lie */
		return str_manifest_files_gz;
	} else if (mtype == SUBTREE_MANIFEST) {
		const char *ldir;
		gzFile mf;

		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_gz);
		if ((mf = gzopen(path, "wb9")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					path, strerror(errno));
			return NULL;
		}

		ldir = strrchr(dir, '/');
		if (ldir == NULL)
			ldir = dir;
		if (strcmp(ldir, "metadata") == 0) {
			size_t len;
			len = snprintf(path, sizeof(path),
					"IGNORE timestamp\n"
					"IGNORE timestamp.chk\n"
					"IGNORE timestamp.commit\n"
					"IGNORE timestamp.x\n");
			gzwrite(mf, path, len);
		}

		if (list_dir(&dentries, &dentrieslen, dir) != 0)
			return NULL;

		for (i = 0; i < dentrieslen; i++) {
			/* ignore existing Manifests */
			if (strcmp(dentries[i], str_manifest_gz) == 0) {
				free(dentries[i]);
				continue;
			}

			if (write_hashes_dir(tv, dir, dentries[i], mf) != 0)
				write_hashes(tv, dir, dentries[i], "DATA", NULL, mf);
			free(dentries[i]);
		}

		free(dentries);
		gzclose(mf);

		if (tv[0].tv_sec != 0) {
			/* set Manifest and dir mtime to most recent file found */
			snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_gz);
			utimes(path, tv);
			utimes(dir, tv);
		}

		return str_manifest_gz;
	} else if (mtype == CATEGORY_MANIFEST) {
		char *mfest;
		gzFile mf;

		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_gz);
		if ((mf = gzopen(path, "wb9")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					path, strerror(errno));
			return NULL;
		}

		if (list_dir(&dentries, &dentrieslen, dir) != 0)
			return NULL;

		for (i = 0; i < dentrieslen; i++) {
			/* ignore existing Manifests */
			if (strcmp(dentries[i], str_manifest_gz) == 0) {
				free(dentries[i]);
				continue;
			}

			snprintf(path, sizeof(path), "%s/%s", dir, dentries[i]);
			if (!stat(path, &s)) {
				if (s.st_mode & S_IFDIR) {
					mfest = generate_dir(path, EBUILD_MANIFEST);

					if (mfest == NULL) {
						fprintf(stderr, "generating Manifest for %s failed!\n",
								path);
						gzclose(mf);
						return NULL;
					}

					snprintf(path, sizeof(path), "%s/%s",
							dentries[i], mfest);
					write_hashes(tv, dir, path, "MANIFEST", NULL, mf);
				} else if (s.st_mode & S_IFREG) {
					write_hashes(tv, dir, dentries[i], "DATA", NULL, mf);
				} /* ignore other "things" (like symlinks) as they
					 don't belong in a tree */
			} else {
				fprintf(stderr, "stat(%s) failed: %s\n",
						path, strerror(errno));
			}
			free(dentries[i]);
		}

		free(dentries);
		gzclose(mf);

		if (tv[0].tv_sec != 0) {
			/* set Manifest and dir mtime to most ebuild dir found */
			snprintf(path, sizeof(path), "%s/%s", dir, str_manifest_gz);
			utimes(path, tv);
			utimes(dir, tv);
		}

		return str_manifest_gz;
	} else if (mtype == EBUILD_MANIFEST) {
		char newmanifest[8192];
		FILE *m;

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
		process_files(tv, path, "", m);

		/* the Manifest file may be missing in case there are no DIST
		 * entries to be stored */
		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest);
		if (!stat(path, &s))
			update_times(tv, &s);
		f = fopen(path, "r");
		if (f != NULL) {
			/* copy the DIST entries, we could do it unconditional, but this
			 * way we can re-run without producing invalid Manifests */
			while (fgets(path, sizeof(path), f) != NULL) {
				if (strncmp(path, "DIST ", 5) == 0)
					if (fwrite(path, strlen(path), 1, m) != 1) {
						fprintf(stderr, "failed to write to "
								"%s/.Manifest.new: %s\n",
								dir, strerror(errno));
						fclose(f);
						fclose(m);
						return NULL;
					}
			}
			fclose(f);
		}

		if (list_dir(&dentries, &dentrieslen, dir) == 0) {
			for (i = 0; i < dentrieslen; i++) {
				if (strcmp(dentries[i] + strlen(dentries[i]) - 7,
							".ebuild") != 0)
				{
					free(dentries[i]);
					continue;
				}
				write_hashes(tv, dir, dentries[i], "EBUILD", m, NULL);
				free(dentries[i]);
			}
			free(dentries);
		}

		write_hashes(tv, dir, "ChangeLog", "MISC", m, NULL);
		write_hashes(tv, dir, "metadata.xml", "MISC", m, NULL);

		fflush(m);
		fclose(m);

		snprintf(path, sizeof(path), "%s/%s", dir, str_manifest);
		rename(newmanifest, path);

		if (tv[0].tv_sec != 0) {
			/* set Manifest and dir mtime to most recent file we found */
			utimes(path, tv);
			utimes(dir, tv);
		}

		return str_manifest;
	} else {
		return NULL;
	}
}

static char *
process_dir_gen(const char *dir)
{
	char path[8192];
	int newhashes;

	snprintf(path, sizeof(path), "%s/metadata/layout.conf", dir);
	if ((newhashes = parse_layout_conf(path)) != 0) {
		hashes = newhashes;
	} else {
		return "generation must be done on a full tree";
	}

	if (chdir(dir) != 0) {
		fprintf(stderr, "cannot chdir() to %s: %s\n", dir, strerror(errno));
		return "not a directory";
	}

	if (generate_dir(".\0", GLOBAL_MANIFEST) == NULL)
		return "generation failed";

	return NULL;
}

static char
verify_gpg_sig(const char *path)
{
	gpgme_ctx_t g_ctx;
	gpgme_data_t manifest;
	gpgme_data_t out;
	gpgme_verify_result_t vres;
	gpgme_signature_t sig;
	gpgme_key_t key;
	char buf[32];
	FILE *f;
	struct tm *ctime;
	char ret = 1;  /* fail */

	if ((f = fopen(path, "r")) == NULL) {
		fprintf(stderr, "failed to open %s: %s\n", path, strerror(errno));
		return ret;
	}

	if (gpgme_new(&g_ctx) != GPG_ERR_NO_ERROR) {
		fprintf(stderr, "failed to create gpgme context\n");
		return ret;
	}

	if (gpgme_data_new(&out) != GPG_ERR_NO_ERROR) {
		fprintf(stderr, "failed to create new gpgme data\n");
		return ret;
	}

	if (gpgme_data_new_from_stream(&manifest, f) != GPG_ERR_NO_ERROR) {
		fprintf(stderr, "failed to create new gpgme data from stream\n");
		return ret;
	}

	if (gpgme_op_verify(g_ctx, manifest, NULL, out) != GPG_ERR_NO_ERROR) {
		fprintf(stderr, "failed to verify signature\n");
		return ret;
	}

	vres = gpgme_op_verify_result(g_ctx);
	fclose(f);

	if (vres == NULL || vres->signatures == NULL) {
		fprintf(stderr, "verification failed due to a missing gpg keyring\n");
		return ret;
	}

	for (sig = vres->signatures; sig != NULL; sig = sig->next) {
		if (sig->status != GPG_ERR_NO_PUBKEY) {
			ctime = gmtime((time_t *)&sig->timestamp);
			strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S UTC", ctime);
			printf("%s key fingerprint "
					"%.4s %.4s %.4s %.4s %.4s  %.4s %.4s %.4s %.4s %.4s\n"
					"%s signature made %s by\n",
					gpgme_pubkey_algo_name(sig->pubkey_algo),
					sig->fpr +  0, sig->fpr +  4, sig->fpr +  8, sig->fpr + 12,
					sig->fpr + 16, sig->fpr + 20, sig->fpr + 24, sig->fpr + 28,
					sig->fpr + 32, sig->fpr + 36,
					sig->status == GPG_ERR_NO_ERROR ? "good" : "BAD",
					buf);

			if (gpgme_get_key(g_ctx, sig->fpr, &key, 0) == GPG_ERR_NO_ERROR) {
				ret = 0;  /* valid */
				if (key->uids != NULL)
					printf("%s\n", key->uids->uid);
				gpgme_key_release(key);
			}
		}

		switch (sig->status) {
			case GPG_ERR_NO_ERROR:
				/* nothing, handled above */
				break;
			case GPG_ERR_SIG_EXPIRED:
				printf("the signature is valid but expired\n");
				break;
			case GPG_ERR_KEY_EXPIRED:
				printf("the signature is valid but the key used to verify "
						"the signature has expired\n");
				break;
			case GPG_ERR_CERT_REVOKED:
				printf("the signature is valid but the key used to verify "
						"the signature has been revoked\n");
				break;
			case GPG_ERR_BAD_SIGNATURE:
				printf("the signature is invalid\n");
				break;
			case GPG_ERR_NO_PUBKEY:
				printf("the signature could not be verified due to a "
						"missing key\n");
				break;
			default:
				printf("there was some other error which prevented the "
						"signature verification\n");
				break;
		}
	}

	gpgme_release(g_ctx);

	return ret;
}

static size_t checked_manifests = 0;
static size_t checked_files = 0;
static size_t failed_files = 0;

static char
verify_file(const char *dir, char *mfline, const char *mfest)
{
	char *path;
	char *size;
	long long int fsize;
	char *hashtype;
	char *hash;
	char *p;
	char buf[8192];
	size_t flen = 0;
	char sha256[(SHA256_DIGEST_LENGTH * 2) + 1];
	char sha512[(SHA512_DIGEST_LENGTH * 2) + 1];
	char whrlpl[(WHIRLPOOL_DIGEST_LENGTH * 2) + 1];
	char blak2b[(BLAKE2B_OUTBYTES * 2) + 1];
	char ret = 0;

	/* mfline is a Manifest file line with type and leading path
	 * stripped, something like:
	 * file <SIZE> <HASHTYPE HASH ...>
	 * we parse this, and verify the size and hashes */

	path = mfline;
	p = strchr(path, ' ');
	if (p == NULL) {
		fprintf(stderr, "%s: corrupt manifest line: %s\n", mfest, path);
		return 1;
	}
	*p++ = '\0';

	size = p;
	p = strchr(size, ' ');
	if (p == NULL) {
		fprintf(stderr, "%s: corrupt manifest line, need size for %s\n",
				mfest, path);
		return 1;
	}
	*p++ = '\0';
	fsize = strtoll(size, NULL, 10);
	if (fsize == 0 && errno == EINVAL) {
		fprintf(stderr, "%s: corrupt manifest line, size is not a number: %s\n",
				dir + 2, size);
		return 1;
	}

	sha256[0] = sha512[0] = whrlpl[0] = blak2b[0] = '\0';
	snprintf(buf, sizeof(buf), "%s/%s", dir, path);
	get_hashes(buf, sha256, sha512, whrlpl, blak2b, &flen);

	if (flen == 0) {
		fprintf(stderr, "cannot locate %s/%s\n", dir + 2, path);
		return 1;
	}

	checked_files++;

	if (flen != fsize) {
		printf("%s:%s:\n- file size mismatch\n"
				"       got: %zd\n"
				"  expected: %lld\n",
				mfest, path, flen, fsize);
		failed_files++;
		return 1;
	}

	/* now we are in free territory, we read TYPE HASH pairs until we
	 * drained the string, and match them against what we computed */
	while (p != NULL && *p != '\0') {
		hashtype = p;
		p = strchr(hashtype, ' ');
		if (p == NULL) {
			fprintf(stderr, "%s: corrupt manifest line, missing hash type\n",
					mfest);
			return 1;
		}
		*p++ = '\0';

		hash = p;
		p = strchr(hash, ' ');
		if (p != NULL)
			*p++ = '\0';

#define idif(X) if (X == 0) printf("%s:%s:\n", mfest, path);
		if (strcmp(hashtype, "SHA256") == 0) {
			if (!(hashes & HASH_SHA256)) {
				idif(ret);
				printf("- warning: hash SHA256 ignored as "
						"it is not enabled for this repository\n");
			} else if (strcmp(hash, sha256) != 0) {
				idif(ret);
				printf("- SHA256 hash mismatch\n"
						"              computed: '%s'\n"
						"  recorded in manifest: '%s'\n",
						sha256, hash);
				ret = 1;
			}
			sha256[0] = '\0';
		} else if (strcmp(hashtype, "SHA512") == 0) {
			if (!(hashes & HASH_SHA512)) {
				idif(ret);
				printf("- warning: hash SHA512 ignored as "
						"it is not enabled for this repository\n");
			} else if (strcmp(hash, sha512) != 0) {
				idif(ret);
				printf("- SHA512 hash mismatch\n"
						"              computed: '%s'\n"
						"  recorded in manifest: '%s'\n",
						sha512, hash);
				ret = 1;
			}
			sha512[0] = '\0';
		} else if (strcmp(hashtype, "WHIRLPOOL") == 0) {
			if (!(hashes & HASH_WHIRLPOOL)) {
				idif(ret);
				printf("- warning: hash WHIRLPOOL ignored as "
						"it is not enabled for this repository\n");
			} else if (strcmp(hash, whrlpl) != 0) {
				idif(ret);
				printf("- WHIRLPOOL hash mismatch\n"
						"              computed: '%s'\n"
						"  recorded in manifest: '%s'\n",
						whrlpl, hash);
				ret = 1;
			}
			whrlpl[0] = '\0';
		} else if (strcmp(hashtype, "BLAKE2B") == 0) {
			if (!(hashes & HASH_BLAKE2B)) {
				idif(ret);
				printf("- warning: hash BLAKE2B ignored as "
						"it is not enabled for this repository\n");
			} else if (strcmp(hash, blak2b) != 0) {
				idif(ret);
				printf("- BLAKE2B hash mismatch\n"
						"              computed: '%s'\n"
						"  recorded in manifest: '%s'\n",
						blak2b, hash);
				ret = 1;
			}
			blak2b[0] = '\0';
		} else {
			idif(ret);
			printf("- unsupported hash: %s\n", hashtype);
			ret = 1;
		}
	}

	if (sha256[0] != '\0') {
		idif(ret);
		printf("- missing hash: SHA256\n");
		ret = 1;
	}
	if (sha512[0] != '\0') {
		idif(ret);
		printf("- missing hash: SHA512\n");
		ret = 1;
	}
	if (whrlpl[0] != '\0') {
		idif(ret);
		printf("- missing hash: WHIRLPOOL\n");
		ret = 1;
	}
	if (blak2b[0] != '\0') {
		idif(ret);
		printf("- missing hash: BLAKE2B\n");
		ret = 1;
	}

	failed_files += ret;
	return ret;
}

static int
compare_elems(const void *l, const void *r)
{
	const char *strl = *((const char **)l) + 2;
	const char *strr = *((const char **)r) + 2;
	unsigned char cl;
	unsigned char cr;
	/* compare treating / as end of string */
	while ((cl = *strl++) == (cr = *strr++))
		if (cl == '\0')
			return 0;
	if (cl == '/')
		cl = '\0';
	if (cr == '/')
		cr = '\0';
	return cl - cr;
}

struct subdir_workload {
	size_t subdirlen;
	size_t elemslen;
	char **elems;
};

static char verify_manifest(const char *dir, const char *manifest);

static char
verify_dir(
		const char *dir,
		char **elems,
		size_t elemslen,
		size_t skippath,
		const char *mfest)
{
	char **dentries = NULL;
	size_t dentrieslen = 0;
	size_t curelem = 0;
	size_t curdentry = 0;
	char *entry;
	char *slash;
	char etpe;
	char ret = 0;
	int cmp;
	struct subdir_workload **subdir = NULL;
	size_t subdirsize = 0;
	size_t subdirlen = 0;

	/* shortcut a single Manifest entry pointing to the same dir
	 * (happens at top-level) */
	if (elemslen == 1 && skippath == 0 &&
			**elems == 'M' && strchr(*elems + 2, '/') == NULL)
	{
		if ((ret = verify_file(dir, *elems + 2, mfest)) == 0) {
			slash = strchr(*elems + 2, ' ');
			if (slash != NULL)
				*slash = '\0';
			/* else, verify_manifest will fail, so ret will be handled */
			ret = verify_manifest(dir, *elems + 2);
		}
		return ret;
	}

	/*
	 * We have a list of entries from the manifest just read, now we
	 * need to match these onto the directory layout.  From what we got
	 * - we can ignore TIMESTAMP and DIST entries
	 * - IGNOREs need to be handled separate (shortcut)
	 * - MANIFESTs need to be handled on their own, for memory
	 *   consumption reasons, we defer them to until we've verified
	 *   what's left, we treat the path the Manifest refers to as IGNORE
	 * - DATAs, EBUILDs and MISCs needs verifying
	 * - AUXs need verifying, but in files/ subdir
	 * If we sort both lists, we should be able to do a merge-join, to
	 * easily flag missing entries in either list without hashing or
	 * anything.
	 */
	if (list_dir(&dentries, &dentrieslen, dir) == 0) {
		while (curdentry < dentrieslen) {
			if (strcmp(dentries[curdentry], str_manifest) == 0 ||
					strcmp(dentries[curdentry], str_manifest_gz) == 0 ||
					strcmp(dentries[curdentry], str_manifest_files_gz) == 0)
			{
				curdentry++;
				continue;
			}

			if (curelem < elemslen) {
				entry = elems[curelem] + 2 + skippath;
				etpe = *elems[curelem];
			} else {
				entry = "";
				etpe = 'I';
			}

			/* handle subdirs first */
			if ((slash = strchr(entry, '/')) != NULL) {
				size_t sublen = slash - entry;
				int elemstart = curelem;
				char **subelems = &elems[curelem];

				/* collect all entries like this one (same subdir) into
				 * a sub-list that we can verify */
				curelem++;
				while (curelem < elemslen &&
						strncmp(entry, elems[curelem] + 2 + skippath,
							sublen + 1) == 0)
					curelem++;

				if (subdirlen == subdirsize) {
					subdirsize += LISTSZ;
					subdir = realloc(subdir,
							subdirsize * sizeof(subdir[0]));
					if (subdir == NULL) {
						fprintf(stderr, "out of memory\n");
						return 1;
					}
				}
				subdir[subdirlen] = malloc(sizeof(struct subdir_workload));
				if (subdir[subdirlen] == NULL) {
					fprintf(stderr, "out of memory\n");
					return 1;
				}
				subdir[subdirlen]->subdirlen = sublen;
				subdir[subdirlen]->elemslen = curelem - elemstart;
				subdir[subdirlen]->elems = subelems;
				subdirlen++;

				curelem--; /* move back, see below */

				/* modify the last entry to be the subdir, such that we
				 * can let the code below synchronise with dentries */
				elems[curelem][2 + skippath + sublen] = ' ';
				entry = elems[curelem] + 2 + skippath;
				etpe = 'S';  /* flag this was a subdir */
			}

			/* does this entry exist in list? */
			if (*entry == '\0') {
				/* end of list reached, force dir to catch up */
				cmp = 1;
			} else {
				slash = strchr(entry, ' ');
				if (slash != NULL)
					*slash = '\0';
				cmp = strcmp(entry, dentries[curdentry]);
				if (slash != NULL)
					*slash = ' ';
			}
			if (cmp == 0) {
				/* equal, so yay */
				if (etpe == 'D') {
					ret |= verify_file(dir, entry, mfest);
				}
				/* else this is I(GNORE) or S(ubdir), which means it is
				 * ok in any way (M shouldn't happen) */
				curelem++;
				curdentry++;
			} else if (cmp < 0) {
				/* entry is missing from dir */
				if (etpe == 'I') {
					/* right, we can ignore this */
				} else {
					ret |= 1;
					slash = strchr(entry, ' ');
					if (slash != NULL)
						*slash = '\0';
					printf("%s:%s:\n- %s file not found\n",
							mfest, entry, etpe == 'M' ? "MANIFEST" : "DATA");
					if (slash != NULL)
						*slash = ' ';
					failed_files++;
				}
				curelem++;
			} else if (cmp > 0) {
				/* dir has extra element */
				ret |= 1;
				printf("%s:\n- found excess file: %s\n",
						mfest, dentries[curdentry]);
				curdentry++;
				failed_files++;
			}
		}

		while (dentrieslen-- > 0)
			free(dentries[dentrieslen]);
		free(dentries);

#pragma omp parallel for shared(ret) private(entry, etpe, slash)
		for (cmp = 0; cmp < subdirlen; cmp++) {
			char ndir[8192];

			entry = subdir[cmp]->elems[0] + 2 + skippath;
			etpe = subdir[cmp]->elems[0][0];

			/* restore original entry format */
			subdir[cmp]->elems[subdir[cmp]->elemslen - 1]
				[2 + skippath + subdir[cmp]->subdirlen] = '/';

			if (etpe == 'M') {
				size_t skiplen = strlen(dir) + 1 + subdir[cmp]->subdirlen;
				/* sub-Manifest, we need to do a proper recurse */
				slash = strrchr(entry, '/');  /* cannot be NULL */
				snprintf(ndir, sizeof(ndir), "%s/%s", dir, entry);
				ndir[skiplen] = '\0';
				slash = strchr(ndir + skiplen + 1, ' ');
				if (slash != NULL)  /* path should fit in ndir ... */
					*slash = '\0';
				if (verify_file(dir, entry, mfest) != 0 ||
						verify_manifest(ndir, ndir + skiplen + 1) != 0)
					ret |= 1;
			} else {
				snprintf(ndir, sizeof(ndir), "%s/%.*s", dir,
						(int)subdir[cmp]->subdirlen, entry);
				ret |= verify_dir(ndir, subdir[cmp]->elems,
						subdir[cmp]->elemslen,
						skippath + subdir[cmp]->subdirlen + 1, mfest);
			}

			free(subdir[cmp]);
		}

		if (subdir)
			free(subdir);

		return ret;
	} else {
		return 1;
	}
}

static char
verify_manifest(const char *dir, const char *manifest)
{
	char buf[8192];
	FILE *f;
	gzFile mf;
	char ret = 0;

	size_t elemssize = 0;
	size_t elemslen = 0;
	char **elems = NULL;
#define append_list(STR) \
	if (strncmp(STR, "TIMESTAMP ", 10) != 0 || strncmp(STR, "DIST ", 5) != 0) {\
		char *endp = STR + strlen(STR) - 1;\
		while (isspace(*endp))\
			*endp-- = '\0';\
		if (elemslen == elemssize) {\
			elemssize += LISTSZ;\
			elems = realloc(elems, elemssize * sizeof(elems[0]));\
			if (elems == NULL) {\
				fprintf(stderr, "out of memory\n");\
				return 1;\
			}\
		}\
		if (strncmp(STR, "IGNORE ", 7) == 0) {\
			STR[5] = 'I';\
			elems[elemslen] = strdup(STR + 5);\
			if (elems[elemslen] == NULL) {\
				fprintf(stderr, "out of memory\n");\
				return 1;\
			}\
			elemslen++;\
		} else if (strncmp(STR, "MANIFEST ", 9) == 0) {\
			STR[7] = 'M';\
			elems[elemslen] = strdup(STR + 7);\
			if (elems[elemslen] == NULL) {\
				fprintf(stderr, "out of memory\n");\
				return 1;\
			}\
			elemslen++;\
		} else if (strncmp(STR, "DATA ", 5) == 0 ||\
				strncmp(STR, "MISC ", 5) == 0 ||\
				strncmp(STR, "EBUILD ", 7) == 0)\
		{\
			if (*STR == 'E') {\
				STR[5] = 'D';\
				elems[elemslen] = strdup(STR + 5);\
			} else {\
				STR[3] = 'D';\
				elems[elemslen] = strdup(STR + 3);\
			}\
			if (elems[elemslen] == NULL) {\
				fprintf(stderr, "out of memory\n");\
				return 1;\
			}\
			elemslen++;\
		} else if (strncmp(STR, "AUX ", 4) == 0) {\
			/* translate directly into what it is: DATA in files/ */\
			size_t slen = strlen(STR + 2) + sizeof("files/");\
			elems[elemslen] = malloc(slen);\
			if (elems[elemslen] == NULL) {\
				fprintf(stderr, "out of memory\n");\
				return 1;\
			}\
			snprintf(elems[elemslen], slen, "D files/%s", STR + 4);\
			elemslen++;\
		}\
	}

	snprintf(buf, sizeof(buf), "%s/%s", dir, manifest);
	if (strcmp(manifest, str_manifest) == 0) {
		if ((f = fopen(buf, "r")) == NULL) {
			fprintf(stderr, "failed to open %s: %s\n",
					buf, strerror(errno));
			return 1;
		}
		while (fgets(buf, sizeof(buf), f) != NULL) {
			append_list(buf);
		}
		fclose(f);
	} else if (strcmp(manifest, str_manifest_files_gz) == 0 ||
			strcmp(manifest, str_manifest_gz) == 0)
	{
		if ((mf = gzopen(buf, "rb9")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for reading: %s\n",
					buf, strerror(errno));
			return 1;
		}
		while (gzgets(mf, buf, sizeof(buf)) != NULL) {
			append_list(buf);
		}
		gzclose(mf);
	}

	/* The idea:
	 * - Manifest without MANIFEST entries, we need to scan the entire
	 *   subtree
	 * - Manifest with MANIFEST entries, assume they are just one level
	 *   deeper, thus ignore that subdir, further like above
	 * - Manifest at top-level, needs to be igored as it only points to
	 *   the larger Manifest.files.gz
	 */
	qsort(elems, elemslen, sizeof(elems[0]), compare_elems);
	snprintf(buf, sizeof(buf), "%s/%s", dir, manifest);
	ret = verify_dir(dir, elems, elemslen, 0, buf + 2);
	checked_manifests++;

	while (elemslen-- > 0)
		free(elems[elemslen]);
	free(elems);

	return ret;
}

static char *
process_dir_vrfy(const char *dir)
{
	char buf[8192];
	int newhashes;
	char *ret = NULL;
	struct timeval startt;
	struct timeval finisht;
	double etime;

	gettimeofday(&startt, NULL);

	fprintf(stdout, "verifying %s...\n", dir);
	snprintf(buf, sizeof(buf), "%s/metadata/layout.conf", dir);
	if ((newhashes = parse_layout_conf(buf)) != 0) {
		hashes = newhashes;
	} else {
		return "verification must be done on a full tree";
	}

	if (chdir(dir) != 0) {
		fprintf(stderr, "cannot chdir() to %s: %s\n", dir, strerror(errno));
		return "not a directory";
	}

	if (verify_gpg_sig(str_manifest) != 0)
		ret = "gpg signature invalid";

	/* verification goes like this:
	 * - verify the signature of the top-level Manifest file (done
	 *   above)
	 * - read the contents of the Manifest file, and process the
	 *   entries - verify them, check there are no files which shouldn't
	 *   be there
	 * - recurse into directories for which Manifest files are defined
	 */
	if (verify_manifest(".\0", str_manifest) != 0)
		ret = "manifest verification failed";

	gettimeofday(&finisht, NULL);

	etime = ((double)((finisht.tv_sec - startt.tv_sec) * 1000000 +
				finisht.tv_usec) - (double)startt.tv_usec) / 1000000.0;
	printf("checked %zd Manifests, %zd files, %zd failures in %.02fs\n",
			checked_manifests, checked_files, failed_files, etime);
	return ret;
}

int
main(int argc, char *argv[])
{
	char *prog;
	char *(*runfunc)(const char *);
	int arg = 1;
	int ret = 0;
	char *rsn;

	if ((prog = strrchr(argv[0], '/')) == NULL) {
		prog = argv[0];
	} else {
		prog++;
	}

	if (argc > 1) {
		if (strcmp(argv[1], "hashverify") == 0 ||
				strcmp(argv[1], "hashgen") == 0)
		{
			prog = argv[1];
			arg = 2;
		}
	}

	if (strcmp(prog, "hashverify") == 0) {
		runfunc = &process_dir_vrfy;
	} else {
		/* default mode: hashgen */
		runfunc = &process_dir_gen;
	}

	gpgme_check_version(NULL);

	if (argc > 1) {
		for (; arg < argc; arg++) {
			rsn = runfunc(argv[arg]);
			if (rsn != NULL) {
				printf("%s\n", rsn);
				ret |= 1;
			}
		}
	} else {
		rsn = runfunc(".");
		if (rsn != NULL) {
			printf("%s\n", rsn);
			ret |= 1;
		}
	}

	return ret;
}
