# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-source-r1.eclass,v 1.9 2007/04/25 18:24:37 robbat2 Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-ext-source-r1 eclass provides a unified interface for compiling and
# installing standalone PHP extensions ('modules') from source code.
#
# To use this eclass, you must add the following to your ebuild:
#
# inherit php-ext-source-r1

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit php-ext-base-r1 flag-o-matic autotools depend.php

EXPORT_FUNCTIONS src_compile src_install

# The extension name, this must be set, otherwise we die
[[ -z "${PHP_EXT_NAME}" ]] && die "No module name specified for the php-ext-source-r1 eclass"

DEPEND=">=sys-devel/m4-1.4.3
		>=sys-devel/libtool-1.5.18"
RDEPEND=""

php-ext-source-r1_src_compile() {
	# Pull in the PHP settings
	has_php
	addpredict /usr/share/snmp/mibs/.index
	addpredict /session_mm_cli0.sem

	# Set the correct config options
	my_conf="--prefix=${PHPPREFIX} --with-php-config=${PHPCONFIG} ${my_conf}"

	# Create configure out of config.m4
		${PHPIZE}

	# Concurrent PHP Apache2 modules support
	if has_concurrentmodphp ; then
		append-ldflags "-Wl,--version-script=${EROOT}/var/lib/php-pkg/${PHP_PKG}/php${PHP_VERSION}-ldvs"
	fi

	# First compile run: the default one
	econf ${my_conf} || die "Unable to configure code to compile"
	emake || die "Unable to make code"
	mv -f "modules/${PHP_EXT_NAME}.so" "${WORKDIR}/${PHP_EXT_NAME}-default.so" || die "Unable to move extension"

	# Concurrent PHP Apache2 modules support
	if has_concurrentmodphp ; then
		# First let's clean up
		make distclean || die "Unable to clean build environment"

		# Second compile run: the versioned one
		econf ${my_conf} || die "Unable to configure versioned code to compile"
		sed -e "s|-Wl,--version-script=${EROOT}/var/lib/php-pkg/${PHP_PKG}/php${PHP_VERSION}-ldvs|-Wl,--version-script=${EROOT}/var/lib/php-pkg/${PHP_PKG}/php${PHP_VERSION}-ldvs -Wl,--allow-shlib-undefined -L/usr/$(get_libdir)/apache2/modules/ -lphp${PHP_VERSION}|g" -i Makefile
		append-ldflags "-Wl,--allow-shlib-undefined -L/usr/$(get_libdir)/apache2/modules/ -lphp${PHP_VERSION}"
		emake || die "Unable to make versioned code"
		mv -f "modules/${PHP_EXT_NAME}.so" "${WORKDIR}/${PHP_EXT_NAME}-versioned.so" || die "Unable to move versioned extension"
	fi
}

php-ext-source-r1_src_install() {
	# Pull in the PHP settings
	has_php
	addpredict /usr/share/snmp/mibs/.index

	# Let's put the default module away
	insinto "${EXT_DIR}"
	newins "${WORKDIR}/${PHP_EXT_NAME}-default.so" "${PHP_EXT_NAME}.so"

	# And now the versioned one, if it exists
	if has_concurrentmodphp ; then
		insinto "${EXT_DIR}-versioned"
		newins "${WORKDIR}/${PHP_EXT_NAME}-versioned.so" "${PHP_EXT_NAME}.so"
	fi

	php-ext-base-r1_src_install
}
