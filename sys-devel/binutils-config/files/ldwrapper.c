/*
 * Copyright 1999-2017 Gentoo Foundation
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
#include <errno.h>
#include <glob.h>
#include <stdarg.h>

/**
 * ldwrapper: Prefix helper to inject -L and -R flags to the invocation
 * of ld.
 *
 * On Darwin it adds -search_path_first to make sure the given paths are
 * searched before the default search path.
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

static inline int is_cross(const char *ctarget) {
	return strcmp(ctarget, CHOST);
}

static inline int is_darwin(const char *ctarget) {
	return (strstr(ctarget, "-darwin") != NULL);
}

static inline int is_aix(const char *ctarget) {
	return (strstr(ctarget, "-aix") != NULL);
}

static inline char *
find_real_ld(const char verbose, const char *wrapper, const char *ctarget)
{
	FILE *f = NULL;
	char *ldoveride;
	char *path;
#define ESIZ 1024  /* POSIX_MAX_PATH */
	char *ret;
	struct stat lde;
	char *config;
	const char *config_prefix;
	size_t configlen;

	/* respect the override in environment */
	ldoveride = getenv("BINUTILS_CONFIG_LD");
	if (ldoveride != NULL && *ldoveride != '\0') {
		if (verbose)
			fprintf(stdout, "%s: using BINUTILS_CONFIG_LD=%s "
					"from environment\n", wrapper, ldoveride);
		return ldoveride;
	}
	if (verbose)
		fprintf(stdout, "%s: BINUTILS_CONFIG_LD not found in environment\n",
				wrapper);

	ret = malloc(sizeof(char) * ESIZ);
	if (ret == NULL) {
		fprintf(stderr, "%s: out of memory allocating string for path to ld\n",
				wrapper);
		exit(1);
	}

	/* find ld in PATH, allowing easy PATH overrides. strdup it because
	 * modifying it would otherwise corrupt the actual PATH environment
	 * variable which we might need to be intact later on to call
	 * binutils-config via popen. */
	path = strdup(getenv("PATH"));
	if (path != NULL && *path != '\0') {
		char *p;
		char *q;
		char *match;
		const char *match_anchor = "/binutils-bin/";
		size_t matchlen = 1 + strlen(ctarget) +
			strlen(match_anchor) + 1;

		match = malloc(sizeof(char) * matchlen);
		if (match == NULL) {
			fprintf(stderr, "%s: out of memory allocating "
					"buffer for path matching\n",
					wrapper);
			exit(1);
		}

		/* construct /CTARGET/binutils-bin/ for matchin against PATH */
		snprintf(match, matchlen, "/%s%s", ctarget, match_anchor);

		for (p = path; (q = strchr(p, ':')) != NULL; p = q + 1) {
			if (q)
				*q = '\0';
			if (strstr(p, match) != NULL) {
				snprintf(ret, ESIZ, "%s/%s", p, wrapper);
				if (stat(ret, &lde) == 0) {
					free(match);
					return ret;
				}
			}
			if (!q)
				break;
		}

		free(match);
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found in PATH\n", wrapper);

	/* parse EPREFIX/etc/env.d/binutils/config-CTARGET to get CURRENT, then
	 * consider $EPREFIX/usr/CTARGET/binutils-bin/CURRENT where we should
	 * be able to find ld */
	config_prefix = EPREFIX "/etc/env.d/binutils/config-";
	configlen = strlen(config_prefix) + strlen(ctarget) + 1;
	config = malloc(sizeof(char) * configlen);
	if (config == NULL) {
		fprintf(stderr, "%s: out of memory allocating "
			"buffer for configuration file name\n",
			wrapper);
		exit(1);
	}

	snprintf(config, configlen, "%s%s", config_prefix, ctarget);
	if ((f = fopen(config, "r")) != NULL) {
		char p[ESIZ];
		char *q;
		while (fgets(p, ESIZ, f) != NULL) {
			if (strncmp(p, "CURRENT=", strlen("CURRENT=")) != 0)
				continue;

			q = p + strlen(p);
			/* strip trailing whitespace (fgets at least includes
			 * the \n) */
			for (q--; isspace(*q); q--)
				*q = '\0';

			q = p + strlen("CURRENT=");
			if (is_cross(ctarget)) {
				snprintf(ret, ESIZ, EPREFIX "/usr/" CHOST "/%s/binutils-bin/%s/%s",
						ctarget, q, wrapper);
			} else {
				snprintf(ret, ESIZ, EPREFIX "/usr/" CHOST "/binutils-bin/%s/%s",
						q, wrapper);
			}
			break;
		}
		fclose(f);
		if (stat(ret, &lde) == 0) {
			free(config);
			return ret;
		}
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found via %s\n", wrapper, config);
	free(config);

	/* last try, call binutils-config to tell us what the linker is
	 * supposed to be */
	config_prefix = "binutils-config -c ";
	configlen = strlen(config_prefix) + strlen(ctarget) + 1;
	config = malloc(sizeof(char) * configlen);
	if (config == NULL) {
		fprintf(stderr, "%s: out of memory allocating "
			"buffer for binutils-config command\n",
			wrapper);
		exit(1);
	}

	snprintf(config, configlen, "%s%s", config_prefix, ctarget);
	if ((f = popen(config, "r")) != NULL) {
		char p[ESIZ];
		char *q = fgets(p, ESIZ, f);
		fclose(f);
		if (q != NULL) {
			size_t ctargetlen = strlen(ctarget);

			/* binutils-config should report CTARGET-<version> */
			if (strncmp(p, ctarget, ctargetlen) == 0 &&
					strlen(p) > ctargetlen &&
					p[ctargetlen] == '-') {
				/* strip trailing whitespace (fgets at least includes
				 * the \n) */
				q = p + strlen(p);
				for (q--; isspace(*q); q--)
					*q = '\0';

				q = p + ctargetlen + 1;
				if (is_cross(ctarget)) {
					snprintf(ret, ESIZ, EPREFIX "/usr/" CHOST
							"/%s/binutils-bin/%s/%s",
							ctarget, q, wrapper);
				} else {
					snprintf(ret, ESIZ, EPREFIX "/usr/" CHOST
							"/binutils-bin/%s/%s",
							q, wrapper);
				}

				if (stat(ret, &lde) == 0) {
					free(config);
					return ret;
				}
			}
		}
	}
	if (verbose)
		fprintf(stdout, "%s: linker not found via %s\n",
				wrapper, config);
	free(config);

	/* we didn't succeed finding the linker */
	return NULL;
}

int
main(int argc, char *argv[])
{
	char *ld = NULL;
	int newargc = 0;
	char **newargv = NULL;
	char *wrapper = argc > 0 ? argv[0] : "ld-wrapper";
	char *wrapperdir = NULL;
	char verbose = getenv("BINUTILS_CONFIG_VERBOSE") != NULL;
	char *builddir = getenv("PORTAGE_BUILDDIR");
	size_t builddirlen;
	char *p;
	int i;
	int j;
	int k;
	glob_t m;
	char *ctarget = CHOST;
	size_t ctargetlen;

	/* two ways to determine CTARGET from argv[0]:
	 * 1. called as <CTARGET>-ld (manually)
	 * 2. called as EPREFIX/usr/libexec/gcc/<CTARGET>/ld (by gcc's collect2)
	 *
	 * TODO: Make argv[0] absolute without resolving symlinks so no. 2 can
	 * work when added to PATH (which shouldn't happen in the wild, but
	 * eh!?). */
	if ((p = strrchr(wrapper, '/')) != NULL) {
		/* cannonicanise wrapper step 1: strip path */
		wrapper = p + 1;

		/* remember directory to see if it's CTARGET but only
		 * if parent is /gcc/ */
		*p = '\0';
		if ((p = strrchr(argv[0], '/')) != NULL) {
			char *q;

			*p = '\0';
			if ((q = strrchr(argv[0], '/')) != NULL &&
				strncmp(q + 1, "gcc", strlen("gcc")) == 0) {
				wrapperdir = p + 1;
			}
		}
	}

	/* see if we have a known CTARGET prefix */
	i = glob(EPREFIX "/etc/env.d/binutils/config-*", GLOB_NOSORT, NULL, &m);
	if (i == GLOB_NOSPACE) {
		fprintf(stderr, "%s: out of memory when inspecting "
				"binutils configuration\n", wrapper);
		exit(1);
	}
	if (i == 0) {
		for (i = 0; i < m.gl_pathc; i++) {
			p = strrchr(m.gl_pathv[i], '/');
			if (p == NULL || strncmp(p, "/config-", strlen("/config-")) != 0)
				continue;

			/* EPREFIX/etc/env.d/binutils/config-arm-something-or-other
			 *                         move here ^ */
			p += strlen("/config-");
			if (strncmp(wrapper, p, strlen(p)) == 0 ||
				(wrapperdir != NULL && strcmp(wrapperdir, p) == 0)) {
				/* this is us! (MEMLEAK) */
				ctarget = strdup(p);
				break;
			}
		}
	}
	/* ignore GLOB_NOMATCH and (possibly) GLOB_ABORTED */
	globfree(&m);

	/* cannonicanise wrapper step2: strip CTARGET */
	ctargetlen = strlen(ctarget);
	if (strncmp(wrapper, ctarget, ctargetlen) == 0 &&
			wrapper[ctargetlen] == '-') {
		wrapper += ctargetlen + 1;
	}

	/* ensure builddir is something useful */
	if (builddir != NULL && *builddir != '/')
		builddir = NULL;
	builddirlen = builddir == NULL ? 0 : strlen(builddir);

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
	/* we always add a null-terminator */
	newargc ++;
	/* If a package being cross-compiled injects standard directories, it's
	 * non-cross-compilable on any platform, prefix or no prefix. So no
	 * need to add PREFIX- or CTARGET-aware libdirs. */
	if (!is_cross(ctarget)) {
		if (is_darwin(ctarget)) {
			/* add the 2 prefix paths (-L) and -search_paths_first */
			newargc += 2 + 1;
		} else {
			/* add the 4 paths we want (-L + -R) */
			newargc += 8;
		}

		if (is_aix(ctarget)) {
			/* AIX ld accepts -R only with -bsvr4 */
			newargc++; /* -bsvr4 */
		}
	}

	/* let's first try to find the real ld */
	ld = find_real_ld(verbose, wrapper, ctarget);
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

	/* put the full path to ld into the new argv[0] we're calling it with
	 * because binutils ld finds its ldscripts directory relative to its
	 * own call path derived from its argv[0] */
	newargv[j++] = ld;

	if (!is_cross(ctarget) && is_darwin(ctarget)) {
		/* inject this first to make the intention clear */
		newargv[j++] = "-search_paths_first";
	}

	/* position k right after the original arguments */
	k = j - 1 + argc;
	for (i = 1; i < argc; i++, j++) {
		if (is_aix(ctarget)) {
			/* AIX ld has this problem:
			 *   $ /usr/ccs/bin/ld -bsvr4 -bE:xx.exp -bnoentry xx.o
			 *   ld: 0706-005 Cannot find or open file: l
			 *       ld:open(): No such file or directory
			 * Simplest workaround is to put -bsvr4 last.
			 */
			if (strcmp(argv[i], "-bsvr4") == 0) {
				--j; --k;
				continue;
			}
		}

		newargv[j] = argv[i];

		if (is_cross(ctarget) || is_darwin(ctarget))
			continue;

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

			/* does it refer to the build directory? skip */
			if (builddir != NULL && strncmp(builddir, path, builddirlen) != 0)
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
	}
	/* add the custom paths */
	if (!is_cross(ctarget)) {
		if (is_darwin(ctarget)) {
			/* FIXME: no support for cross-compiling *to* Darwin */
			newargv[k++] = "-L" EPREFIX "/usr/lib";
			newargv[k++] = "-L" EPREFIX "/lib";
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

		if (is_aix(ctarget))
			newargv[k++] = "-bsvr4"; /* last one, see above */
	}
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
