# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Deep/Test-Deep-0.098.ebuild,v 1.3 2007/12/17 19:12:12 drac Exp $

EAPI="prefix"

inherit perl-module
IUSE=""

DESCRIPTION="Test::Deep - Extremely flexible deep comparison"
SRC_URI="mirror://cpan/authors/id/F/FD/FDALY/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~fdaly/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

SRC_TEST="do"
DEPEND="dev-perl/Test-NoWarnings
	dev-perl/Test-Tester
	dev-lang/perl"
