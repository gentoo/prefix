# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Copy-Recursive/File-Copy-Recursive-0.36.ebuild,v 1.3 2008/09/30 12:50:42 tove Exp $

MODULE_AUTHOR=DMUEY
inherit perl-module

DESCRIPTION="uses File::Copy to recursively copy dirs"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
