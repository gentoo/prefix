# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/lft/lft-3.0.ebuild,v 1.2 2008/01/18 18:49:37 armin76 Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Layer Four Traceroute: an advanced traceroute implementation"
HOMEPAGE="http://oppleman.com/lft/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="VOSTROM"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="net-libs/libpcap"

src_compile() {
	# avoid suid related security issues.
	append-ldflags $(bindnow-flags)

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"
	dodoc CHANGELOG README TODO
}
