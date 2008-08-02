# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pngcrush/pngcrush-1.6.7.ebuild,v 1.1 2008/07/30 20:07:40 drac Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Portable Network Graphics (PNG) optimizing utility"
HOMEPAGE="http://pmt.sourceforge.net/pngcrush"
SRC_URI="mirror://debian/pool/main/p/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=media-libs/libpng-1.2.26-r1"

S=${WORKDIR}/${P}-nolib

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Use system libpng, fix various bugs and sanitize Makefile
	epatch "${FILESDIR}"/${P}-modified_debian_patchset_1.patch
}

src_compile() {
	tc-export CC
	emake || die "emake failed."
}

src_install() {
	dobin ${PN} || die "dobin failed."
	dodoc *.txt
}
