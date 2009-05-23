# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/t1utils/t1utils-1.34.ebuild,v 1.12 2009/05/22 14:38:23 aballier Exp $

inherit eutils

IUSE=""

DESCRIPTION="Type 1 Font utilities"
SRC_URI="http://www.lcdf.org/type/${P}.tar.gz"
HOMEPAGE="http://www.lcdf.org/type/#t1utils"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
LICENSE="BSD"

DEPEND="virtual/libc"
RDEPEND="${DEPEND}
	!<media-libs/freetype-1.4_pre20080316"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/t1utils-1.34-glibc-2.10.patch
}

src_install () {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc NEWS README
}
