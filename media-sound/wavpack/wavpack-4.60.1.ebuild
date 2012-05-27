# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/wavpack/wavpack-4.60.1.ebuild,v 1.10 2012/05/17 15:25:01 aballier Exp $

EAPI=4
inherit eutils libtool

DESCRIPTION="WavPack audio compression tools"
HOMEPAGE="http://www.wavpack.com"
SRC_URI="http://www.wavpack.com/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="mmx"

RDEPEND="virtual/libiconv"
DEPEND="${RDEPEND}"

DOCS=( ChangeLog README )

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.41.0-interix.patch
	epatch "${FILESDIR}"/${PN}-4.50.0-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch

	elibtoolize
}

src_configure() {
	econf \
		--disable-static \
		$(use_enable mmx)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +
}
