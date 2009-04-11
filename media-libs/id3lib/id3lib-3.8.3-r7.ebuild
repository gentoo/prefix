# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/id3lib/id3lib-3.8.3-r7.ebuild,v 1.1 2008/07/29 15:04:05 yngwin Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools

MY_P=${P/_/}
S="${WORKDIR}"/${MY_P}

DESCRIPTION="Id3 library for C/C++"
HOMEPAGE="http://id3lib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE="doc"

RESTRICT="test"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-zlib.patch
	epatch "${FILESDIR}"/${P}-test_io.patch
	epatch "${FILESDIR}"/${P}-autoconf259.patch
	epatch "${FILESDIR}"/${P}-doxyinput.patch
	epatch "${FILESDIR}"/${P}-unicode16.patch
	epatch "${FILESDIR}"/${P}-gcc-4.3.patch

	# Security fix for bug 189610.
	epatch "${FILESDIR}"/${P}-security.patch

	AT_M4DIR="${S}/m4" eautoreconf
}

src_compile() {
	econf || die "econf failed."
	emake || die "emake failed."

	if use doc; then
		cd doc/
		doxygen Doxyfile || die "doxygen failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS ChangeLog HISTORY README THANKS TODO

	if use doc; then
		dohtml -r doc
	fi
}
