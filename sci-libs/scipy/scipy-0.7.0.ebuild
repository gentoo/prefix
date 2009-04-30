# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/scipy/scipy-0.7.0.ebuild,v 1.2 2009/02/20 10:29:30 bicatali Exp $

EAPI=2
NEED_PYTHON=2.4

inherit eutils distutils fortran flag-o-matic

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
DESCRIPTION="Scientific algorithms library for Python"
HOMEPAGE="http://www.scipy.org/"
LICENSE="BSD"

SLOT="0"

IUSE="test umfpack"

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

CDEPEND=">=dev-python/numpy-1.2
	virtual/cblas
	virtual/lapack
	umfpack? ( sci-libs/umfpack )"

DEPEND="${CDEPEND}
	dev-util/pkgconfig
	test? ( dev-python/nose )
	umfpack? ( || ( >=dev-lang/swig-1.3.38 <=dev-lang/swig-1.3.36[python] ) )"

RDEPEND="${CDEPEND}
	dev-python/imaging"

DOCS="THANKS.txt LATEST.txt TOCHANGE.txt"

scipy_fortran_setup() {
	append-ldflags -shared
	FORTRAN="gfortran g77 ifc"
	fortran_pkg_setup
	local fc=
	case ${FORTRANC} in
		gfortran) fc=gnu95 ;;
		g77) fc=gnu ;;
		ifc|ifort)
			if use ia64; then
				fc=intele
			elif use amd64; then
				fc=intelem
			else
				fc=intel
			fi
			;;
		*)	eerror "Unknown fortran compiler: ${FORTRANC}"
			die "scipy_fortran_setup failed" ;;
	esac
	export SCIPY_FCONFIG="config_fc --fcompiler=${fc} --noopt --noarch"
}

pkg_setup() {
	# scipy automatically detects libraries by default
	export {FFTW,FFTW3,UMFPACK}=None
	use umfpack && unset UMFPACK
	scipy_fortran_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.7.0_beta1-implicit.patch
	epatch "${FILESDIR}"/${PN}-0.6.0-stsci.patch
	cat > site.cfg <<-EOF
		[DEFAULT]
		library_dirs = /usr/$(get_libdir)
		include_dirs = /usr/include
		[atlas]
		include_dirs = $(pkg-config --cflags-only-I \
			cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
		library_dirs = $(pkg-config --libs-only-L \
			cblas blas lapack| sed -e \
			's/^-L//' -e 's/ -L/:/g' -e 's/ //g'):/usr/$(get_libdir)
		atlas_libs = $(pkg-config --libs-only-l \
			cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		lapack_libs = $(pkg-config --libs-only-l \
			lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		[blas_opt]
		include_dirs = $(pkg-config --cflags-only-I \
			cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
		library_dirs = $(pkg-config --libs-only-L \
			cblas blas | sed -e 's/^-L//' -e 's/ -L/:/g' \
			-e 's/ //g'):/usr/$(get_libdir)
		libraries = $(pkg-config --libs-only-l \
			cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		[lapack_opt]
		library_dirs = $(pkg-config --libs-only-L \
			lapack | sed -e 's/^-L//' -e 's/ -L/:/g' \
			-e 's/ //g'):/usr/$(get_libdir)
		libraries = $(pkg-config --libs-only-l \
			lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
	EOF
}

src_compile() {
	# when fortran flags are set, pic is removed.
	[[ -n ${FFLAGS} ]] && FFLAGS="${FFLAGS} -fPIC"
	distutils_src_compile ${SCIPY_FCONFIG}
}

src_test() {
	"${python}" setup.py install \
		--home="${S}"/test \
		--no-compile \
		${SCIPY_FCONFIG} || die "install test failed"
	pushd "${S}"/test/lib*/python
	PYTHONPATH=. "${python}" -c "import scipy; scipy.test('full')" 2>&1 | tee test.log
	grep -q ^ERROR test.log && die "test failed"
	popd
	rm -rf test
}

src_install() {
	distutils_src_install ${SCIPY_FCONFIG}
}

pkg_postinst() {
	elog "You might want to set the variable SCIPY_PIL_IMAGE_VIEWER"
	elog "to your prefered image viewer if you don't like the default one. Ex:"
	elog "\t echo \"export SCIPY_PIL_IMAGE_VIEWER=display\" >> ~/.bashrc"
}
