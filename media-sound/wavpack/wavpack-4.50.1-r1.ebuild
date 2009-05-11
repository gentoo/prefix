# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/wavpack/wavpack-4.50.1-r1.ebuild,v 1.1 2009/05/10 14:58:32 ssuominen Exp $

EAPI=2
inherit eutils libtool autotools

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="mmx"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gcc44.patch

	epatch "${FILESDIR}"/${PN}-4.41.0-interix.patch
	epatch "${FILESDIR}"/${PN}-4.50.0-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch
	eautoreconf # need new libtool for interix

	elibtoolize
}

src_configure() {
	econf $(use_enable mmx)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README
}
