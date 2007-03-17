# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-source-r1.eclass,v 1.6 2007/03/05 01:50:47 chtekk Exp $
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

inherit php-ext-base-r1 flag-o-matic

EXPORT_FUNCTIONS src_compile src_install

# ---begin ebuild configurable settings

# Wether or not to add a line in the php.ini for the extension
# (defaults to "yes" and shouldn't be changed in most cases)
[ -z "${PHP_EXT_INI}" ] && PHP_EXT_INI="yes"

# ---end ebuild configurable settings

DEPEND=">=sys-devel/m4-1.4.3
		>=sys-devel/libtool-1.5.18
		>=sys-devel/automake-1.9.6
		sys-devel/automake-wrapper
		>=sys-devel/autoconf-2.59
		sys-devel/autoconf-wrapper"

php-ext-source-r1_src_compile() {
	# Pull in the PHP settings
	has_php
	cd "${S}"
	my_conf="${my_conf} --prefix=${PHPPREFIX} --with-php-config=${PHPCONFIG}"
	addpredict /usr/share/snmp/mibs/.index

	# Create configure out of config.m4
	${PHPIZE}

	# Set needed automake/autoconf versions
	export WANT_AUTOMAKE=1.9 WANT_AUTOCONF=2.5

	# Concurrent PHP Apache2 modules support
	if built_with_use =${PHP_PKG} apache2 || phpconfutils_built_with_use =${PHP_PKG} apache2 ; then
		if built_with_use =${PHP_PKG} concurrentmodphp || phpconfutils_built_with_use =${PHP_PKG} concurrentmodphp ; then
			append-ldflags "-Wl,--version-script=${ROOT}/var/lib/php-pkg/${PHP_PKG}/php${PHP_VERSION}-ldvs"
		fi
	fi

	# First compile run: the default
	./configure ${my_conf} || die "Unable to configure code to compile"
	emake || die "Unable to make code"
	mv -f "modules/${PHP_EXT_NAME}.so" "${WORKDIR}/${PHP_EXT_NAME}-default.so" || die "Unable to move extension"

	# Concurrent PHP Apache2 modules support
	if built_with_use =${PHP_PKG} apache2 || phpconfutils_built_with_use =${PHP_PKG} apache2 ; then
		if built_with_use =${PHP_PKG} concurrentmodphp || phpconfutils_built_with_use =${PHP_PKG} concurrentmodphp ; then
			# First let's clean up
			make distclean || die "Unable to clean build environment"

			# Second compile run: the versioned one
			append-ldflags "-Wl,--allow-shlib-undefined -L/usr/$(get_libdir)/apache2/modules/ -lphp${PHP_VERSION}"
			./configure ${my_conf} || die "Unable to configure code to compile"
			emake || die "Unable to make code"
			mv -f "modules/${PHP_EXT_NAME}.so" "${WORKDIR}/${PHP_EXT_NAME}-versioned.so" || die "Unable to move extension"
		fi
	fi
}

php-ext-source-r1_src_install() {
	has_php

	# Let's put the default module away
	insinto "${EXT_DIR}"
	newins "${WORKDIR}/${PHP_EXT_NAME}-default.so" "${PHP_EXT_NAME}.so"

	# And now the versioned one
	if built_with_use =${PHP_PKG} apache2 || phpconfutils_built_with_use =${PHP_PKG} apache2 ; then
		if built_with_use =${PHP_PKG} concurrentmodphp || phpconfutils_built_with_use =${PHP_PKG} concurrentmodphp ; then
			insinto "${EXT_DIR}-versioned"
			newins "${WORKDIR}/${PHP_EXT_NAME}-versioned.so" "${PHP_EXT_NAME}.so"
		fi
	fi

	php-ext-base-r1_src_install
}
