# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kde-source.eclass,v 1.24 2006/10/14 20:27:21 swegener Exp $
#
# Author Dan Armak <danarmak@gentoo.org>
#
# This is for kde-base cvs ebuilds. Read comments about settings.
# It uses $S and sets $SRC_URI, so inherit it as late as possible (certainly after any other eclasses).
# See http://www.gentoo.org/~danarmak/kde-cvs.html !
# All of the real functionality is in cvs.eclass; this just adds some trivial kde-specific items


# --- begin user-configurable settings ---

# Set yours in profile (e.g. make.conf), or export from the command line to override.
# Most have acceptable default values or are set by the ebuilds, but be sure to read the comments
# in cvs.eclass for detailed descriptions of them all.
# You should probably set at least ECVS_SERVER.

# TODO: add options to store the modules as tarballs in $DISTDIR or elsewhere

# Under this directory the cvs modules are stored/accessed
# Storing in tarballs in $DISTDIR to be implemented soon
[ -z "$ECVS_TOP_DIR" ] && ECVS_TOP_DIR="$DISTDIR/cvs-src/kde"

# Set to name of cvs server. Set to "" to disable fetching (offline mode).
# In offline mode, we presume that modules are already checked out at the specified
# location and that they shouldn't be updated.
# Format example: "anoncvs.kde.org:/home/kde" (without :pserver:anonymous@ part)
# Mirror list is available at http://developer.kde.org/source/anoncvs.html
[ -z "$ECVS_SERVER" ] && ECVS_SERVER="anoncvs.kde.org:/home/kde"
[ -z "$ECVS_AUTH" ] && ECVS_AUTH="pserver"

# for apps living inside modules like kdenonbeta - see also beginning of our _src_unpack
# KCVS_SUBDIR=...

# If a tag is specified as ECVS_BRANCH, it will be used for the kde-common module
# as well. If that is wrong (fex when checking out kopete branch kopete_0_6_2_release),
# use KCVS_BRANCH instead.

# you can set this variable (in your ebuild, of course) to disable fetching of <module>/doc/*
# under the KCVS_SUBDIR scheme. this is appropriate for kde-i18n stuff, but not for
# eg kdeextragear, kdenonbeta etc.
# KCVS_SUBDIR_NODOC=true

# Other variables: see cvs.eclass

# we do this here and not in the very beginning because we need to keep
# the configuration order intact: env. and profile settings override
# kde-source.eclass defaults, which in turn override cvs.eclass defaults
inherit cvs
#... and reset $ECLASS. Ugly I know, hopefully I can prettify it someday

# --- end user-configurable settings ---

DESCRIPTION="$DESCRIPTION (cvs) "

# set this to more easily maintain cvs and std ebuilds side-by-side
# (we don't need to remove SRC_URI, kde-dist.eclass, kde.org.eclass etc
# from the cvs ones). To download patches or something, set SRC_URI again after
# inheriting kde_source.
SRC_URI=""


if [ -n "$KCVS_SUBDIR" -o -n "$KCVS_MODULE" ]; then
	S="$WORKDIR/$KCVS_MODULE"
else
	# default for kde-base ebuilds
	S="$WORKDIR/${ECVS_MODULE:-$PN}"
fi


kde-source_src_unpack() {

	debug-print-function $FUNCNAME $*

	# decide what the main module is that we're fetching and call cvs_src_unpack
	# the other things are fetched later
	# (kde-common/admin, <module>/doc/*, <module>/<files>)
	if [ -n "$KCVS_SUBDIR" ]; then
		ECVS_MODULE="$KCVS_MODULE/$KCVS_SUBDIR"
	elif [ -n "$KCVS_MODULE" ]; then
		ECVS_MODULE="$KCVS_MODULE"
	else
		# default for kde-base ebuilds
		ECVS_MODULE="$PN"
	fi

	cvs_src_unpack

	# subdirs of kde modules get special treatment that is designed for
	# subdirs which are separate selfcontained apps and only need
	# automake/autoconf stuff etc. added to them.
	# this fits for apps from kdenonbeta, kdeextragear modules etc.
	# So, if we just fetched a module's subdir, fetch the top directory
	# of the module (non-recursively) and make it build only the subdirectory
	# we need.
	# ECVS_LOCALNAME note: disabled when KCVS_SUBDIR is enabled because the logic
	# of how it should work is unclear and I don't see any need for it here anyway
	if [ -n "$KCVS_SUBDIR" ]; then

		if [ -n "$KCVS_BRANCH" ]; then
			ECVS_BRANCH2="$ECVS_BRANCH"
			ECVS_BRANCH="$KCVS_BRANCH"
		fi

		ECVS_MODULE="$KCVS_MODULE" ECVS_LOCAL=yes cvs_src_unpack

		# we need the <module>/doc/<name> directory too,
		# and we need the top-level doc/ directory fetched locally
		ECVS_MODULE="${KCVS_MODULE}/doc" ECVS_LOCAL=yes cvs_src_unpack

		# but, if such a directory doesn't exist on the cvs server and we're
		# in offline mode cvs.eclass will abort, so only call this if we're
		# in online mode or the dir is already fetched
		# also, the ebuild might have disabled this functionality explicitly
		# (kde-i18n stuff does this for now)
		if [ -z "$KCVS_SUBDIR_NODOC" ] && [ -d "$ECVS_TOP_DIR/$KCVS_MODULE/doc/$KCVS_SUBDIR" -o "$ECVS_SERVER" != "offline" ]; then
			ECVS_MODULE="${KCVS_MODULE}/doc/${KCVS_SUBDIR}" cvs_src_unpack
		fi

		if [ -n "$KCVS_BRANCH" ]; then
			ECVS_BRANCH="$ECVS_BRANCH2"
		fi

	fi

	# typically for kde cvs apps, the admin subdir lives in the kde-common module
	# which is also needed
	if [ ! -d "$S/admin" ]; then
		ECVS_MODULE="kde-common/admin" cvs_src_unpack
		mv ${WORKDIR}/kde-common/admin $S/
	fi

	# make sure we give them a clean cvs checkout
	cd ${S}
	[ -f "admin/cvs-clean.pl" ] && make -f admin/Makefile.common cvs-clean
	[ -f "config.cache" ] && rm config.cache

}


EXPORT_FUNCTIONS src_unpack

