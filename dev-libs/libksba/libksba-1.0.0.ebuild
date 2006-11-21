# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libksba/libksba-1.0.0.ebuild,v 1.2 2006/10/30 18:58:58 alonbl Exp $

EAPI="prefix"

inherit libtool

DESCRIPTION="makes X.509 certificates and CMS easily accessible to applications"
HOMEPAGE="http://www.gnupg.org/(en)/download/index.html#libksba"
SRC_URI="mirror://gnupg/libksba/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=dev-libs/libgpg-error-1.2
	dev-libs/libgcrypt"

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
	if use ppc-macos;
	then
		touch gl/libgnu.la
		sed -i \
			-e 's|../gl/libgnu.la||g' \
			src/Makefile.in \
			|| die "sed failed"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README README-alpha THANKS TODO VERSION
}
