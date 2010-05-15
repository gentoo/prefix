# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/octave/octave-3.2.4-r1.ebuild,v 1.5 2010/05/13 06:35:13 jer Exp $

EAPI="2"
inherit flag-o-matic xemacs-elisp-common autotools

DESCRIPTION="High-level interactive language for numerical computations"
LICENSE="GPL-3"
HOMEPAGE="http://www.octave.org/"
SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.bz2"

SLOT="0"
IUSE="curl doc emacs fltk fftw opengl readline sparse test xemacs zlib"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

RDEPEND="dev-libs/libpcre
	media-gfx/graphicsmagick[cxx]
	media-libs/qhull
	sci-libs/qrupdate
	sci-mathematics/glpk
	sci-visualization/gnuplot
	sys-libs/ncurses
	virtual/lapack
	x11-libs/libX11
	curl? ( net-misc/curl )
	fltk? ( x11-libs/fltk:1.1[opengl?] )
	fftw? ( sci-libs/fftw:3.0 )
	opengl? ( virtual/opengl media-libs/ftgl )
	sparse? ( sci-libs/arpack
		sci-libs/camd
		sci-libs/ccolamd
		sci-libs/cholmod
		sci-libs/colamd
		sci-libs/cxsparse
		sci-libs/umfpack )
	xemacs? ( app-editors/xemacs )
	zlib? ( sys-libs/zlib )
	!sci-mathematics/octave-forge"

DEPEND="${RDEPEND}
	virtual/latex-base
	sys-apps/texinfo
	|| ( dev-texlive/texlive-genericrecommended
		 app-text/ptex )
	dev-util/gperf
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.2.0_parallel_make.patch
	epatch "${FILESDIR}"/${PN}-3.2.0_as_needed.patch
	epatch "${FILESDIR}"/${PN}-3.2.4-imread.patch
	epatch "${FILESDIR}"/${PN}-3.2.4-ldflags.patch
	epatch "${FILESDIR}"/${PN}-3.2.4-fltk-magic.patch
	epatch "${FILESDIR}"/${PN}-3.2.4-darwin.patch
	eautoreconf
}

src_configure() {
	# hdf5 disabled because not really useful (bug #299876)
	econf \
		--localstatedir="${EPREFIX}"/var/state/octave \
		--enable-shared \
		--without-hdf5 \
		--with-qrupdate \
		--with-blas="$(pkg-config --libs blas)" \
		--with-lapack="$(pkg-config --libs lapack)" \
		$(use_enable readline) \
		$(use_with curl) \
		$(use_with fftw) \
		$(use_with fltk) \
		$(use_with opengl framework-opengl) \
		$(use_with sparse arpack) \
		$(use_with sparse umfpack) \
		$(use_with sparse colamd) \
		$(use_with sparse ccolamd) \
		$(use_with sparse cholmod) \
		$(use_with sparse cxsparse) \
		$(use_with zlib)
}

src_compile() {
	emake || die "emake failed"
	if use xemacs; then
		cd "${S}/emacs"
		xemacs-elisp-comp *.el
	fi
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"

	if use doc; then
		einfo "Installing documentation..."
		insinto /usr/share/doc/${PF}
		doins $(find doc -name \*.pdf)
	fi

	if use emacs || use xemacs; then
		cd emacs
		exeinto /usr/bin
		doexe octave-tags || die "Failed to install octave-tags"
		doman octave-tags.1 || die "Failed to install octave-tags.1"
		if use xemacs; then
			xemacs-elisp-install ${PN} *.el *.elc
		fi
		cd ..
	fi
	use test && dodoc test/fntests.log
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/octave-${PV}" > 99octave
	doenvd 99octave || die
}
