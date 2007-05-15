# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-base-r1.eclass,v 1.7 2007/05/12 02:54:35 chtekk Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-ext-base-r1 eclass provides a unified interface for adding standalone
# PHP extensions ('modules') to the php.ini files on your system.
#
# Combined with php-ext-source-r1, we have a standardised solution for supporting
# PHP extensions.

inherit depend.php

EXPORT_FUNCTIONS src_install

# The extension name, this must be set, otherwise we die
[[ -z "${PHP_EXT_NAME}" ]] && die "No module name specified for the php-ext-base-r1 eclass"

# Wether or not to add a line to php.ini for the extension
# (defaults to "yes" and shouldn't be changed in most cases)
[[ -z "${PHP_EXT_INI}" ]] && PHP_EXT_INI="yes"

# Wether the extension is a ZendEngine extension or not
# (defaults to "no" and if you don't know what is it, you don't need it)
[[ -z "${PHP_EXT_ZENDEXT}" ]] && PHP_EXT_ZENDEXT="no"

php-ext-base-r1_buildinilist() {
	# Work out the list of <ext>.ini files to edit/add to
	if [[ -z "${PHPSAPILIST}" ]] ; then
		PHPSAPILIST="apache2 cli cgi"
	fi

	PHPINIFILELIST=""

	for x in ${PHPSAPILIST} ; do
		if [[ -f "/etc/php/${x}-php${PHP_VERSION}/php.ini" ]] ; then
			PHPINIFILELIST="${PHPINIFILELIST} etc/php/${x}-php${PHP_VERSION}/ext/${PHP_EXT_NAME}.ini"
		fi
	done
}

php-ext-base-r1_src_install() {
	# Pull in the PHP settings
	has_php
	addpredict /usr/share/snmp/mibs/.index

	# Build the list of <ext>.ini files to edit/add to
	php-ext-base-r1_buildinilist

	# Add the needed lines to the <ext>.ini files
	if [[ "${PHP_EXT_INI}" = "yes" ]] ; then
		php-ext-base-r1_addextension "${PHP_EXT_NAME}.so"
	fi

	# Symlink the <ext>.ini files from ext/ to ext-active/
	for inifile in ${PHPINIFILELIST} ; do
		inidir="${inifile/${PHP_EXT_NAME}.ini/}"
		inidir="${inidir/ext/ext-active}"
		dodir "/${inidir}"
		dosym "/${inifile}" "/${inifile/ext/ext-active}"
	done

	# Add support for installing PHP files into a version dependant directory
	PHP_EXT_SHARED_DIR="/usr/share/${PHP_SHARED_CAT}/${PHP_EXT_NAME}"
}

php-ext-base-r1_addextension() {
	if [[ "${PHP_EXT_ZENDEXT}" = "yes" ]] ; then
		# We need the full path for ZendEngine extensions
		# and we need to check for debugging enabled!
		if has_zts ; then
			if has_debug ; then
				ext_type="zend_extension_debug_ts"
			else
				ext_type="zend_extension_ts"
			fi
			ext_file="${EXT_DIR}/$1"
		else
			if has_debug ; then
				ext_type="zend_extension_debug"
			else
				ext_type="zend_extension"
			fi
			ext_file="${EXT_DIR}/$1"
		fi
	else
		# We don't need the full path for normal extensions!
		ext_type="extension"
		ext_file="$1"
	fi

	php-ext-base-r1_addtoinifiles "${ext_type}" "${ext_file}" "Extension added"
}

# $1 - Setting name
# $2 - Setting value
# $3 - File to add to
# $4 - Sanitized text to output

php-ext-base-r1_addtoinifile() {
	if [[ ! -d `dirname $3` ]] ; then
		mkdir -p `dirname $3`
	fi

	# Are we adding the name of a section?
	if [[ ${1:0:1} == "[" ]] ; then
		echo "$1" >> "$3"
		my_added="$1"
	else
		echo "$1=$2" >> "$3"
		my_added="$1=$2"
	fi

	if [[ -z "$4" ]] ; then
		einfo "Added '$my_added' to /$3"
	else
		einfo "$4 to /$3"
	fi

	insinto /`dirname $3`
	doins "$3"
}

php-ext-base-r1_addtoinifiles() {
	for x in ${PHPINIFILELIST} ; do
		php-ext-base-r1_addtoinifile "$1" "$2" "$x" "$3"
	done
}
