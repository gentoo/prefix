# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DBD-Pg/DBD-Pg-1.49.ebuild,v 1.12 2007/04/15 20:38:38 corsair Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="The Perl DBD::Pg Module"
HOMEPAGE="http://cpan.org/modules/by-module/DBD/${P}.readme"
SRC_URI="mirror://cpan/authors/id/D/DB/DBDPG/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/perl-Test-Simple
	>=virtual/perl-Test-Harness-2.03
	>=dev-perl/DBI-1.45
	>=dev-db/libpq-7.3.15
	dev-lang/perl"

# env variables for compilation:
export POSTGRES_INCLUDE=/usr/include/postgresql/pgsql
export POSTGRES_LIB=/usr/lib/postgresql/

mydoc="README"
