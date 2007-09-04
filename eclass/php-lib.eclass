# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-lib.eclass,v 1.6 2007/09/02 17:49:20 jokey Exp $
#
# Author: Stuart Herbert <stuart@gentoo.org>
#
# The php-lib eclass provides a unified interface for adding new
# PHP libraries.  PHP libraries are PHP scripts designed for reuse inside
# other PHP scripts.
#
# This eclass doesn't do a lot (yet)

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php-lib-r1.eclass instead!

inherit php-lib-r1

deprecation_warning() {
	eerror "Please upgrade ${PF} to use php-lib-r1.eclass!"
}

php-lib_src_install() {
	deprecation_warning
	php-lib-r1_src_install
}
