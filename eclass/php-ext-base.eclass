# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-base.eclass,v 1.21 2007/09/02 17:49:20 jokey Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
#
# The php-ext-base eclass provides a unified interface for adding standalone
# PHP extensions ('modules') to the php.ini files on your system.
#
# Combined with php-ext-source, we have a standardised solution for supporting
# PHP extensions

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php-ext-base-r1.eclass instead!

inherit php-ext-base-r1

deprecation_warning() {
	eerror "Please upgrade ${PF} to use php-ext-base-r1.eclass!"
}

php-ext-base_buildinilist () {
	deprecation_warning
	php-ext-base-r1_buildinilist
}

php-ext-base_src_install() {
	deprecation_warning
	php-ext-base-r1_src_install
}

php-ext-base_addextension () {
	deprecation_warning
	php-ext-base-r1_addextension
}

php-ext-base_addtoinifile () {
	deprecation_warning
	php-ext-base-r1_addtoinifile
}

php-ext-base_addtoinifiles () {
	deprecation_warning
	php-ext-base-r1_addtoinifiles
}
