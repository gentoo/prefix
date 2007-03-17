# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-pecl-r1.eclass,v 1.5 2007/03/05 01:50:47 chtekk Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# This eclass should be used by all dev-php[4,5]/pecl-* ebuilds, as a uniform way of installing PECL extensions.
# For more information about PECL, see http://pecl.php.net/

[[ -z "${PHP_EXT_PECL_PKG}" ]] && PHP_EXT_PECL_PKG="${PN/pecl-/}"

PECL_PKG="${PHP_EXT_PECL_PKG}"
MY_PV="${PV/_/}"
PECL_PKG_V="${PECL_PKG}-${MY_PV}"

[[ -z "${PHP_EXT_NAME}" ]] && PHP_EXT_NAME="${PECL_PKG}"

inherit php-ext-source-r1 depend.php

EXPORT_FUNCTIONS src_compile src_install

# Needs to be set if the filename differs from the package name
if [[ -n "${PHP_EXT_PECL_FILENAME}" ]] ; then
	FILENAME="${PHP_EXT_PECL_FILENAME}-${MY_PV}.tgz"
else
	FILENAME="${PECL_PKG_V}.tgz"
fi

SRC_URI="http://pecl.php.net/get/${FILENAME}"
HOMEPAGE="http://pecl.php.net/${PECL_PKG}"

S="${WORKDIR}/${PECL_PKG_V}"

php-ext-pecl-r1_src_compile() {
	has_php
	php-ext-source-r1_src_compile
}

php-ext-pecl-r1_src_install() {
	has_php
	php-ext-source-r1_src_install

	# Those two are always present
	dodoc-php "${WORKDIR}/package.xml" CREDITS
}
