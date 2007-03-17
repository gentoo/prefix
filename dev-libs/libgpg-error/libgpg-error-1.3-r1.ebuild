# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgpg-error/libgpg-error-1.3-r1.ebuild,v 1.3 2007/02/28 22:05:58 genstef Exp $

EAPI="prefix"

inherit libtool eutils

DESCRIPTION="Contains error handling functions used by GnuPG software"
HOMEPAGE="http://www.gnupg.org/(en)/download/index.html#libgpg-error"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch "${FILESDIR}/${P}-nls.patch"

	elibtoolize
}

src_compile() {
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README
}
