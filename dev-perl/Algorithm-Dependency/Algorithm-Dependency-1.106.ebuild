# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Algorithm-Dependency/Algorithm-Dependency-1.106.ebuild,v 1.1 2008/09/06 07:45:02 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Toolkit for implementing dependency systems"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

SRC_TEST="do"

RDEPEND="dev-perl/Params-Util
	>=virtual/perl-File-Spec-0.82
	dev-lang/perl"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-ClassAPI )"
