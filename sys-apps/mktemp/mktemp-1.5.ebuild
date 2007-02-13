# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/mktemp/mktemp-1.5.ebuild,v 1.1 2006/07/06 04:48:11 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="allow safe temporary file creation from shell scripts."
HOMEPAGE="http://www.mktemp.org/"
SRC_URI="ftp://ftp.mktemp.org/pub/mktemp/mktemp-1.5.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=sys-apps/debianutils-2.16.2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
}

src_compile() {
	econf --with-libc || die
	emake || die
}

src_install() {
	into /
	dobin mktemp || die
	newman mktemp.man mktemp.1
	dodoc README RELEASE_NOTES
}
