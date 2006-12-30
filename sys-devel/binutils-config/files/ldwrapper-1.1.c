/*
 * Copyright 1999-2006 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * $Id: $
 * Author: Fabian Groffen <grobian@gentoo.org>
 * based on the work of gcc wrapper done by:
 * Martin Schlemmer <azarah@gentoo.org>
 * Mike Frysinger <vapier@gentoo.org>
 */

#define _REENTRANT
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <unistd.h>
#include <sys/wait.h>
#include <libgen.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>

#define BINUTILS_CONFIG    "@GENTOO_PORTAGE_EPREFIX@/usr/bin/binutils-config"
#define ENVD_BASE_BINUTILS "@GENTOO_PORTAGE_EPREFIX@/etc/env.d/05binutils"
#define ENVD_BASE_GCC      "@GENTOO_PORTAGE_EPREFIX@/etc/env.d/05gcc"

struct wrapper_data {
	char name[MAXPATHLEN + 1];
	char fullname[MAXPATHLEN + 1];
	char bin[MAXPATHLEN + 1];
	char ldpath[MAXPATHLEN + 1];
	char tmp[MAXPATHLEN + 1];
	char *path;
};

static const char *wrapper_strerror(int err, struct wrapper_data *data)
{
	/* this app doesn't use threads and strerror
	 * is more portable than strerror_r */
	strncpy(data->tmp, strerror(err), sizeof(data->tmp));
	return data->tmp;
}

static void wrapper_exit(char *msg, ...)
{
	va_list args;
	fprintf(stderr, "binutils-config error: ");
	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);
	exit(1);
}

/* check_for_binutils checks in path for the file we are seeking
 * it returns 1 if found (with data->bin setup), 0 if not and
 * negative on error
 */
static int check_for_binutils(char *path, struct wrapper_data *data)
{
	struct stat sbuf;
	int result;
	char str[MAXPATHLEN + 1];
	size_t len = strlen(path) + strlen(data->name) + 2;

	snprintf(str, len, "%s/%s", path, data->name);

	/* Stat possible file to check that
	 * 1) it exist and is a regular file, and
	 * 2) it is not the wrapper itself, and
	 * 3) it is in a /binutils-bin/ directory tree
	 */
	result = stat(str, &sbuf);
	if ((result == 0) && \
	    ((sbuf.st_mode & S_IFREG) || (sbuf.st_mode & S_IFLNK)) && \
	    (strcmp(str, data->fullname) != 0) && \
	    (strstr(str, "/binutils-bin/") != 0)) {

		strncpy(data->bin, str, MAXPATHLEN);
		data->bin[MAXPATHLEN] = 0;
		result = 1;
	} else
		result = 0;

	return result;
}

static int find_binutils_in_path(struct wrapper_data *data)
{
	char *token = NULL, *state;
	char str[MAXPATHLEN + 1];

	if (data->path == NULL) return 0;

	/* Make a copy since strtok_r will modify path */
	snprintf(str, MAXPATHLEN + 1, "%s", data->path);

	token = strtok_r(str, ":", &state);

	/* Find the first file with suitable name in PATH.  The idea here is
	 * that we do not want to bind ourselfs to something static like the
	 * default profile, or some odd environment variable, but want to be
	 * able to build something with a non default binutils by just tweaking
	 * the PATH ... */
	while ((token != NULL) && strlen(token)) {
		if (check_for_binutils(token, data))
			return 1;
		token = strtok_r(NULL, ":", &state);
	}

	return 0;
}

/* find_binutils_in_envd parses /etc/env.d/05binutils, and tries to
 * extract PATH, which is set to the current profile's bin
 * directory ...
 */
static int find_binutils_in_envd(struct wrapper_data *data, int cross_compile)
{
	FILE *envfile = NULL;
	char *token = NULL, *state;
	char str[MAXPATHLEN + 1];
	char *strp = str;
	char envd_file[MAXPATHLEN + 1];

	if (!cross_compile) {
		snprintf(envd_file, MAXPATHLEN, "%s", ENVD_BASE_BINUTILS);
	} else {
		char *ctarget, *end = strrchr(data->name, '-');
		if (end == NULL)
			return 0;
		ctarget = strdup(data->name);
		ctarget[end - data->name] = '\0';
		snprintf(envd_file, MAXPATHLEN, "%s-%s", ENVD_BASE_BINUTILS, ctarget);
		free(ctarget);
	}
	envfile = fopen(envd_file, "r");
	if (envfile == NULL)
		return 0;

	while (0 != fgets(strp, MAXPATHLEN, envfile)) {
		/* Keep reading ENVD_FILE until we get a line that
		 * starts with 'PATH='
		 */
		if (((strp) && (strlen(strp) > strlen("PATH=")) &&
		    !strncmp("PATH=", strp, strlen("PATH=")))) {

			token = strtok_r(strp, "=", &state);
			if ((token != NULL) && strlen(token))
				/* The second token should be the value of PATH .. */
				token = strtok_r(NULL, "=", &state);
			else
				goto bail;

			if ((token != NULL) && strlen(token)) {
				strp = token;
				/* A bash variable may be unquoted, quoted with " or
				 * quoted with ', so extract the value without those ..
				 */
				token = strtok(strp, "\n\"\'");

				while (token != NULL) {
					if (check_for_binutils(token, data)) {
						fclose(envfile);
						return 1;
					}

					token = strtok(NULL, "\n\"\'");
				}
			}
		}
		strp = str;
	}

bail:
	fclose(envfile);
	return (cross_compile ? 0 : find_binutils_in_envd(data, 1));
}

/* find_ldpath_in_envd parses /etc/env.d/05gcc, and tries to
 * extract LDPATH, which is set to the LDPATH for all compilers, with
 * the current compiler first, of which only the first path is returned
 */
static int find_ldpath_in_envd(struct wrapper_data *data, int cross_compile)
{
	FILE *envfile = NULL;
	char *token = NULL, *state;
	char str[MAXPATHLEN + 1];
	char *strp = str;
	char envd_file[MAXPATHLEN + 1];

	if (!cross_compile) {
		snprintf(envd_file, MAXPATHLEN, "%s", ENVD_BASE_GCC);
	} else {
		char *ctarget, *end = strrchr(data->name, '-');
		if (end == NULL)
			return 0;
		ctarget = strdup(data->name);
		ctarget[end - data->name] = '\0';
		snprintf(envd_file, MAXPATHLEN, "%s-%s", ENVD_BASE_GCC, ctarget);
		free(ctarget);
	}
	envfile = fopen(envd_file, "r");
	if (envfile == NULL)
		return 0;

	while (0 != fgets(strp, MAXPATHLEN, envfile)) {
		/* Keep reading ENVD_FILE until we get a line that
		 * starts with 'LDPATH='
		 */
		if (((strp) && (strlen(strp) > strlen("LDPATH=")) &&
		    !strncmp("LDPATH=", strp, strlen("LDPATH=")))) {

			token = strtok_r(strp, "=", &state);
			if ((token != NULL) && strlen(token))
				/* The second token should be the value of LDPATH .. */
				token = strtok_r(NULL, "=", &state);
			else
				goto bail;

			if ((token != NULL) && strlen(token)) {
				strp = token;
				/* A bash variable may be unquoted, quoted with " or
				 * quoted with ', so extract the value without those ..
				 */
				token = strtok(strp, "\n\"\'");

				if (token != NULL) {
					/* only take the first path in the string */
					if ((strp = strchr(token, ':')) != NULL)
						*strp = '\0';
					strncpy(data->ldpath, token, MAXPATHLEN);
					fclose(envfile);
					return 1;
				}
			}
		}
		strp = str;
	}

bail:
	fclose(envfile);
	return (cross_compile ? 0 : find_ldpath_in_envd(data, 1));
}

static void find_wrapper_binutils(struct wrapper_data *data)
{
	FILE *inpipe = NULL;
	char str[MAXPATHLEN + 1];

	if (find_binutils_in_path(data))
		return;

	if (find_binutils_in_envd(data, 0))
		return;

	/* Only our wrapper is in PATH, so
	   get the CC path using gcc-config and
	   execute the real binary in there... */
	inpipe = popen(BINUTILS_CONFIG " --get-bin-path", "r");
	if (inpipe == NULL)
		wrapper_exit(
			"Could not open pipe: %s\n",
			wrapper_strerror(errno, data));

	if (fgets(str, MAXPATHLEN, inpipe) == 0)
		wrapper_exit(
			"Could not get linker binary path: %s\n",
			wrapper_strerror(errno, data));

	strncpy(data->bin, str, sizeof(data->bin) - 1);
	data->bin[strlen(data->bin) - 1] = '/';
	strncat(data->bin, data->name, sizeof(data->bin) - 1);
	data->bin[MAXPATHLEN] = 0;

	pclose(inpipe);
}

static char **build_new_argv(char **argv, const char *newflags_str)
{
#define MAX_NEWFLAGS 32
	char *newflags[MAX_NEWFLAGS];
	char **retargv;
	unsigned int argc, i;
	char *state, *flags_tokenized;

	retargv = argv;

	for (argc = 0; argv[argc] != NULL; argc++);

	/* Tokenize the flag list and put it into newflags array */
	flags_tokenized = strdup(newflags_str);
	if (flags_tokenized == NULL)
		return retargv;
	i = 0;
	newflags[i] = strtok_r(flags_tokenized, " \t\n", &state);
	while (newflags[i] != NULL && i < MAX_NEWFLAGS-1)
		newflags[++i] = strtok_r(NULL, " \t\n", &state);

	/* allocate memory for our spiffy new argv */
	retargv = (char**)calloc(argc + i + 1, sizeof(char*));
	/* copy over the old argv */
	memcpy(retargv, argv, (argc) * sizeof(char*));
	/* append the new flags after the original ones, such that they do
	 * not override (-L flag order) */
	memcpy(retargv + argc, newflags, i * sizeof(char*));

	return retargv;
}

int main(int argc, char *argv[])
{
	struct wrapper_data *data;
	size_t size;
	int i;
	char **newargv = argv;
	char callarg[MAXPATHLEN * 8 + 1];

	data = alloca(sizeof(*data));
	if (data == NULL)
		wrapper_exit("%s wrapper: out of memory\n", argv[0]);
	memset(data, 0, sizeof(*data));

	if (getenv("PATH")) {
		data->path = strdup(getenv("PATH"));
		if (data->path == NULL)
			wrapper_exit("%s wrapper: out of memory\n", argv[0]);
	}

	/* What should we find ? */
	strcpy(data->name, basename(argv[0]));

	/* What is the full name of our wrapper? */
	size = sizeof(data->fullname);
	i = snprintf(data->fullname, size, "@GENTOO_PORTAGE_EPREFIX@/usr/bin/%s", data->name);
	if ((i == -1) || (i > (int)size))
		wrapper_exit("invalid wrapper name: \"%s\"\n", data->name);

	find_wrapper_binutils(data);

	if (data->path)
		free(data->path);
	data->path = NULL;

	/* Get the include path for the compiler */
	if (find_ldpath_in_envd(data, 0) == 0) {
		data->ldpath[0] = '\0';
		fprintf(stderr, "binutils-config warning: no GCC found on your system!");
	}

	/* We add -L and -rpath flags before invoking the real binary */
#if !defined(NEEDS_LIBRARY_INCLUDES) && !defined(NEEDS_RPATH_DIRECTIONS)
# error NEEDS_LIBRARY_INCLUDES and/or NEEDS_RPATH_DIRECTIONS must be defined
#endif
	if (data->ldpath[0] == '\0') {
		size = snprintf(callarg, MAXPATHLEN * 8,
#ifdef NEEDS_LIBRARY_INCLUDES
				"%s "
#endif
#ifdef NEEDS_RPATH_DIRECTIONS
				"%s"
#endif
				,
#ifdef NEEDS_LIBRARY_INCLUDES
				"@LIBRARY_INCLUDES@"
#endif
#ifdef NEEDS_RPATH_DIRECTIONS
				,
				"@RUNPATH_DIRECTIONS@"
#endif
		);
	} else {
		size = snprintf(callarg, MAXPATHLEN * 8,
#ifdef NEEDS_LIBRARY_INCLUDES
				"%s -L%s "
#endif
#ifdef NEEDS_RPATH_DIRECTIONS
				"%s -rpath=%s"
#endif
				,
#ifdef NEEDS_LIBRARY_INCLUDES
				"@LIBRARY_INCLUDES@",
				data->ldpath
#endif
#ifdef NEEDS_RPATH_DIRECTIONS
				,
				"@RUNPATH_DIRECTIONS@",
				data->ldpath
#endif
		);
	}
	callarg[size] = '\0';
	newargv = build_new_argv(argv, callarg);
	if (!newargv)
		wrapper_exit("%s wrapper: out of memory\n", argv[0]);

	/* Ok, lets do it one more time ... */
	if (execv(data->bin, newargv) < 0)
		wrapper_exit("Could not run/locate \"%s\"\n", data->name);

	return 0;
}
