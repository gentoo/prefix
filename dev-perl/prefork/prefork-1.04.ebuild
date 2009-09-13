# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/prefork/prefork-1.04.ebuild,v 1.2 2009/09/10 07:48:49 fauli Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Optimized module loading for forking or non-forking processes"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=virtual/perl-File-Spec-0.80
	>=virtual/perl-Scalar-List-Utils-1.10"
RDEPEND="${DEPEND}"

SRC_TEST="do"
