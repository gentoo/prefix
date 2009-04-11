# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/megapov/megapov-1.2.1.ebuild,v 1.4 2008/12/21 22:03:29 maekke Exp $

inherit eutils

DESCRIPTION="The popular collection of unofficial extensions of POV-Ray"
HOMEPAGE="http://megapov.inetart.net/"
SRC_URI="http://megapov.inetart.net/packages/unix/${P}.tgz"
LICENSE="povlegal-3.6"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"
IUSE=""

DEPEND=">=media-gfx/povray-3.6.1
	media-libs/libpng
	media-libs/tiff
	media-libs/jpeg
	sys-libs/zlib"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-povrayconf.patch
	epatch "${FILESDIR}"/${P}-povrayini.patch
}

src_compile() {
	econf CFLAGS="${CFLAGS}" CPPFLAGS="${CXXFLAGS}" \
		--prefix="${EPREFIX}/usr" --libdir="${EPREFIX}/usr/share/${PN}" \
		--sysconfdir="${EPREFIX}/etc" --without-svga --with-x \
		--disable-strip \
		COMPILED_BY="Gentoo Linux" || \
		die './configure failed'
	emake || \
		die 'compile failed'
}

src_install() {
	emake DESTDIR="${D}" install || die 'make install failed'
	ln -sf ./${P} "${ED}"/usr/share/${PN}
	# povray installs this file
	rm -f "${ED}"/usr/share/man/man1/povray.1*
}

pkg_postinst() {
	elog "The MegaPOV files have been installed.  The following line"
	elog "has been added to the megapov/povray.ini to enable use of"
	elog "library files from the povray-3.6 installation:"
	elog
	elog "Library_Path=${EPREFIX}/usr/share/${PN}/include"
	echo
}
