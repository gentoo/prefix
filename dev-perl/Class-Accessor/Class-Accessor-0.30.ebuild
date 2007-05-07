# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Accessor/Class-Accessor-0.30.ebuild,v 1.7 2007/05/05 17:35:04 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Automated accessor generation"
HOMEPAGE="http://search.cpan.org/~kasei/${P}/"
SRC_URI="mirror://cpan/authors/id/K/KA/KASEI/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""
SRC_TEST="do"
DEPEND="dev-lang/perl"
