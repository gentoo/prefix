# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/B-Keywords/B-Keywords-1.06.ebuild,v 1.5 2008/02/20 19:49:13 nixnut Exp $

inherit perl-module

DESCRIPTION="Lists of reserved barewords and symbol names"
HOMEPAGE="http://search.cpan.org/~jjore/"
SRC_URI="mirror://cpan/authors/id/J/JJ/JJORE/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
