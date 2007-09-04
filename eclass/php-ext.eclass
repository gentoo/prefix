# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext.eclass,v 1.12 2007/09/02 17:49:20 jokey Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
#
# The php-ext eclass provides a unified interface for compiling and
# installing standalone PHP extensions ('modules').

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php-ext-source-r1.eclass instead!

inherit php-ext-source-r1 php-ext-base-r1

deprecation_warning() {
	eerror "Please upgrade ${PF} to use php-ext-source-r1.eclass!"
}

php-ext_buildinilist () {
	deprecation_warning
	php-ext-base-r1_buildinilist
}

php-ext_src_compile() {
	deprecation_warning
	php-ext-source-r1_src_compile
}

php-ext_src_install() {
	deprecation_warning
	php-ext-source-r1_src_install
}

php-ext_pkg_postinst() {
	deprecation_warning
}

php-ext_addextensiontoinifile () {
	deprecation_warning
	php-ext-base-r1_addtoinifiles
}

php-ext_addextension () {
	deprecation_warning
	php-ext-base-r1_addextension
}

php-ext_addtoinifile () {
	deprecation_warning
	php-ext-base-r1_addtoinifile
}

php-ext_addtoinifiles () {
	deprecation_warning
	php-ext-base-r1_addtoinifiles
}
