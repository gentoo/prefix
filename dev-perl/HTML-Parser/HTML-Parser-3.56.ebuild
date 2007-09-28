# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTML-Parser/HTML-Parser-3.56.ebuild,v 1.8 2007/07/11 15:41:36 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Parse <HEAD> section of HTML documents"
HOMEPAGE="http://search.cpan.org/~gaas/${P}/"
SRC_URI="mirror://cpan/authors/id/G/GA/GAAS/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="unicode"

DEPEND=">=dev-perl/HTML-Tagset-3.03
	dev-lang/perl"

mydoc="ANNOUNCEMENT TODO"

src_compile() {
	use unicode && answer='y' || answer='n'
	if [ "${MMSIXELEVEN}" ]; then
		echo "${answer}" | perl Makefile.PL ${myconf} \
		PREFIX=/usr INSTALLDIRS=vendor DESTDIR=${ED}
	else
		echo "${answer}" | perl Makefile.PL ${myconf} \
		PREFIX=${ED}/usr INSTALLDIRS=vendor
	fi
	perl-module_src_test
}
