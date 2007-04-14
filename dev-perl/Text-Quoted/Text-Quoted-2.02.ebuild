# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Quoted/Text-Quoted-2.02.ebuild,v 1.2 2007/04/09 16:45:10 mcummings Exp $

EAPI="prefix"

# this is an RT dependency

inherit perl-module

DESCRIPTION="Extract the structure of a quoted mail message"
SRC_URI="mirror://cpan/authors/id/F/FA/FALCONE/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~falcone/"

IUSE=""
SRC_TEST="do"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND="dev-perl/text-autoformat
	dev-perl/Text-Tabs+Wrap
	dev-lang/perl"
