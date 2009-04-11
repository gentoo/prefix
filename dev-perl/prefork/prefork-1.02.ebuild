# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/prefork/prefork-1.02.ebuild,v 1.1 2008/08/02 11:03:08 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Optimized module loading for forking or non-forking processes"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=virtual/perl-File-Spec-0.80
	>=virtual/perl-Scalar-List-Utils-1.10
	dev-lang/perl"
