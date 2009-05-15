# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpcdec/libmpcdec-1.2.6-r2.ebuild,v 1.9 2009/05/11 09:02:10 ssuominen Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="Musepack decoder library"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://files.musepack.net/source/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-riceitdown.patch \
		"${FILESDIR}"/${P}+libtool22.patch
	eautoreconf
}

src_configure() {
	econf \
		--enable-static \
		--enable-shared
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
	find "${ED}" -name '*.la' -delete
}
