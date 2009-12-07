# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Pod-Simple/Pod-Simple-3.07.ebuild,v 1.3 2009/12/04 13:29:03 tove Exp $

MODULE_AUTHOR=ARANDAL
inherit perl-module

DESCRIPTION="framework for parsing Pod"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=virtual/perl-Pod-Escapes-1.04
	dev-lang/perl"

SRC_TEST="do"
