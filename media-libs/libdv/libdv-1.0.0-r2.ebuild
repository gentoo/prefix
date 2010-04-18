# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdv/libdv-1.0.0-r2.ebuild,v 1.10 2008/01/03 14:02:26 aballier Exp $

inherit eutils flag-o-matic libtool

DESCRIPTION="Software codec for dv-format video (camcorders etc)"
HOMEPAGE="http://libdv.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${PN}-1.0.0-pic.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug sdl xv"

RDEPEND="dev-libs/popt
	sdl? ( >=media-libs/libsdl-1.2.5 )
	xv? ( x11-libs/libXv )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.99-2.6.patch
	epatch "${WORKDIR}"/${PN}-1.0.0-pic.patch
	epatch "${FILESDIR}"/${PN}-1.0.0-solaris.patch
	epatch "${FILESDIR}"/${PN}-1.0.0-darwin.patch
	elibtoolize
	epunt_cxx #74497
}

src_compile() {
	econf \
		$(use_with debug) \
		--disable-gtk --disable-gtktest \
		$(use_enable sdl) \
		$(use_enable xv) \
		$(use x86-macos && echo "--disable-asm") \
		|| die "econf failed."
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog INSTALL NEWS README* TODO
}
