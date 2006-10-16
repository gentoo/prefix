# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext.eclass,v 1.11 2006/10/14 20:27:21 swegener Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
#
# The php-ext eclass provides a unified interface for compiling and
# installing standalone PHP extensions ('modules').


EXPORT_FUNCTIONS src_compile src_install pkg_postinst

# ---begin ebuild configurable settings

# The extension name, this must be set, otherwise we die.
[ -z "$PHP_EXT_NAME" ] && die "No module name specified for the php-ext eclass."

# Wether the extensions is a Zend Engine extension
#(defaults to "no" and if you don't know what is it, you don't need it.)
[ -z "$PHP_EXT_ZENDEXT" ] && PHP_EXT_ZENDEXT="no"

# Wether or not to add a line in the php.ini for the extension
# (defaults to "yes" and shouldn't be changed in most cases)
[ -z "$PHP_EXT_INI" ] && PHP_EXT_INI="yes"

# ---end ebuild configurable settings

DEPEND="${DEPEND}
		virtual/php
		>=sys-devel/m4-1.4
		>=sys-devel/libtool-1.4.3"

RDEPEND="${RDEPEND}
		virtual/php"

php-ext_buildinilist () {
	# work out the list of .ini files to edit/add to

	if [ -z "${PHPSAPILIST}" ]; then
		PHPSAPILIST="apache1 apache2 cli"
	fi

	PHPINIFILELIST=""

	for x in ${PHPSAPILIST} ; do
		if [ -f /etc/php/${x}-php4/php.ini ]; then
			PHPINIFILELIST="${PHPINIFILELIST} /etc/php/${x}-php4/php.ini"
		fi
	done

	if [[ ${PHPINIFILELIST} = "" ]]; then
		msg="No PHP ini files found for this extension"
		eerror ${msg}
		die ${msg}
	fi

#	einfo "php.ini files found in $PHPINIFILELIST"
}

php-ext_src_compile() {
	addpredict /usr/share/snmp/mibs/.index
	#phpize creates configure out of config.m4
	phpize
	econf $myconf
	emake || die
}

php-ext_src_install() {
	chmod +x build/shtool
	#this will usually be /usr/lib/php/extensions/no-debug-no-zts-20020409/
	#but i prefer not taking this risk
	EXT_DIR="`php-config --extension-dir 2>/dev/null`"
	insinto $EXT_DIR
	doins modules/$PHP_EXT_NAME.so
}

php-ext_pkg_postinst() {
	if [ "$PHP_EXT_INI" = "yes" ] ; then
		php-ext_buildinilist
		php-ext_addextension "${EXT_DIR}/${PHP_EXT_NAME}.so"
	fi
}

php-ext_extension_is_present () {
	grep "^$1=$2" $3 > /dev/null 2>&1
}

php-ext_addextensiontoinifile () {
	php-ext_extension_is_present $1 $2 $3 && return

	einfo "Extension added to $3"
	echo "$1=$2" >> $3
}

php-ext_addextension () {
	if [ "${PHP_EXT_ZENDEXT}" = "yes" ]; then
		ext="zend_extension"
	else
		ext="extension"
	fi

	for x in ${PHPINIFILELIST} ; do
		php-ext_addextensiontoinifile "$ext" "$1" "$x"
	done
}

php-ext_setting_is_present () {
	grep "^$1=" $2 > /dev/null 2>&1
}

# $1 - setting name
# $2 - setting value
# $3 - file to add to

php-ext_addtoinifile () {
	php-ext_setting_is_present $1 $3 && return

	einfo "Added '$1=$2' to $3"
	echo "$1=$2" >> $3
}

php-ext_addtoinifiles () {
	for x in ${PHPINIFILELIST} ; do
		php-ext_addtoinifile $1 $2 $x
	done
}
