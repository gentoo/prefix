/*
 * Copyright 1999-2024 Gentoo Authors
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
 * of ld, and many more necessary linker flags/tweaks.
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
	int rpathcnt = 0;
	char **newargv = NULL;
	char **rpaths = NULL;
	char **lpaths = NULL;
	char *wrapper = argv[0];
	char *wrapperctarget = NULL;
	char verbose = getenv("BINUTILS_CONFIG_VERBOSE") != NULL;
	char *builddir = getenv("PORTAGE_BUILDDIR");
	char ldbuf[ESIZ * 2];
	char *ld = ldbuf;
	char ctarget[128];
	char *darwin_dt = getenv("MACOSX_DEPLOYMENT_TARGET");
	int darwin_dt_ver = 0;
	char is_cross = 0;
	char is_darwin = 0;
	char darwin_use_rpath = 1;
	char *p;
	size_t len;
	int i;
	int j;
	DIR *dirp;
	struct dirent *dp;

#ifdef DARWIN_LD_DEFAULT_TARGET
	if (darwin_dt == NULL)
		darwin_dt = DARWIN_LD_DEFAULT_TARGET;
#endif

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
		if (argv[i][0] == '-') {
			/* -L: account space for the matching -R */
			if (argv[i][1] == 'L')
				newargc++;
			if (argv[i][1] == 'R' || strcmp(argv[i], "-rpath") == 0)
				rpathcnt++;
			if (argv[i][1] == 'v' || argv[i][1] == 'V')
				verbose = 1;
			if ((strcmp(argv[i], "-macosx_version_min") == 0 ||
				 strcmp(argv[i], "-macos_version_min") == 0) && i < argc - 1)
				darwin_dt = argv[i + 1];
			if (strcmp(argv[i], "-platform_version") == 0 &&
				i < argc - 3 && strcmp(argv[i + 1], "macos") == 0)
				darwin_dt = argv[i + 2];
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

	if (is_darwin && darwin_dt != NULL) {
		darwin_dt_ver = (int)strtol(darwin_dt, &p, 10) * 100;
		if (*p == '.')
			darwin_dt_ver += (int)strtol(p + 1, &p, 10);
	}

	/* If a package being cross-compiled injects standard directories, it's
	 * non-cross-compilable on any platform, prefix or no prefix. So no
	 * need to add PREFIX- or CTARGET-aware libdirs. */
	if (!is_cross) {
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
				darwin_use_rpath = darwin_dt_ver >= 1005;
			}

			if (darwin_use_rpath) {
				/* We need two additional arguments for each:
				 * -rpath and the path itself */
				newargc *= 2;

				/* PREFIX rpaths */
				newargc += 2 * 2;
			}

			/* PREFIX paths */
			newargc += 3;

			/* add -search_paths_first */
			newargc += 1;

			/* add -syslibroot <path> -platform_version macos <ver> 0.0 */
			newargc += 6;
		} else {
			/* add the 4 paths we want (-L + -R) */
			newargc += 8;
		}
	}

	/* Note: Code below assumes that newargc is the count of -L arguments. */

	/* allocate space for -L lookups/uniqueifying */
	lpaths = malloc(sizeof(lpaths[0]) * (newargc + 1));
	if (lpaths == NULL) {
		fprintf(stderr, "%s: failed to allocate memory for new arguments\n",
				wrapper);
		exit(1);
	}
	lpaths[0] = NULL;

	if (!is_darwin || darwin_use_rpath) {
		rpaths = malloc(sizeof(rpaths[0]) * (rpathcnt + 1));
		if (rpaths == NULL) {
			fprintf(stderr, "%s: failed to allocate memory for new arguments\n",
					wrapper);
			exit(1);
		}
		rpaths[0] = NULL;
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
		char  target[(2 * ESIZ) + 16];
		FILE *ld64out;
		int   ld64ver = 0;

		/* call the linker to figure out what options we can use :(
		 * some Developer Tools ld64 versions:
		 * Xcode   ld64   dyld
		 * 3.1.1:  85.2.1        Leopard 10.5, sdk_version unknown,
		 *                                     need macosx_version_min
		 * 8.2.1:  274.2         xtools-2.2.4, sdk_version plus
		 *                                     macosx_version_min
		 * 10.0:   409.12        High Sierra 10.13 like above
		 * 12.0:   609           Big Sur 11, sdk_version only
		 * 13.0:   711
		 * 13.3.1: 762
		 * 14.0:   819.6
		 * 14.2:   820.1
		 * 14.3.1: 857.1
		 * 15.0:   907   1022.1  Sanoma 23, platform_version iso sdk_version
		 * 15.3    1053.12       called ld
		 * all to be found from the PROJECT:ld64-650.9 or
		 * PROJECT:dyld-1022.1 or PROJECT:ld-1053.12 bit from the first line
		 * NOTE: e.g. my Sanoma mac with CommandLineTools has 650.9
		 *       which is not a version from any Developer Tools ?!?
		 * Currently we need to distinguish XCode 15 according to
		 * bug #910277, so we look for 907 and old targets before 12 */
#define LD64_3_1    8500
#define LD64_8_2   27400
#define LD64_10_0  40900
#define LD64_12_0  60900
#define LD64_15_0  90700
		snprintf(target, sizeof(target), "%s -v 2>&1", ld);
		ld64out = popen(target, "r");
		if (ld64out != NULL) {
			char *proj;
			long  comp;
			if (fgets(target, sizeof(target), ld64out) != 0 &&
				((proj = strstr(target, "PROJECT:ld64-")) != NULL ||
				 (proj = strstr(target, "PROJECT:dyld-")) != NULL ||
				 (proj = strstr(target, "PROJECT:ld-")) != NULL))
			{
				/* we don't distinguish between ld64 and dyld here, for
				 * now it seems the numbers line up for our logic */
				proj += sizeof("PROJECT:ld") - 1;
				proj += *proj == '-' ? 1 : 3;
				comp  = strtol(proj, &proj, 10);
				/* we currently have no need to parse fractions, the
				 * major version is significant enough, so just stop */
				ld64ver = (int)comp * 100;
			}
			pclose(ld64out);
		}

		/* macOS Big Sur (Darwin 20) has an empty /usr/lib, so the
		 * linker really has to look into the SDK, for which it needs to
		 * be told where it is (symlinked right into our EPREFIX root as
		 * MacOSX.sdk) via the -syslibroot argument, older targets also
		 * get this SDK path setup, old bootstraps would break, but that
		 * would be easy to resolve -- there's unlikely to be many old
		 * bootstraps out there that don't have the SDK path symlink */
		newargv[j++] = "-syslibroot";
		newargv[j++] = EPREFIX "/MacOSX.sdk";

		/* ld64 will try to infer sdk version when -syslibroot is
		 * used from the path given, unfortunately this searches for
		 * the first numbers it finds, which means anything random
		 * in EPREFIX, causing errors.  Explicitly set the
		 * deployment version here, for the sdk link can be
		 * versionless when set to CommandLineTools
		 * macOS Sanoma however needs a new way to set this version,
		 * so do the right thing */
		if (ld64ver >= LD64_15_0) {
			newargv[j++] = "-platform_version";
			newargv[j++] = "macos";
			newargv[j++] = darwin_dt;
			newargv[j++] = "0.0";
		} else if (ld64ver >= LD64_8_2) {
			newargv[j++] = "-sdk_version";
			newargv[j++] = darwin_dt;
		}

		if (ld64ver < LD64_12_0) {
			newargv[j++] = "-macosx_version_min";
			newargv[j++] = darwin_dt;
		}

		/* inject this before -L args to make the intention clear */
		newargv[j++] = "-search_paths_first";
	}

	for (i = 1; i < argc; i++, j++) {
		if (is_darwin) {
			/* skip platform version stuff, we already pushed it out */
			if ((strcmp(argv[i], "-macosx_version_min") == 0 ||
				 strcmp(argv[i], "-macos_version_min") == 0) && i < argc - 1)
			{
				i++;
				j--;
				continue;
			}
			if (strcmp(argv[i], "-platform_version") == 0 &&
				i < argc - 3 && strcmp(argv[i + 1], "macos") == 0)
			{
				i += 3;
				j--;
				continue;
			}
		}

		newargv[j] = argv[i];

		if (is_cross || (is_darwin && !darwin_use_rpath))
			continue;

		/* on ELF/Mach-O targets we add runpaths for all found search paths */
		if (argv[i][0] == '-' && (argv[i][1] == 'L' || argv[i][1] == 'R')) {
			char *path;
			int pth;
			char duplicate;
			int nexti = i;

			/* arguments can be in many ways here:
			 * -L<path>
			 * -L <path> (yes, this is accepted)
			 * -L(whitespace)? <path in next argument>
			 * where path is absolute (not relative) */
			path = &argv[i][2];
			while (*path != '\0' && isspace(*path))
				path++;
			if (*path == '\0') {
				nexti++;
				/* no more arguments?!? skip */
				if (nexti >= argc)
					continue;
				path = argv[nexti];
				while (*path != '\0' && isspace(*path))
					path++;
			}
			/* not absolute (or empty)?!? skip */
			if (*path != '/')
				continue;

			/* does it refer to the build directory? skip */
			if (builddir != NULL && strncmp(builddir, path, len) == 0)
				continue;

			/* loop-search for this path, if it was emitted already,
			 * suppress it -- this is not just some fancy beautification!
			 * CLT15.3 on macOS warns about duplicate paths, and
			 * any project that triggers on these warnings causes
			 * problems, such as Ruby claiming the linker is broken */
			duplicate = 0;
			if (argv[i][1] == 'L') {
				for (pth = 0; lpaths[pth] != NULL; pth++) {
					if (strcmp(lpaths[pth], path) == 0) {
						duplicate = 1;
						break;
					}
				}
				if (duplicate) {
					i = nexti;
					j--;
					continue;
				}
				/* record path */
				lpaths[pth++] = path;
				lpaths[pth]   = NULL;
			} else if (!is_darwin || darwin_use_rpath) {
				for (pth = 0; rpaths[pth] != NULL; pth++) {
					if (strcmp(rpaths[pth], path) == 0) {
						duplicate = 1;
						break;
					}
				}
				if (duplicate) {
					i = nexti;
					j--;
					continue;
				}
				/* record path */
				rpaths[pth++] = path;
				rpaths[pth]   = NULL;
			}
		} else if ((!is_darwin || darwin_use_rpath) &&
				   strcmp(argv[i], "-rpath") == 0)
		{
			char *path;
			int pth;
			char duplicate;
			int nexti = i + 1;

			/* no more arguments?!? skip */
			if (nexti >= argc)
				continue;
			path = argv[nexti];
			while (*path != '\0' && isspace(*path))
				path++;
			/* not absolute (or empty)?!? skip */
			if (*path != '/')
				continue;

			/* does it refer to the build directory? skip */
			if (builddir != NULL && strncmp(builddir, path, len) == 0)
				continue;

			duplicate = 0;
			for (pth = 0; rpaths[pth] != NULL; pth++) {
				if (strcmp(rpaths[pth], path) == 0) {
					duplicate = 1;
					break;
				}
			}
			if (duplicate) {
				j--;
				i = nexti;
				continue;
			}
			/* record path */
			rpaths[pth++] = path;
			rpaths[pth]   = NULL;
		}
	}
	/* add the custom paths */
	if (!is_cross) {
		int pth;
#define path_not_exists(W,P) \
		for (pth = 0; W[pth] != NULL; pth++) { \
			if (strcmp(W[pth], P) == 0) \
				break; \
		} \
		if (W[pth] == NULL)
#define add_path(P) \
		path_not_exists(lpaths, P) newargv[j++] = "-L" P
#define add_path_rpath(P) \
		path_not_exists(lpaths, P) { \
			lpaths[pth++] = P; \
			lpaths[pth]   = NULL; \
			newargv[j++] = "-L" P; \
		}

		if (is_darwin) {
			/* FIXME: no support for cross-compiling *to* Darwin */
			add_path(EPREFIX "/usr/" CHOST "/lib/gcc");
			add_path_rpath(EPREFIX "/usr/lib");
			add_path_rpath(EPREFIX "/lib");
		} else {
			add_path_rpath(EPREFIX "/usr/" CHOST "/lib/gcc");
			add_path_rpath(EPREFIX "/usr/" CHOST "/lib");
			add_path_rpath(EPREFIX "/usr/lib");
			add_path_rpath(EPREFIX "/lib");
		}
	}
	/* add rpaths for -L entries */
	if (!is_darwin || darwin_use_rpath) {
		for (i = 0; lpaths[i] != NULL; i++) {
			int pth;
			path_not_exists(rpaths, lpaths[i]) {
				size_t sze;
				if (is_darwin && darwin_use_rpath) {
					newargv[j++] = "-rpath";
					newargv[j++] = lpaths[i];
				} else if (!is_darwin) {
					sze = 2 + strlen(lpaths[i]) + 1;
					newargv[j] = malloc(sizeof(char) * sze);
					if (newargv[j] == NULL) {
						fprintf(stderr, "%s: failed to allocate memory for "
								"'%s' -R argument\n", wrapper, argv[i]);
						exit(1);
					}

					snprintf(newargv[j++], sze, "-R%s", lpaths[i]);
				}
			}
		}
	}
	newargv[j] = NULL;

	if (verbose) {
		fprintf(stderr, "%s: invoking %s with arguments:\n", wrapper, ld);
		for (j = 0; newargv[j] != NULL; j++)
			fprintf(stderr, "  %s%s",
					newargv[j],
					newargv[j + 1] != NULL && newargv[j + 1][0] != '-'
					? "" : "\n");
	}

	/* finally, execute the real ld */
	execv(ld, newargv);
	fprintf(stderr, "%s: failed to execute %s: %s\n",
			wrapper, ld, strerror(errno));
	exit(1);
}
