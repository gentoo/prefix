/* Copyright 2006-2015 Gentoo Foundation; Distributed under the GPL v2 */
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <openssl/sha.h>
#include <openssl/whrlpool.h>

/* Generate thick Manifests based on thin Manifests */
/* gcc -o hashgen -fopenmp -Wall -Werror -O3 -pipe -lssl -lcrypto hashgen.c */

static inline void
hex_hash(char *out, const unsigned char *buf, const int length)
{
	int i;
	for (i = 0; i < length; i++) {
		snprintf(&out[i * 2], 3, "%02x", buf[i]);
	}
}

static void
write_hashes(const char *root, const char *name, const char *type, FILE *m)
{
	FILE *f;
	char fname[8096];
	size_t flen = 0;
	char sha256[(SHA256_DIGEST_LENGTH * 2) + 1];
	char sha512[(SHA512_DIGEST_LENGTH * 2) + 1];
	char whrlpl[(WHIRLPOOL_DIGEST_LENGTH * 2) + 1];
	char data[8096];
	size_t len;
	SHA256_CTX s256;
	SHA512_CTX s512;
	WHIRLPOOL_CTX whrl;

	snprintf(fname, sizeof(fname), "%s/%s", root, name);
	if ((f = fopen(fname, "r")) == NULL)
		return;

	SHA256_Init(&s256);
	SHA512_Init(&s512);
	WHIRLPOOL_Init(&whrl);

	while ((len = fread(data, 1, sizeof(data), f)) > 0) {
		flen += len;
#pragma omp parallel sections
		{
#pragma omp section
			{
				SHA256_Update(&s256, data, len);
			}
#pragma omp section
			{
				SHA512_Update(&s512, data, len);
			}
#pragma omp section
			{
				WHIRLPOOL_Update(&whrl, data, len);
			}
		}
	}

#pragma omp parallel sections
	{
		{
			unsigned char sha256buf[SHA256_DIGEST_LENGTH];
			SHA256_Final(sha256buf, &s256);
			hex_hash(sha256, sha256buf, SHA256_DIGEST_LENGTH);
		}
#pragma omp section
		{
			unsigned char sha512buf[SHA512_DIGEST_LENGTH];
			SHA512_Final(sha512buf, &s512);
			hex_hash(sha512, sha512buf, SHA512_DIGEST_LENGTH);
		}
#pragma omp section
		{
			unsigned char whrlplbuf[WHIRLPOOL_DIGEST_LENGTH];
			WHIRLPOOL_Final(whrlplbuf, &whrl);
			hex_hash(whrlpl, whrlplbuf, WHIRLPOOL_DIGEST_LENGTH);
		}
	}
	fclose(f);

	fprintf(m, "%s %s %zd SHA256 %s SHA512 %s WHIRLPOOL %s\n",
			type, name, flen, sha256, sha512, whrlpl);
}

static char
process_files(const char *dir, const char *off, FILE *m)
{
	char path[8096];
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
			write_hashes(dir, path, "AUX", m);
		}
		closedir(d);
		return 1;
	} else {
		return 0;
	}
}

static void
process_dir(const char *dir)
{
	char manifest[8096];
	FILE *f;
	DIR *d;
	struct dirent *e;
	char path[8096];

	snprintf(manifest, sizeof(manifest), "%s/Manifest", dir);
	if ((f = fopen(manifest, "r")) == NULL) {
		/* recurse into subdirs */
		if ((d = opendir(dir)) != NULL) {
			struct stat s;
			while ((e = readdir(d)) != NULL) {
				if (e->d_name[0] == '.')
					continue;
				snprintf(path, sizeof(path), "%s/%s", dir, e->d_name);
				if (!stat(path, &s) && s.st_mode & S_IFDIR)
					process_dir(path);
			}
			closedir(d);
		}
	} else {
		/* this looks like an ebuild dir, so update the Manifest */
		FILE *m;
		char newmanifest[8096];
		char buf[8096];
		struct stat s;
		struct timeval tv[2];

		/* set mtime of Manifest to the one of the parent dir, this way
		 * we enure the Manifest gets mtime bumped upon any change made
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

		snprintf(newmanifest, sizeof(newmanifest), "%s/.Manifest.new", dir);
		if ((m = fopen(newmanifest, "w")) == NULL) {
			fprintf(stderr, "failed to open file '%s' for writing: %s\n",
					newmanifest, strerror(errno));
			return;
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
					return;
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
				write_hashes(dir, e->d_name, "EBUILD", m);
			}
			closedir(d);
		}

		write_hashes(dir, "ChangeLog", "MISC", m);
		write_hashes(dir, "metadata.xml", "MISC", m);

		fflush(m);
		fclose(m);

		rename(newmanifest, manifest);
		if (tv[0].tv_sec != 0) {
			/* restore dir mtime, and set Manifest mtime to match it */
			utimes(manifest, tv);
			utimes(dir, tv);
		}
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
