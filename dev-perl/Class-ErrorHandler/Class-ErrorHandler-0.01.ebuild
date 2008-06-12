# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-ErrorHandler/Class-ErrorHandler-0.01.ebuild,v 1.18 2007/01/19 21:50:02 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Automated accessor generation"
HOMEPAGE="http://search.cpan.org/~btrott/"
SRC_URI="mirror://cpan/authors/id/B/BT/BTROTT/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	>=dev-perl/module-build-0.28"
