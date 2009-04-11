# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Copy-Recursive/File-Copy-Recursive-0.37.ebuild,v 1.1 2008/10/20 20:07:24 tove Exp $

MODULE_AUTHOR=DMUEY
inherit perl-module

DESCRIPTION="uses File::Copy to recursively copy dirs"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
