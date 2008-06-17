# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/audiofile/audiofile-0.2.6-r4.ebuild,v 1.1 2008/06/16 12:12:55 flameeyes Exp $

EAPI="prefix"

inherit libtool autotools base flag-o-matic

DESCRIPTION="An elegant API for accessing audio files"
HOMEPAGE="http://www.68k.org/~michael/audiofile/"
SRC_URI="http://www.68k.org/~michael/audiofile/${P}.tar.gz
	mirror://gentoo/${P}-constantise.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

PATCHES=(
	"${FILESDIR}"/sfconvert-eradicator.patch
	"${FILESDIR}"/${P}-m4.patch
	"${WORKDIR}"/${P}-constantise.patch
	"${FILESDIR}"/${P}-fmod.patch

	### Patch for bug #118600
	"${FILESDIR}"/${PN}-largefile.patch
)

src_unpack() {
	base_src_unpack
	cd "${S}"

	sed -i -e 's:noinst_PROGRAMS:check_PROGRAMS:' \
		"${S}"/test/Makefile.am \
		|| die "unable to disable tests building"

	eautoreconf # need new libtool for interix
	elibtoolize
}

src_compile() {
	econf --enable-largefile || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ACKNOWLEDGEMENTS AUTHORS ChangeLog README TODO NEWS NOTES
}
