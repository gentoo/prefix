# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/umfpack/umfpack-5.2.0.ebuild,v 1.9 2009/04/20 19:41:04 maekke Exp $

inherit autotools eutils

MY_PN=UMFPACK

DESCRIPTION="Unsymmetric multifrontal sparse LU factorization library"
HOMEPAGE="http://www.cise.ufl.edu/research/sparse/umfpack"
SRC_URI="http://www.cise.ufl.edu/research/sparse/${PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"
RDEPEND="virtual/blas
	sci-libs/amd"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-autotools.patch
	eautoreconf
}

src_compile() {
	econf \
		--with-blas="$(pkg-config --libs blas)" \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README.txt Doc/ChangeLog || die "dodoc failed"
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins Doc/*.pdf || die "doins failed"
	fi
}
