# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Base/Test-Base-0.59.ebuild,v 1.1 2009/08/25 17:53:42 robbat2 Exp $

EAPI=2

MODULE_AUTHOR=INGY
inherit perl-module

DESCRIPTION="A Data Driven Testing Framework"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=virtual/perl-Test-Simple-0.62
	>=dev-perl/Spiffy-0.30
	dev-perl/Test-Deep"
RDEPEND="${DEPEND}"

SRC_TEST="do"
