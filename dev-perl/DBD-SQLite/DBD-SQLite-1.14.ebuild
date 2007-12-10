# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-SQLite/DBD-SQLite-1.14.ebuild,v 1.1 2007/12/09 18:09:58 yuval Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Self Contained RDBMS in a DBI Driver"
HOMEPAGE="http://search.cpan.org/~msergeant/${P}/"
SRC_URI="mirror://cpan/authors/id/M/MS/MSERGEANT/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/DBI-1.42
	!<dev-perl/DBD-SQLite-1
	dev-lang/perl"

myconf="USE_LOCAL_SQLITE=1"
