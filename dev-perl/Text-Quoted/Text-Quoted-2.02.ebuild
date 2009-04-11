# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Quoted/Text-Quoted-2.02.ebuild,v 1.5 2009/03/07 11:24:56 tove Exp $

# this is an RT dependency

inherit perl-module

DESCRIPTION="Extract the structure of a quoted mail message"
SRC_URI="mirror://cpan/authors/id/F/FA/FALCONE/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~falcone/"

IUSE=""
SRC_TEST="do"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

DEPEND="dev-perl/text-autoformat
	virtual/perl-Text-Tabs+Wrap
	dev-lang/perl"
