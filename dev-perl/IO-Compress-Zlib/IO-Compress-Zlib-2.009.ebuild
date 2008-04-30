# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Zlib/IO-Compress-Zlib-2.009.ebuild,v 1.1 2008/04/29 09:39:49 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS

inherit perl-module

DESCRIPTION="Read/Write compressed files"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/IO-Compress-Base-2.009
	>=dev-perl/Compress-Raw-Zlib-2.009
	dev-lang/perl"

SRC_TEST="do"
