# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Path-Class/Path-Class-0.16.ebuild,v 1.5 2007/11/19 20:49:05 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Cross-platform path specification manipulation"
SRC_URI="mirror://cpan/authors/id/K/KW/KWILLIAMS/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~kwilliams/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl
	>=virtual/perl-File-Spec-0.87
	virtual/perl-Test-Simple
	>=dev-perl/module-build-0.28"
