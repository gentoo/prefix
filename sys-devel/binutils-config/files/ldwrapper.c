/*
 * Copyright 1999-2013 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Fabian Groffen <grobian@gentoo.org>
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <strings.h>
#include <string.h>
#include <ctype.h>
#include <sys/stat.h>
#include <errno.h>

/**
 * ldwrapper: Prefix helper to inject -L and -R flags to the invocation
 * of ld.
 *
 * On Darwin it adds -search_path_first to make sure the given paths are
 * searched before the default search path.
 * The wrapper will inject -L entries for:
 *   - EPREFIX/usr/CHOST/lib/gcc (when gcc)
 *   - EPREFIX/usr/CHOST/lib     (when binutils)
 *   - EPREFIX/usr/lib
 *   - EPREFIX/lib 
 * On ELF platforms, the wrapper will then add -R (-rpath) entries for
 * all -L entries found in the invocation to ensure the libraries found
 * at link time will be found at runtime too.
 */

#ifndef EPREFIX
# error EPREFIX must be defined!
#endif
#ifndef CHOST
# error CHOST must be defined!
#endif


static inline void
find_real_ld(char **ld, char verbose, char *wrapper)
{
	FILE *f = NULL;
	char *ldoveride;
	char *path;
#define ESIZ 1024
	char *e;
	struct stat lde;

	/* we may not succeed finding the linker */
	*ld = NULL;

	/* respect the override in environment */
	ldoveride = getenv("BINUTILS_CONFIG_LD");
	if (ldoveride != NULL && *ldoveride != '\0') {
		if (verbose)
			fprintf(stdout, "%s: using BINUTILS_CONFIG_LD=%s "
					"from environment\n", wrapper, ldoveride);
		*ld = ldoveride;
		return;
	}
	if (verbose)
		fprintf(stdout, "%s: BINUTILS_CONFIG_LD not found in environment\n",
				wrapper);
	
	if ((e = malloc(sizeof(char) * ESIZ)) == NULL) {
		fprintf(stderr, "%s: out of memory allocating string for path to ld\n",
				wrapper);
		exit(1);
	}

	/* find ld in PATH, allowing easy PATH overrides */
	path = getenv("PATH");
	while (path > (char*)1 && *path != '\0') {
		char *q = strchr(path, ':');
		if (q)
			*q = '\0';
		if (strstr(path, "/" CHOST "/binutils-bin/") != NULL) {
			snprintf(e, ESIZ, "%s/%s", path, wrapper);
			if (stat(e, &lde) == 0)
				*ld = e;
		}
		if (q)
			*q = ':'; /* restore PATH value */
		if (*ld)
			return;
		path = q + 1;
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found in PATH\n", wrapper);

	/* parse EPREFIX/etc/env.d/binutils/config-CHOST to get CURRENT, then
	 * consider $EPREFIX/usr/CHOST/binutils-bin/CURRENT where we should
	 * be able to find ld */
	*e = '\0';
	if ((f = fopen(EPREFIX "/etc/env.d/binutils/config-" CHOST, "r")) != NULL) {
		char p[ESIZ];
		while (fgets(p, ESIZ, f) != NULL) {
			if (strncmp(p, "CURRENT=", strlen("CURRENT=")) == 0) {
				char *q = p + strlen(p);
				/* strip trailing whitespace (fgets at least includes
				 * the \n) */
				for (q--; isspace(*q); q--)
					*q = '\0';
					;
				snprintf(e, ESIZ, EPREFIX "/usr/" CHOST "/binutils-bin/%s/%s",
						p + strlen("CURRENT="), wrapper);
				break;
			}
		}
		fclose(f);
		if (stat(e, &lde) == 0) {
			*ld = e;
			return;
		}
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found via " EPREFIX
				"/etc/env.d/binutils/config-" CHOST " (ld=%s)\n",
				wrapper, e);
	
	/* last try, call binutils-config to tell us what the linker is
	 * supposed to be */
	*e = '\0';
	if ((f = popen("binutils-config -c", "r")) != NULL) {
		char p[ESIZ];
		char *q;
		if (fgets(p, ESIZ, f) != NULL) {
			q = p;
			if (strncmp(q, CHOST "-", strlen(CHOST "-")) == 0)
				q += strlen(CHOST "-");
			snprintf(e, ESIZ, EPREFIX "/usr/" CHOST "/binutils-bin/%s/%s",
					q, wrapper);
		} else {
			*p = '\0';
		}
		fclose(f);
		if (*p && stat(e, &lde) == 0) {
			*ld = e;
			return;
		}
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found via binutils-config -c (ld=%s)\n",
				wrapper, e);
}

int
main(int argc, char *argv[])
{
	char *ld = NULL;
	int newargc = 0;
	char **newargv = NULL;
	char *wrapper = argc > 0 ? argv[0] : "ld-wrapper";
	char verbose = getenv("BINUTILS_CONFIG_VERBOSE") != NULL;
	char *p;
	int i;
	int j;
	int k;

	/* cannonicanise wrapper, stripping path and CHOST */
	if ((p = strrchr(wrapper, '/')) != NULL)
		wrapper = p + 1;
	p = CHOST "-";
	if (strncmp(wrapper, p, strlen(p)) == 0)
		wrapper += strlen(p);

	/* walk over the arguments to see if there's anything interesting
	 * for us and calculate the final number of arguments */
	for (i = 1; i < argc; i++) {
		/* -L: account space for the matching -R */
		if (argv[i][0] == '-') {
			if (argv[i][1] == 'L')
				newargc++;
			if (argv[i][1] == 'v' || argv[i][1] == 'V')
				verbose = 1;
		}
	}
	/* account the original arguments */
	newargc += argc > 0 ? argc : 1;
#ifdef TARGET_DARWIN
	/* add the 2 prefix paths (-L), -search_paths_first and a
	 * null-terminator */
	newargc += 2 + 1 + 1;
#else
	/* add the 4 paths we want (-L + -R) and a null-terminator */
	newargc += 8 + 1;
#endif

	/* let's first try to find the real ld */
	find_real_ld(&ld, verbose, wrapper);
	if (ld == NULL) {
		fprintf(stderr, "%s: failed to locate the real ld!\n", wrapper);
		exit(1);
	}

	newargv = malloc(sizeof(char *) * newargc);
	if (newargv == NULL) {
		fprintf(stderr, "%s: failed to allocate memory for new arguments\n",
				wrapper);
		exit(1);
	}

	/* construct the new argv */
	j = 0;
	if ((p = strrchr(ld, '/')) != NULL) {
		newargv[j++] = p + 1;
	} else {
		newargv[j++] = ld;
	}
#ifdef TARGET_DARWIN
	/* inject this first to make the intention clear */
	newargv[j++] = "-search_paths_first";
#endif
	/* position k right after the original arguments */
	k = j - 1 + argc;
	for (i = 1; i < argc; i++, j++) {
		newargv[j] = argv[i];
#ifndef TARGET_DARWIN
		/* on ELF targets we add runpaths for all found search paths */
		if (argv[i][0] == '-' && argv[i][1] == 'L') {
			char *path;
			size_t len;

			/* arguments can be in many ways here:
			 * -L<path>
			 * -L <path> (yes, this is accepted)
			 * -L(whitespace)? <path in next argument>
			 * where path is absolute (not relative) */
			path = &argv[i][2];
			while (*path != '\0' && isspace(*path))
				path++;
			if (*path == '\0') {
				/* no more arguments?!? skip */
				if (i + 1 >= argc)
					continue;
				path = argv[i + 1];
				while (*path != '\0' && isspace(*path))
					path++;
			}
			/* not absolute (or empty)?!? skip */
			if (*path != '/')
				continue;

			len = 2 + strlen(path) + 1;
			newargv[k] = malloc(sizeof(char) * len);
			if (newargv[k] == NULL) {
				fprintf(stderr, "%s: failed to allocate memory for "
						"'%s' -R argument\n", wrapper, argv[i]);
				exit(1);
			}
			snprintf(newargv[k], len, "-R%s", path);
			k++;
		}
#endif
	}
	/* add the custom paths */
#ifdef TARGET_DARWIN
	newargv[k++] = "-L" EPREFIX "/usr/lib";
	newargv[k++] = "-L" EPREFIX "/lib";
#else
	newargv[k++] = "-L" EPREFIX "/usr/" CHOST "/lib/gcc";
	newargv[k++] = "-R" EPREFIX "/usr/" CHOST "/lib/gcc";
	newargv[k++] = "-L" EPREFIX "/usr/" CHOST "/lib";
	newargv[k++] = "-R" EPREFIX "/usr/" CHOST "/lib";
	newargv[k++] = "-L" EPREFIX "/usr/lib";
	newargv[k++] = "-R" EPREFIX "/usr/lib";
	newargv[k++] = "-L" EPREFIX "/lib";
	newargv[k++] = "-R" EPREFIX "/lib";
#endif
	newargv[k] = NULL;

	if (verbose) {
		fprintf(stdout, "%s: invoking %s with arguments:\n", wrapper, ld);
		for (j = 0; newargv[j] != NULL; j++)
			fprintf(stdout, "  %s\n", newargv[j]);
	}

	/* finally, execute the real ld */
	execv(ld, newargv);
	fprintf(stderr, "%s: failed to execute %s: %s\n",
			wrapper, ld, strerror(errno));
	exit(1);
}
