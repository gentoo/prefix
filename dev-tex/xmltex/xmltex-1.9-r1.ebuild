# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/xmltex/xmltex-1.9-r1.ebuild,v 1.8 2008/09/14 18:05:38 aballier Exp $

inherit latex-package

IUSE=""

DESCRIPTION="A non validating namespace aware XML parser implemented in TeX"
HOMEPAGE="http://www.dcarlisle.demon.co.uk/xmltex/manual.html"
# Taken from: ftp://www.ctan.org/tex-archive/macros/xmltex.tar.gz
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LPPL-1.2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="virtual/latex-base"

S=${WORKDIR}/${PN}/base

has_tetex_3() {
	if has_version '>=app-text/tetex-2.96' || has_version '>=app-text/ptex-3.1.4.20041026' ; then
		true
	else
		false
	fi
}

src_compile() {
	if has_tetex_3 ; then
		latex -ini -progname=xmltex "&latex" xmltex.ini || die "xmltex.ini failed"
		pdftex -ini -progname=pdfxmltex "&pdflatex" pdfxmltex.ini || die "pdfxmltex.ini failed"
	else
		tex -ini -progname=xmltex xmltex.ini || die "xmltex.ini failed"
		pdftex -ini -progname=pdfxmltex pdfxmltex.ini || die "pdfxmltex.ini failed"
	fi
}

src_install() {

	local TEXMF_PATH="$(kpsewhich --expand-var='$TEXMFMAIN')"

	insinto ${TEXMF_PATH#${EPREFIX}}/web2c
	doins *.fmt || die

	insinto ${TEXMF}/tex/xmltex
	doins *.{xml,xmt,cfg,tex,ini}

	dodir /usr/bin
	if has_tetex_3 ; then
		dosym /usr/bin/latex /usr/bin/xmltex
		dosym /usr/bin/pdflatex /usr/bin/pdfxmltex
	else
		dosym /usr/bin/tex /usr/bin/xmltex
		dosym /usr/bin/pdftex /usr/bin/pdfxmltex
	fi

	dohtml *.html
	dodoc readme.txt
}

pkg_preinst() {

	local TEXMF_PATH="$(kpsewhich --expand-var='$TEXMFMAIN')"

	if ! grep pdfxmltex ${TEXMF_PATH}/web2c/texmf.cnf > /dev/null 2>&1 ; then
		cat >>${TEXMF_PATH}/web2c/texmf.cnf<<-EOF

		! Automatically added by Portage (dev-tex/xmltex)
		TEXINPUTS.pdfxmltex = .;\$TEXMF/{pdftex,tex}/{xmltex,plain,generic,}//
		EOF
	fi
}
