# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/tetex/tetex-2.0.2-r9.ebuild,v 1.12 2007/01/15 07:26:42 wormo Exp $

EAPI="prefix"

inherit tetex-2 flag-o-matic

DESCRIPTION="a complete TeX distribution"
HOMEPAGE="http://tug.org/teTeX/"

KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

src_unpack() {
	tetex-2_src_unpack

	# bug 75801
	EPATCH_OPTS="-d ${S}/libs/xpdf/xpdf -p0" epatch ${FILESDIR}/xpdf-CESA-2004-007-xpdf2-newer.diff
	EPATCH_OPTS="-d ${S}/libs/xpdf -p1" epatch ${FILESDIR}/xpdf-goo-sizet.patch
	EPATCH_OPTS="-d ${S}/libs/xpdf -p1" epatch ${FILESDIR}/xpdf2-underflow.patch
	EPATCH_OPTS="-d ${S}/libs/xpdf/xpdf -p0" epatch ${FILESDIR}/xpdf-3.00pl2-CAN-2004-1125.patch
	EPATCH_OPTS="-d ${S}/libs/xpdf/xpdf -p0" epatch ${FILESDIR}/xpdf-3.00pl3-CAN-2005-0064.patch

	# bug 122365
	EPATCH_OPTS="-d ${WORKDIR}" epatch ${FILESDIR}/tetex-2.0.2-flex-unput.patch || die

	#bug 115775
	EPATCH_OPTS="-d ${S}/libs/xpdf/xpdf -p2" epatch ${FILESDIR}/xpdf-2.02pl1-CAN-2005-3191-3.patch

	EPATCH_OPTS="-d ${S} -p1" epatch ${FILESDIR}/xdvizilla.patch

	# bug 85404
	EPATCH_OPTS="-d ${S} -p1" epatch ${FILESDIR}/${P}-epstopdf-wrong-rotation.patch

	# bug 118264
	EPATCH_OPTS="-d ${WORKDIR} -p0" epatch ${FILESDIR}/${P}-dvi-draw-conflicting-types.patch

	# On OSX/Darwin we have to use glibtool instead
	cp "${FILESDIR}"/${P}-use-system-libtool.patch "${T}"/
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e '/^+/s|libtool|glibtool|g' \
			"${T}"/${P}-use-system-libtool.patch

	# bug 80985
	EPATCH_OPTS="-d ${S} -p1" epatch "${T}"/${P}-use-system-libtool.patch

	# bug 115775 (from comment 17)
	EPATCH_OPTS="-d ${S} -p1" epatch ${FILESDIR}/${P}-skip_bibtex_test.patch

}

src_compile() {
	use amd64 && replace-flags "-O3" "-O2"
	tetex_src_compile
}

src_install() {
	insinto /usr/share/texmf/tex/latex/greek
	doins ${FILESDIR}/iso-8859-7.def
	tetex-2_src_install
}
