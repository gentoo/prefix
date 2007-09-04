# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-sapi.eclass,v 1.93 2007/09/02 17:49:20 jokey Exp $
# Author: Robin H. Johnson <robbat2@gentoo.org>

# DEPRECATED!!! 
# STOP USING THIS ECLASS, use one of the php?_?-sapi eclasses instead!

deprecation_warning() {
	eerror "Please upgrade ${PF} to use one of the php?_?-sapi eclasses instead!"
}

php-sapi_check_java_config() {
	deprecation_warning
}

php-sapi_src_unpack() {
	deprecation_warning
}

php-sapi_src_compile() {
	deprecation_warning
}

php-sapi_src_install() {
	deprecation_warning
}

php-sapi_pkg_preinst() {
	deprecation_warning
}

php-sapi_pkg_postinst() {
	deprecation_warning
}

php-sapi_securityupgrade() {
	deprecation_warning
}

php-sapi_warning_mssql_freetds() {
	deprecation_warning
}
