# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php5_0-sapi.eclass,v 1.37 2007/12/24 12:29:36 armin76 Exp $

# ========================================================================
#
# php5_0-sapi.eclass
#		Eclass for building different php5.0 SAPI instances
#
#		USE THIS ECLASS FOR THE "CONCENTRATED" PACKAGES
#
#		Based on robbat2's work on the php4 sapi eclass
#
# Author:	Stuart Herbert
#			<stuart@gentoo.org>
#
# Author:	Luca Longinotti
#			<chtekk@gentoo.org>
#
# ========================================================================

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use php5_2-sapi eclass instead!

inherit php5_2-sapi

deprecation_warning() {
        eerror "Please upgrade ${PF} to use php5_2-sapi eclass instead!"
}

php5_0-sapi_check_use_flags() {
        deprecation_warning
        php5_2-sapi_check_use_flags
}

php5_0-sapi_set_php_ini_dir() {
        deprecation_warning
	php5_2-sapi_set_php_ini_dir
}

php5_0-sapi_install_ini() {
        deprecation_warning
	php5_2-sapi_install_ini
}

php5_0-sapi_pkg_setup() {
	php5_0-sapi_check_use_flags
}

php5_0-sapi_src_unpack() {
	deprecation_warning
	php5_2-sapi_src_unpack
}

php5_0-sapi_src_compile() {
	deprecation_warning
	php5_2-sapi_src_compile
}

php5_0-sapi_src_install() {
	deprecation_warning
	php5_2-sapi_src_install
}

php5_0-sapi_pkg_postinst() {
	deprecation_warning
	php5_2-sapi_pkg_postinst
}
