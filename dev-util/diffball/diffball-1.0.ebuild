# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/diffball/diffball-1.0.ebuild,v 1.9 2008/10/13 21:05:46 zmedico Exp $

IUSE="debug"

DESCRIPTION="Delta compression suite for using/generating binary patches"
HOMEPAGE="http://developer.berlios.de/projects/diffball/"
SRC_URI="mirror://berlios/diffball/${P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=">=sys-libs/zlib-1.1.4
	>=app-arch/bzip2-1.0.2"
RESTRICT="strip"

src_compile() {
	econf $(use_enable debug asserts)
	emake || die "emake failed"
}

src_install() {
	cd ${S}
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog README TODO
}
