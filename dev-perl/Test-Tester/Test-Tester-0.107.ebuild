# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Tester/Test-Tester-0.107.ebuild,v 1.7 2009/03/15 13:22:31 ranger Exp $

EAPI="prefix"

MODULE_AUTHOR=FDALY
inherit perl-module

DESCRIPTION="Ease testing test modules built with Test::Builder"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
