# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Clone/Clone-0.23.ebuild,v 1.6 2007/08/09 14:26:49 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Recursively copy Perl datatypes"
SRC_URI="mirror://cpan/modules/by-authors/id/R/RD/RDF/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/R/RD/RDF/${P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
