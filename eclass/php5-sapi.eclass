# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php5-sapi.eclass,v 1.59 2007/09/02 17:49:20 jokey Exp $
#
# eclass/php5-sapi.eclass
#		Eclass for building different php5 SAPI instances
#
#		Based on robbat2's work on the php4 sapi eclass
#
# Author(s)		Stuart Herbert
#				<stuart@gentoo.org>
#
# ========================================================================

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php5_2-sapi eclass instead!

inherit php5_2-sapi

deprecation_warning() {
        eerror "Please upgrade ${PF} to use php5_2-sapi eclass instead!"
}

php5-sapi_check_awkward_uses() {
	deprecation_warning
	php5_2-sapi_check_use_flags
}

php5-sapi_pkg_setup() {
	deprecation_warning
	php5_2-sapi_pkg_setup
}

php5-sapi_src_unpack() {
	deprecation_warning
	php5_2-sapi_src_unpack
}

php5-sapi_src_compile() {
	deprecation_warning
	php5_2-sapi_src_compile
}

php5-sapi_src_install() {
	deprecation_warning
	php5_2-sapi_src_install
}

php5-sapi_pkg_postinst() {
	deprecation_warning
	php5_2-sapi_pkg_postinst
}
