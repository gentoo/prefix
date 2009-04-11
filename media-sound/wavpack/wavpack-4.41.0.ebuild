# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/wavpack/wavpack-4.41.0.ebuild,v 1.13 2008/04/20 21:43:29 flameeyes Exp $

inherit libtool flag-o-matic autotools

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="mmx"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	eautoreconf # need new libtool for interix
}

src_compile() {
	test-flags-CC -flax-vector-conversions && \
		append-flags -flax-vector-conversions

	econf $(use_enable mmx)
	emake || die "emake failed."
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README
}
