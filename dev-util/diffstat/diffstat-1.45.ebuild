# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/diffstat/diffstat-1.45.ebuild,v 1.1 2007/09/25 23:33:55 swegener Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="creates a histogram from a diff of the insertions, deletions, and modifications per-file"
HOMEPAGE="http://invisible-island.net/diffstat/diffstat.html"
SRC_URI="ftp://invisible-island.net/${PN}/${P}.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86"
IUSE=""

DEPEND="sys-apps/diffutils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.37-hard-locale.patch
}

src_install() {
	dobin diffstat || die "dobin failed"
	doman diffstat.1 || die "doman failed"
	dodoc README CHANGES
}
