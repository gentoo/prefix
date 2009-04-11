# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Warn/Test-Warn-0.10.ebuild,v 1.5 2007/11/10 14:51:23 drac Exp $

inherit perl-module

DESCRIPTION="Perl extension to test methods for warnings"
HOMEPAGE="http://search.cpan.org/~chorny/"
SRC_URI="mirror://cpan/authors/id/C/CH/CHORNY/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/Test-Exception
	>=dev-perl/Sub-Uplevel-0.09-r1
	dev-perl/Array-Compare
	dev-perl/Tree-DAG_Node
	dev-lang/perl"
