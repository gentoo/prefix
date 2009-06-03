# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/octave/octave-3.0.3.ebuild,v 1.7 2009/05/30 08:41:23 ulm Exp $

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
	fftw? ( >=sci-libs/fftw-3.1.2 )
	zlib? ( sys-libs/zlib )
	hdf5? ( sci-libs/hdf5 )
	curl? ( net-misc/curl )
	xemacs? ( virtual/xemacs )
	sparse? ( sci-libs/umfpack
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

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.0.0-pkg.patch
	epatch "${FILESDIR}"/${P}-test-fix.patch
	epatch "${FILESDIR}"/${PN}-3.0.1-fix_handle_for_plotyy.patch
	epatch "${FILESDIR}"/${PN}-3.0.1-no_helvetica.patch
}

src_compile() {
	econf \
		--localstatedir=/var/state/octave \
		--enable-shared \
		--with-blas="$(pkg-config --libs blas)" \
		--with-lapack="$(pkg-config --libs lapack)" \
		$(use_with hdf5) \
		$(use_with curl) \
		$(use_with zlib) \
		$(use_with fftw) \
		$(use_with sparse umfpack) \
		$(use_with sparse colamd) \
		$(use_with sparse ccolamd) \
		$(use_with sparse cholmod) \
		$(use_with sparse cxsparse) \
		$(use_enable readline)

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

	echo "LDPATH=/usr/$(get_libdir)/octave-${PV}" > 99octave
	doenvd 99octave || die

	# Fixes ls-R files to remove /var/tmp/portage references.
	sed -i \
		-e "s:${ED}::g" \
		"${ED}"/usr/*/${PN}/ls-R \
		|| die "Failed to fix ls-R files."
}
