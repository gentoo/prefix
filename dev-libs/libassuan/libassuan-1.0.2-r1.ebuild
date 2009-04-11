# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libassuan/libassuan-1.0.2-r1.ebuild,v 1.11 2008/08/30 06:16:44 dragonheart Exp $

inherit flag-o-matic

DESCRIPTION="Standalone IPC library used by gpg, gpgme and newpg"
HOMEPAGE="http://www.gnupg.org/related_software/libassuan.en.html"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
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
