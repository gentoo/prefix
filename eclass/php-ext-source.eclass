# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ext-source.eclass,v 1.12 2007/09/02 19:17:44 jokey Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Stuart Herbert <stuart@gentoo.org>
#
# The php-ext-source eclass provides a unified interface for compiling and
# installing standalone PHP extensions ('modules') from source code

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php-ext-source-r1.eclass instead!

inherit php-ext-source-r1

deprecation_warning() {
        eerror "Please upgrade ${PF} to use php-ext-source-r1.eclass!"
}


php-ext-source_src_compile() {
	deprecation_warning
	php-ext-source-r1_src_compile
}

php-ext-source_src_install() {
	deprecation_warning
	php-ext-source-r1_src_install
}
