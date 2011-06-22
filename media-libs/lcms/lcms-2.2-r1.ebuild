# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-2.2-r1.ebuild,v 1.1 2011/06/12 16:41:53 ssuominen Exp $

EAPI=4
inherit eutils

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="mirror://sourceforge/${PN}/lcms2-${PV}.tar.gz"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc jpeg static-libs test tiff zlib"

RDEPEND="jpeg? ( virtual/jpeg )
	tiff? ( media-libs/tiff )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/lcms2-${PV}

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-header.patch \
		"${FILESDIR}"/${P}-lm.patch
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_with zlib)
}

src_compile() {
	default

	if use test; then
		cd testbed
		emake testcms
	fi
}

src_test() {
	cd testbed
	./testcms || die
}

src_install() {
	default

	if use doc; then
		docinto pdf
		dodoc doc/*.pdf
	fi

	find "${ED}" -name '*.la' -exec rm -f {} +
}
