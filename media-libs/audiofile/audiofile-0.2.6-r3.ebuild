# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/audiofile/audiofile-0.2.6-r3.ebuild,v 1.12 2007/09/22 04:54:01 tgall Exp $

inherit autotools eutils flag-o-matic

DESCRIPTION="An elegant API for accessing audio files"
HOMEPAGE="http://www.68k.org/~michael/audiofile/"
SRC_URI="http://www.68k.org/~michael/audiofile/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"/sfcommands
	epatch "${FILESDIR}"/sfconvert-eradicator.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-constantise.patch
	epatch "${FILESDIR}"/${P}-fmod.patch

	### Patch for bug #118600
	epatch "${FILESDIR}"/${PN}-largefile.patch
	eautoreconf # need new libtool for interix
}

src_compile() {
	[[ ${CHOST} == powerpc-*-darwin* ]] \
		&& filter-flags -m* # need to avoid altivec stuff
	econf --enable-largefile || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ACKNOWLEDGEMENTS AUTHORS ChangeLog README TODO NEWS NOTES
}
