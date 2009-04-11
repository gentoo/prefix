# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pod-Tests/Pod-Tests-1.19.ebuild,v 1.1 2008/08/01 10:07:57 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Extracts embedded tests and code examples from POD"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/perl-File-Spec
	dev-lang/perl"

SRC_TEST="do"
