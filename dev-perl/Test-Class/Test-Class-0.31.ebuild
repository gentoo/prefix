# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Class/Test-Class-0.31.ebuild,v 1.1 2008/09/15 08:32:59 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=ADIE
inherit perl-module

DESCRIPTION="Easily create test classes in an xUnit style."

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"
SRC_TEST="do"

RDEPEND=">=virtual/perl-Storable-2
	>=virtual/perl-Test-Simple-0.62
	>=dev-perl/Test-Exception-0.25
	>=dev-perl/Devel-Symdump-2.03
	dev-lang/perl"
DEPEND="${RDEPEND}
	dev-perl/module-build
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"
