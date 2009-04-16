# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/R/R-2.8.1.ebuild,v 1.7 2009/04/15 18:33:32 ranger Exp $

EAPI=2
inherit eutils fortran flag-o-matic bash-completion versionator

DESCRIPTION="Language and environment for statistical computing and graphics"
HOMEPAGE="http://www.r-project.org/"
SRC_URI="mirror://cran/src/base/R-2/${P}.tar.gz
	bash-completion? ( mirror://gentoo/R.bash_completion.bz2 )"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

IUSE="doc java jpeg lapack minimal nls png readline tk X cairo"

# common depends
CDEPEND="dev-lang/perl
	dev-libs/libpcre
	app-arch/bzip2
	virtual/blas
	virtual/ghostscript
	cairo? ( x11-libs/cairo[X]
		|| ( >=x11-libs/pango-1.20[X] <x11-libs/pango-1.20 ) )
	readline? ( sys-libs/readline )
	jpeg? ( media-libs/jpeg )
	png? ( media-libs/libpng )
	lapack? ( virtual/lapack )
	tk? ( dev-lang/tk )
	X? ( x11-libs/libXmu x11-misc/xdg-utils )"

DEPEND="${CDEPEND}
	dev-util/pkgconfig
	doc? ( virtual/latex-base
	  || ( dev-texlive/texlive-fontsrecommended
		   app-text/tetex
		   app-text/ptex ) )"

RDEPEND="${CDEPEND}
	app-arch/unzip
	app-arch/zip
	java? ( >=virtual/jre-1.5 )"

R_HOME="${EPREFIX}"/usr/$(get_libdir)/${PN}

pkg_setup() {
	FORTRAN="gfortran ifc g77"
	fortran_pkg_setup
	export FFLAGS="${FFLAGS:--O2}"
	[[ ${FORTRANC} = gfortran || ${FORTRANC} = if* ]] && \
		export FCFLAGS="${FCFLAGS:-${FFLAGS}}"
	filter-ldflags -Wl,-Bdirect -Bdirect
}

src_prepare() {

	# fix packages.html for doc (bug #205103)
	# check in later versions if fixed
	sed -i \
		-e "s:../../library:../../../../$(get_libdir)/R/library:g" \
		src/library/tools/R/packageshtml.R \
		|| die "sed failed"

	# fix Rscript
	sed -i \
		-e "s:-DR_HOME='\"\$(rhome)\"':-DR_HOME='\"${R_HOME}\"':" \
		src/unix/Makefile.in || die "sed unix Makefile failed"

	use lapack && \
		export LAPACK_LIBS="$(pkg-config --libs lapack)"

	if use X; then
		export R_BROWSER="$(type -p xdg-open)"
		export R_PDFVIEWER="$(type -p xdg-open)"
	fi
}

src_configure() {
	econf \
		--disable-rpath \
		--enable-R-profiling \
		--enable-memory-profiling \
		--enable-R-shlib \
		--enable-linux-lfs \
		--with-system-zlib \
		--with-system-bzlib \
		--with-system-pcre \
		--with-blas="$(pkg-config --libs blas)" \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		rdocdir="${EPREFIX}"/usr/share/doc/${PF} \
		$(use_enable nls) \
		$(use_with lapack) \
		$(use_with tk tcltk) \
		$(use_with jpeg jpeglib) \
		$(use_with !minimal recommended-packages) \
		$(use_with png libpng) \
		$(use_with readline) \
		$(use_with cairo) \
		$(use_with X x)
}

src_compile(){
	emake || die "emake failed"
	RMATH_V=0.0.0
	emake -j1 -C src/nmath/standalone \
		libRmath_la_LDFLAGS=-Wl,-soname,libRmath.so.${RMATH_V} \
		|| die "emake math library failed"
	if use doc; then
		export VARTEXFONTS="${T}/fonts"
		emake info pdf || die "emake docs failed"
	fi
}

src_test() {
	# we need to unset R_HOME otherwise some of the diff based
	# tests fail due to warnings in the output
	R_HOME="" emake -j1 check || die "Some of the tests failed"
}

src_install() {
	# -j1 because creates various dirs sequentially (hit should be small)
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	if use doc; then
		emake DESTDIR="${D}" \
			install-info install-pdf || die "emake install docs failed"
	fi

	emake -j1 \
		-C src/nmath/standalone \
		DESTDIR="${D}" install \
		|| die "emake install math library failed"

	local mv=$(get_major_version ${RMATH_V})
	mv  "${D}"/usr/$(get_libdir)/libRmath.so \
		"${D}"/usr/$(get_libdir)/libRmath.so.${RMATH_V}
	dosym libRmath.so.${RMATH_V} /usr/$(get_libdir)/libRmath.so.${mv}
	dosym libRmath.so.${mv} /usr/$(get_libdir)/libRmath.so

	# env file
	cat > 99R <<-EOF
		LDPATH=${R_HOME}/lib
		R_HOME=${R_HOME}
	EOF
	doenvd 99R || die "doenvd failed"

	dobashcompletion "${WORKDIR}"/R.bash_completion
}

pkg_config() {
	if use java; then
		einfo "Re-initializing java paths for ${P}"
		R CMD javareconf
	fi
}
