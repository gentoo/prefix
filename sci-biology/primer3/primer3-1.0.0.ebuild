# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/primer3/primer3-1.0.0.ebuild,v 1.12 2007/06/28 14:36:23 ribosome Exp $

EAPI="prefix"

DESCRIPTION="Design primers for PCR reactions."
HOMEPAGE="http://primer3.sourceforge.net/"
SRC_URI="http://frodo.wi.mit.edu/${PN}/${PN}_${PV}.tar.gz"
LICENSE="whitehead"

SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86"
IUSE=""

RDEPEND=""

DEPEND="dev-lang/perl"

S=${WORKDIR}/${PN}_${PV}/src

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
	cd ../test
	perl primer_test.pl primer3_core || die
}

src_install () {
	dobin primer3_core
	dodoc release_notes ../README ../example
}
