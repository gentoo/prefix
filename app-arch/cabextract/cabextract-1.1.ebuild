# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cabextract/cabextract-1.1.ebuild,v 1.17 2006/09/24 19:46:38 seemant Exp $

EAPI="prefix"

WANT_AUTOMAKE=latest

inherit eutils autotools

DESCRIPTION="Extracts files from Microsoft .cab files"
HOMEPAGE="http://www.kyz.uklinux.net/cabextract.php"
SRC_URI="http://www.kyz.uklinux.net/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-mempcpy.patch

	eautoreconf
}

src_install() {
	make DESTDIR="${EDEST}" install || die
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO doc/magic
}
