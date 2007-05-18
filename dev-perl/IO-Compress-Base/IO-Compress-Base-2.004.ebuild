# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Base/IO-Compress-Base-2.004.ebuild,v 1.7 2007/05/16 18:10:35 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Base Class for IO::Compress modules"
HOMEPAGE="http://search.cpan.org/~pmqs"
SRC_URI="mirror://cpan/authors/id/P/PM/PMQS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="virtual/perl-Scalar-List-Utils
	dev-lang/perl"

SRC_TEST="do"
