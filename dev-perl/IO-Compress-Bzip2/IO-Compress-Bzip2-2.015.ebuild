# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Bzip2/IO-Compress-Bzip2-2.015.ebuild,v 1.11 2008/12/10 17:14:16 aballier Exp $

MODULE_AUTHOR=PMQS
inherit perl-module

DESCRIPTION="Read and write bzip2 files/buffers"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND="~dev-perl/Compress-Raw-Bzip2-${PV}
	~virtual/perl-IO-Compress-Base-${PV}"

SRC_TEST=do
