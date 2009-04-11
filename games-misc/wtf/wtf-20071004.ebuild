# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/wtf/wtf-20071004.ebuild,v 1.8 2007/12/11 16:52:21 nixnut Exp $

inherit eutils prefix

DESCRIPTION="translates acronyms for you"
HOMEPAGE="http://www.mu.org/~mux/wtf/"
SRC_URI="http://www.mu.org/~mux/wtf/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="!games-misc/bsd-games"
RDEPEND="${DEPEND}
	sys-apps/grep"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-20050505-updates.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify wtf
}

src_install() {
	dobin wtf || die "dogamesbin failed"
	doman wtf.6
	insinto /usr/share/misc
	doins acronyms* || die "doins failed"
}
