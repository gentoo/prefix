# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Bzip2/IO-Compress-Bzip2-2.015.ebuild,v 1.8 2008/10/27 16:30:24 aballier Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS
inherit perl-module

DESCRIPTION="Read and write bzip2 files/buffers"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="~dev-perl/Compress-Raw-Bzip2-${PV}
	~dev-perl/IO-Compress-Base-${PV}"

SRC_TEST=do
