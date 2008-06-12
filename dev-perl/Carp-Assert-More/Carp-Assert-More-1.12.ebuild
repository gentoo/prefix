# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Carp-Assert-More/Carp-Assert-More-1.12.ebuild,v 1.12 2007/01/14 22:37:20 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="convenience wrappers around Carp::Assert"
HOMEPAGE="http://search.cpan.org/~petdance"
SRC_URI="mirror://cpan/authors/id/P/PE/PETDANCE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="virtual/perl-Scalar-List-Utils
	dev-perl/Carp-Assert
	dev-perl/Test-Exception
	dev-lang/perl"
