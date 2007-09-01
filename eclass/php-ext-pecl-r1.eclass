# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-pecl-r1.eclass,v 1.7 2007/08/31 10:00:56 jokey Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Author: Jakub Moc <jakub@gentoo.org>

# @ECLASS: php-ext-pecl-r1.eclass
# @MAINTAINER:
# Gentoo PHP team <php-bugs@gentoo.org>
# @BLURB: A uniform way of installing PECL extensions
# @DESCRIPTION:
# This eclass should be used by all dev-php[45]/pecl-* ebuilds
# as a uniform way of installing PECL extensions.
# For more information about PECL, see http://pecl.php.net/

# @VARIABLE: PHP_EXT_PECL_FILENAME
# @DESCRIPTION: 
# Set in ebuild if the filename differs from the package name so that SRC_URI gets set correctly.

# @VARIABLE: DOCS
# @DESCRIPTION: 
# Set in ebuild if you wish to install additional, package-specific documentation.

[[ -z "${PHP_EXT_PECL_PKG}" ]] && PHP_EXT_PECL_PKG="${PN/pecl-/}"

PECL_PKG="${PHP_EXT_PECL_PKG}"
MY_PV="${PV/_/}"
PECL_PKG_V="${PECL_PKG}-${MY_PV}"

[[ -z "${PHP_EXT_NAME}" ]] && PHP_EXT_NAME="${PECL_PKG}"

inherit php-ext-source-r1 depend.php

EXPORT_FUNCTIONS src_compile src_install

if [[ -n "${PHP_EXT_PECL_FILENAME}" ]] ; then
	FILENAME="${PHP_EXT_PECL_FILENAME}-${MY_PV}.tgz"
else
	FILENAME="${PECL_PKG_V}.tgz"
fi

SRC_URI="http://pecl.php.net/get/${FILENAME}"
HOMEPAGE="http://pecl.php.net/${PECL_PKG}"

S="${WORKDIR}/${PECL_PKG_V}"

# @FUNCTION: php-ext-pecl-r1_src_compile
# @DESCRIPTION:
# Takes care of standard compile for PECL packages.
php-ext-pecl-r1_src_compile() {
	has_php
	php-ext-source-r1_src_compile
}

# @FUNCTION: php-ext-pecl-r1_src_install
# @DESCRIPTION:
# Takes care of standard install for PECL packages.
# You can also simply add examples to IUSE to automagically install 
# examples supplied with the package.
php-ext-pecl-r1_src_install() {
	has_php
	php-ext-source-r1_src_install

	# Those two are always present.
	dodoc-php "${WORKDIR}/package.xml" CREDITS

	for doc in ${DOCS} ; do
		[[ -s ${doc} ]] && dodoc-php ${doc}
	done

	if has examples ${IUSE} && use examples ; then
		insinto /usr/share/doc/${CATEGORY}/${PF}/examples
		doins -r examples/*
	fi
}
