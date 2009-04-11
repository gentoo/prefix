# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/lft/lft-3.0-r1.ebuild,v 1.1 2009/01/24 01:03:24 jer Exp $

DESCRIPTION="Layer Four Traceroute: an advanced traceroute implementation"
HOMEPAGE="http://oppleman.com/lft/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="VOSTROM"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="net-libs/libpcap"

src_install() {
	einstall || die "einstall failed"
	dodoc CHANGELOG README TODO
}
