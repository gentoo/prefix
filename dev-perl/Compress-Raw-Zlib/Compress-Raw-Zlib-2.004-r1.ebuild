# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Compress-Raw-Zlib/Compress-Raw-Zlib-2.004-r1.ebuild,v 1.8 2007/08/25 13:17:23 vapier Exp $

EAPI="prefix"

inherit perl-module multilib

DESCRIPTION="Low-Level Interface to zlib compression library"
HOMEPAGE="http://search.cpan.org/~pmqs"
SRC_URI="mirror://cpan/authors/id/P/PM/PMQS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="dev-lang/perl
		sys-libs/zlib"

DEPEND=${RDEPEND}

SRC_TEST="do"

src_unpack() {
	perl-module_src_unpack

	cat - > "${S}/config.in" <<EOF
BUILD_ZLIB = False
INCLUDE = ${EPREFIX}/usr/include
LIB = ${EPREFIX}/usr/${get_libdir}

OLD_ZLIB = False
GZIP_OS_CODE = AUTO_DETECT
EOF
}
