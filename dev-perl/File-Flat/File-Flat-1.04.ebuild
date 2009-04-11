# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Flat/File-Flat-1.04.ebuild,v 1.3 2008/09/30 12:53:06 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Implements a flat filesystem"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/Class-Autouse-1
	>=dev-perl/Test-ClassAPI-1.02
	>=dev-perl/File-Copy-Recursive-0.36
	>=dev-perl/File-Remove-0.38
	>=virtual/perl-File-Spec-0.85
	>=virtual/perl-File-Temp-0.17
	>=dev-perl/File-Remove-0.21
	>=dev-perl/File-Slurp-9999.04
	>=dev-perl/prefork-0.02
	dev-lang/perl"
