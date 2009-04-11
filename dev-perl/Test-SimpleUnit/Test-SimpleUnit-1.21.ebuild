# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-SimpleUnit/Test-SimpleUnit-1.21.ebuild,v 1.13 2007/01/19 16:51:26 mcummings Exp $

inherit perl-module

DESCRIPTION="Simplified Perl unit-testing framework"
HOMEPAGE="http://search.cpan.org/~ged/"
SRC_URI="mirror://cpan/authors/id/G/GE/GED/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-perl/ExtUtils-AutoInstall
	dev-perl/Data-Compare
	dev-lang/perl"
