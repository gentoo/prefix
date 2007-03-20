# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Elemental/XML-Elemental-2.0.ebuild,v 1.11 2007/01/19 17:25:09 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="an XML::Parser style and generic classes for simplistic and perlish handling of XML data. "
HOMEPAGE="http://search.cpan.org/~tima/"
SRC_URI="mirror://cpan/authors/id/T/TI/TIMA/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/XML-Parser
	dev-perl/XML-SAX
		dev-perl/Class-Accessor
	dev-lang/perl"
