# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmikmod/libmikmod-3.1.11-r5.ebuild,v 1.2 2008/01/16 18:07:17 grobian Exp $

EAPI="prefix"

WANT_AUTOMAKE="1.5"

inherit flag-o-matic eutils libtool autotools

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.raphnet.net/"
SRC_URI="http://mikmod.raphnet.net/files/${P}.tar.gz
	mirror://gentoo/${P}-esdm4.patch.bz2"

LICENSE="|| ( LGPL-2.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="oss esd alsa"

DEPEND=">=media-libs/audiofile-0.2.3
	alsa? ( >=media-libs/alsa-lib-0.5.9 )
	esd? ( >=media-sound/esound-0.2.19 )"

src_unpack() {
	unpack ${A}

	epatch "${DISTDIR}"/${P}-esdm4.patch.bz2

	cd "${S}"
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-amd64-ppc64-archdef.patch
	epatch "${FILESDIR}"/${P}-respectflags.patch
	epatch "${FILESDIR}"/${P}-alsa.patch
	epatch "${FILESDIR}"/${P}-doubleRegister.patch
	AT_M4DIR="${S}/m4" eautoreconf
}

src_compile() {
	econf --enable-af \
		$(use_enable esd) \
		$(use_enable alsa) \
		$(use_enable oss)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS README TODO
	dohtml docs/*.html
}
