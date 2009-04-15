# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numeric/numeric-24.2-r6.ebuild,v 1.14 2009/04/13 11:38:12 armin76 Exp $

NEED_PYTHON=2.3

inherit distutils eutils

MY_P=Numeric-${PV}

DESCRIPTION="Numerical multidimensional array language facility for Python."
HOMEPAGE="http://numeric.scipy.org/"
SRC_URI="mirror://sourceforge/numpy/${MY_P}.tar.gz
	doc? ( http://numpy.scipy.org/numpy.pdf )"

RDEPEND="lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	lapack? ( dev-util/pkgconfig )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc lapack"

S="${WORKDIR}/${MY_P}"

# ex usage: pkgconf_cfg --libs-only-l cblas: ['cblas','atlas']
pkgconf_cfg() {
	local cfg="["
	for i in $(pkg-config "$1" "$2"); do
		cfg="${cfg}'${i:2}'"
	done
	echo "${cfg//\'\'/','}]"
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
	# fix gettimeofday issue on NetBSD
	epatch "${FILESDIR}"/${PN}-24.2.ranf.c.patch
	# rename z_abs on interix3, since there is a name colission with the system math.h
	epatch "${FILESDIR}"/${P}-interix3.patch

	# adapt lapack/cblas support
	if use lapack; then
		cd "${S}"
		mv customize.py customize.py.orig
		cat > customize.py << EOF
use_system_lapack = 1
lapack_libraries = $(pkgconf_cfg --libs-only-l lapack)
lapack_library_dirs = $(pkgconf_cfg --libs-only-L lapack)
use_system_blas = 1
dotblas_libraries = $(pkgconf_cfg --libs-only-l cblas)
dotblas_library_dirs = $(pkgconf_cfg --libs-only-L cblas)
dotblas_cblas_header = '<cblas.h>'
EOF
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
	newdoc Packages/MA/README README.MA || die
	newdoc Packages/RNG/README README.RNG || die

	if use lapack; then
		docinto dotblas
		dodoc Packages/dotblas/{README,profileDot}.txt || die "doc for dotblas failed"
		insinto /usr/share/doc/${PF}/dotblas
		doins Packages/dotblas/profileDot.py || die "example for dotblas failed"
	fi

	# install tutorial and docs
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r Test Demo/NumTut || die "install tutorial failed"
		newins "${DISTDIR}"/numpy.pdf numeric.pdf || die "install doc failed"
	fi
}
