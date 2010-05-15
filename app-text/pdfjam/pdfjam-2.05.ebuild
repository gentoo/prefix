# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/pdfjam/pdfjam-2.05.ebuild,v 1.1 2010/04/29 09:37:19 aballier Exp $

MY_PV=${PV/./}
DESCRIPTION="pdfnup, pdfjoin and pdf90"
HOMEPAGE="http://www.warwick.ac.uk/go/pdfjam"
SRC_URI="http://www.warwick.ac.uk/go/pdfjam/${PN}_${MY_PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
S=${WORKDIR}/${PN}

DEPEND="virtual/latex-base"
RDEPEND="${DEPEND}"

## grobian: do we still need to prefix this stuff?
#src_compile() {
#	for i in pdf90 pdfjoin pdfnup; do
#		cp scripts/$i scripts/$i.orig
#		sed -e 's,^pdflatex="/usr/local/bin/pdflatex",pdflatex="'"${EPREFIX}"'/usr/bin/pdflatex",' \
#			-e '1c\#!/usr/bin/env sh' \
#			-e 's:for d in /etc /usr/share/etc /usr/local/share /usr/local/etc:for d in "'"${EPREFIX}"'"/etc:' \
#			scripts/$i.orig > scripts/$i
#	done
#}

src_install() {
	dobin bin/* || die
	dodoc PDFjam-README.html || die
	doman man1/* || die
}
