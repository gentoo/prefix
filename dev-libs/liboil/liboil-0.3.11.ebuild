# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboil/liboil-0.3.11.ebuild,v 1.3 2007/04/21 07:27:13 hanno Exp $

EAPI="prefix"

inherit flag-o-matic autotools

DESCRIPTION="library of simple functions that are optimized for various CPUs"
HOMEPAGE="http://www.schleef.org/liboil/"
SRC_URI="http://www.schleef.org/${PN}/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0.3"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc"

RDEPEND="=dev-libs/glib-2*"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/liboil-0.3.10-sse2revert.diff
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	strip-flags
	filter-flags -O?
	append-flags -O2
	econf $(use_enable doc gtk-doc) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
