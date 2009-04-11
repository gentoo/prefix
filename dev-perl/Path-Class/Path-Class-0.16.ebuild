# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Path-Class/Path-Class-0.16.ebuild,v 1.9 2008/11/22 11:47:45 tove Exp $

MODULE_AUTHOR=KWILLIAMS
inherit perl-module

DESCRIPTION="Cross-platform path specification manipulation"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"
SRC_TEST="do"

RDEPEND="dev-lang/perl
	>=virtual/perl-File-Spec-0.87"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? ( virtual/perl-Test-Simple )"
