# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Module-Pluggable/Module-Pluggable-3.8.ebuild,v 1.1 2008/09/20 11:31:55 tove Exp $

MODULE_AUTHOR=SIMONW
inherit perl-module

DESCRIPTION="automatically give your module the ability to have plugins"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="virtual/perl-File-Spec
	dev-lang/perl"
