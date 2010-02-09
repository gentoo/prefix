# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/octave/octave-3.2.3-r1.ebuild,v 1.2 2010/02/03 10:14:06 fauli Exp $

EAPI="2"
inherit flag-o-matic fortran xemacs-elisp-common

DESCRIPTION="High-level interactive language for numerical computations"
LICENSE="GPL-3"
HOMEPAGE="http://www.octave.org/"
SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.bz2"

SLOT="0"
IUSE="emacs readline zlib doc hdf5 curl fftw xemacs sparse"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

RDEPEND="virtual/lapack
	dev-libs/libpcre
	sys-libs/ncurses
	sci-visualization/gnuplot
	>=sci-mathematics/glpk-4.15
	media-libs/qhull
	sci-libs/qrupdate
	fftw? ( >=sci-libs/fftw-3.1.2 )
	zlib? ( sys-libs/zlib )
	hdf5? ( sci-libs/hdf5 )
	curl? ( net-misc/curl )
	xemacs? ( app-editors/xemacs )
	sparse? ( sci-libs/umfpack
		sci-libs/arpack
		sci-libs/colamd
		sci-libs/camd
		sci-libs/ccolamd
		sci-libs/cholmod
		sci-libs/cxsparse )
	!sci-mathematics/octave-forge"

DEPEND="${RDEPEND}
	virtual/latex-base
	sys-apps/texinfo
	|| ( dev-texlive/texlive-genericrecommended
		app-text/ptex )
	dev-util/gperf
	dev-util/pkgconfig"

FORTRAN="gfortran ifc g77 f2c"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.2.0_parallel_make.patch
	epatch "${FILESDIR}"/${PN}-3.2.0_as_needed.patch
}

src_configure() {
	econf \
		--localstatedir="${EPREFIX}"/var/state/octave \
		--enable-shared \
		--with-blas="$(pkg-config --libs blas)" \
		--with-lapack="$(pkg-config --libs lapack)" \
		--with-qrupdate \
		$(use_with hdf5) \
		$(use_with curl) \
		$(use_with zlib) \
		$(use_with fftw) \
		$(use_with sparse arpack) \
		$(use_with sparse umfpack) \
		$(use_with sparse colamd) \
		$(use_with sparse ccolamd) \
		$(use_with sparse cholmod) \
		$(use_with sparse cxsparse) \
		$(use_enable readline)
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

	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/octave-${PV}" > 99octave
	doenvd 99octave || die
}
