# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-lib.eclass,v 1.5 2007/07/02 14:24:27 peper Exp $
#
# Author: Stuart Herbert <stuart@gentoo.org>
#
# The php-lib eclass provides a unified interface for adding new
# PHP libraries.  PHP libraries are PHP scripts designed for reuse inside
# other PHP scripts.
#
# This eclass doesn't do a lot (yet)

RESTRICT="${RESTRICT} strip"

EXPORT_FUNCTIONS src_install

# ---begin ebuild configurable settings

# provide default extension name if necessary
[ -z "$PHP_LIB_NAME" ] && PHP_LIB_NAME="${PN}"

PHP_LIB_DIR="/usr/lib/php/${PHP_LIB_NAME}"

# ---end ebuild configurable settings

DEPEND="${DEPEND}
		virtual/php"

# you have to pass in a list of the PHP files to install
#
# $1 - directory in ${S} to insert from
# $2 ... list of files to install

php-lib_src_install() {
	local x

	S_DIR="$1"
	shift

	for x in $@ ; do
		SUBDIR="`dirname $x`"
		insinto ${PHP_LIB_DIR}/${SUBDIR}
		doins ${S_DIR}/$x
	done
}

