# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PadWalker/PadWalker-1.7.ebuild,v 1.2 2009/01/09 21:31:19 josejx Exp $

MODULE_AUTHOR=ROBIN
inherit perl-module

DESCRIPTION="play with other peoples' lexical variables"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
