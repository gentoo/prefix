# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/wtf/wtf-20080912.ebuild,v 1.7 2008/12/02 20:19:32 ranger Exp $

inherit eutils prefix

DESCRIPTION="translates acronyms for you"
HOMEPAGE="http://netbsd.org/"
SRC_URI="http://dev.gentooexperimental.org/~darkside/distfiles/${PN}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="!games-misc/bsd-games"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify wtf
}

src_compile() {
	:
}

src_install() {
	dobin wtf || die "dogamesbin failed"
	doman wtf.6
	insinto /usr/share/misc
	doins acronyms* || die "doins failed"
	dodoc README
}
