# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Handler-YAWriter/XML-Handler-YAWriter-0.23-r1.ebuild,v 1.17 2007/01/19 17:28:04 mcummings Exp $

inherit perl-module

MY_P="${P/_/}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="A Perl module providing a simple API to parsed XML instances"
HOMEPAGE="http://search.cpan.org/~kraehe/"
SRC_URI="mirror://cpan/authors/id/K/KR/KRAEHE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=dev-perl/libxml-perl-0.07-r1
	dev-lang/perl"
