# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsoundtouch/libsoundtouch-1.5.0.ebuild,v 1.6 2010/07/17 17:26:16 armin76 Exp $

EAPI=2
MY_PN=${PN/lib}
inherit autotools eutils flag-o-matic multilib

DESCRIPTION="Audio processing library for changing tempo, pitch and playback rates."
HOMEPAGE="http://www.surina.net/soundtouch/"
SRC_URI="http://www.surina.net/soundtouch/${P/lib}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="sse2"

S=${WORKDIR}/${MY_PN}

src_prepare() {
	epatch "${FILESDIR}"/${P}-flags_and_version.patch
	# bug 337128
	rm -Rf config/m4/{libtool,ltoptions,ltsugar,ltversion,lt~obsolete}.m4
	eautoreconf

	if use sse2; then
		append-flags -msse2
	else
		sed -i -e '/^.*#define ALLOW_X86_OPTIMIZATIONS.*$/d' \
			include/STTypes.h || die
	fi
}

src_configure() {
	econf \
		--enable-shared \
		--disable-dependency-tracking \
		--disable-integer-samples
}

src_compile() {
	emake CFLAGS="${CFLAGS}" \
		CXXFLAGS="${CXXFLAGS}" || die
}

src_install() {
	emake DESTDIR="${D}" pkgdocdir="${EPREFIX}/usr/share/doc/${PF}/html" \
		install || die

	# Upstream changed pkgconfig filename
	dosym ${MY_PN}-1.4.pc \
		/usr/$(get_libdir)/pkgconfig/${MY_PN}-1.0.pc || die

	rm -f "${ED}"/usr/share/doc/${PF}/html/COPYING.TXT
}
