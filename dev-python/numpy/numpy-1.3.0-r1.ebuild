# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numpy/numpy-1.3.0-r1.ebuild,v 1.2 2009/08/29 19:07:57 arfrever Exp $

EAPI="2"

NEED_PYTHON="2.4"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils flag-o-matic toolchain-funcs

DESCRIPTION="Fast array and numerical python library"
SRC_URI="mirror://sourceforge/numpy/${P}.tar.gz"
HOMEPAGE="http://numpy.scipy.org/"

RDEPEND="dev-python/setuptools
	lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	lapack? ( dev-util/pkgconfig )
	test? ( >=dev-python/nose-0.10 )"

IUSE="lapack test"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
LICENSE="BSD"

RESTRICT_PYTHON_ABIS="3*"

pkg_setup() {
	# whatever LDFLAGS set will break linking
	# see progress in http://projects.scipy.org/scipy/numpy/ticket/573
	if [[ ${CHOST} != *-darwin* ]] ; then
	if [ -n "${LDFLAGS}" ]; then
		append-ldflags -shared
	else
		LDFLAGS="-shared"
	fi
	fi

	# only one fortran to link with:
	# linking with cblas and lapack library will force
	# autodetecting and linking to all available fortran compilers
	use lapack || return
	[[ -z ${FC} ]] && FC=$(tc-getFC)
	# when fortran flags are set, pic is removed.
	FFLAGS="${FFLAGS} -fPIC"
	export NUMPY_FCONFIG="config_fc --noopt --noarch"
}

src_prepare() {
	# Fix some paths and docs in f2py
	epatch "${FILESDIR}"/${PN}-1.1.0-f2py.patch

	epatch "${FILESDIR}/${P}-parisc.patch" # bug 277438
	epatch "${FILESDIR}/${P}-alpha.patch" # bug 277438
	epatch "${FILESDIR}/${P}-arm-sh.patch"

	epatch "${FILESDIR}"/${P}-fenv-freebsd.patch # bug 279487

	# Gentoo patch for ATLAS library names
	sed -i \
		-e "s:'f77blas':'blas':g" \
		-e "s:'ptf77blas':'blas':g" \
		-e "s:'ptcblas':'cblas':g" \
		-e "s:'lapack_atlas':'lapack':g" \
		numpy/distutils/system_info.py \
		|| die "sed system_info.py failed"

	if use lapack; then
		append-ldflags "$(pkg-config --libs-only-other cblas lapack)"
		sed -i -e '/NO_ATLAS_INFO/,+1d' numpy/core/setup.py || die
		cat >> site.cfg <<-EOF
			[atlas]
			include_dirs = $(pkg-config --cflags-only-I \
				cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
			library_dirs = $(pkg-config --libs-only-L \
				cblas blas lapack | sed -e \
				's/^-L//' -e 's/ -L/:/g' -e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			atlas_libs = $(pkg-config --libs-only-l \
				cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			lapack_libs = $(pkg-config --libs-only-l \
				lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			[blas_opt]
			include_dirs = $(pkg-config --cflags-only-I \
				cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
			library_dirs = $(pkg-config --libs-only-L \
				cblas blas | sed -e 's/^-L//' -e 's/ -L/:/g' \
				-e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			libraries = $(pkg-config --libs-only-l \
				cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			[lapack_opt]
			library_dirs = $(pkg-config --libs-only-L \
				lapack | sed -e 's/^-L//' -e 's/ -L/:/g' \
				-e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			libraries = $(pkg-config --libs-only-l \
				lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		EOF
	else
		export {ATLAS,PTATLAS,BLAS,LAPACK,MKL}=None
	fi

	# fix invalid and unprefixed shebangs
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/python' \
		numpy/distutils/conv_template.py \
		numpy/distutils/from_template.py \
		numpy/distutils/system_info.py \
		numpy/ma/bench.py
}

src_compile() {
	distutils_src_compile ${NUMPY_FCONFIG}
}

src_test() {
	testing() {
		"$(PYTHON)" setup.py ${NUMPY_FCONFIG} build -b "build-${PYTHON_ABI}" install \
			--home="${S}/test-${PYTHON_ABI}" --no-compile || die "install test failed"
		pushd "${S}/test-${PYTHON_ABI}/"lib* > /dev/null
		PYTHONPATH=python "$(PYTHON)" -c "import numpy; numpy.test()" 2>&1 | tee test.log
		grep -q '^ERROR' test.log && die "test failed"
		popd > /dev/null
		rm -fr test-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install ${NUMPY_FCONFIG}
	dodoc THANKS.txt DEV_README.txt COMPATIBILITY
	rm -f "${ED}"/usr/lib/python*/site-packages/numpy/*.txt || die
	docinto f2py
	dodoc numpy/f2py/docs/*.txt || die "dodoc f2py failed"
	doman numpy/f2py/f2py.1 || die "doman failed"
}
