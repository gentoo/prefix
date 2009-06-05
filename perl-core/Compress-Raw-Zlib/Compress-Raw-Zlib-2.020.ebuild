# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Compress-Raw-Zlib/Compress-Raw-Zlib-2.020.ebuild,v 1.1 2009/06/03 22:22:05 tove Exp $

EAPI=2

MODULE_AUTHOR=PMQS
inherit multilib perl-module

DESCRIPTION="Low-Level Interface to zlib compression library"

SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND=">=sys-libs/zlib-1.2.2.1"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod )"

SRC_TEST="do"

src_prepare() {
	perl-module_src_prepare

	cat <<-EOF > "${S}/config.in"
		BUILD_ZLIB = False
		INCLUDE = /usr/include
		LIB = /usr/${get_libdir}

		OLD_ZLIB = False
		GZIP_OS_CODE = AUTO_DETECT
	EOF
}
