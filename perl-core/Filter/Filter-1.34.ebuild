# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Filter/Filter-1.34.ebuild,v 1.1 2008/08/02 11:36:47 tove Exp $

MODULE_AUTHOR=PMQS
inherit perl-module

DESCRIPTION="Interface for creation of Perl Filters"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

mymake="/usr"
SRC_TEST=do
