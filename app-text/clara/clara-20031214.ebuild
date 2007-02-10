# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/clara/clara-20031214.ebuild,v 1.14 2007/01/28 05:39:38 genone Exp $

EAPI="prefix"

DESCRIPTION="An OCR (Optical Character Recognition) program"
SRC_URI="http://www.geocities.com/claraocr/clara-20031214.tar.gz"
HOMEPAGE="http://www.geocities.com/claraocr/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~ppc-macos"
IUSE=""

DEPEND="|| ( x11-libs/libX11 virtual/x11 )"

src_compile() {
	emake || die
	emake doc || die
}

src_install() {
	dobin clara selthresh
	doman doc/clara*.1 selthresh.1

	dodoc ANNOUNCE CHANGELOG doc/FAQ
	insinto /usr/share/doc/${P}
	doins imre.pbm

	dohtml doc/*.html
}

pkg_postinst() {
	elog
	elog "Please note that Clara OCR has to be trained to recognize text,"
	elog "without a training session it simply won't work. Have a look at"
	elog "the docs in /usr/share/doc/${P}/html/ to get more "
	elog "info about the training procedure."
	elog
}
