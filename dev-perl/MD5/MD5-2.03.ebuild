# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MD5/MD5-2.03.ebuild,v 1.14 2007/01/19 14:07:18 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="The Perl MD5 Module"
SRC_URI="mirror://cpan/authors/id/G/GA/GAAS/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/~gaas/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="virtual/perl-Digest-MD5
	dev-lang/perl"
SRC_TEST="do"

export OPTIMIZE="${CFLAGS}"
