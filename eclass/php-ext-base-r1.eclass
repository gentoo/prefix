# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-base-r1.eclass,v 1.5 2007/02/02 19:09:33 chtekk Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
# Maintained by the PHP Herd <php-bugs@gentoo.org>
#
# The php-ext-base-r1 eclass provides a unified interface for adding standalone
# PHP extensions ('modules') to the php.ini files on your system.
#
# Combined with php-ext-source-r1, we have a standardised solution for supporting
# PHP extensions.

inherit depend.php

EXPORT_FUNCTIONS src_install

# ---begin ebuild configurable settings

# The extension name, this must be set, otherwise we die.
[ -z "${PHP_EXT_NAME}" ] && die "No module name specified for the php-ext eclass."

# Wether the extensions is a Zend Engine extension
#(defaults to "no" and if you don't know what is it, you don't need it.)
[ -z "${PHP_EXT_ZENDEXT}" ] && PHP_EXT_ZENDEXT="no"

# Wether or not to add a line in the php.ini for the extension
# (defaults to "yes" and shouldn't be changed in most cases)
[ -z "${PHP_EXT_INI}" ] && PHP_EXT_INI="yes"

# ---end ebuild configurable settings

DEPEND="${DEPEND}
		>=sys-devel/m4-1.4.3
		>=sys-devel/libtool-1.5.18
		>=sys-devel/automake-1.9.6
		sys-devel/automake-wrapper
		>=sys-devel/autoconf-2.59
		sys-devel/autoconf-wrapper"

php-ext-base-r1_buildinilist() {
	# work out the list of .ini files to edit/add to
	if [ -z "${PHPSAPILIST}" ]; then
		PHPSAPILIST="apache1 apache2 cli cgi"
	fi

	PHPINIFILELIST=

	for x in ${PHPSAPILIST} ; do
		if [ -f /etc/php/${x}-php${PHP_VERSION}/php.ini ]; then
			PHPINIFILELIST="${PHPINIFILELIST} etc/php/${x}-php${PHP_VERSION}/ext/${PHP_EXT_NAME}.ini"
		fi
	done
}

php-ext-base-r1_src_install() {
	has_php
	addpredict /usr/share/snmp/mibs/.index
	php-ext-base-r1_buildinilist
	if [ "${PHP_EXT_INI}" = "yes" ] ; then
		php-ext-base-r1_addextension "${PHP_EXT_NAME}.so"
	fi
	for inifile in ${PHPINIFILELIST} ; do
		inidir=${inifile/${PHP_EXT_NAME}.ini/}
		inidir=${inidir/ext/ext-active}
		dodir "/${inidir}"
		dosym "/${inifile}" "/${inifile/ext/ext-active}"
	done
	# add support for installing php files into a version dependant directory
	PHP_EXT_SHARED_DIR="/usr/share/${PHP_SHARED_CAT}/${PHP_EXT_NAME}"
}

php-ext-base-r1_addextension() {
	if [ "${PHP_EXT_ZENDEXT}" = "yes" ] ; then
		if has_zts ; then
			ext_type="zend_extension_ts"
			ext_file="${EXT_DIR}/$1"
		else
			ext_type="zend_extension"
			ext_file="${EXT_DIR}/$1"
		fi
	else
		# we do *not* add the full path for the extension!
		ext_type="extension"
		ext_file="$1"
	fi

	php-ext-base-r1_addtoinifiles "${ext_type}" "${ext_file}" "Extension added"
}

# $1 - setting name
# $2 - setting value
# $3 - file to add to
# $4 - sanitised text to output

php-ext-base-r1_addtoinifile() {
	if [[ ! -d `dirname $3` ]]; then
		mkdir -p `dirname $3`
	fi

	# are we adding the name of a section?
	if [[ ${1:0:1} == "[" ]] ; then
		echo "$1" >> $3
		my_added="$1"
	else
		echo "$1=$2" >> $3
		my_added="$1=$2"
	fi

	if [ -z "$4" ]; then
		einfo "Added '$my_added' to /$3"
	else
		einfo "$4 to /$3"
	fi

	# yes, this is inefficient - but it works every time ;-)

	insinto /`dirname $3`
	doins $3
}

php-ext-base-r1_addtoinifiles() {
	for x in ${PHPINIFILELIST} ; do
		php-ext-base-r1_addtoinifile "$1" "$2" "$x" "$3"
	done
}
