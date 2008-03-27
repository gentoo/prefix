# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/glpk/glpk-4.27.ebuild,v 1.3 2008/03/26 14:03:08 bicatali Exp $

EAPI="prefix"

DESCRIPTION="GNU Linear Programming Kit"
LICENSE="GPL-3"
HOMEPAGE="http://www.gnu.org/software/glpk/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

SLOT="0"
IUSE="doc gmp iodbc mysql"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="iodbc? ( dev-db/libiodbc )
	gmp? ( dev-libs/gmp )
	mysql? ( virtual/mysql )"

src_compile() {
	econf \
		$(use_enable gmp) \
		$(use_enable iodbc) \
		$(use_enable mysql) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# INSTALL include some usage docs
	dodoc AUTHORS ChangeLog NEWS README || \
		die "failed to install docs"

	# 380Kb
	insinto /usr/share/doc/${PF}/examples
	doins examples/*.{c,mod,lp,mps,dat} || \
		die "failed to install examples"

	if use doc; then
		cd "${S}"/doc
		dodoc *.ps *.txt || die "failed to install manual files"
		insinto /usr/share/doc/${PF}
		doins memo/gomory.djvu || die "failed to instal memo"
	fi
}
