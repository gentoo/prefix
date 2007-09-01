# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Inspector/Class-Inspector-1.17.ebuild,v 1.1 2007/08/20 09:06:45 yuval Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Provides information about Classes"
HOMEPAGE="http://search.cpan.org/~adamk"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-macos"
IUSE=""

DEPEND="virtual/perl-Test-Simple
	dev-lang/perl"

SRC_TEST="do"
