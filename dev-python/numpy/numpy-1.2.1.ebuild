# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numpy/numpy-1.2.1.ebuild,v 1.12 2009/04/14 10:09:51 armin76 Exp $

NEED_PYTHON=2.4

inherit distutils eutils flag-o-matic fortran

DESCRIPTION="Fast array and numerical python library"
SRC_URI="mirror://sourceforge/numpy/${P}.tar.gz"
HOMEPAGE="http://numeric.scipy.org/"

RDEPEND="lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	test? ( >=dev-python/nose-0.10 )
	lapack? ( dev-util/pkgconfig )"

IUSE="lapack test"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
LICENSE="BSD"

# whatever LDFLAGS set will break linking
# see progress in http://projects.scipy.org/scipy/numpy/ticket/573
if [[ ${CHOST} != *-darwin* ]] ; then
if [ -n "${LDFLAGS}" ]; then
	append-ldflags -shared
else
	LDFLAGS="-shared"
fi
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
		*) eerror "Unknown fortran compiler: ${FORTRANC}"
		   die "numpy_fortran_setup failed" ;;
	esac

	# when fortran flags are set, pic is removed.
	use amd64 && FFLAGS="${FFLAGS} -fPIC"
	export NUMPY_FCONFIG="config_fc --fcompiler=${fc} --noopt --noarch"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix some paths and docs in f2py
	epatch "${FILESDIR}"/${PN}-1.1.0-f2py.patch

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
	pushd "${S}"/test/lib*
	PYTHONPATH=python "${python}" -c "import numpy; numpy.test()" 2>&1 | tee test.log
	grep -q '^ERROR' test.log && die "test failed"
	popd
	rm -rf test
}

src_install() {
	distutils_src_install ${NUMPY_FCONFIG}
	dodoc THANKS.txt DEV_README.txt COMPATIBILITY
	rm -f "${ED}"/usr/lib/python*/site-packages/numpy/*.txt
	docinto f2py
	dodoc numpy/f2py/docs/*.txt || die "dodoc f2py failed"
	doman numpy/f2py/f2py.1 || die "doman failed"
}

pkg_postinst() {
	if ( has_version sys-devel/gcc && ! built_with_use sys-devel/gcc fortran ||
		! has_version sys-devel/gcc ) &&
		! has_version dev-lang/ifc
	then
		ewarn "To use numpy's f2py you need a fortran compiler."
		ewarn "You can either set USE=fortran flag and re-install gcc,"
		ewarn "or install dev-lang/ifc"
	fi
}
