# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-pecl.eclass,v 1.6 2007/09/02 17:49:20 jokey Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
#
# This eclass should be used by all dev-php/PECL-* ebuilds, as a uniform way of installing PECL extensions.
# For more information about PECL, see: http://pecl.php.net

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php-ext-pecl-r1.eclass instead!

inherit php-ext-pecl-r1

deprecation_warning() {
	eerror "Please upgrade ${PF} to use php-ext-pecl-r1.eclass!"
}

php-ext-pecl_src_compile() {
	deprecation_warning
	php-ext-pecl-r1_src_compile
}

php-ext-pecl_src_install() {
	deprecation_warning
	php-ext-pecl-r1_src_install
}
