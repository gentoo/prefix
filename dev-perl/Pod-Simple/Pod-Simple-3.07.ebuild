# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pod-Simple/Pod-Simple-3.07.ebuild,v 1.1 2008/08/01 09:40:45 tove Exp $

MODULE_AUTHOR=ARANDAL
inherit perl-module

DESCRIPTION="framework for parsing Pod"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/Pod-Escapes-1.04
	dev-lang/perl"

SRC_TEST="do"
