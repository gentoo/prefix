# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/IO-Compress-Bzip2/IO-Compress-Bzip2-2.015.ebuild,v 1.1 2009/04/18 10:43:46 tove Exp $

MODULE_AUTHOR=PMQS
inherit perl-module

DESCRIPTION="Read and write bzip2 files/buffers"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~virtual/perl-Compress-Raw-Bzip2-${PV}
	~virtual/perl-IO-Compress-Base-${PV}"
RDEPEND="${DEPEND}"

SRC_TEST=do
