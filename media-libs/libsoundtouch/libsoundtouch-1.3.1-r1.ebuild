# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsoundtouch/libsoundtouch-1.3.1-r1.ebuild,v 1.2 2007/03/24 20:41:20 armin76 Exp $

EAPI="prefix"

inherit autotools

IUSE="sse"

MY_P="${P/lib}"

DESCRIPTION="Audio processing library for changing tempo, pitch and playback rates."
HOMEPAGE="http://www.surina.net/soundtouch/"
SRC_URI="http://www.surina.net/soundtouch/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-Makefile.patch
	eautoreconf

	# Bug #148695
	use sse \
		|| sed -i -e '/^.*#define ALLOW_OPTIMIZATIONS.*$/d' "${S}"/include/STTypes.h
}

src_compile() {
	econf $myconf \
		--enable-shared \
		--disable-integer-samples \
		|| die "./configure failed"
	# fixes C(XX)FLAGS from configure, so we can use *ours*
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" pkgdocdir="${EPREFIX}/usr/share/doc/${PF}" install || die
	rm -f ${ED}/usr/share/doc/${PF}/COPYING.TXT	# remove obsolete LICENCE file
}
