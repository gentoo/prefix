# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/scipy/scipy-0.7.1.ebuild,v 1.3 2009/09/04 21:31:22 arfrever Exp $

EAPI="2"
NEED_PYTHON="2.4"
SUPPORT_PYTHON_ABIS="1"

inherit eutils distutils flag-o-matic toolchain-funcs

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
DESCRIPTION="Scientific algorithms library for Python"
HOMEPAGE="http://www.scipy.org/"
LICENSE="BSD"

SLOT="0"
IUSE="umfpack"
#IUSE="test umfpack"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

CDEPEND=">=dev-python/numpy-1.2
	virtual/cblas
	virtual/lapack
	umfpack? ( sci-libs/umfpack )"

DEPEND="${CDEPEND}
	dev-util/pkgconfig
	umfpack? ( dev-lang/swig )"
#	test? ( dev-python/nose )

RDEPEND="${CDEPEND}
	dev-python/imaging"

RESTRICT_PYTHON_ABIS="3.*"

# buggy tests
RESTRICT="test"

DOCS="THANKS.txt LATEST.txt TOCHANGE.txt"

pkg_setup() {
	# scipy automatically detects libraries by default
	export {FFTW,FFTW3,UMFPACK}=None
	use umfpack && unset UMFPACK
	append-ldflags -shared
	[[ -z ${FC}  ]] && export FC=$(tc-getFC)
	# hack to force F77 to be FC until bug #278772 is fixed
	[[ -z ${F77} ]] && export F77=$(tc-getFC)
	export SCIPY_FCONFIG="config_fc --noopt --noarch"
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
	[[ -n ${FFLAGS} ]] && FFLAGS="${FFLAGS} -fPIC"
	distutils_src_compile ${SCIPY_FCONFIG}
}

src_test() {
	testing() {
		"$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install \
			--home="${S}/test-${PYTHON_ABI}" --no-compile ${SCIPY_FCONFIG} || die "install test failed"
		pushd "${S}/test-${PYTHON_ABI}/"lib*/python > /dev/null
		PYTHONPATH=. "${python}" -c "import scipy; scipy.test('full')" 2>&1 | tee test.log
		grep -q ^ERROR test.log && die "test failed"
		popd > /dev/null
		rm -fr test-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install ${SCIPY_FCONFIG}
}

pkg_postinst() {
	distutils_pkg_postinst

	elog "You might want to set the variable SCIPY_PIL_IMAGE_VIEWER"
	elog "to your prefered image viewer if you don't like the default one. Ex:"
	elog "\t echo \"export SCIPY_PIL_IMAGE_VIEWER=display\" >> ~/.bashrc"
}
