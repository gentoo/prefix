# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numpy/numpy-1.1.1.ebuild,v 1.5 2009/04/06 18:17:44 armin76 Exp $

NEED_PYTHON=2.4

inherit distutils eutils flag-o-matic fortran

DESCRIPTION="Fast array and numerical python library"
SRC_URI="mirror://sourceforge/numpy/${P}.tar.gz"
HOMEPAGE="http://numeric.scipy.org/"

RDEPEND="lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	lapack? ( dev-util/pkgconfig )"

IUSE="lapack"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
LICENSE="BSD"

# whatever LDFLAGS set will break linking
# see progress in http://projects.scipy.org/scipy/numpy/ticket/573
if [ -n "${LDFLAGS}" ]; then
	append-ldflags -shared
else
	LDFLAGS="-shared"
fi

pkg_setup() {
	# only one fortran to link with:
	# linking with cblas and lapack library will force
	# autodetecting and linking to all available fortran compilers
	use lapack || return
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
			die "numpy_fortran_setup failed" ;;
	esac

	# when fortran flags are set, pic is removed.
	use amd64 && FFLAGS="${FFLAGS} -fPIC"
	export NUMPY_FCONFIG="config_fc --fcompiler=${fc}"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix some paths and docs in f2py
	epatch "${FILESDIR}"/${PN}-1.1.0-f2py.patch
	if use lapack; then
		append-ldflags "$(pkg-config --libs-only-other cblas lapack)"
		sed -i -e '/NO_ATLAS_INFO/,+1d' numpy/core/setup.py || die
		cat >> site.cfg <<-EOF
			[blas_opt]
			include_dirs = $(pkg-config --cflags-only-I cblas \
				| sed -e 's/^-I//' -e 's/ -I/:/g')
			library_dirs = $(pkg-config --libs-only-L cblas \
				| sed -e 's/^-L//' -e 's/ -L/:/g')
			libraries = $(pkg-config --libs-only-l cblas \
				| sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			[lapack_opt]
			library_dirs = $(pkg-config --libs-only-L lapack \
				| sed -e 's/^-L//' -e 's/ -L/:/g')
			libraries = $(pkg-config --libs-only-l lapack \
				| sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		EOF
	else
		export {ATLAS,PTATLAS,BLAS,LAPACK,MKL}=None
	fi
}

src_compile() {
	# when fortran flags are set, pic is removed but unfortunately needed
	distutils_src_compile ${NUMPY_FCONFIG}
}

src_test() {
	"${python}" setup.py ${NUMPY_FCONFIG} install \
		--home="${S}"/test \
		--no-compile \
		|| die "install test failed"

	pushd "${S}"/test/lib*/python
	PYTHONPATH=. "${python}" -c "import numpy; numpy.test(10,3)" 2>&1 \
		| tee test.log
	grep -q '^OK$' test.log || die "test failed"
	popd

	rm -rf test
}

src_install() {
	distutils_src_install ${NUMPY_FCONFIG}

	docinto numpy
	dodoc numpy/doc/*txt || die "dodoc failed"

	docinto f2py
	dodoc numpy/f2py/docs/*txt || die "dodoc f2py failed"
	doman numpy/f2py/f2py.1 || die "doman failed"
}

pkg_postinst() {
	if  ! built_with_use sys-devel/gcc fortran &&
		! has_version dev-lang/ifc
	then
		ewarn "To use numpy's f2py you need a fortran compiler."
		ewarn "You can either set USE=fortran flag and re-install gcc,"
		ewarn "or install dev-lang/ifc"
	fi
}
