# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmikmod/libmikmod-3.2.0_beta2-r1.ebuild,v 1.4 2010/01/09 19:55:35 jer Exp $

EAPI=2
MY_P=${P/_/-}
inherit autotools eutils

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.raphnet.net/"
SRC_URI="http://mikmod.raphnet.net/files/${MY_P}.tar.gz"

LICENSE="|| ( LGPL-2.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
# Enable OSS by default since ALSA support isn't available, look below
IUSE="+oss"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-64bit.patch \
		"${FILESDIR}"/${P}-autotools.patch \
		"${FILESDIR}"/${P}-info.patch \
		"${FILESDIR}"/${P}-doubleRegister.patch \
		"${FILESDIR}"/${PN}-CVE-2007-6720.patch \
		"${FILESDIR}"/${PN}-CVE-2009-0179.patch
	AT_M4DIR=${S} eautoreconf
}

src_configure() {
	# * af is something called AF/AFlib.h and -lAF, not audiofile in tree
	# * alsa support is for deprecated API and doesn't work
	econf \
		--disable-af \
		--disable-alsa \
		--disable-esd \
		$(use_enable oss)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README TODO
	dohtml docs/*.html
}
