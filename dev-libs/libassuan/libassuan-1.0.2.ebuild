# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libassuan/libassuan-1.0.2.ebuild,v 1.3 2007/07/06 17:39:20 alonbl Exp $

EAPI="prefix"

DESCRIPTION="Standalone IPC library used by gpg, gpgme and newpg"
HOMEPAGE="http://www.gnupg.org/(en)/download/index.html#libassuan"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND="
	virtual/libc
	>=dev-libs/pth-1.3.7
	>=dev-libs/libgpg-error-1.4"
RDEPEND="${DEPEND}"

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
