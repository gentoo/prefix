# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numeric/numeric-24.2-r6.ebuild,v 1.1 2007/09/01 22:24:30 bicatali Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils eutils fortran

MY_P=Numeric-${PV}

DESCRIPTION="Numerical multidimensional array language facility for Python."
HOMEPAGE="http://numeric.scipy.org/"
SRC_URI="mirror://sourceforge/numpy/${MY_P}.tar.gz
	doc? ( http://numpy.scipy.org/numpy.pdf )"

# numeric needs cblas (virtual/cblas work in progress)
# and lapack. needs fortran to get the proper fortran to C library.
RDEPEND="lapack? ( || ( >=sci-libs/blas-atlas-3.7.11-r1
						>=sci-libs/cblas-reference-20030223-r3 )
					virtual/lapack )"
DEPEND="${RDEPEND}
	lapack? ( app-admin/eselect-cblas )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc lapack"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if use lapack; then
		FORTRAN="gfortran g77 ifc"
		fortran_pkg_setup
		for d in $(eselect cblas show); do mycblas=${d}; done
		if [[ -z "${mycblas/reference/}" ]] && [[ -z "${mycblas/atlas/}" ]]; then
			ewarn "You need to set cblas to atlas or reference. Do:"
			ewarn "   eselect cblas set <impl>"
			ewarn "where <impl> is atlas, threaded-atlas or reference"
			die "setup failed"
		fi
	fi
}

src_unpack() {
	unpack ${A}

	# fix list problem
	epatch "${FILESDIR}"/${P}-arrayobject.patch
	# fix skips of acosh, asinh
	epatch "${FILESDIR}"/${P}-umath.patch
	# fix eigenvalue hang
	epatch "${FILESDIR}"/${P}-eigen.patch
	# fix a bug in the test
	epatch "${FILESDIR}"/${P}-test.patch
	# fix only for python-2.5
	distutils_python_version
	[[ "${PYVER}" == 2.5 ]] && epatch "${FILESDIR}"/${P}-python25.patch
	# fix for dotblas from uncommited cvs
	epatch "${FILESDIR}"/${P}-dotblas.patch

	# adapt lapack support
	if use lapack; then
		epatch "${FILESDIR}"/${P}-lapack.patch
		local flib=
		if  [[ "${FORTRANC}" == gfortran ]]; then
			flib=gfortran
		elif [[ "${FORTRANC}" == if* ]]; then
			flib=imf
		fi
		if [[ "${mycblas}" == reference ]]; then
			sed -i \
				-e "s:g2c:${flib}:g" \
				-e "s:'atlas',::g" \
				-e "s:include/atlas:include/cblas:g" \
				"${S}"/customize.py \
				|| die "sed for lapack failed"
		fi
	fi
}

src_test() {
	cd build/lib*
	PYTHONPATH=. "${python}" "${S}"/Test/test.py \
		|| die "test failed"
}

src_install() {
	distutils_src_install

	# install various README from packages
	newdoc Packages/MA/README README.MA
	newdoc Packages/RNG/README README.RNG

	if use lapack; then
		docinto dotblas
		dodoc Packages/dotblas/{README,profileDot}.txt
		insinto /usr/share/doc/${PF}/dotblas
		doins Packages/dotblas/profileDot.py
	fi

	# install tutorial and docs
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r Test Demo/NumTut || die "install tutorial failed"
		newins "${DISTDIR}"/numpy.pdf numeric.pdf || die "install doc failed"
	fi
}
