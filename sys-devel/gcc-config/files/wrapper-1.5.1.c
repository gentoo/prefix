/*
 * Copyright 1999-2008 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/files/wrapper-1.5.1.c,v 1.1 2008/03/16 01:20:11 vapier Exp $
 * Author: Martin Schlemmer <azarah@gentoo.org>
 * az's lackey: Mike Frysinger <vapier@gentoo.org>
 */

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

#define GCC_CONFIG "@GENTOO_PORTAGE_EPREFIX@/usr/bin/gcc-config"
#define ENVD_BASE  "@GENTOO_PORTAGE_EPREFIX@/etc/env.d/05gcc"

struct wrapper_data {
	char *name, *fullname, *bin, *path;
};

static const struct {
	char *alias;
	char *target;
} wrapper_aliases[] = {
	{ "cc",  "gcc" },
	{ "f77", "g77" },
	{ NULL, NULL }
};

static void wrapper_err(char *msg, ...)
{
	va_list args;
	fprintf(stderr, "gcc-config error: ");
	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);
	fprintf(stderr, "\n");
	exit(1);
}
#define wrapper_errp(fmt, ...) wrapper_err(fmt ": %s", ## __VA_ARGS__, strerror(errno))

#define xmemwrap(func, proto, use) \
static void *x ## func proto \
{ \
	void *ret = func use; \
	if (!ret) \
		wrapper_err(#func "out of memory"); \
	return ret; \
}
xmemwrap(malloc, (size_t size), (size))
xmemwrap(calloc, (size_t nemb, size_t size), (nemb, size))
xmemwrap(strdup, (const char *s), (s))

/* check_for_target checks in path for the file we are seeking
 * it returns 1 if found (with data->bin setup), 0 if not and
 * negative on error
 */
static int check_for_target(char *path, struct wrapper_data *data)
{
	struct stat sbuf;
	char str[MAXPATHLEN + 1];
	size_t len = strlen(path) + strlen(data->name) + 2;

	snprintf(str, sizeof(str), "%s/%s", path, data->name);

	/* Stat possible file to check that
	 * 1) it exist and is a regular file, and
	 * 2) it is not the wrapper itself, and
	 * 3) it is in a /gcc-bin/ directory tree
	 */
	if (stat(str, &sbuf) == 0 &&
	    (S_ISREG(sbuf.st_mode) || S_ISLNK(sbuf.st_mode)) &&
	    (strcmp(str, data->fullname) != 0) &&
	    (strstr(str, "/gcc-bin/") != 0))
	{
		data->bin = xstrdup(str);
		return 1;
	}

	return 0;
}

static int find_target_in_path(struct wrapper_data *data)
{
	char *token = NULL, *state;
	char *str;

	if (data->path == NULL)
		return 0;

	/* Make a copy since strtok_r will modify path */
	str = xstrdup(data->path);

	/* Find the first file with suitable name in PATH.  The idea here is
	 * that we do not want to bind ourselfs to something static like the
	 * default profile, or some odd environment variable, but want to be
	 * able to build something with a non default gcc by just tweaking
	 * the PATH ... */
	token = strtok_r(str, ":", &state);
	while (token != NULL) {
		if (check_for_target(token, data))
			return 1;
		token = strtok_r(NULL, ":", &state);
	}

	return 0;
}

/* find_target_in_envd parses /etc/env.d/05gcc, and tries to
 * extract PATH, which is set to the current profile's bin
 * directory ...
 */
static int find_target_in_envd(struct wrapper_data *data, int cross_compile)
{
	FILE *envfile = NULL;
	char *token = NULL, *state;
	char str[MAXPATHLEN + 1];
	char *strp = str;
	char envd_file[MAXPATHLEN + 1];

	if (!cross_compile) {
		/* for the sake of speed, we'll keep a symlink around for
		 * the native compiler.  #190260
		 */
		snprintf(envd_file, sizeof(envd_file)-1, "@GENTOO_PORTAGE_EPREFIX@/etc/env.d/gcc/.NATIVE");
	} else {
		char *ctarget, *end = strrchr(data->name, '-');
		if (end == NULL)
			return 0;
		ctarget = xstrdup(data->name);
		ctarget[end - data->name] = '\0';
		snprintf(envd_file, MAXPATHLEN, "%s-%s", ENVD_BASE, ctarget);
		free(ctarget);
	}

	envfile = fopen(envd_file, "r");
	if (envfile == NULL)
		return 0;

	while (fgets(strp, MAXPATHLEN, envfile) != NULL) {
		/* Keep reading ENVD_FILE until we get a line that
		 * starts with 'GCC_PATH=' ... keep 'PATH=' around
		 * for older gcc versions.
		 */
		if (strncmp(strp, "GCC_PATH=", strlen("GCC_PATH=")) &&
		    strncmp(strp, "PATH=", strlen("PATH=")))
			continue;

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
				if (check_for_target(token, data)) {
					fclose(envfile);
					return 1;
				}

				token = strtok(NULL, "\n\"\'");
			}
		}

		strp = str;
	}

 bail:
	fclose(envfile);
	return (cross_compile ? 0 : find_target_in_envd(data, 1));
}

static void find_wrapper_target(struct wrapper_data *data)
{
	if (find_target_in_path(data))
		return;

	if (find_target_in_envd(data, 0))
		return;

	/* Only our wrapper is in PATH, so get the CC path using
	 * gcc-config and execute the real binary in there ...
	 */
	FILE *inpipe = popen(GCC_CONFIG " --get-bin-path", "r");
	if (inpipe == NULL)
		wrapper_errp("could not open pipe");

	char str[MAXPATHLEN + 1];
	if (fgets(str, MAXPATHLEN, inpipe) == 0)
		wrapper_errp("could not get compiler binary path");

	/* chomp! */
	size_t plen = strlen(str);
	if (str[plen-1] == '\n')
		str[plen-1] = '\0';

	data->bin = xmalloc(strlen(str) + 1 + strlen(data->name) + 1);
	sprintf(data->bin, "%s/%s", str, data->name);

	pclose(inpipe);
}

/* This function modifies PATH to have gcc's bin path appended */
static void modify_path(struct wrapper_data *data)
{
	char *newpath = NULL, *token = NULL, *state;
	char dname_data[MAXPATHLEN + 1], str[MAXPATHLEN + 1];
	char *str2 = dname_data, *dname = dname_data;
	size_t len = 0;

	if (data->bin == NULL)
		return;

	snprintf(str2, MAXPATHLEN + 1, "%s", data->bin);

	if ((dname = dirname(str2)) == NULL)
		return;

	if (data->path == NULL)
		return;

	/* Make a copy since strtok_r will modify path */
	snprintf(str, MAXPATHLEN + 1, "%s", data->path);

	token = strtok_r(str, ":", &state);

	/* Check if we already appended our bin location to PATH */
	if ((token != NULL) && strlen(token))
		if (!strcmp(token, dname))
			return;

	len = strlen(dname) + strlen(data->path) + 2 + strlen("PATH") + 1;

	newpath = xmalloc(len);
	memset(newpath, 0, len);

	snprintf(newpath, len, "PATH=%s:%s", dname, data->path);
	putenv(newpath);
}

static char *abi_flags[] = {
	"-m32", "-m64", "-mabi", NULL
};
static char **build_new_argv(char **argv, const char *newflags_str)
{
#define MAX_NEWFLAGS 32
	char *newflags[MAX_NEWFLAGS];
	char **retargv;
	unsigned int argc, i;
	char *state, *flags_tokenized;

	retargv = argv;

	/* make sure user hasn't specified any ABI flags already ...
	 * if they have, lets just get out of here ... this of course
	 * is by no means complete, it's merely a hack that works most
	 * of the time ...
	 */
	for (argc = 0; argv[argc]; ++argc)
		for (i = 0; abi_flags[i]; ++i)
			if (!strncmp(argv[argc], abi_flags[i], strlen(abi_flags[i])))
				return retargv;

	/* Tokenize the flag list and put it into newflags array */
	flags_tokenized = xstrdup(newflags_str);
	i = 0;
	newflags[i] = strtok_r(flags_tokenized, " \t\n", &state);
	while (newflags[i] != NULL && i < MAX_NEWFLAGS-1)
		newflags[++i] = strtok_r(NULL, " \t\n", &state);

	/* allocate memory for our spiffy new argv */
	retargv = xcalloc(argc + i + 1, sizeof(char*));
	/* start building retargv */
	retargv[0] = argv[0];
	/* insert the ABI flags first so cmdline always overrides ABI flags */
	memcpy(retargv+1, newflags, i * sizeof(char*));
	/* copy over the old argv */
	if (argc > 1)
		memcpy(retargv+1+i, argv+1, (argc-1) * sizeof(char*));

	return retargv;
}

int main(int argc, char *argv[])
{
	struct wrapper_data data;

	memset(&data, 0, sizeof(data));

	if (getenv("PATH"))
		data.path = xstrdup(getenv("PATH"));

	/* What should we find ? */
	data.name = basename(xstrdup(argv[0]));

	/* Allow for common compiler names like cc->gcc */
	size_t i;
	for (i = 0; wrapper_aliases[i].alias; ++i)
		if (!strcmp(data.name, wrapper_aliases[i].alias))
			data.name = wrapper_aliases[i].target;

	/* What is the full name of our wrapper? */
	data.fullname = xmalloc(strlen(data.name) + sizeof("@GENTOO_PORTAGE_EPREFIX@/usr/bin/") + 1);
	sprintf(data.fullname, "@GENTOO_PORTAGE_EPREFIX@/usr/bin/%s", data.name);

	find_wrapper_target(&data);

	modify_path(&data);

	free(data.path);
	data.path = NULL;

	/* Set argv[0] to the correct binary, else gcc can't find internal headers
	 * http://bugs.gentoo.org/8132
	 */
	argv[0] = data.bin;

	/* If $ABI is in env, add appropriate env flags */
	char **newargv = argv;
	if (getenv("ABI")) {
		char envvar[50];

		/* We use CFLAGS_${ABI} for gcc, g++, g77, etc as the flags that would
		 * be in there are the same no matter which compiler we are using.
		 */
		snprintf(envvar, sizeof(envvar), "CFLAGS_%s", getenv("ABI"));
		envvar[sizeof(envvar)-1] = '\0';

		if (getenv(envvar))
			newargv = build_new_argv(argv, getenv(envvar));
	}

	/* Ok, lets do it one more time ... */
	execv(data.bin, newargv);

	/* shouldn't have made it here if things worked ... */
	wrapper_err("could not run/locate '%s'", data.name);

	return 123;
}
