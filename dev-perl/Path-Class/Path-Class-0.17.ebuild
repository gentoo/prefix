# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Path-Class/Path-Class-0.17.ebuild,v 1.4 2009/08/26 16:11:57 armin76 Exp $

EAPI=2

MODULE_AUTHOR=KWILLIAMS
inherit perl-module

DESCRIPTION="Cross-platform path specification manipulation"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND="dev-lang/perl
	>=virtual/perl-File-Spec-0.87"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? ( virtual/perl-Test-Simple )"

SRC_TEST="do"
