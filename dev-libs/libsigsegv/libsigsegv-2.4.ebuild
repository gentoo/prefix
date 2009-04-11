# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libsigsegv/libsigsegv-2.4.ebuild,v 1.13 2008/07/07 13:14:19 armin76 Exp $

inherit eutils autotools

DESCRIPTION="GNU libsigsegv is a library for handling page faults in user mode."
HOMEPAGE="ftp://ftp.gnu.org/pub/gnu/libsigsegv/"
SRC_URI="mirror://gnu/libsigsegv/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-ppc-macos.patch
	AT_M4DIR=m4 eautoreconf
}

src_compile() {
	econf --enable-shared
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed."
	dodoc AUTHORS ChangeLog* NEWS PORTING README* || die
}
