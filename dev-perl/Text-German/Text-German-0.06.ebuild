# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-German/Text-German-0.06.ebuild,v 1.9 2007/03/05 12:33:28 ticho Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="German grundform reduction"
HOMEPAGE="http://search.cpan.org/~ulpfr/"
SRC_URI="mirror://cpan/authors/id/U/UL/ULPFR/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"


DEPEND="dev-lang/perl"
