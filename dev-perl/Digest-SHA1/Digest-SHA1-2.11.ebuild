# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Digest-SHA1/Digest-SHA1-2.11.ebuild,v 1.16 2007/01/15 17:31:27 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="NIST SHA message digest algorithm"
HOMEPAGE="http://search.cpan.org/~gaas/"
SRC_URI="http://www.perl.com/CPAN/authors/id/GAAS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/perl-digest-base
	dev-lang/perl"

SRC_TEST="do"
