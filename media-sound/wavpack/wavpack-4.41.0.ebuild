# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-sound/wavpack/wavpack-4.41.0.ebuild,v 1.12 2008/03/07 07:39:15 drac Exp $

EAPI="prefix"

inherit autotools flag-o-matic eutils

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux"
IUSE="mmx"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	eautoreconf # need new libtool for interix
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	econf $(use_enable mmx)
	emake || die "emake failed."
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README
}
