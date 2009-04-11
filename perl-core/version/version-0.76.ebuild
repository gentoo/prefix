# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/version/version-0.76.ebuild,v 1.2 2008/11/04 09:41:07 vapier Exp $

MODULE_AUTHOR=JPEACOCK
inherit perl-module

DESCRIPTION="Perl extension for Version Objects"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	>=virtual/perl-Module-Build-0.28"

SRC_TEST="do"
