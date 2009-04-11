# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/primer3/primer3-1.1.4.ebuild,v 1.1 2008/08/26 19:08:09 ribosome Exp $

DESCRIPTION="Design primers for PCR reactions."
HOMEPAGE="http://primer3.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="whitehead"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"

RDEPEND=""

S="${WORKDIR}/src"

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ ${CHOST} == *-darwin* ]] && \
		sed -e "s:LIBOPTS ='-static':LIBOPTS =:" -i Makefile
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
