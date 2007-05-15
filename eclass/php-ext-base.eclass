# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-base.eclass,v 1.20 2007/05/12 02:54:35 chtekk Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
#
# The php-ext-base eclass provides a unified interface for adding standalone
# PHP extensions ('modules') to the php.ini files on your system.
#
# Combined with php-ext-source, we have a standardised solution for supporting
# PHP extensions


EXPORT_FUNCTIONS src_install

# ---begin ebuild configurable settings

# The extension name, this must be set, otherwise we die.
[ -z "$PHP_EXT_NAME" ] && die "No module name specified for the php-ext eclass."

# Wether the extensions is a Zend Engine extension
#(defaults to "no" and if you don't know what is it, you don't need it.)
[ -z "$PHP_EXT_ZENDEXT" ] && PHP_EXT_ZENDEXT="no"

# Wether or not to add a line in the php.ini for the extension
# (defaults to "yes" and shouldn't be changed in most cases)
[ -z "$PHP_EXT_INI" ] && PHP_EXT_INI="yes"

# find out where to install extensions
EXT_DIR="`php-config --extension-dir 2>/dev/null`"

# ---end ebuild configurable settings

DEPEND="${DEPEND}
		dev-php/php
		>=sys-devel/m4-1.4
		>=sys-devel/libtool-1.4.3"

RDEPEND="${RDEPEND}
		virtual/php"

php-ext-base_buildinilist () {
	# work out the list of .ini files to edit/add to

	if [ -z "${PHPSAPILIST}" ]; then
		PHPSAPILIST="apache2 cli cgi"
	fi

	PHPINIFILELIST=

	for x in ${PHPSAPILIST} ; do
		if [ -f /etc/php/${x}-php4/php.ini ]; then
			PHPINIFILELIST="${PHPINIFILELIST} etc/php/${x}-php4/php.ini"
		fi

		if [ -f /etc/php/${x}-php5/php.ini ]; then
			PHPINIFILELIST="${PHPINIFILELIST} etc/php/${x}-php5/php.ini"
		fi
	done

	if [ "${PHPINIFILELIST}+" = "+" ] ; then
		# backwards support for the old location

		if [ -f /etc/php4/php.ini ] ; then
			PHPINIFILELIST="etc/php4/php.ini"
		else
			msg="No PHP ini files found for this extension"
			eerror ${msg}
			die ${msg}
		fi
	fi

#	einfo "php.ini files found in $PHPINIFILELIST"
}

php-ext-base_src_install() {
	addpredict /usr/share/snmp/mibs/.index
	php-ext-base_buildinilist
	if [ "$PHP_EXT_INI" = "yes" ] ; then
		php-ext-base_addextension "${PHP_EXT_NAME}.so"
	fi
}

php-ext-base_addextension () {
	if [ "${PHP_EXT_ZENDEXT}" = "yes" ]; then
		ext_type="zend_extension"
		ext_file="${EXT_DIR}/$1"
	else
		# we do *not* add the full path for the extension!
		ext_type="extension"
		ext_file="$1"
	fi

	php-ext-base_addtoinifiles "$ext_type" "$ext_file" "Extension added"
}

php-ext-base_setting_is_present () {
	grep "^$1=$2" /$3 > /dev/null 2>&1
}

php-ext-base_inifileinimage () {
	if [ ! -f $1 ]; then
		mkdir -p `dirname $1`
		cp /$1 $1
	fi
}

# $1 - setting name
# $2 - setting value
# $3 - file to add to
# $4 - sanitised text to output

php-ext-base_addtoinifile () {
	if [ "$1" != "extension" ] && [ "$1" != "zend_extension" ]; then
		php-ext-base_setting_is_present $1 "" $3 && return
	else
		php-ext-base_setting_is_present "$1" "$2" "$3" && return
	fi

	php-ext-base_inifileinimage $3

	echo "$1=$2" >> $3

	if [ -z "$4" ]; then
		einfo "Added '$1=$2' to /$3"
	else
		einfo "$4 to /$3"
	fi

	# yes, this is inefficient - but it works every time ;-)

	insinto /`dirname $3`
	doins $3
}

php-ext-base_addtoinifiles () {
	for x in ${PHPINIFILELIST} ; do
		php-ext-base_addtoinifile $1 $2 $x "$3"
	done
}
