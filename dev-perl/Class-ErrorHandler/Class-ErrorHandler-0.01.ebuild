# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-ErrorHandler/Class-ErrorHandler-0.01.ebuild,v 1.20 2009/01/14 11:01:55 tove Exp $

MODULE_AUTHOR=BTROTT
inherit perl-module

DESCRIPTION="Automated accessor generation"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
PREFER_BUILDPL="no"
