# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Exception/Test-Exception-0.25.ebuild,v 1.10 2007/08/21 13:45:43 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="test functions for exception based code"
HOMEPAGE="http://search.cpan.org/~adie/"
SRC_URI="mirror://cpan/authors/id/A/AD/ADIE/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND="${RDEPEND}
	>=dev-perl/module-build-0.28"

RDEPEND=">=virtual/perl-Test-Simple-0.64
	>=dev-perl/Sub-Uplevel-0.13
	dev-lang/perl"
