# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Prints Excel spreadsheet (XLS, XLW) as a plain text"
HOMEPAGE="http://wizard.ae.krakow.pl/~jb/xls2txt/"
SRC_URI="http://wizard.ae.krakow.pl/~jb/xls2txt/xls2txt-0.11.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	exeinto /usr/bin
	doexe xls2txt
}
