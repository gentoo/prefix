# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/primer3/primer3-1.1.1.ebuild,v 1.1 2007/06/28 15:51:24 ribosome Exp $

EAPI="prefix"

DESCRIPTION="Design primers for PCR reactions."
HOMEPAGE="http://primer3.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="whitehead"

SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl"

RDEPEND=""

S="${WORKDIR}/${P}/src"

src_unpack() {
	unpack ${A}
	if use ppc-macos; then
		cd ${S}
		sed -e "s:LIBOPTS ='-static':LIBOPTS =:" -i Makefile || die
	fi
}

src_compile() {
	emake -e || die
}

src_test () {
	make primer_test || die
}

src_install () {
	dobin long_seq_tm_test ntdpal oligotm primer3_core || die \
			"Could not install program."
	dodoc ../{how-to-cite.txt,README.txt,example} || die \
			"Could not install documentation."
}
