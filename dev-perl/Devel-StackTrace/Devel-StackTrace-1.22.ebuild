# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Devel-StackTrace/Devel-StackTrace-1.22.ebuild,v 1.5 2009/09/19 16:44:07 nixnut Exp $

EAPI=2

MODULE_AUTHOR=DROLSKY
inherit perl-module

DESCRIPTION="Devel-StackTrace module for perl"

SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="virtual/perl-File-Spec"
DEPEND=">=virtual/perl-Module-Build-0.28
	${RDEPEND}"

SRC_TEST="do"
