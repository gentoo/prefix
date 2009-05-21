# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Readonly/Readonly-1.03.ebuild,v 1.7 2009/03/01 19:26:01 tcunha Exp $

inherit perl-module

DESCRIPTION="Facility for creating read-only scalars, arrays, hashes"
SRC_URI="mirror://cpan/authors/id/R/RO/ROODE/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/dist/Readonly/Readonly.pm"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
