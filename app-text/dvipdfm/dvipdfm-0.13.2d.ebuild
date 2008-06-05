# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dvipdfm/dvipdfm-0.13.2d.ebuild,v 1.4 2007/12/11 10:58:15 aballier Exp $

EAPI="prefix"

DESCRIPTION="DVI to PDF translator"
SRC_URI="http://gaspra.kettering.edu/dvipdfm/${P}.tar.gz"
HOMEPAGE="http://gaspra.kettering.edu/dvipdfm/"
LICENSE="GPL-2"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
SLOT="0"
IUSE=""

DEPEND="!>=app-text/tetex-2
	>=media-libs/libpng-1.2.1
	>=sys-libs/zlib-1.1.4
	!>=app-text/tetex-2
	!app-text/ptex
	virtual/latex-base"

S="${WORKDIR}/${PN}"

src_install () {
	einstall || die "einstall failed!"

	dodoc AUTHORS ChangeLog Credits NEWS OBTAINING README* TODO

	docinto doc
	dodoc doc/*

	docinto latex-support
	dodoc latex-support/*

	insinto /usr/share/texmf/tex/latex/dvipdfm/
	doins latex-support/dvipdfm.def
}

pkg_postinst() {
	if [ "$ROOT" = "/" ] ; then
		"${EPREFIX}"/usr/sbin/texmf-update
	fi
}
