# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/smpeg/smpeg-0.4.4-r9.ebuild,v 1.14 2012/09/09 22:21:48 radhermit Exp $

EAPI=4

inherit eutils toolchain-funcs autotools flag-o-matic

DESCRIPTION="SDL MPEG Player Library"
HOMEPAGE="http://www.lokigames.com/development/smpeg.php3"
SRC_URI="ftp://ftp.lokigames.com/pub/open-source/smpeg/${P}.tar.gz
	mirror://gentoo/${P}-gtkm4.patch.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE="X debug mmx opengl static-libs"

DEPEND=">=media-libs/libsdl-1.2.0
	opengl? (
		virtual/glu
		virtual/opengl
	)
	X? (
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libX11
	)"
RDEPEND="${DEPEND}"

DOCS=( CHANGES README README.SDL_mixer TODO )

src_prepare() {
	epatch "${FILESDIR}"/${P}-m4.patch \
		"${FILESDIR}"/${P}-gnu-stack.patch \
		"${FILESDIR}"/${P}-config.patch \
		"${FILESDIR}"/${P}-PIC.patch \
		"${FILESDIR}"/${P}-gcc41.patch \
		"${FILESDIR}"/${P}-flags.patch \
		"${FILESDIR}"/${P}-automake.patch \
		"${FILESDIR}"/${P}-mmx.patch \
		"${FILESDIR}"/${P}-malloc.patch \
		"${FILESDIR}"/${P}-missing-init.patch

	cd "${WORKDIR}"
	epatch "${DISTDIR}"/${P}-gtkm4.patch.bz2
	rm "${S}/acinclude.m4"

	cd "${S}"
	AT_M4DIR="${S}/m4" eautoreconf
}

src_configure() {
	[[ ${CHOST} == *-solaris* ]] && append-libs -lnsl -lsocket
	tc-export CC CXX RANLIB AR

	# the debug option is bogus ... all it does is add extra
	# optimizations if you pass --disable-debug
	econf \
		--enable-debug \
		--disable-gtk-player \
		$(use_enable static-libs static) \
		$(use_enable debug assertions) \
		$(use_with X x) \
		$(use_enable opengl opengl-player) \
		$(use_enable mmx)
}

src_install() {
	default
	use static-libs || find "${ED}" -name '*.la' -exec rm -f {} +
}
