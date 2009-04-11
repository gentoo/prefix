# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Tabs+Wrap/Text-Tabs+Wrap-2006.1117.ebuild,v 1.8 2008/09/30 15:19:36 tove Exp $

MODULE_AUTHOR=MUIR
MODULE_SECTION=modules
inherit perl-module

DESCRIPTION="Expand/unexpand tabs per unix expand and line wrapping"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
