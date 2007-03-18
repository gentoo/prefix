# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/steghide/steghide-0.5.1.ebuild,v 1.11 2006/08/16 00:39:09 squinky86 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A steganography program which hides data in various media files"
HOMEPAGE="http://steghide.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=app-crypt/mhash-0.8.18-r1
		>=dev-libs/libmcrypt-2.5.7
		>=media-libs/jpeg-6b-r3
		>=sys-libs/zlib-1.1.4-r2"

src_unpack(){
	unpack ${A}
	epatch "${FILESDIR}"/${P}-gcc34.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	cd "${S}"
	# we need this for Darwin ... and prefix!
	[[ ${CHOST} == *-darwin* ]] \
		&& libt=$(type -P glibtool) \
		|| libt=$(type -P libtool)
	sed -i -e "/^LIBTOOL =/s|libtool|${libt}|" src/Makefile.in
}

src_compile() {
	econf || die "configure failed"
#	epatch "${FILESDIR}"/fix-libtool-invocation.patch
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "installation failed"
}
