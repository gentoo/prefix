# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libwmf/libwmf-0.2.8.4.ebuild,v 1.12 2007/02/11 11:24:22 vapier Exp $

EAPI="prefix"

inherit eutils autotools

#The configure script finds the 5.50 ghostscript Fontmap file while run.
#This will probably work, especially since the real one (6.50) in this case
#is empty. However beware in case there is any trouble

DESCRIPTION="library for converting WMF files"
HOMEPAGE="http://wvware.sourceforge.net/"
SRC_URI="mirror://sourceforge/wvware/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="jpeg X expat xml debug doc gtk gd"

RDEPEND="virtual/ghostscript
	xml? ( !expat? ( dev-libs/libxml2 ) )
	expat? ( dev-libs/expat )
	gd? ( media-libs/gd )
	>=media-libs/freetype-2.0.1
	sys-libs/zlib
	media-libs/libpng
	jpeg? ( media-libs/jpeg )
	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
	)
	gtk? ( >=x11-libs/gtk+-2.1.2 ) "
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	X? (
		x11-libs/libXt
		x11-libs/libXpm
	)"
# plotutils are not really supported yet, so looks like that's it

src_unpack() {
	unpack ${A}
	cd "${S}"
	if ! use doc ; then
		sed -e 's:doc::' -i Makefile.am
	fi
	if ! use gtk ; then
		sed -e 's:@LIBWMF_GDK_PIXBUF_TRUE@:#:' -i src/Makefile.in
	fi
	epatch "${FILESDIR}"/${P}-intoverflow.patch
	epatch "${FILESDIR}"/${P}-build.patch

	eautoreconf
}

src_compile() {
	if use expat && use xml ; then
		einfo "You can specify only one USE flag from expat and xml, to use expat"
		einfo "or libxml2, respectively."
		einfo
		einfo "You have both flags enabled, we will default to expat (like autocheck does)."
		myconf="${myconf} --with-expat --without-libxml2"
	else
		myconf="${myconf} $(use_with expat) $(use_with xml libxml2)"
	fi

	econf \
		$(use_enable debug) \
		$(use_with jpeg) \
		$(use_with X x) \
		$(use_enable gd) \
		--with-sys-gd \
		${myconf} \
		--with-gsfontdir="${EPREFIX}"/usr/share/ghostscript/fonts \
		--with-fontdir="${EPREFIX}"/usr/share/libwmf/fonts/ \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		|| die "./configure failed"

	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc README AUTHORS CREDITS ChangeLog NEWS TODO
}
