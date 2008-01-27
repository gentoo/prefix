# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/par/par-1.1.ebuild,v 1.25 2008/01/26 18:54:58 grobian Exp $

EAPI="prefix"

DESCRIPTION="Parchive archive fixing tool"
HOMEPAGE="http://parchive.sourceforge.net/"
SRC_URI="mirror://sourceforge/parchive/par-v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="!app-text/par
	!dev-util/par"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/par-cmdline

src_compile() {
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	dobin par || die "dobin failed"
	dodoc AUTHORS NEWS README
}
