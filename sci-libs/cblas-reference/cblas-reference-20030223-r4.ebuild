# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/cblas-reference/cblas-reference-20030223-r4.ebuild,v 1.15 2008/12/07 18:41:11 vapier Exp $

inherit autotools eutils fortran multilib

MyPN="${PN/-reference/}"

DESCRIPTION="C wrapper interface to the F77 reference BLAS implementation"
LICENSE="public-domain"
HOMEPAGE="http://www.netlib.org/blas/"
SRC_URI="http://www.netlib.org/blas/blast-forum/${MyPN}.tgz"

SLOT="0"
IUSE=""
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

RDEPEND="virtual/blas
	app-admin/eselect-cblas"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

FORTRAN="gfortran g77 ifc"
ESELECT_PROF=reference
S="${WORKDIR}/CBLAS"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-autotool.patch
	eautoreconf

	cp "${FILESDIR}"/eselect.cblas.reference "${T}"/
	sed -i -e "s:/usr:${EPREFIX}/usr:" "${T}"/eselect.cblas.reference || die
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/\.so\([\.0-9]\+\)\?/\1.dylib/g' \
			"${T}"/eselect.cblas.reference || die
	fi
}

src_compile() {
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir)/blas/reference \
		--with-blas="$(pkg-config --libs blas)" \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README || die "failed to install docs"
	insinto /usr/share/doc/${PF}
	doins cblas_example*c || die "install examples failed"
	eselect cblas add $(get_libdir) "${T}"/eselect.cblas.reference ${ESELECT_PROF}
}

pkg_postinst() {
	local p=cblas
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
