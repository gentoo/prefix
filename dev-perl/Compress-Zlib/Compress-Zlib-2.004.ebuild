# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Compress-Zlib/Compress-Zlib-2.004.ebuild,v 1.10 2007/07/05 15:25:38 tgall Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Zlib perl module"
HOMEPAGE="http://search.cpan.org/~pmqs/"
SRC_URI="mirror://cpan/modules/by-module/Compress/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="sys-libs/zlib
	>=dev-perl/Compress-Raw-Zlib-2.004
	>=dev-perl/IO-Compress-Base-2.004
	>=dev-perl/IO-Compress-Zlib-2.004
	virtual/perl-Scalar-List-Utils
	dev-lang/perl"

SRC_TEST="do"

mydoc="TODO"
