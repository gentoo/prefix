# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.17.ebuild,v 1.3 2006/10/19 17:29:44 flameeyes Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile/"
SRC_URI="http://www.mega-nerd.com/libsndfile/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="sqlite flac alsa"
RESTRICT="test"

RDEPEND="flac? ( ~media-libs/flac-1.1.2 )
	alsa? ( media-libs/alsa-lib )
	sqlite? ( >=dev-db/sqlite-3.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize
	epunt_cxx
}

src_compile() {
	econf \
		$(use_enable sqlite) \
		$(use_enable flac) \
		$(use_enable alsa) \
		--disable-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${EDEST}" htmldocdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}
