# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-CSV_XS/Text-CSV_XS-0.23-r1.ebuild,v 1.4 2006/08/06 00:19:55 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="comma-separated values manipulation routines"
SRC_URI="mirror://cpan/authors/id/J/JW/JWIED/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~jwied/${P}"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"


DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"
