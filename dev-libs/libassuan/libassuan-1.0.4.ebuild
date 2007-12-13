# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libassuan/libassuan-1.0.4.ebuild,v 1.1 2007/12/12 19:39:57 alonbl Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Standalone IPC library used by gpg, gpgme and newpg"
HOMEPAGE="http://www.gnupg.org/(en)/download/index.html#libassuan"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/pth-1.3.7
	>=dev-libs/libgpg-error-1.4"
RDEPEND="${DEPEND}"

src_compile() {
	# https://bugs.g10code.com/gnupg/issue817
	append-flags "-fpic -fPIC"
	append-ldflags "-fpic -fPIC"

	econf || die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
