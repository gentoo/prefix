# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/texmacs/texmacs-1.0.7.ebuild,v 1.1 2008/11/02 07:14:43 grozin Exp $
EAPI="prefix 1"
inherit autotools
MY_P=${P/tex/TeX}-src
DESCRIPTION="Wysiwyg text processor with high-quality maths"

SRC_URI="ftp://ftp.texmacs.org/pub/TeXmacs/targz/${MY_P}.tar.gz
	ftp://ftp.texmacs.org/pub/TeXmacs/targz/TeXmacs-600dpi-fonts.tar.gz"

HOMEPAGE="http://www.texmacs.org/"
LICENSE="GPL-2"
SLOT="0"
IUSE="imlib jpeg netpbm -qt4 svg spell"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"

RDEPEND="virtual/latex-base
	virtual/ghostscript
	>=dev-scheme/guile-1.4
	media-libs/freetype
	x11-libs/libXext
	qt4? ( x11-libs/qt-gui:4 )
	imlib? ( media-libs/imlib2 )
	jpeg? ( || ( media-gfx/imagemagick media-gfx/jpeg2ps ) )
	svg? ( || ( media-gfx/inkscape gnome-base/librsvg ) )
	netpbm? ( media-libs/netpbm )
	spell? ( || ( >=app-text/ispell-3.2 >=app-text/aspell-0.5 ) )"

DEPEND="${RDEPEND}
	x11-proto/xproto"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use qt4; then
		ewarn "Qt port is highly experimental"
		ewarn "If you want a stable TeXmacs, emerge with USE=-qt4"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# macx-g++ -> linux-g++
	epatch "${FILESDIR}"/${P}-autotroll.patch

	# don't strip
	epatch "${FILESDIR}"/${P}-strip.patch

	epatch "${FILESDIR}"/${PN}-1.0.6.14-interix.patch

	eautoreconf
}


src_compile() {
	econf $(use_with imlib imlib2) \
		--enable-optimize="${CXXFLAGS}" \
		$(use_enable qt4 qt)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc TODO || die "dodoc failed"
	domenu "${FILESDIR}"/TeXmacs.desktop || die "domenu failed"

	# now install the fonts
	insinto /usr/share/texmf
	doins -r "${WORKDIR}/fonts" || die "installing fonts failed"
}
