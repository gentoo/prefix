# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Parse-Yapp/Parse-Yapp-1.05-r1.ebuild,v 1.21 2007/07/10 23:33:30 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

MY_P="${P/_/}"

DESCRIPTION="Compiles yacc-like LALR grammars to generate Perl OO parser modules"
HOMEPAGE="http://search.cpan.org/~fdesar/"
SRC_URI="mirror://cpan/authors/id/F/FD/FDESAR/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

S=${WORKDIR}/${MY_P}

src_install() {
	perl-module_src_install

	insinto /usr/share/doc/${PF}/examples
	doins Calc.yp YappParse.yp
}

DEPEND="dev-lang/perl"
