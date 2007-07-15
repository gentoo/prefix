# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unarj/unarj-2.65.ebuild,v 1.1 2007/07/14 14:51:34 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Utility for opening arj archives"
HOMEPAGE="http://www.arjsoftware.com/"
SRC_URI="mirror://freebsd/ports/local-distfiles/ache/${P}.tgz"

LICENSE="arj"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-CAN-2004-0947.patch
	epatch "${FILESDIR}"/${P}-sanitation.patch
	epatch "${FILESDIR}"/${P}-gentoo-fbsd.patch
}

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	dobin unarj || die 'dobin failed'
	dodoc unarj.txt technote.txt || die 'dodoc failed'
}
