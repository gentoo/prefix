# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MD5/MD5-2.03.ebuild,v 1.13 2006/08/05 13:38:57 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="The Perl MD5 Module"
SRC_URI="mirror://cpan/authors/id/G/GA/GAAS/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/authors/is/G/GA/GAAS/${P}.readme"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="virtual/perl-Digest-MD5
	dev-lang/perl"
RDEPEND="${DEPEND}"
SRC_TEST="do"

export OPTIMIZE="${CFLAGS}"

