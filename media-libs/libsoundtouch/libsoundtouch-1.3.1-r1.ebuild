# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsoundtouch/libsoundtouch-1.3.1-r1.ebuild,v 1.16 2008/09/29 22:49:42 jer Exp $

inherit autotools eutils flag-o-matic libtool

MY_P=${P/lib}

DESCRIPTION="Audio processing library for changing tempo, pitch and playback rates."
HOMEPAGE="http://www.surina.net/soundtouch/"
SRC_URI="http://www.surina.net/soundtouch/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="sse"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-Makefile.patch \
		"${FILESDIR}"/${P}-gcc-4.3.patch
	edos2unix Makefile.am
	eautoreconf

	# Bug #148695
	if use sse; then
		append-flags -msse
	else
		sed -i -e '/^.*#define ALLOW_OPTIMIZATIONS.*$/d' "${S}"/include/STTypes.h
	fi
}

src_compile() {
	econf --enable-shared --disable-integer-samples
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" pkgdocdir="${EPREFIX}/usr/share/doc/${PF}/html" install \
		|| die "emake install failed."
	rm -f "${ED}"/usr/share/doc/${PF}/html/COPYING.TXT
}
