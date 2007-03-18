# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/graphicsmagick/graphicsmagick-1.1.7-r3.ebuild,v 1.6 2006/12/26 05:01:48 vapier Exp $

EAPI="prefix"

inherit libtool flag-o-matic perl-app multilib

MY_PN="GraphicsMagick"
MY_P=${MY_PN}-${PV}

DESCRIPTION="A collection of tools and libraries for many image formats"
HOMEPAGE="http://www.graphicsmagick.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="X gs jbig jpeg2k jpeg lcms lzw perl png tiff truetype wmf xml doc depth16 depth32"

RDEPEND="app-arch/bzip2
	sys-libs/zlib
	X? ( || (
		( x11-libs/libXext x11-libs/libXt x11-libs/libX11 x11-libs/libICE x11-libs/libSM )
		virtual/x11
	) )
	gs?   ( virtual/ghostscript )
	jbig? ( media-libs/jbigkit )
	jpeg2k? ( media-libs/jasper )
	jpeg? ( >=media-libs/jpeg-6b )
	lcms? ( >=media-libs/lcms-1.06 )
	perl? ( dev-lang/perl )
	png? ( media-libs/libpng )
	tiff? ( >=media-libs/tiff-3.5.5 )
	xml? ( >=dev-libs/libxml2-2.4.10 )
	truetype? ( =media-libs/freetype-2* )
	wmf? ( >=media-libs/libwmf-0.2.5 )"
DEPEND="${RDEPEND}
	X? ( || ( ( x11-proto/xextproto x11-proto/xproto ) virtual/x11 ) )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-overflow.patch"
	epatch "${FILESDIR}/${PN}-libpng.patch"
	epatch "${FILESDIR}/${P}-dcm.patch"
	epatch "${FILESDIR}/${P}-palm.patch"

	# Netscape is still used ?  More people should have Mozilla
	sed -i 's:netscape:mozilla:g' configure
}

src_compile() {
	DEPTH=8
	use depth16 && DEPTH=16
	use depth32 && DEPTH=32
	econf \
		--with-gs-font-dir=/usr/share/fonts/default/ghostscript \
		--enable-shared \
		--with-threads \
		--with-bzlib \
		--without-perl \
		--without-fpx \
		$(use_with X x) \
		$(use_with jbig) \
		$(use_with jpeg2k) \
		$(use_with jpeg) \
		$(use_with lcms) \
		$(use_enable lzw) \
		$(use_with png) \
		$(use_with tiff) \
		$(use_with truetype ttf) \
		$(use_with wmf) \
		$(use_with xml xml) \
		--with-quantum-depth=${DEPTH} \
		|| die

	# make PerlMagick using portage tools instead of Makefile to avoid sandbox issues
	if use perl ; then
		cd PerlMagick
		perl-app_src_prep
		perl-app_src_compile
		cd ..
	fi

	emake || die "compile problem"
}

src_install() {
	emake DESTDIR="${D}" install || die

	if use perl ; then
		cd PerlMagick
		perl-module_src_install
		cd ..
	fi

	dosym ${MY_P} /usr/$(get_libdir)/GraphicsMagick

	rm -f "${ED}"/usr/share/GraphicsMagick/*.txt
	rm -rf "${ED}"/usr/share/${MY_P}/www

	if use doc ; then
	    dohtml -r www/*
	fi

	dosed "s:-I/usr/include ::" /usr/bin/GraphicsMagick-config
	dosed "s:-I/usr/include ::" /usr/bin/GraphicsMagick++-config
}
