# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/prosper/prosper-1.5-r1.ebuild,v 1.7 2008/02/05 20:32:02 grobian Exp $

inherit latex-package

CONTRIB="contrib-prosper-1.0.0"

DESCRIPTION="Prosper is a LaTeX class for writing transparencies"
HOMEPAGE="http://prosper.sf.net/"
# Taken from: ftp://ftp.dante.de/tex-archive/macros/latex/contrib/${PN}.tar.gz
SRC_URI="mirror://gentoo/${P}.tar.gz
	mirror://sourceforge/prosper/${CONTRIB}.tar.gz"
LICENSE="LPPL-1.2"	# has been changed since 1.5
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
S=${WORKDIR}/${PN}
IUSE=""

src_install(){
	cd ${S}
	latex-package_src_doinstall styles
	insinto ${TEXMF}/tex/latex/${PN}/img/
	doins img/*.{ps,gif}
	for i in `find ./contrib/ -maxdepth 1 -type f -name "*.sty"`
	do
		insinto ${TEXMF}/tex/latex/${PN}/contrib/
		doins $i
	done
	insinto ${TEXMF}/tex/latex/${PN}/contrib/img/
	doins ./contrib/img/*.{ps,eps}
	dodoc README TODO NEWS FAQ AUTHORS ChangeLog
	dodoc doc/*.{eps,pdf,tex,ps}
	docinto doc-examples/
	dodoc doc/doc-examples/*.tex
	docinto contrib/
	dodoc contrib/*.{ps,tex}
}
