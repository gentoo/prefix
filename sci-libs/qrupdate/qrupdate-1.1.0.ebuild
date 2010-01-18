# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/qrupdate/qrupdate-1.1.0.ebuild,v 1.1 2010/01/12 05:16:13 markusle Exp $

EAPI="2"

inherit eutils fortran multilib

DESCRIPTION="A library for fast updating of QR and Cholesky decompositions"
HOMEPAGE="http://sourceforge.net/projects/qrupdate"
SRC_URI="mirror://sourceforge/qrupdate/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE=""

RDEPEND="virtual/blas
		virtual/lapack"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"

FORTRAN="gfortran ifc g77"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.0.1-makefile.patch
	# I mailed both patches below to the author -- grobian 2010-01-18
	epatch "${FILESDIR}"/${PN}-1.1.0-darwin-dylib.patch
	epatch "${FILESDIR}"/${PN}-1.1.0-destdir.patch

	local BLAS_LIBS="$(pkg-config --libs blas)"
	local LAPACK_LIBS="$(pkg-config --libs lapack)"

	sed -i Makeconf \
		-e "s:gfortran:${FORTRANC}:g" \
		-e "s:FFLAGS=.*:FFLAGS=${FFLAGS}:" \
		-e "s:BLAS=.*:BLAS=${BLAS_LIBS}:" \
		-e "s:LAPACK=.*:LAPACK=${LAPACK_LIBS}:" \
		-e "/^LIBDIR=/a\PREFIX=${EPREFIX}/usr" \
		|| die "Failed to set up Makeconf"
}

src_compile() {
	emake solib || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install-shlib || die "emake install failed"

	dodoc README ChangeLog || die "dodoc failed"
}
