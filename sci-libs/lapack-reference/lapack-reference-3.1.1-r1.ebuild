# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/lapack-reference/lapack-reference-3.1.1-r1.ebuild,v 1.20 2008/12/07 19:10:42 vapier Exp $

inherit eutils autotools flag-o-matic fortran multilib

MyPN="${PN/-reference/}"

DESCRIPTION="FORTRAN reference implementation of LAPACK Linear Algebra PACKage"
HOMEPAGE="http://www.netlib.org/lapack/index.html"
SRC_URI="http://www.netlib.org/lapack/${MyPN}-lite-${PV}.tgz
	mirror://gentoo/${P}-autotools.patch.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc"

DEPEND="virtual/blas
	dev-util/pkgconfig
	app-admin/eselect-lapack"
RDEPEND="virtual/blas
	app-admin/eselect-lapack
	doc? ( app-doc/lapack-docs )"

S="${WORKDIR}/${MyPN}-lite-${PV}"

pkg_setup() {
	FORTRAN="g77 gfortran ifc"
	fortran_pkg_setup
	if  [[ ${FORTRANC} == if* ]]; then
		ewarn "Using Intel Fortran at your own risk"
		export LDFLAGS="$(raw-ldflags)"
		export NOOPT_FFLAGS=-O
	fi
	ESELECT_PROF=reference
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P}-autotools.patch
	epatch "${FILESDIR}"/${P}-test-fix.patch
	eautoreconf

	# set up the testing routines
	sed -e "s:g77:${FORTRANC}:" \
		-e "s:-funroll-all-loops -O3:${FFLAGS} $(pkg-config --cflags blas):" \
		-e "s:LOADOPTS =:LOADOPTS = ${LDFLAGS} $(pkg-config --cflags blas):" \
		-e "s:../../blas\$(PLAT).a:$(pkg-config --libs blas):" \
		-e "s:lapack\$(PLAT).a:SRC/.libs/liblapack.a:" \
		make.inc.example > make.inc \
		|| die "Failed to set up make.inc"
}

src_compile() {
	econf \
		--libdir="${EPREFIX}/usr/$(get_libdir)/lapack/reference" \
		--with-blas="$(pkg-config --libs blas)" \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README || die "dodoc failed"
	eselect lapack add $(get_libdir) "${FILESDIR}"/eselect.lapack.reference ${ESELECT_PROF}
}

src_test() {
	cd "${S}"/TESTING/MATGEN
	emake || die "Failed to create tmglib.a"
	cd "${S}"/TESTING
	emake || die "lapack-reference tests failed."
}

pkg_postinst() {
	local p=lapack
	local current_lib=$(eselect ${p} show | cut -d' ' -f2)
	if [[ ${current_lib} == ${ESELECT_PROF} || -z ${current_lib} ]]; then
		# work around eselect bug #189942
		local configfile="${EROOT}"/etc/env.d/${p}/$(get_libdir)/config
		[[ -e ${configfile} ]] && rm -f ${configfile}
		eselect ${p} set ${ESELECT_PROF}
		elog "${p} has been eselected to ${ESELECT_PROF}"
	else
		elog "Current eselected ${p} is ${current_lib}"
		elog "To use ${p} ${ESELECT_PROF} implementation, you have to issue (as root):"
		elog "\t eselect ${p} set ${ESELECT_PROF}"
	fi
}
