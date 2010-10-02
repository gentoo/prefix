# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dvipdfm/dvipdfm-0.13.2d-r1.ebuild,v 1.14 2010/03/08 15:40:37 ssuominen Exp $

inherit eutils

DESCRIPTION="DVI to PDF translator"
SRC_URI="http://gaspra.kettering.edu/dvipdfm/${P}.tar.gz"
HOMEPAGE="http://gaspra.kettering.edu/dvipdfm/"
LICENSE="GPL-2"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE=""

DEPEND="!>=app-text/tetex-2
	>=media-libs/libpng-1.2.1
	>=sys-libs/zlib-1.1.4
	!app-text/ptex
	virtual/latex-base"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-libpng14.patch
}

src_install () {
	einstall || die "einstall failed!"

	# Install .map and .enc files to correct locations, bug #200956
	dodir /usr/share/texmf/fonts/map/dvipdfm/base

	for i in cmr.map psbase14.map lw35urw.map lw35urwa.map t1fonts.map; do
		mv "${ED}usr/share/texmf/dvipdfm/config/${i}" "${ED}usr/share/texmf/fonts/map/dvipdfm/base" || die "moving .map file failed"
	done

	dodir /usr/share/texmf/fonts/enc/dvipdfm

	mv "${ED}usr/share/texmf/dvipdfm/base" "${ED}usr/share/texmf/fonts/enc/dvipdfm/base" || die "moving .enc file failed"

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
