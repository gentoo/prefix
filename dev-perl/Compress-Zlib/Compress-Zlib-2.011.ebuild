# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Compress-Zlib/Compress-Zlib-2.011.ebuild,v 1.1 2008/05/20 15:42:06 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS

inherit perl-module

DESCRIPTION="A Zlib perl module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-libs/zlib
	>=dev-perl/Compress-Raw-Zlib-${PV}
	>=dev-perl/IO-Compress-Base-${PV}
	>=dev-perl/IO-Compress-Zlib-${PV}
	virtual/perl-Scalar-List-Utils
	dev-lang/perl"

SRC_TEST="do"

mydoc="TODO"
