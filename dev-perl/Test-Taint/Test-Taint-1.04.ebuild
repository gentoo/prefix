# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Taint/Test-Taint-1.04.ebuild,v 1.12 2007/07/14 14:31:55 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Tools to test taintedness"
HOMEPAGE="http://search.cpan.org/~petdance/"
SRC_URI="mirror://cpan/authors/id/P/PE/PETDANCE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
