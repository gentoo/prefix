# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SGMLSpm/SGMLSpm-1.03-r5.ebuild,v 1.20 2007/07/12 08:45:04 uberlord Exp $

EAPI="prefix"

MY_P="${P}ii"
DESCRIPTION="Perl library for parsing the output of nsgmls"
HOMEPAGE="http://search.cpan.org/author/DMEGG/SGMLSpm-1.03ii/"
SRC_URI="mirror://cpan/authors/id/D/DM/DMEGG/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-lang/perl-5.8.0-r12"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}"/${P}-Makefile "${S}"/Makefile
	eval `perl '-V:package'`
	eval `perl '-V:version'`
	cd "${S}"
	sed -i -e "s:5.6.1:${version}:" Makefile
#	sed -i -e "s:perl5:perl5/vendor_perl/${version}:" Makefile
	sed -i -e "s:MODULEDIR = \${PERL5DIR}/site_perl/${version}/SGMLS:MODULEDIR = \${PERL5DIR}/vendor_perl/${version}/SGMLS:" Makefile
	sed -i -e "s:SPECDIR = \${PERL5DIR}:SPECDIR = ${ED}/usr/share/SGMLS:" Makefile
	sed -i -e "s:\${PERL5DIR}/SGMLS.pm:\${PERL5DIR}/vendor_perl/${version}/SGMLS.pm:" Makefile
	sed -i -e "s/^all: .*/all:/" Makefile

	sed -i \
		-e "s:PERL = :PERL = ${EPREFIX}:" \
		-e "s:PERL5DIR = \${D}:PERL5DIR = ${ED}:" \
		-e "s:BINDIR = \${D}:BINDIR = ${ED}:" \
		-e "s:HTMLDIR = \${D}:HTMLDIR = ${ED}:" Makefile
}

src_install () {
	dodir /usr/bin
	dodir /usr/lib/${package}/vendor_perl/${version}
	dodir /usr/share/SGMLS
	dodoc BUGS ChangeLog README TODO
	make install -f "${S}"/Makefile || die
	make docs -f "${S}"/Makefile || die
#	cd ${ED}/usr/lib/${package}/vendor_perl/${version}
}
