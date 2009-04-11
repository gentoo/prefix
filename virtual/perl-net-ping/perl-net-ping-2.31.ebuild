# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-net-ping/perl-net-ping-2.31.ebuild,v 1.4 2007/07/11 05:04:22 mr_bones_ Exp $

DESCRIPTION="Virtual for net-ping"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE=""
DEPEND=""
RDEPEND="|| ( >=dev-lang/perl-5.8.7 ~perl-core/net-ping-${PV} )"
