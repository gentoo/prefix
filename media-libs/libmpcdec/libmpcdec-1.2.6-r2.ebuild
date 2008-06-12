# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpcdec/libmpcdec-1.2.6-r2.ebuild,v 1.2 2008/04/20 17:33:31 flameeyes Exp $

EAPI="prefix"

inherit eutils libtool autotools

DESCRIPTION="Musepack decoder library"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://files2.musepack.net/source/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-riceitdown.patch"
	epatch "${FILESDIR}/${P}+libtool22.patch"

	eautoreconf
	elibtoolize
}

src_compile() {
	econf \
		--enable-static \
		--enable-shared \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog README

	find "${ED}" -name '*.la' -delete
}
