# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numpy/numpy-1.0.4-r2.ebuild,v 1.10 2008/05/20 13:52:31 bicatali Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils eutils flag-o-matic fortran

MY_P=${P/_beta/b}
MY_P=${MY_P/_}

DESCRIPTION="Fast array and numerical python library"
SRC_URI="mirror://sourceforge/numpy/${MY_P}.tar.gz"
HOMEPAGE="http://numeric.scipy.org/"

RDEPEND="!dev-python/f2py
	lapack? ( virtual/cblas virtual/lapack )"

DEPEND="${RDEPEND}
	lapack? ( dev-util/pkgconfig )"

IUSE="lapack"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
LICENSE="BSD"

S="${WORKDIR}/${MY_P}"

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
	epatch "${FILESDIR}"/${PN}-1.0.1-f2py.patch

	# Patch to use feclearexcept(3) rather than fpsetsticky(3) on FreeBSD 5.3+
	epatch "${FILESDIR}"/${P}-freebsd.patch

	# Detect phenom and nocona hardware correctly.  Bug #183236.
	epatch "${FILESDIR}"/${P}-cpuinfo.patch

	# Gentoo patch for ATLAS library and include dirs
	sed -i \
		-e "s:'f77blas':'blas':g" \
		-e "s:'ptf77blas':'blas':g" \
		-e "s:'ptcblas':'cblas':g" \
		-e "s:'lapack_atlas':'lapack':g" \
		-e "s:'atlas\*',:'','atlas\*',:g" \
		numpy/distutils/system_info.py \
		|| die "sed system_info.py failed"

	cat > site.cfg <<-EOF
		[DEFAULT]
		library_dirs = ${EPREFIX}/usr/$(get_libdir)
		include_dirs = ${EPREFIX}/usr/include
	EOF

	if use lapack; then
		# cblas and lapack libraries under the name of atlas
		# otherwise scipy will not create fast _dotblas
		cat >> site.cfg <<-EOF
			[atlas]
			atlas_libs = $(pkg-config --libs-only-l cblas lapack \
				| sed -e 's/^-l//' -e 's/ -l/,/g')
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
	if ! built_with_use sys-devel/gcc fortran && ! has_version dev-lang/ifc; then
		ewarn "To use numpy's f2py you need a fortran compiler."
		ewarn "You can either set USE=fortran flag and re-emerge gcc,"
		ewarn "or emerge dev-lang/ifc"
	fi
}
