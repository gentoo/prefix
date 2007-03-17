# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-lib-r1.eclass,v 1.5 2007/03/05 01:50:47 chtekk Exp $
#
# Author: Stuart Herbert <stuart@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-lib-r1 eclass provides a unified interface for adding new
# PHP libraries. PHP libraries are PHP scripts designed for reuse inside
# other PHP scripts.

inherit depend.php

EXPORT_FUNCTIONS src_install

DEPEND="dev-lang/php"
RDEPEND="${DEPEND}"

# provide default extension name if necessary
[[ -z "${PHP_LIB_NAME}" ]] && PHP_LIB_NAME="${PN}"

# you have to pass in a list of the PHP files to install
#
# $1 - directory in ${S} to insert from
# $2 ... list of files to install

php-lib-r1_src_install() {
	has_php

	# install to the correct phpX folder, if not specified
	# fall back to /usr/share/php
	if [[ -n "${PHP_SHARED_CAT}" ]] ; then
		PHP_LIB_DIR="/usr/share/${PHP_SHARED_CAT}/${PHP_LIB_NAME}"
	else
		PHP_LIB_DIR="/usr/share/php/${PHP_LIB_NAME}"
	fi

	local x

	S_DIR="$1"
	shift

	for x in $@ ; do
		SUBDIR="`dirname ${x}`"
		insinto "${PHP_LIB_DIR}/${SUBDIR}"
		doins "${S_DIR}/${x}"
	done
}
