# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmikmod/libmikmod-3.2.0_beta2.ebuild,v 1.1 2009/07/23 18:07:55 ssuominen Exp $

EAPI=2
MY_P=${P/_/-}

inherit autotools eutils

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.raphnet.net/"
SRC_URI="http://mikmod.raphnet.net/files/${MY_P}.tar.gz"

LICENSE="|| ( LGPL-2.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="alsa oss"

RDEPEND="media-libs/audiofile
	alsa? ( media-libs/alsa-lib )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-64bit.patch \
		"${FILESDIR}"/${P}-autotools.patch \
		"${FILESDIR}"/${P}-info.patch \
		"${FILESDIR}"/${P}-doubleRegister.patch
	AT_M4DIR=${S} eautoreconf
}

src_configure() {
	econf \
		--enable-af \
		$(use_enable alsa) \
		--disable-esd \
		$(use_enable oss)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README TODO
	dohtml docs/*.html
}
