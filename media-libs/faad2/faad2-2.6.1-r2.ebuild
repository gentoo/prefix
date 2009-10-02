# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faad2/faad2-2.6.1-r2.ebuild,v 1.10 2009/09/30 09:44:49 ssuominen Exp $

inherit eutils autotools

DESCRIPTION="AAC audio decoding library"
HOMEPAGE="http://www.audiocoding.com/"
SRC_URI="mirror://sourceforge/faac/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~x86-solaris"
IUSE="digitalradio"

RDEPEND=""
DEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-abi_has_changed.patch"
	epatch "${FILESDIR}/${P}-libtool22.patch"
	epatch "${FILESDIR}/${P}-broken-pipe.patch"
	epatch "${FILESDIR}/${P}-implicitdeclar.patch"
	epatch "${FILESDIR}/${P}-main-overflow.patch"
	eautoreconf
}

src_compile() {
	econf \
		$(use_with digitalradio drm) \
		--without-xmms
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README README.linux TODO
}
