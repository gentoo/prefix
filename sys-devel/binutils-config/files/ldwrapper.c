/*
 * Copyright 1999-2019 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Authors: Fabian Groffen <grobian@gentoo.org>
 *          Michael Haubenwallner <haubi@gentoo.org>
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <strings.h>
#include <string.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <dirent.h>

/**
 * ldwrapper: Prefix helper to inject -L and -R flags to the invocation
 * of ld.
 *
 * On Darwin it adds -search_paths_first to make sure the given paths are
 * searched before the default search path, and sets -syslibroot
 * starting from Big Sur 11.0.
 * On AIX it ensures -bsvr4 is the last argument.
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

#define ESIZ 1024  /* POSIX_MAX_PATH */

static inline char
find_real_ld(char **ld, size_t ldlen, const char verbose, const char is_cross,
		const char *wrapper, const char *ctarget)
{
	FILE *f = NULL;
	char *ldoverride;
	char *path;
	char *ret;
	struct stat lde;
	char config[ESIZ];
	size_t len;

	/* respect the override in environment */
	ldoverride = getenv("BINUTILS_CONFIG_LD");
	if (ldoverride != NULL && *ldoverride != '\0') {
		if (verbose)
			fprintf(stderr, "%s: using BINUTILS_CONFIG_LD=%s "
					"from environment\n", wrapper, ldoverride);
		snprintf(*ld, ldlen, "%s", ldoverride);
		return 0;
	}
	if (verbose)
		fprintf(stderr, "%s: BINUTILS_CONFIG_LD not found in environment\n",
				wrapper);

	/* Find ld in PATH, allowing easy PATH overrides.
	 * Remember NOT to modify the from getenv returned string, as we need
	 * an untampered PATH for popen calls later. */
	path = getenv("PATH");
	if (path != NULL && *path != '\0') {
		char *p;
		char *q;
		char match[ESIZ];

		/* construct /CTARGET/binutils-bin/ for matching against PATH */
		snprintf(match, sizeof(match), "/%s/binutils-bin/", ctarget);

		for (; (p = strstr(path, match)) != NULL; path = q) {
			q = p;
			/* find start of PATH component */
			for (; p >= path && *p != ':'; p--)
				;
			p++;
			/* now see to the end */
			for (q += strlen(match); *q != '\0' && *q != ':'; q++)
				;
			if (*q == ':')
				q--;

			/* glue it together */
			snprintf(*ld, ldlen, "%.*s/%s", (int)(q - p), p, wrapper);
			if (verbose)
				fprintf(stderr, "%s: trying from PATH: %s\n",
						wrapper, *ld);
			if (stat(*ld, &lde) == 0)
				return 0;
		}
	}
	if (verbose)
		fprintf(stderr, "%s: linker not found in PATH\n", wrapper);

	/* parse EPREFIX/etc/env.d/binutils/config-CTARGET to get CURRENT, then
	 * consider $EPREFIX/usr/CTARGET/binutils-bin/CURRENT where we should
	 * be able to find ld */
	snprintf(config, sizeof(config), EPREFIX "/etc/env.d/binutils/config-%s",
			ctarget);
	if ((f = fopen(config, "r")) != NULL) {
		char p[ESIZ];
		char *q;
		while (fgets(p, ESIZ, f) != NULL) {
			len = strlen("CURRENT=");
			if (strncmp(p, "CURRENT=", len) != 0)
				continue;

			q = p + strlen(p);
			/* strip trailing whitespace (fgets at least includes the \n) */
			for (q--; isspace(*q); q--)
				*q = '\0';

			q = p + len;
			if (verbose)
				fprintf(stderr, "%s: %s defines CURRENT=%s\n",
						wrapper, config, q);
			if (is_cross) {
				snprintf(*ld, ldlen,
						EPREFIX "/usr/" CHOST "/%s/binutils-bin/%s/%s",
						ctarget, q, wrapper);
			} else {
				snprintf(*ld, ldlen,
						EPREFIX "/usr/" CHOST "/binutils-bin/%s/%s",
						q, wrapper);
			}
			break;
		}
		fclose(f);
		if (verbose)
			fprintf(stderr, "%s: trying from %s: %s\n",
					wrapper, config, *ld);
		if (stat(*ld, &lde) == 0)
			return 0;
	}
	if (verbose)
		fprintf(stderr, "%s: linker not found via %s\n", wrapper, config);

	/* last try, shell out to binutils-config to tell us what the linker
	 * is supposed to be */
	snprintf(config, sizeof(config), "binutils-config -c %s", ctarget);
	if ((f = popen(config, "r")) != NULL) {
		char p[ESIZ];
		char *q = fgets(p, ESIZ, f);
		fclose(f);
		if (q != NULL) {
			len = strlen(ctarget);

			/* binutils-config should report CTARGET-<version> */
			if (strncmp(p, ctarget, len) == 0 &&
					strlen(p) > len && p[len] == '-')
			{
				/* strip trailing whitespace (fgets at least includes
				 * the \n) */
				q = p + strlen(p);
				for (q--; isspace(*q); q--)
					*q = '\0';

				q = p + len + 1;
				if (is_cross) {
					snprintf(*ld, ldlen,
							EPREFIX "/usr/" CHOST "/%s/binutils-bin/%s/%s",
							ctarget, q, wrapper);
				} else {
					snprintf(*ld, ldlen,
							EPREFIX "/usr/" CHOST "/binutils-bin/%s/%s",
							q, wrapper);
				}

				if (verbose)
					fprintf(stderr, "%s: trying from %s: %s\n",
							wrapper, config, *ld);
				if (stat(*ld, &lde) == 0)
					return 0;
			}
		}
	}
	if (verbose)
		fprintf(stderr, "%s: linker not found via %s\n",
				wrapper, config);

	/* we didn't succeed finding the linker */
	return 1;
}

int
main(int argc, char *argv[])
{
	int newargc = 0;
	char **newargv = NULL;
	char *wrapper = argv[0];
	char *wrapperctarget = NULL;
	char verbose = getenv("BINUTILS_CONFIG_VERBOSE") != NULL;
	char *builddir = getenv("PORTAGE_BUILDDIR");
	char ldbuf[ESIZ];
	char *ld = ldbuf;
	char ctarget[128];
	char *darwin_dt = getenv("MACOSX_DEPLOYMENT_TARGET");
	char is_cross = 0;
	char is_darwin = 0;
	char darwin_use_rpath = 1;
	char *p;
	size_t len;
	int i;
	int j;
	int k;
	DIR *dirp;
	struct dirent *dp;

	/* two ways to determine CTARGET from argv[0]:
	 * 1. called as <CTARGET>-ld (manually)
	 * 2. called as EPREFIX/usr/libexec/gcc/<CTARGET>/ld (by gcc's collect2)
	 *
	 * TODO: Make argv[0] absolute without resolving symlinks so no. 2 can
	 * work when added to PATH (which shouldn't happen in the wild, but
	 * eh!?). */
	if ((p = strrchr(wrapper, '/')) != NULL) {
		char *q;

		/* see to case 2 first */
		*p = '\0';
		if ((q = strrchr(wrapper, '/')) != NULL) {
			/* q points to "/<CTARGET>" now */
			len = strlen("/gcc");
			if (q - len > wrapper && strncmp(q - len, "/gcc", len) == 0)
				wrapperctarget = q + 1;
		}

		/* cannonicanise wrapper step 1: strip path */
		wrapper = p + 1;
	}

	/* default to "ld" when called directly */
	if (strcmp(wrapper, "ldwrapper") == 0)
		wrapper = "ld";

	/* see if we have a known CTARGET prefix */
	ctarget[0] = '\0';
	if ((dirp = opendir(EPREFIX "/etc/env.d/binutils")) != NULL) {
		while ((dp = readdir(dirp)) != NULL) {
			len = strlen("config-");
			if (strncmp(dp->d_name, "config-", len) != 0)
				continue;
			p = dp->d_name + len;
			if (strncmp(p, wrapper, strlen(p)) == 0 ||
					(wrapperctarget != NULL &&
					 strcmp(p, wrapperctarget) == 0))
			{
				/* this is us! */
				snprintf(ctarget, sizeof(ctarget), "%s", p);
				is_cross = strcmp(ctarget, CHOST) != 0;
				break;
			}
		}
	}
	if (ctarget[0] == '\0')
		snprintf(ctarget, sizeof(ctarget), "%s", CHOST);

	is_darwin = strstr(ctarget, "-darwin") != NULL;

	/* cannonicanise wrapper step2: strip CTARGET from wrapper */
	len = strlen(ctarget);
	if (strncmp(wrapper, ctarget, len) == 0 && wrapper[len] == '-')
		wrapper += len + 1;

	/* ensure builddir is something useful */
	if (builddir != NULL && *builddir != '/')
		builddir = NULL;
	len = builddir == NULL ? 0 : strlen(builddir);

	/* walk over the arguments to see if there's anything interesting
	 * for us and calculate the final number of arguments */
	for (i = 1; i < argc; i++) {
		/* -L: account space for the matching -R */
		if (argv[i][0] == '-') {
			if (argv[i][1] == 'L')
				newargc++;
			if (argv[i][1] == 'v' || argv[i][1] == 'V')
				verbose = 1;
			if (strcmp(argv[i], "-macosx_version_min") == 0 && i < argc - 1)
				darwin_dt = argv[i + 1];
			/* ld64 will refuse to accept -rpath if any of the
			 * following options are given */
			if (strcmp(argv[i], "-static") == 0 ||
					strcmp(argv[i], "-dylinker") == 0 ||
					strcmp(argv[i], "-preload") == 0 ||
					strcmp(argv[i], "-r") == 0 ||
					strcmp(argv[i], "-kext") == 0)
				darwin_use_rpath = 0;
		}
	}

	/* Note: Code below assumes that newargc is the count of -L arguments. */

	/* If a package being cross-compiled injects standard directories, it's
	 * non-cross-compilable on any platform, prefix or no prefix. So no
	 * need to add PREFIX- or CTARGET-aware libdirs. */
	if (!is_cross) {
		struct stat st;

		if (is_darwin) {
			/* check deployment target if nothing prevents us from
			 * using -rpath as of yet
			 * # ld64 -rpath foo
			 * ld: -rpath can only be used when targeting Mac OS X
			 * 10.5 or later */
			if (darwin_use_rpath) {
				/* version format is x.y.z. atoi will stop
				 * parsing at dots. darwin_dt != NULL isn't
				 * just for safety: ld64 also refuses -rpath
				 * when not given a deployment target at all */
				darwin_use_rpath = darwin_dt != NULL &&
					(atoi(darwin_dt) > 10 ||
					 (strncmp(darwin_dt, "10.", 3) == 0 &&
					  atoi(darwin_dt + 3) >= 5));
			}

			if (darwin_use_rpath) {
				/* We need two additional arguments for each:
				 * -rpath and the path itself */
				newargc *= 2;

				/* and we will be adding two for the each of
				 * the two system paths as well */
				newargc += 4;
			}

			/* add the 2 prefix paths (-L) and -search_paths_first */
			newargc += 2 + 1;

#ifdef DARWIN_LD_SYSLIBROOT
			/* add -syslibroot <path> */
			newargc += 2;
#endif
		} else {
			/* add the 4 paths we want (-L + -R) */
			newargc += 8;
		}
	}

	/* account the original arguments */
	newargc += argc;
	/* we always add a sentinel */
	newargc++;

	/* let's first try to find the real ld */
	if (find_real_ld(&ld, sizeof(ldbuf), verbose, is_cross,
				wrapper, ctarget) != 0)
	{
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

	/* put the full path to ld into the new argv[0] we're calling it with
	 * because binutils ld finds its ldscripts directory relative to its
	 * own call path derived from its argv[0] */
	newargv[j++] = ld;

	if (!is_cross && is_darwin) {
		/* inject this first to make the intention clear */
#ifdef DARWIN_LD_SYSLIBROOT
		newargv[j++] = "-syslibroot";
		newargv[j++] = EPREFIX "/MacOSX.sdk";
#endif
		newargv[j++] = "-search_paths_first";
	}

	/* position k right after the original arguments */
	k = j - 1 + argc;
	for (i = 1; i < argc; i++, j++) {
		newargv[j] = argv[i];

		if (is_cross || (is_darwin && !darwin_use_rpath))
			continue;

		/* on ELF targets we add runpaths for all found search paths */
		if (argv[i][0] == '-' && argv[i][1] == 'L') {
			char *path;
			size_t sze;

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

			/* does it refer to the build directory? skip */
			if (builddir != NULL && strncmp(builddir, path, len) == 0)
				continue;

			if (is_darwin) {
				newargv[k] = "-rpath";
				newargv[++k] = path;
			} else {
				sze = 2 + strlen(path) + 1;
				newargv[k] = malloc(sizeof(char) * sze);
				if (newargv[k] == NULL) {
					fprintf(stderr, "%s: failed to allocate memory for "
							"'%s' -R argument\n", wrapper, argv[i]);
					exit(1);
				}

				snprintf(newargv[k], sze, "-R%s", path);
			}

			k++;
		}
	}
	/* add the custom paths */
	if (!is_cross) {
		if (is_darwin) {
			/* FIXME: no support for cross-compiling *to* Darwin */
			newargv[k++] = "-L" EPREFIX "/usr/lib";
			newargv[k++] = "-L" EPREFIX "/lib";

			if (darwin_use_rpath) {
				newargv[k++] = "-rpath";
				newargv[k++] = EPREFIX "/usr/lib";
				newargv[k++] = "-rpath";
				newargv[k++] = EPREFIX "/lib";
			}
		} else {
			newargv[k++] = "-L" EPREFIX "/usr/" CHOST "/lib/gcc";
			newargv[k++] = "-R" EPREFIX "/usr/" CHOST "/lib/gcc";
			newargv[k++] = "-L" EPREFIX "/usr/" CHOST "/lib";
			newargv[k++] = "-R" EPREFIX "/usr/" CHOST "/lib";
			newargv[k++] = "-L" EPREFIX "/usr/lib";
			newargv[k++] = "-R" EPREFIX "/usr/lib";
			newargv[k++] = "-L" EPREFIX "/lib";
			newargv[k++] = "-R" EPREFIX "/lib";
		}
	}
	newargv[k] = NULL;

	if (verbose) {
		fprintf(stderr, "%s: invoking %s with arguments:\n", wrapper, ld);
		for (j = 0; newargv[j] != NULL; j++)
			fprintf(stderr, "  %s\n", newargv[j]);
	}

	/* finally, execute the real ld */
	execv(ld, newargv);
	fprintf(stderr, "%s: failed to execute %s: %s\n",
			wrapper, ld, strerror(errno));
	exit(1);
}
