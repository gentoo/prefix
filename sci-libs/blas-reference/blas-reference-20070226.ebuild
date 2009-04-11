# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/blas-reference/blas-reference-20070226.ebuild,v 1.18 2008/12/07 18:26:29 vapier Exp $

inherit eutils autotools fortran multilib flag-o-matic

LAPACKPV="3.1.1"
LAPACKPN="lapack-lite"

DESCRIPTION="Basic Linear Algebra Subprograms F77 reference implementations"
HOMEPAGE="http://www.netlib.org/blas/"
SRC_URI="http://www.netlib.org/lapack/${LAPACKPN}-${LAPACKPV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"

DEPEND="app-admin/eselect-blas"
RDEPEND="${DEPEND}
	doc? ( app-doc/blas-docs )"

S="${WORKDIR}/${LAPACKPN}-${LAPACKPV}"

pkg_setup() {
	FORTRAN="g77 gfortran ifc"
	fortran_pkg_setup
	if  [[ ${FORTRANC} == if* ]]; then
		ewarn "Using Intel Fortran at your own risk"
		LDFLAGS="$(raw-ldflags)"
	fi
	ESELECT_PROF=reference
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-autotool.patch
	eautoreconf
}

src_compile() {
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir)/blas/reference \
		|| die "econf failed"
	emake LDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	eselect blas add $(get_libdir) "${FILESDIR}"/eselect.blas.reference ${ESELECT_PROF}
}

pkg_postinst() {
	local p=blas
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
